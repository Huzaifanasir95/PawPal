import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../pages/sign_in_screen.dart';
import '../pages/sign_up_screen.dart';

class AuthNavigator extends StatefulWidget {
  const AuthNavigator({super.key});

  @override
  State<AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<AuthNavigator> {
  bool _isSignUp = false;

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          authenticated: (user) {
            // Navigation will be handled by AuthFlow
          },
          unauthenticated: () {},
          error: (message) {
            // Error handling is done in individual screens
          },
          passwordResetSent: () {},
          accountTypeRequired: (idToken, displayName, photoUrl) {
            // Navigation handled by AuthFlow
          },
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: _isSignUp ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: _isSignUp 
          ? SignUpScreen(
              key: const ValueKey('signup'),
              onNavigateToSignIn: _toggleAuthMode,
            )
          : SignInScreen(
              key: const ValueKey('signin'),
              onNavigateToSignUp: _toggleAuthMode,
            ),
      ),
    );
  }
}