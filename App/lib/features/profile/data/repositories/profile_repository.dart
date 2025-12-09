import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/data/models/auth_user.dart';

class ProfileRepository {
  final AuthRepository _authRepository;

  ProfileRepository(this._authRepository);

  // Get current user profile
  Future<AuthUser?> getCurrentUserProfile() async {
    return await _authRepository.getUserProfile();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? accountType,
  }) async {
    return await _authRepository.updateUserProfile(
      displayName: displayName,
      accountType: accountType,
    );
  }

  // Get account type
  Future<String?> getAccountType() async {
    return await _authRepository.getAccountType();
  }

  // Update account type
  Future<void> updateAccountType(String accountType) async {
    return await _authRepository.updateAccountType(accountType);
  }
}