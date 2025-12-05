import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<AuthUser?> _authStateSubscription;
  bool _isProcessingAuthChange = false;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.initial()) {
    
    // Listen to auth state changes with debouncing
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (!isClosed && !_isProcessingAuthChange) {
        _isProcessingAuthChange = true;
        if (user != null) {
          add(AuthEvent.userChanged(user));
        } else {
          add(const AuthEvent.signedOut());
        }
        // Reset flag after a short delay to prevent rapid state changes
        Future.delayed(const Duration(milliseconds: 300), () {
          _isProcessingAuthChange = false;
        });
      }
    });

    on<_SignInWithEmail>((event, emit) async {
      if (!isClosed) {
        await _onSignInWithEmail(event.email, event.password, emit);
      }
    });

    on<_SignUpWithEmail>((event, emit) async {
      if (!isClosed) {
        await _onSignUpWithEmail(event.email, event.password, event.name, emit);
      }
    });

    on<_SignInWithGoogle>((event, emit) async {
      if (!isClosed) {
        await _onSignInWithGoogle(emit);
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
    Emitter<AuthState> emit,
  ) async {
    if (isClosed) return;
    emit(const AuthState.loading());
    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
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
    try {
      await _authRepository.signInWithGoogle();
      // The stream will handle emitting the authenticated state
    } catch (e) {
      if (!isClosed) {
        emit(AuthState.error(e.toString()));
      }
    }
  }

  Future<void> _onSignOut(Emitter<AuthState> emit) async {
    if (isClosed) return;
    print('AuthBloc: Starting sign out');
    emit(const AuthState.loading());
    try {
      await _authRepository.signOut();
      print('AuthBloc: Sign out completed');
      // The stream will handle emitting the unauthenticated state
    } catch (e) {
      print('AuthBloc: Sign out error: $e');
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
    if (!isClosed) {
      emit(AuthState.authenticated(user));
    }
  }

  void _onSignedOut(Emitter<AuthState> emit) {
    if (!isClosed) {
      emit(const AuthState.unauthenticated());
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