import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

@freezed
class AuthUser with _$AuthUser {
  const AuthUser._(); // Private constructor for custom getters
  
  const factory AuthUser({
    required String id,
    required String email,
    String? displayName,
    String? accountType,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AuthUser;

  // Alias getters for backward compatibility
  String get uid => id;
  String? get photoURL => photoUrl;

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}

@freezed
class SignUpRequest with _$SignUpRequest {
  const factory SignUpRequest({
    required String email,
    required String password,
    String? displayName,
  }) = _SignUpRequest;

  factory SignUpRequest.fromJson(Map<String, dynamic> json) => _$SignUpRequestFromJson(json);
}

@freezed
class SignInRequest with _$SignInRequest {
  const factory SignInRequest({
    required String email,
    required String password,
  }) = _SignInRequest;

  factory SignInRequest.fromJson(Map<String, dynamic> json) => _$SignInRequestFromJson(json);
}

@freezed
class GoogleSignInRequest with _$GoogleSignInRequest {
  const factory GoogleSignInRequest({
    required String idToken,
    String? displayName,
    String? photoUrl,
  }) = _GoogleSignInRequest;

  factory GoogleSignInRequest.fromJson(Map<String, dynamic> json) => _$GoogleSignInRequestFromJson(json);
}

@freezed
class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? displayName,
    String? accountType,
    String? photoUrl,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);
}
