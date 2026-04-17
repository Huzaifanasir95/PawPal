part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkAuth() = _CheckAuth;
  const factory AuthEvent.signInWithEmail(String email, String password) = _SignInWithEmail;
  const factory AuthEvent.signUpWithEmail(
    String email,
    String password,
    String? name,
    String? accountType,
  ) = _SignUpWithEmail;
  const factory AuthEvent.signInWithGoogle() = _SignInWithGoogle;
  const factory AuthEvent.completeGoogleSignIn(String idToken, String accountType, String? displayName, String? photoUrl) = _CompleteGoogleSignIn;
  const factory AuthEvent.signOut() = _SignOut;
  const factory AuthEvent.resetPassword(String email) = _ResetPassword;
  const factory AuthEvent.updateAccountType(String accountType) = _UpdateAccountType;
  const factory AuthEvent.userChanged(AuthUser user) = _UserChanged;
  const factory AuthEvent.signedOut() = _SignedOut;
}