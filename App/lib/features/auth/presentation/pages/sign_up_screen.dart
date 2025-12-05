import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_password_field.dart';
import '../bloc/auth_bloc.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSignIn;
  
  const SignUpScreen({
    super.key,
    this.onNavigateToSignIn,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  DateTime? _lastButtonPress;
  String _accountType = 'pet_owner'; // Default to pet owner

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              authenticated: (user) {
                // No manual navigation - AuthFlow will handle this
              },
              unauthenticated: () {},
              error: (message) {
                // Don't show error for user cancellation
                if (!message.toLowerCase().contains('cancelled')) {
                  CustomSnackbar.showError(context, message);
                }
              },
              passwordResetSent: () {},
            );
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
            children: [
              SizedBox(height: 50.h),
              
              // Primary Logo
              Row(
                children: [
                  Image.asset(
                    AppImages.primaryLogo,
                    width: 58.w,
                    height: 58.h,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 58.w,
                        height: 58.h,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(29.r),
                        ),
                        child: Icon(
                          Icons.pets,
                          color: AppColors.primary,
                          size: 30.w,
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 50.h),
              
              // Sign up Title
              Text(
                AppStrings.signUp,
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 48.sp,
                  color: AppColors.authTitle,
                  fontWeight: FontWeight.w800,
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // Social Login Buttons
              Row(
                children: [
                  // Google Sign In Button
                  Expanded(
                    flex: 2,
                    child: _buildGoogleSignInButton(context),
                  ),
                  SizedBox(width: 12.w),
                  
                  // Facebook and Twitter buttons (optional)
                 
                ],
              ),
              
              SizedBox(height: 40.h),
              
              // Or with Email
              Text(
                AppStrings.orWithEmail,
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.authText,
                ),
              ),
              
              SizedBox(height: 30.h),
              
              // Name Input
              _buildInputField(
                hintText: AppStrings.name,
                icon: Icons.person,
                controller: _nameController,
              ),
              
              SizedBox(height: 20.h),
              
              // Email Input
              _buildInputField(
                hintText: AppStrings.yourEmail,
                icon: Icons.check,
                controller: _emailController,
              ),
              
              SizedBox(height: 20.h),
              
              // Password Input
              CustomPasswordField(
                controller: _passwordController,
                labelText: AppStrings.password,
                hintText: 'Enter your password',
              ),
              
              SizedBox(height: 20.h),
              
              // Confirm Password Input
              CustomPasswordField(
                controller: _confirmPasswordController,
                labelText: AppStrings.confirmPassword,
                hintText: 'Confirm your password',
                isConfirmPassword: true,
              ),
              
              SizedBox(height: 30.h),
              
              // Account Type Selection
              Text(
                'I am a',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.authText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildAccountTypeOption(
                      'Pet Owner',
                      'pet_owner',
                      Icons.pets,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildAccountTypeOption(
                      'Veterinarian',
                      'vet',
                      Icons.medical_services,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 40.h),
              
              // Create Account Button
              _buildCreateAccountButton(context),
              
              SizedBox(height: 30.h),
              
              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.authTextSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onNavigateToSignIn ?? () {
                      // Fallback navigation if callback not provided
                      final authBloc = context.read<AuthBloc>();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: authBloc,
                            child: const SignInScreen(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      AppStrings.signIn,
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.authTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
      )
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        
        return Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: isLoading ? AppColors.googleButton.withOpacity(0.7) : AppColors.googleButton,
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.googleButton.withOpacity(0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25.r),
              onTap: isLoading ? null : () {
                if (!mounted) return;
                
                // Prevent rapid button presses
                final now = DateTime.now();
                if (_lastButtonPress != null && 
                    now.difference(_lastButtonPress!).inMilliseconds < 2000) {
                  return;
                }
                _lastButtonPress = now;
                
                try {
                  final authBloc = context.read<AuthBloc>();
                  if (!authBloc.isClosed) {
                    authBloc.add(const AuthEvent.signInWithGoogle());
                  }
                } catch (e) {
                  debugPrint('Google sign-in error: $e');
                  CustomSnackbar.showError(context, 'Failed to sign in with Google');
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                      ),
                    )
                  else
                    Icon(
                      Icons.g_mobiledata,
                      color: AppColors.surface,
                      size: 30.sp,
                    ),
                  SizedBox(width: 8.w),
                  Text(
                    AppStrings.withGoogle,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.surface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
  }) {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.socialBorder,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: AppColors.authInputText,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.authInputText,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(
            icon,
            color: AppColors.primary,
            size: 12.sp,
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        
        return Container(
      width: double.infinity,
      height: 65.h,
      decoration: BoxDecoration(
        color: isLoading ? AppColors.googleButton.withOpacity(0.7) : AppColors.googleButton,
        borderRadius: BorderRadius.circular(98.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(98.r),
          onTap: isLoading ? null : () {
            if (!mounted) return;
            
            // Prevent rapid button presses
            final now = DateTime.now();
            if (_lastButtonPress != null && 
                now.difference(_lastButtonPress!).inMilliseconds < 2000) {
              return;
            }
            _lastButtonPress = now;
            
            // Validate fields
            final name = _nameController.text.trim();
            final email = _emailController.text.trim();
            final password = _passwordController.text;
            final confirmPassword = _confirmPasswordController.text;
            
            if (name.isEmpty) {
              CustomSnackbar.showError(context, 'Please enter your name');
              return;
            }
            
            if (email.isEmpty) {
              CustomSnackbar.showError(context, 'Please enter your email');
              return;
            }
            
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
              CustomSnackbar.showError(context, 'Please enter a valid email address');
              return;
            }
            
            if (password.isEmpty) {
              CustomSnackbar.showError(context, 'Please enter your password');
              return;
            }
            
            if (password.length < 6) {
              CustomSnackbar.showError(context, 'Password must be at least 6 characters long');
              return;
            }
            
            if (password != confirmPassword) {
              CustomSnackbar.showError(context, 'Passwords do not match');
              return;
            }
            
            // Sign up with email and password
            try {
              final authBloc = context.read<AuthBloc>();
              if (!authBloc.isClosed) {
                authBloc.add(
                  AuthEvent.signUpWithEmail(
                    email,
                    password,
                    name,
                  ),
                );
                
                // After successful signup, set the user role
                Future.delayed(const Duration(milliseconds: 500), () async {
                  try {
                    final apiClient = ApiClient.instance;
                    await apiClient.post('/api/v1/auth/set-role', data: {
                      'role': _accountType,
                    });
                  } catch (e) {
                    debugPrint('Failed to set user role: $e');
                  }
                });
              }
            } catch (e) {
              debugPrint('Sign-up error: $e');
              CustomSnackbar.showError(context, 'Failed to create account. Please try again.');
            }
          },
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  )
                : Text(
                    'Create Account',
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 24.sp,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
        },
    );
  }

  Widget _buildAccountTypeOption(String label, String value, IconData icon) {
    final isSelected = _accountType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _accountType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
