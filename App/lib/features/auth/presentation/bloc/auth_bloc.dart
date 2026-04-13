import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<AuthUser?> _authStateSubscription;
  String? _lastAuthSnapshot;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.initial()) {
    
    // Listen to auth state changes with debouncing
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (isClosed) return;

      final snapshot =
          user == null
              ? 'signed_out'
              : '${user.id}:${user.accountType ?? ''}:${user.updatedAt?.millisecondsSinceEpoch ?? 0}';

      if (snapshot == _lastAuthSnapshot) {
        return;
      }
      _lastAuthSnapshot = snapshot;

      if (user != null) {
        add(AuthEvent.userChanged(user));
      } else {
        add(const AuthEvent.signedOut());
      }
    });

    on<_SignInWithEmail>((event, emit) async {
      if (!isClosed) {
        await _onSignInWithEmail(event.email, event.password, emit);
      }
    });

    on<_SignUpWithEmail>((event, emit) async {
      if (!isClosed) {
        await _onSignUpWithEmail(
          event.email,
          event.password,
          event.name,
          event.accountType,
          emit,
        );
      }
    });

    on<_SignInWithGoogle>((event, emit) async {
      if (!isClosed) {
        await _onSignInWithGoogle(emit);
      }
    });

    on<_CompleteGoogleSignIn>((event, emit) async {
      if (!isClosed) {
        await _onCompleteGoogleSignIn(event.idToken, event.accountType, event.displayName, event.photoUrl, emit);
      }
    });

    on<_SignOut>((event, emit) async {
      if (!isClosed) {
        await _onSignOut(emit);
      }
    });

    on<_ResetPassword>((event, emit) async {
      if (!isClosed) {
        await _onResetPassword(event.email, emit);
      }
    });

    on<_UserChanged>((event, emit) {
      if (!isClosed) {
        _onUserChanged(event.user, emit);
      }
    });

    on<_SignedOut>((event, emit) {
      if (!isClosed) {
        _onSignedOut(emit);
      }
    });

    on<_UpdateAccountType>((event, emit) async {
      if (!isClosed) {
        await _onUpdateAccountType(event.accountType, emit);
      }
    });

    on<_CheckAuth>((event, emit) async {
      if (!isClosed) {
        await _onCheckAuth(emit);
      }
    });
  }

  // Getter for auth repository
  AuthRepository get authRepository => _authRepository;

  Future<void> _onCheckAuth(Emitter<AuthState> emit) async {
    if (isClosed) return;
    emit(const AuthState.loading());
    try {
      await _authRepository.initialize();
      
      // Check if user is authenticated after initialization
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        if (!isClosed) {
          emit(AuthState.authenticated(currentUser));
        }
      } else {
        if (!isClosed) {
          emit(const AuthState.unauthenticated());
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(const AuthState.unauthenticated());
      }
    }
  }

  Future<void> _onSignInWithEmail(
    String email,
    String password,
    Emitter<AuthState> emit,
  ) async {
    if (isClosed) return;
    emit(const AuthState.loading());
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // The stream will handle emitting the authenticated state
    } catch (e) {
      if (!isClosed) {
        emit(AuthState.error(e.toString()));
      }
    }
  }

  Future<void> _onSignUpWithEmail(
    String email,
    String password,
    String? name,
    String? accountType,
    Emitter<AuthState> emit,
  ) async {
    if (isClosed) return;
    emit(const AuthState.loading());
    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
        accountType: accountType,
      );
      // The stream will handle emitting the authenticated state
    } catch (e) {
      if (!isClosed) {
        emit(AuthState.error(e.toString()));
      }
    }
  }

  Future<void> _onSignInWithGoogle(Emitter<AuthState> emit) async {
    if (isClosed) return;
    emit(const AuthState.loading());

    if (kIsWeb) {
      if (!isClosed) {
        emit(
          const AuthState.error(
            'Google Sign-In is not configured for web. Use email/password or configure web client ID.',
          ),
        );
      }
      return;
    }
    
    // Keep reference to Google Sign In instance
    final googleSignIn = GoogleSignIn();
    
    try {
      // Sign out first to ensure fresh login
      try {
        await googleSignIn.signOut();
      } catch (_) {}
      
      // Get the Google user
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        if (!isClosed) {
          emit(const AuthState.error('Google sign in was cancelled'));
        }
        return;
      }
      
      // Get the authentication details
      final googleAuth = await googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        if (!isClosed) {
          emit(const AuthState.error('Failed to obtain Google ID token'));
        }
        return;
      }
      
      // Now try to sign in with our backend
      final authResponse = await _authRepository.signInWithGoogle(
        idToken: googleAuth.idToken!,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
      
      // Check if this is a new user who needs to select account type
      if (authResponse.isNewUser) {
        if (!isClosed) {
          _debugLog('🆕 New user detected, showing account type selection');
          emit(AuthState.accountTypeRequired(
            googleAuth.idToken!,
            googleUser.displayName,
            googleUser.photoUrl,
          ));
        }
      } else {
        _debugLog('✅ Existing user, authentication complete');
        // For existing users, the stream will handle emitting the authenticated state
      }
    } catch (e) {
      _debugLog('❌ Google Sign-In error: $e');
      if (!isClosed) {
        emit(AuthState.error(e.toString()));
      }
    }
  }

  Future<void> _onCompleteGoogleSignIn(
    String idToken,
    String accountType,
    String? displayName,
    String? photoUrl,
    Emitter<AuthState> emit,
  ) async {
    if (isClosed) return;
    emit(const AuthState.loading());
    try {
      _debugLog('📝 Completing Google Sign-In with account type: $accountType');
      await _authRepository.signInWithGoogle(
        idToken: idToken,
        displayName: displayName,
        photoUrl: photoUrl,
        accountType: accountType,
      );
      _debugLog('✅ Account creation complete');
      // The stream will handle emitting the authenticated state
    } catch (e) {
      _debugLog('❌ Complete Google Sign-In error: $e');
      if (!isClosed) {
        emit(AuthState.error(e.toString()));
      }
    }
  }

  Future<void> _onSignOut(Emitter<AuthState> emit) async {
    if (isClosed) return;
    _debugLog('AuthBloc: Starting sign out');
    emit(const AuthState.loading());
    try {
      await _authRepository.signOut();
      _debugLog('AuthBloc: Sign out completed');
      // The stream will handle emitting the unauthenticated state
    } catch (e) {
      _debugLog('AuthBloc: Sign out error: $e');
      if (!isClosed) {
        emit(AuthState.error(e.toString()));
      }
    }
  }

  Future<void> _onResetPassword(String email, Emitter<AuthState> emit) async {
    if (isClosed) return;
    emit(const AuthState.loading());
    try {
      await _authRepository.resetPassword(email);
      if (!isClosed) {
        emit(const AuthState.passwordResetSent());
      }
    } catch (e) {
      if (!isClosed) {
        emit(AuthState.error(e.toString()));
      }
    }
  }

  void _onUserChanged(AuthUser user, Emitter<AuthState> emit) {
    final shouldSkip = state.maybeWhen(
      authenticated: (currentUser) =>
          currentUser.id == user.id &&
          (currentUser.accountType ?? '') == (user.accountType ?? ''),
      orElse: () => false,
    );

    if (shouldSkip) {
      return;
    }

    if (!isClosed) {
      emit(AuthState.authenticated(user));
    }
  }

  void _onSignedOut(Emitter<AuthState> emit) {
    if (!isClosed && state is! _Unauthenticated) {
      emit(const AuthState.unauthenticated());
    }
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  Future<void> _onUpdateAccountType(String accountType, Emitter<AuthState> emit) async {
    if (isClosed) return;
    try {
      await _authRepository.updateAccountType(accountType);
      // The stream will handle emitting the updated state
    } catch (e) {
      if (!isClosed) {
        emit(AuthState.error(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}