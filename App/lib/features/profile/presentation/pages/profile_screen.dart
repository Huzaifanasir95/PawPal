import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/data/models/auth_user.dart';
import '../../../auth/presentation/pages/sign_in_screen.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthUser? _userProfile;
  bool _isLoading = true;
  bool _isUpdating = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final _displayNameController = TextEditingController();
  String? _selectedAccountType;

  // Map backend values to display names
  String _mapAccountTypeToDisplay(String? backendType) {
    if (backendType == null) return 'Pet Owner';
    
    switch (backendType.toLowerCase()) {
      case 'vet':
      case 'veterinarian':
        return 'Veterinarian';
      case 'petowner':
      case 'pet_owner':
      case 'pet owner':
        return 'Pet Owner';
      case 'breeder':
        return 'Breeder';
      case 'pet sitter':
      case 'petsitter':
        return 'Pet Sitter';
      case 'pet trainer':
      case 'pettrainer':
        return 'Pet Trainer';
      case 'shelter':
      case 'rescue':
      case 'shelter/rescue':
        return 'Shelter/Rescue';
      default:
        return 'Other';
    }
  }

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
        // Use the AuthUser directly
        _userProfile = currentUser;

        _displayNameController.text = _userProfile?.displayName ?? '';
        _selectedAccountType = _mapAccountTypeToDisplay(_userProfile?.accountType);

        // Try to load additional profile data
        try {
          final profileRepo = ProfileRepository(context.read<AuthBloc>().authRepository);
          final fullProfile = await profileRepo.getCurrentUserProfile();
          if (fullProfile != null) {
            _userProfile = fullProfile;
            _displayNameController.text = _userProfile?.displayName ?? '';
            _selectedAccountType = _mapAccountTypeToDisplay(_userProfile?.accountType);
          }
        } catch (e) {
          // Profile data might not exist yet, use basic info
          debugPrint('Could not load full profile: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
      String? avatarUrl;
      
      // Upload image if selected
      if (_selectedImage != null) {
        try {
          final imageService = getIt<ImageService>();
          avatarUrl = await imageService.uploadImage(_selectedImage!);
          if (avatarUrl == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image upload failed - please use a smaller image'),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() => _isUpdating = false);
            return;
          }
        } catch (e) {
          debugPrint('Failed to upload avatar: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isUpdating = false);
          return;
        }
      }

      final profileRepo = ProfileRepository(context.read<AuthBloc>().authRepository);

      await profileRepo.updateUserProfile(
        displayName: _displayNameController.text.trim(),
        avatarUrl: avatarUrl,
      );

      // Reload profile
      await _loadUserProfile();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      if (!mounted) return;
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

  bool _isBase64DataUrl(String url) {
    return url.startsWith('data:image/');
  }

  Widget _buildProfileImage() {
    final imageUrl = _userProfile?.photoURL;

    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      // Check if it's a base64 data URL
      if (_isBase64DataUrl(imageUrl)) {
        try {
          final base64String = imageUrl.split(',').last;
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                size: 50.sp,
                color: AppColors.primary,
              );
            },
          );
        } catch (e) {
          debugPrint('Failed to decode base64 image: $e');
          return Icon(
            Icons.person,
            size: 50.sp,
            color: AppColors.primary,
          );
        }
      } else {
        // Regular HTTP URL
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 50.sp,
              color: AppColors.primary,
            );
          },
        );
      }
    } else {
      return Icon(
        Icons.person,
        size: 50.sp,
        color: AppColors.primary,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to take photo: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: Text('Choose from Gallery', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text('Take a Photo', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              if (_userProfile?.photoURL != null || _selectedImage != null)
                ListTile(
                  leading: Icon(Icons.delete, color: AppColors.error),
                  title: Text('Remove Photo', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          unauthenticated: () {
            // User logged out, navigate to sign in screen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: const SignInScreen(),
                ),
              ),
              (route) => false,
            );
          },
          orElse: () {},
        );
      },
      child: Scaffold(
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
                        Stack(
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
                              child: ClipOval(
                                child: _buildProfileImage(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  width: 32.w,
                                  height: 32.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.background,
                                      width: 2.w,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

                  // Account Type (Read-only)
                  _buildTextField(
                    label: 'Account Type',
                    initialValue: _selectedAccountType ?? '',
                    hint: 'Your account type',
                    icon: Icons.badge_outlined,
                    readOnly: true,
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
      )
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
    ); // End Scaffold
    
  }
}