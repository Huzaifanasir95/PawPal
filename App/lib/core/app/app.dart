import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../core/theme/app_theme_controller.dart';

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

  const AuthFlow({super.key, required this.authRepository});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool _showOnboarding = true;
  bool _isLoading = true;
  String? _lastThemeSyncKey;

  bool _shouldListen(AuthState current) {
    return current.maybeWhen(
      accountTypeRequired: (_, __, ___) => true,
      orElse: () => false,
    );
  }

  bool _shouldBuild(AuthState previous, AuthState current) {
    if (identical(previous, current)) {
      return false;
    }

    if (previous.runtimeType != current.runtimeType) {
      return true;
    }

    return current.maybeWhen(
      authenticated: (user) {
        final previousUser = previous.maybeWhen(
          authenticated: (value) => value,
          orElse: () => null,
        );

        return previousUser?.id != user.id ||
            previousUser?.accountType != user.accountType;
      },
      error: (message) {
        final previousMessage = previous.maybeWhen(
          error: (value) => value,
          orElse: () => null,
        );
        return previousMessage != message;
      },
      orElse: () => false,
    );
  }

  String _themeSyncKeyFor(AuthState state) {
    return state.when(
      initial: () => 'guest:initial',
      loading: () => 'guest:loading',
      authenticated: (user) => 'auth:${user.uid}:${user.accountType ?? 'pet_owner'}',
      unauthenticated: () => 'guest:unauthenticated',
      error: (message) => 'guest:error:${message.hashCode}',
      passwordResetSent: () => 'guest:password_reset_sent',
      accountTypeRequired: (idToken, displayName, photoUrl) => 'guest:account_type_required:${idToken.hashCode}',
    );
  }

  void _scheduleThemeSync(AuthState state) {
    final nextKey = _themeSyncKeyFor(state);
    if (_lastThemeSyncKey == nextKey) {
      return;
    }

    _lastThemeSyncKey = nextKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      state.when(
        initial: () {
          context.read<AppThemeController>().resetToGuest();
        },
        loading: () {},
        authenticated: (user) {
          context.read<AppThemeController>().syncUserContext(
            userId: user.uid,
            activeRole: user.accountType ?? 'pet_owner',
          );
        },
        unauthenticated: () {
          context.read<AppThemeController>().resetToGuest();
        },
        error: (_) {
          context.read<AppThemeController>().resetToGuest();
        },
        passwordResetSent: () {},
        accountTypeRequired: (_, __, ___) {
          context.read<AppThemeController>().resetToGuest();
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('hasCompletedOnboarding') ?? false;

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_showOnboarding) {
      return OnboardingScreenWrapper(onComplete: _onOnboardingComplete);
    }

    // After onboarding, listen to auth state changes
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) => _shouldListen(current),
      buildWhen: (previous, current) => _shouldBuild(previous, current),
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          authenticated: (_) {},
          unauthenticated: () {},
          error: (_) {},
          passwordResetSent: () {},
          accountTypeRequired: (idToken, displayName, photoUrl) {
            if (!mounted) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (_) => BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: AccountTypeSelectionScreen(
                          idToken: idToken,
                          displayName: displayName,
                          photoUrl: photoUrl,
                        ),
                      ),
                ),
              );
            });
          },
        );
      },
      builder: (context, state) {
        _scheduleThemeSync(state);

        return state.when(
          initial: () {
            return const AuthNavigator();
          },
          loading:
              () => const AuthNavigator(), // Don't show full-screen loading
          authenticated: (user) {
            // Use role from auth payload immediately, avoiding an extra profile fetch.
            return RoleBasedHome(
              key: ValueKey('home_${user.uid}_${user.accountType}'),
              initialAccountType: user.accountType,
            );
          },
          unauthenticated: () {
            return const AuthNavigator();
          },
          error: (message) {
            return const AuthNavigator(); // Show auth with error
          },
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

  const OnboardingScreenWrapper({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(onComplete: onComplete);
  }
}

class PawPawlApp extends StatefulWidget {
  const PawPawlApp({super.key});

  @override
  State<PawPawlApp> createState() => _PawPawlAppState();
}

class _PawPawlAppState extends State<PawPawlApp> {
  final AuthRepository _authRepository = getIt<AuthRepository>();
  late AuthBloc _authBloc;
  late AppThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: _authRepository);
    _themeController = AppThemeController();
    // Initialize auth check
    _authBloc.add(const AuthEvent.checkAuth());
  }

  @override
  void dispose() {
    _authBloc.close();
    _authRepository.dispose();
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (context) => getIt<CommunityBloc>()),
        BlocProvider(create: (context) => getIt<VetBloc>()),
        BlocProvider(create: (context) => getIt<ChatBloc>()),
        Provider<AuthRepository>.value(value: _authRepository),
        Provider<ImageService>(create: (context) => getIt<ImageService>()),
        ChangeNotifierProvider<AppThemeController>.value(value: _themeController),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<AppThemeController>(
            builder: (context, themeController, _) {
              return MaterialApp(
                title: 'PawPawl',
                debugShowCheckedModeBanner: false,
                theme: themeController.lightTheme,
                darkTheme: themeController.darkTheme,
                themeMode: themeController.themeMode,
                home: AuthFlow(authRepository: _authRepository),
              );
            },
          );
        },
      ),
    );
  }
}
