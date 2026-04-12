import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/community/presentation/bloc/community_bloc.dart';
import '../../features/vet/presentation/bloc/vet_bloc.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/widgets/auth_navigator.dart';
import '../../features/auth/presentation/pages/account_type_selection_screen.dart';
import '../../features/home/presentation/pages/role_based_home.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/image_service.dart';

class AuthFlow extends StatefulWidget {
  final AuthRepository authRepository;
  
  const AuthFlow({
    super.key,
    required this.authRepository,
  });

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool _showOnboarding = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    
    if (mounted) {
      setState(() {
        _showOnboarding = !hasCompletedOnboarding;
        _isLoading = false;
      });
    }
  }

  void _onOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    
    if (mounted) {
      setState(() {
        _showOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreenWrapper(
        onComplete: _onOnboardingComplete,
      );
    }
    
    // After onboarding, listen to auth state changes
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        debugPrint('🎯 AuthFlow listenWhen: previous=${previous.toString()}, current=${current.toString()}');
        return true; // Always listen
      },
      buildWhen: (previous, current) {
        debugPrint('🎯 AuthFlow buildWhen: previous=${previous.toString()}, current=${current.toString()}');
        return true; // Always rebuild
      },
      listener: (context, state) {
        debugPrint('🎭 AuthFlow listener called: ${state.toString()}');
        state.when(
          initial: () {},
          loading: () {},
          authenticated: (user) {
            debugPrint('🎭 AuthFlow listener: authenticated ${user.email}');
            // Navigation is handled in the builder
          },
          unauthenticated: () {},
          error: (message) {},
          passwordResetSent: () {},
          accountTypeRequired: (idToken, displayName, photoUrl) {
            // Navigate to account type selection
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: AccountTypeSelectionScreen(
                    idToken: idToken,
                    displayName: displayName,
                    photoUrl: photoUrl,
                  ),
                ),
              ),
            );
          },
        );
      },
      builder: (context, state) {
        debugPrint('🏗️ AuthFlow builder called: ${state.toString()}');
        return state.when(
          initial: () => const AuthNavigator(),
          loading: () => const AuthNavigator(), // Don't show full-screen loading
          authenticated: (user) {
            // Use role from auth payload immediately, avoiding an extra profile fetch.
            return RoleBasedHome(
              key: ValueKey('home_${user.uid}_${user.accountType}'),
              initialAccountType: user.accountType,
            );
          },
          unauthenticated: () => const AuthNavigator(),
          error: (message) => const AuthNavigator(), // Show auth with error
          passwordResetSent: () => const AuthNavigator(),
          accountTypeRequired: (idToken, displayName, photoUrl) {
            // Show auth navigator while navigation happens in listener
            return const AuthNavigator();
          },
        );
      },
    );
  }
}

class OnboardingScreenWrapper extends StatelessWidget {
  final VoidCallback onComplete;
  
  const OnboardingScreenWrapper({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      onComplete: onComplete,
    );
  }
}

class PawPawlApp extends StatefulWidget {
  const PawPawlApp({super.key});

  @override
  State<PawPawlApp> createState() => _PawPawlAppState();
}

class _PawPawlAppState extends State<PawPawlApp> {
  final AuthRepository _authRepository = AuthRepository();
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: _authRepository);
    // Initialize auth check
    _authBloc.add(const AuthEvent.checkAuth());
  }

  @override
  void dispose() {
    _authBloc.close();
    _authRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _authBloc,
        ),
        BlocProvider(
          create: (context) => getIt<CommunityBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<VetBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ChatBloc>(),
        ),
        Provider<AuthRepository>.value(
          value: _authRepository,
        ),
        Provider<ImageService>(
          create: (context) => getIt<ImageService>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'PawPawl',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: AuthFlow(authRepository: _authRepository),
          );
        },
      ),
    );
  }
}