import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme_controller.dart';
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
  bool _isRoleUpdating = false;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final _displayNameController = TextEditingController();
  String? _selectedAccountType;
  String _selectedPixelTheme = 'classic';
  List<String> _assignedRoles = const [];
  String _selectedThemeRole = 'pet_owner';

  static const List<String> _availableRoles = <String>[
    'pet_owner',
    'vet',
    'seller',
    'caregiver',
  ];

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

  String _normalizeRoleKey(String? role) {
    final normalized = role?.trim().toLowerCase() ?? '';
    switch (normalized) {
      case 'pet_owner':
      case 'petowner':
      case 'pet-owner':
      case 'pet owner':
      case 'owner':
        return 'pet_owner';
      case 'vet':
      case 'veterinarian':
      case 'veterinary':
        return 'vet';
      case 'seller':
      case 'vendor':
      case 'merchant':
      case 'shop_owner':
      case 'shop owner':
      case 'shopowner':
        return 'seller';
      case 'caregiver':
      case 'care_giver':
      case 'pet_caregiver':
        return 'caregiver';
      default:
        return 'pet_owner';
    }
  }

  String _themeRoleLabel(String role) {
    switch (_normalizeRoleKey(role)) {
      case 'vet':
        return 'Veterinary';
      case 'seller':
        return 'Seller';
      case 'caregiver':
        return 'Caregiver';
      default:
        return 'Pet Owner';
    }
  }

  int _roleSortOrder(String role) {
    switch (_normalizeRoleKey(role)) {
      case 'pet_owner':
        return 0;
      case 'caregiver':
        return 1;
      case 'vet':
        return 2;
      case 'seller':
        return 3;
      default:
        return 4;
    }
  }

  String _activeRole() {
    final active = context.read<AuthBloc>().authRepository.activeRole;
    return _normalizeRoleKey(active ?? _userProfile?.accountType);
  }

  String _roleDescription(String role) {
    switch (_normalizeRoleKey(role)) {
      case 'vet':
        return 'Consultations, veterinary tools, and patient chat';
      case 'seller':
        return 'Marketplace listings, inventory, and orders';
      case 'caregiver':
        return 'Care services, availability, and bookings';
      default:
        return 'Pets, community, and everyday pet care';
    }
  }

  Future<void> _switchActiveRole(String role) async {
    final normalizedRole = _normalizeRoleKey(role);
    final active = _activeRole();
    if (_isRoleUpdating || normalizedRole == active) return;

    setState(() {
      _isRoleUpdating = true;
    });

    try {
      final authRepository = context.read<AuthBloc>().authRepository;
      await authRepository.switchRole(normalizedRole);
      if (!mounted) return;

      context.read<AppThemeController>().setActiveRole(normalizedRole);
      await _loadRolePreferences();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Active role switched to ${_themeRoleLabel(normalizedRole)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRoleUpdating = false;
        });
      }
    }
  }

  Future<void> _addRole(String role) async {
    final normalizedRole = _normalizeRoleKey(role);
    if (_assignedRoles.contains(normalizedRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role already assigned to this account')),
      );
      return;
    }

    setState(() {
      _isRoleUpdating = true;
    });

    try {
      final authRepository = context.read<AuthBloc>().authRepository;
      await authRepository.addUserRole(normalizedRole);
      await authRepository.switchRole(normalizedRole);
      if (!mounted) return;

      context.read<AppThemeController>().setActiveRole(normalizedRole);
      await _loadRolePreferences();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_themeRoleLabel(normalizedRole)} role added and activated',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRoleUpdating = false;
        });
      }
    }
  }

  Future<void> _showAddRoleSheet() async {
    final availableRoles =
        _availableRoles
            .where((role) => !_assignedRoles.contains(role))
            .toList();

    if (availableRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All supported roles are already assigned'),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Role',
                  style: AppTextStyles.onboardingTitle.copyWith(
                    fontSize: 18.sp,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Add another role to unlock related dashboards and tools.',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 12.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 10.h),
                ...availableRoles.map(
                  (role) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_add_alt_1_rounded),
                    title: Text(_themeRoleLabel(role)),
                    subtitle: Text(_roleDescription(role)),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _addRole(role);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadCustomizationSettings();
    _loadRolePreferences();
  }

  Future<void> _loadRolePreferences() async {
    final authRepository = context.read<AuthBloc>().authRepository;
    final fallbackRole = _normalizeRoleKey(
      authRepository.activeRole ??
          _userProfile?.accountType ??
          authRepository.currentUser?.accountType,
    );

    var roles =
        authRepository.assignedRoles.map(_normalizeRoleKey).toSet().toList();

    if (roles.isEmpty) {
      roles = <String>[fallbackRole];
    }

    try {
      final serverRoles = await authRepository.getUserRoles(forceRefresh: true);
      final normalized = serverRoles.map(_normalizeRoleKey).toSet().toList();
      if (normalized.isNotEmpty) {
        roles = normalized;
      }
    } catch (e) {
      debugPrint('Could not refresh assigned roles for theming: $e');
    }

    final activeRole = _normalizeRoleKey(
      authRepository.activeRole ?? _userProfile?.accountType ?? fallbackRole,
    );
    if (!roles.contains(activeRole)) {
      roles.add(activeRole);
    }

    roles.sort((a, b) => _roleSortOrder(a).compareTo(_roleSortOrder(b)));

    if (!mounted) return;
    setState(() {
      _assignedRoles = roles;
      if (!_assignedRoles.contains(_selectedThemeRole)) {
        _selectedThemeRole = activeRole;
      }
    });
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
        backgroundColor: Colors.green,
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
    final colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => SafeArea(
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
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Choose how your running pet looks on the home card.',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 13.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...['classic', 'chunky', 'doggo'].map((theme) {
                    return RadioListTile<String>(
                      value: theme,
                      groupValue: _selectedPixelTheme,
                      activeColor: colorScheme.primary,
                      title: Text(
                        _themeLabel(theme),
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 15.sp,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        theme == 'doggo'
                            ? 'Playful running dog'
                            : 'Running pixel cat variant',
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
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
        _selectedAccountType = _mapAccountTypeToDisplay(
          _userProfile?.accountType,
        );
        _selectedThemeRole = _normalizeRoleKey(_userProfile?.accountType);

        // Try to load additional profile data
        try {
          final profileRepo = ProfileRepository(
            context.read<AuthBloc>().authRepository,
          );
          final fullProfile = await profileRepo.getCurrentUserProfile();
          if (fullProfile != null) {
            _userProfile = fullProfile;
            _displayNameController.text = _userProfile?.displayName ?? '';
            _selectedAccountType = _mapAccountTypeToDisplay(
              _userProfile?.accountType,
            );
            _selectedThemeRole = _normalizeRoleKey(_userProfile?.accountType);
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
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        await _loadRolePreferences();
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name cannot be empty'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
      final profileRepo = ProfileRepository(
        context.read<AuthBloc>().authRepository,
      );

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
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _selectedImage = null;
        _selectedImageBytes = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _showUpdateEmailDialog() async {
    final emailController = TextEditingController(
      text: _userProfile?.email ?? '',
    );
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Update Email'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'New Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Enter your new email';
                        final valid = RegExp(
                          r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                        ).hasMatch(email);
                        if (!valid) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Enter your current password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      isSubmitting
                          ? null
                          : () async {
                            if (!formKey.currentState!.validate()) return;

                            setDialogState(() => isSubmitting = true);
                            try {
                              final profileRepo = ProfileRepository(
                                context.read<AuthBloc>().authRepository,
                              );

                              await profileRepo.updateEmail(
                                newEmail: emailController.text.trim(),
                                currentPassword: passwordController.text,
                              );

                              if (!mounted) return;
                              await _loadUserProfile();
                              if (!mounted) return;

                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              );
                            } finally {
                              if (dialogContext.mounted) {
                                setDialogState(() => isSubmitting = false);
                              }
                            }
                          },
                  child:
                      isSubmitting
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text('Update Email'),
                ),
              ],
            );
          },
        );
      },
    );

    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> _showUpdatePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Update Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty)
                          return 'Enter current password';
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                      validator: (value) {
                        final next = value ?? '';
                        if (next.isEmpty) return 'Enter new password';
                        if (next.length < 6)
                          return 'Password must be at least 6 characters';
                        if (next == currentPasswordController.text) {
                          return 'New password must be different';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: Icon(Icons.verified_user_outlined),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty)
                          return 'Confirm your new password';
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      isSubmitting
                          ? null
                          : () async {
                            if (!formKey.currentState!.validate()) return;

                            setDialogState(() => isSubmitting = true);
                            try {
                              final profileRepo = ProfileRepository(
                                context.read<AuthBloc>().authRepository,
                              );

                              await profileRepo.updatePassword(
                                currentPassword: currentPasswordController.text,
                                newPassword: newPasswordController.text,
                              );

                              if (!mounted) return;
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Password updated successfully',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              );
                            } finally {
                              if (dialogContext.mounted) {
                                setDialogState(() => isSubmitting = false);
                              }
                            }
                          },
                  child:
                      isSubmitting
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text('Update Password'),
                ),
              ],
            );
          },
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  bool _isBase64DataUrl(String url) {
    return url.startsWith('data:image/');
  }

  Widget _buildProfileImage() {
    final imageUrl = _userProfile?.photoURL;
    final avatarColor = Theme.of(context).colorScheme.primary;

    if (_selectedImage != null) {
      if (_selectedImageBytes != null) {
        return Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
      }

      return FutureBuilder<Uint8List>(
        future: _selectedImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }
          return Icon(Icons.person, size: 50.sp, color: avatarColor);
        },
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
              return Icon(Icons.person, size: 50.sp, color: avatarColor);
            },
          );
        } catch (e) {
          debugPrint('Failed to decode base64 image: $e');
          return Icon(Icons.person, size: 50.sp, color: avatarColor);
        }
      } else {
        // Regular HTTP URL
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, size: 50.sp, color: avatarColor);
          },
        );
      }
    } else {
      return Icon(Icons.person, size: 50.sp, color: avatarColor);
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
        final imageBytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = imageBytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
        final imageBytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = imageBytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to take photo: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) {
            final colorScheme = Theme.of(context).colorScheme;

            return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      'Choose from Gallery',
                      style: AppTextStyles.bodyMedium,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.camera_alt, color: colorScheme.primary),
                    title: Text(
                      'Take a Photo',
                      style: AppTextStyles.bodyMedium,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                  if (_userProfile?.photoURL != null || _selectedImage != null)
                    ListTile(
                      leading: Icon(Icons.delete, color: colorScheme.error),
                      title: Text(
                        'Remove Photo',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedImage = null;
                          _selectedImageBytes = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            );
            },
    );
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) {
            final colorScheme = Theme.of(context).colorScheme;

            return AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text(
              'Logout',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 16.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Logout',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 16.sp,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
          },
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          title: Text(
            'Profile',
            style: AppTextStyles.onboardingTitle.copyWith(
              fontSize: 20.sp,
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: colorScheme.onPrimary,
              size: 24.sp,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showPetThemeSelector,
              icon: Icon(
                Icons.settings_outlined,
                color: colorScheme.onPrimary,
                size: 24.sp,
              ),
              tooltip: 'Pixel Pet Style',
            ),
            IconButton(
              onPressed: _showLogoutDialog,
              icon: Icon(
                Icons.logout,
                color: colorScheme.onPrimary,
                size: 24.sp,
              ),
            ),
          ],
        ),
        body:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                )
                : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.surface,
                        colorScheme.surfaceContainerHighest.withOpacity(0.55),
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
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.surface,
                                colorScheme.primaryContainer.withOpacity(0.45),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.32),
                              width: 1,
                            ),
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
                                      color: colorScheme.primary.withOpacity(
                                        0.12,
                                      ),
                                      border: Border.all(
                                        color: colorScheme.primary,
                                        width: 3.w,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: _buildProfileImage(),
                                    ),
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
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: colorScheme.surface,
                                            width: 2.w,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 16.sp,
                                          color: colorScheme.onPrimary,
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
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _userProfile?.email ?? '',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.onboardingBody.copyWith(
                                  fontSize: 14.sp,
                                  color: colorScheme.onSurfaceVariant,
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
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    _mapAccountTypeToDisplay(
                                      _userProfile!.accountType,
                                    ),
                                    style: AppTextStyles.onboardingBody
                                        .copyWith(
                                          fontSize: 13.sp,
                                          color: colorScheme.primary,
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
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.surface,
                                colorScheme.primaryContainer.withOpacity(0.42),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.32),
                              width: 1,
                            ),
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
                                      color: colorScheme.primary.withOpacity(
                                        0.15,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: colorScheme.primary,
                                      size: 18.sp,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Edit Profile',
                                          style: AppTextStyles.onboardingTitle
                                              .copyWith(
                                                fontSize: 19.sp,
                                                color: colorScheme.onSurface,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'Keep your account details up to date.',
                                          style: AppTextStyles.onboardingBody
                                              .copyWith(
                                                fontSize: 12.sp,
                                                color:
                                                    colorScheme.onSurfaceVariant,
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
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          _isUpdating
                                              ? null
                                              : _showUpdateEmailDialog,
                                      icon: Icon(Icons.alternate_email),
                                      label: Text('Change Email'),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          _isUpdating
                                              ? null
                                              : _showUpdatePasswordDialog,
                                      icon: Icon(
                                        Icons.lock_reset_outlined,
                                      ),
                                      label: Text('Change Password'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              SizedBox(
                                width: double.infinity,
                                height: 56.h,
                                child: ElevatedButton(
                                  onPressed:
                                      _isUpdating ? null : _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    elevation: 2,
                                  ),
                                  child:
                                      _isUpdating
                                          ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          )
                                          : Text(
                                            'Update Profile',
                                            style: AppTextStyles.onboardingBody
                                                .copyWith(
                                                  fontSize: 18.sp,
                                                  color: colorScheme.onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildRoleManagementCard(),
                        SizedBox(height: 16.h),
                        _buildAppearanceCard(),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildRoleManagementCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final titleColor = colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurfaceVariant;
    final activeRole = _activeRole();
    final roles =
        _assignedRoles.isNotEmpty
            ? List<String>.from(_assignedRoles)
            : <String>[activeRole];
    roles.sort((a, b) => _roleSortOrder(a).compareTo(_roleSortOrder(b)));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.primaryContainer.withOpacity(0.42),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.32),
          width: 1,
        ),
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
                  color: colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.manage_accounts_outlined,
                  color: colorScheme.primary,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Roles',
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: 19.sp,
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Switch roles or add a new one from your account settings.',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 12.sp,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isRoleUpdating) ...[
            SizedBox(height: 10.h),
            LinearProgressIndicator(
              minHeight: 3,
              borderRadius: BorderRadius.circular(999.r),
              color: colorScheme.primary,
              backgroundColor: colorScheme.primary.withOpacity(0.2),
            ),
          ],
          SizedBox(height: 12.h),
          Text(
            'Current Active Role',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 13.sp,
              color: subtitleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              _themeRoleLabel(activeRole),
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 13.sp,
                color: titleColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Assigned Roles',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 13.sp,
              color: subtitleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                roles
                    .map(
                      (role) => ChoiceChip(
                        label: Text(
                          _themeRoleLabel(role),
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 13.sp,
                            color:
                                role == activeRole
                                    ? colorScheme.primary
                                    : titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: role == activeRole,
                        selectedColor: colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.35),
                        ),
                        onSelected:
                            _isRoleUpdating
                                ? null
                                : (_) {
                                  _switchActiveRole(role);
                                },
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _isRoleUpdating || roles.length >= _availableRoles.length
                      ? null
                      : _showAddRoleSheet,
              icon: Icon(Icons.add_circle_outline_rounded),
              label: Text('Add Role'),
              style: OutlinedButton.styleFrom(
                foregroundColor: titleColor,
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.55),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final titleColor = colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurfaceVariant;
    final themeController = context.watch<AppThemeController>();
    final roles =
        _assignedRoles.isNotEmpty
            ? _assignedRoles
            : <String>[_normalizeRoleKey(_userProfile?.accountType)];
    final selectedRole =
        roles.contains(_selectedThemeRole) ? _selectedThemeRole : roles.first;
    final selectedPaletteId = themeController.selectedPaletteIdForRole(
      selectedRole,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.primaryContainer.withOpacity(0.42),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.32),
          width: 1,
        ),
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
                  color: colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: colorScheme.primary,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: 19.sp,
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Customize dark mode and colors for each role.',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 12.sp,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Dark Mode',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 15.sp,
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Apply a darker look across the app.',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 12.sp,
                color: subtitleColor,
              ),
            ),
            value: themeController.isDarkMode,
            onChanged: (value) async {
              await themeController.setDarkMode(value);
            },
          ),
          SizedBox(height: 6.h),
          Text(
            'Role to customize',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                roles
                    .map(
                      (role) => ChoiceChip(
                        label: Text(
                          _themeRoleLabel(role),
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 13.sp,
                            color:
                                selectedRole == role
                                    ? colorScheme.primary
                                    : titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: selectedRole == role,
                        selectedColor: colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.35),
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedThemeRole = role;
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: 14.h),
          Text(
            'Color Palette for ${_themeRoleLabel(selectedRole)}',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children:
                themeController.palettes.map((palette) {
                  final isSelected = palette.id == selectedPaletteId;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () async {
                      await themeController.setRoleTheme(
                        selectedRole,
                        palette.id,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 136.w,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? palette.primary
                                  : colorScheme.outline.withValues(alpha: 0.35),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 16.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: palette.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              palette.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 12.sp,
                                color: titleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
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
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              icon,
              color: colorScheme.onSurfaceVariant,
              size: 20.sp,
            ),
            filled: true,
            fillColor:
                readOnly
                    ? colorScheme.surfaceContainerHighest.withOpacity(0.6)
                    : colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.55),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.55),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
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


