import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/image_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/data/models/auth_user.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _pixelThemePrefKey = 'home_pixel_pet_theme';
  AuthUser? _userProfile;
  bool _isLoading = true;
  bool _isUpdating = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final _displayNameController = TextEditingController();
  String? _selectedAccountType;
  String _selectedPixelTheme = 'classic';

  // Map backend values to display names
  String _mapAccountTypeToDisplay(String? backendType) {
    if (backendType == null) return 'Pet Owner';
    
    switch (backendType.toLowerCase()) {
      case 'vet':
      case 'veterinarian':
      case 'veterinary':
        return 'Veterinarian';
      case 'seller':
      case 'vendor':
      case 'merchant':
      case 'shop_owner':
      case 'shop owner':
      case 'shopowner':
        return 'Seller';
      case 'petowner':
      case 'pet_owner':
      case 'pet owner':
      case 'pet-owner':
        return 'Pet Owner';
      case 'caregiver':
      case 'care_giver':
      case 'pet_caregiver':
        return 'Caregiver';
      case 'admin':
        return 'Admin';
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
    _loadCustomizationSettings();
  }

  Future<void> _loadCustomizationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedPixelTheme = prefs.getString(_pixelThemePrefKey) ?? 'classic';
    });
  }

  Future<void> _savePixelTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pixelThemePrefKey, theme);

    if (!mounted) return;
    setState(() {
      _selectedPixelTheme = theme;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Home pixel pet style updated'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _themeLabel(String key) {
    switch (key) {
      case 'chunky':
        return 'Chunky Cat';
      case 'doggo':
        return 'Doggo Run';
      default:
        return 'Classic Cat';
    }
  }

  Future<void> _showPetThemeSelector() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF1F6F8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home Pixel Pet Style',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Choose how your running pet looks on the home card.',
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 10.h),
              ...['classic', 'chunky', 'doggo'].map((theme) {
                return RadioListTile<String>(
                  value: theme,
                  groupValue: _selectedPixelTheme,
                  activeColor: AppColors.primary,
                  title: Text(
                    _themeLabel(theme),
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 15.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    theme == 'doggo'
                        ? 'Playful running dog'
                        : 'Running pixel cat variant',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    Navigator.pop(context);
                    _savePixelTheme(value);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

    String? avatarUrl;
    String? warningMessage;

    try {
      // Upload image if selected
      if (_selectedImage != null) {
        try {
          final imageService = getIt<ImageService>();
          avatarUrl = await imageService.uploadImage(_selectedImage!);
          if (avatarUrl == null) {
            warningMessage =
                'Profile image could not be uploaded. Other profile changes will still be saved.';
          }
        } catch (e) {
          debugPrint('Failed to upload avatar: $e');
          warningMessage =
              'Profile image upload failed. Other profile changes will still be saved.';
          avatarUrl = null;
        }
      }

      if (!mounted) return;
      final profileRepo = ProfileRepository(context.read<AuthBloc>().authRepository);

      try {
        await profileRepo.updateUserProfile(
          displayName: _displayNameController.text.trim(),
          avatarUrl: avatarUrl,
        );
      } catch (e) {
        final errorText = e.toString().toLowerCase();
        final isAvatarRelatedFailure =
            avatarUrl != null &&
            (errorText.contains('avatar') ||
                errorText.contains('image') ||
                errorText.contains('insert') ||
                errorText.contains('upload'));

        if (!isAvatarRelatedFailure) {
          rethrow;
        }

        warningMessage =
            'Profile details were saved, but profile image could not be stored.';

        await profileRepo.updateUserProfile(
          displayName: _displayNameController.text.trim(),
        );
      }

      // Reload profile
      await _loadUserProfile();

      if (!mounted) return;

      if (warningMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(warningMessage),
            backgroundColor: AppColors.warning,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      
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
      if (mounted) {
        setState(() => _isUpdating = false);
      }
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

    if (!mounted) return;

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
            if (!mounted) return;

            // Close profile screen and let AuthFlow switch the root content.
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFD6E2E8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4E9F9A),
          elevation: 0,
          title: Text(
            'Profile',
            style: AppTextStyles.onboardingTitle.copyWith(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showPetThemeSelector,
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 24.sp,
              ),
              tooltip: 'App Customization',
            ),
            IconButton(
              onPressed: _showLogoutDialog,
              icon: Icon(
                Icons.logout,
                color: Colors.white,
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
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFDDE8ED),
                    Color(0xFFD2DEE5),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF1F6F8),
                            Color(0xFFDDE9EE),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFB9CBD4), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 108.w,
                                height: 108.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.12),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 3.w,
                                  ),
                                ),
                                child: ClipOval(child: _buildProfileImage()),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: _showImageSourceDialog,
                                  child: Container(
                                    width: 34.w,
                                    height: 34.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFF1F6F8),
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
                          SizedBox(height: 14.h),
                          Text(
                            _userProfile?.displayName ?? 'User',
                            style: AppTextStyles.onboardingTitle.copyWith(
                              fontSize: 27.sp,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _userProfile?.email ?? '',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_userProfile?.accountType != null) ...[
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                _mapAccountTypeToDisplay(_userProfile!.accountType),
                                style: AppTextStyles.onboardingBody.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF1F6F8),
                            Color(0xFFDDE9EE),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFB9CBD4), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34.w,
                                height: 34.h,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primary,
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Edit Profile',
                                      style: AppTextStyles.onboardingTitle.copyWith(
                                        fontSize: 19.sp,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Keep your account details up to date.',
                                      style: AppTextStyles.onboardingBody.copyWith(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          _buildTextField(
                            label: 'Display Name',
                            controller: _displayNameController,
                            hint: 'Enter your display name',
                            icon: Icons.person_outline,
                          ),
                          SizedBox(height: 14.h),
                          _buildTextField(
                            label: 'Account Type',
                            initialValue: _selectedAccountType ?? '',
                            hint: 'Your account type',
                            icon: Icons.badge_outlined,
                            readOnly: true,
                          ),
                          SizedBox(height: 14.h),
                          _buildTextField(
                            label: 'Email',
                            initialValue: _userProfile?.email ?? '',
                            hint: 'Your email address',
                            icon: Icons.email_outlined,
                            readOnly: true,
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: _isUpdating ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF19262D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 2,
                              ),
                              child: _isUpdating
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Update Profile',
                                      style: AppTextStyles.onboardingBody.copyWith(
                                        fontSize: 18.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
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
            fillColor: readOnly
                ? const Color(0xFFE9F0F4)
                : const Color(0xFFF7FBFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: Color(0xFFC7D6DE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: Color(0xFFC7D6DE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
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