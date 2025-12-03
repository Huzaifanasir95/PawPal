import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/data/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isUpdating = false;

  // Form controllers
  final _displayNameController = TextEditingController();
  String? _selectedAccountType;

  final List<String> _accountTypes = [
    'Pet Owner',
    'Breeder',
    'Veterinarian',
    'Pet Sitter',
    'Pet Trainer',
    'Shelter/Rescue',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      // For now, we'll create a mock profile since we need to integrate with auth properly
      // In a real implementation, this would come from the auth repository
      final currentUser = context.read<AuthBloc>().state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

      if (currentUser != null) {
        // Create a basic profile from Firebase user
        _userProfile = UserProfile(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          displayName: currentUser.displayName,
          accountType: null, // We'll load this separately
          createdAt: null,
          updatedAt: null,
        );

        _displayNameController.text = _userProfile?.displayName ?? '';

        // Try to load additional profile data
        try {
          final profileRepo = ProfileRepository(context.read<AuthBloc>().authRepository);
          final fullProfile = await profileRepo.getCurrentUserProfile();
          if (fullProfile != null) {
            _userProfile = fullProfile;
            _displayNameController.text = _userProfile?.displayName ?? '';
            _selectedAccountType = _userProfile?.accountType;
          }
        } catch (e) {
          // Profile data might not exist yet, use basic info
          print('Could not load full profile: $e');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name cannot be empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final profileRepo = ProfileRepository(context.read<AuthBloc>().authRepository);

      await profileRepo.updateUserProfile(
        displayName: _displayNameController.text.trim(),
        accountType: _selectedAccountType,
      );

      // Reload profile
      await _loadUserProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Logout',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      context.read<AuthBloc>().add(const AuthEvent.signOut());
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: Icon(
              Icons.logout,
              color: AppColors.accent,
              size: 24.sp,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3.w,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _userProfile?.displayName ?? 'User',
                          style: AppTextStyles.onboardingTitle.copyWith(
                            fontSize: 24.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _userProfile?.email ?? '',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_userProfile?.accountType != null) ...[
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              _userProfile!.accountType!,
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Profile Form
                  Text(
                    'Edit Profile',
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 20.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Display Name
                  _buildTextField(
                    label: 'Display Name',
                    controller: _displayNameController,
                    hint: 'Enter your display name',
                    icon: Icons.person_outline,
                  ),

                  SizedBox(height: 20.h),

                  // Account Type
                  Text(
                    'Account Type',
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedAccountType,
                        hint: Text(
                          'Select account type',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        isExpanded: true,
                        items: _accountTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 16.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountType = value;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Email (Read-only)
                  _buildTextField(
                    label: 'Email',
                    initialValue: _userProfile?.email ?? '',
                    hint: 'Your email address',
                    icon: Icons.email_outlined,
                    readOnly: true,
                  ),

                  SizedBox(height: 40.h),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isUpdating
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                            )
                          : Text(
                              'Update Profile',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 18.sp,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required String hint,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          readOnly: readOnly,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
            filled: true,
            fillColor: readOnly ? AppColors.surface.withOpacity(0.5) : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }
}