import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_password_field.dart';
import '../bloc/auth_bloc.dart';
import 'sign_up_screen.dart';
import 'forgot_password_page.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSignUp;
  
  const SignInScreen({
    super.key,
    this.onNavigateToSignUp,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? _lastButtonPress;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              authenticated: (user) {
                // Don't handle here - let AuthFlow handle navigation
                print('🏠 SignIn: Authenticated - letting AuthFlow handle it');
              },
              unauthenticated: () {},
              error: (message) {
                // Don't show error for user cancellation
                if (!message.toLowerCase().contains('cancelled')) {
                  CustomSnackbar.showError(context, message);
                }
              },
              passwordResetSent: () {
                CustomSnackbar.showSuccess(context, 'Password reset email sent!');
              },
              accountTypeRequired: (idToken, displayName, photoUrl) {
                // Navigation handled by AuthFlow
              },
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
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(29.r),
                        ),
                        child: Icon(
                          Icons.pets,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30.w,
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 50.h),
              
              // Sign in Title
              Text(
                AppStrings.signIn,
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 48.sp,
                  color: Theme.of(context).colorScheme.onSurface,
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
                  
                  
                ],
              ),
              
              SizedBox(height: 40.h),
              
              // Or with Email
              Text(
                AppStrings.orWithEmail,
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 20.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              SizedBox(height: 30.h),
              
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
              
              SizedBox(height: 16.h),
              
              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    AppStrings.forgot,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Get Started Button
              _buildGetStartedButton(context),
              
              SizedBox(height: 30.h),
              
              // New User Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${AppStrings.newUser} ',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onNavigateToSignUp ?? () {
                      // Fallback navigation if callback not provided
                      final authBloc = context.read<AuthBloc>();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: authBloc,
                            child: const SignUpScreen(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      AppStrings.signUp,
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        // Use primary color for better contrast and visibility
        final buttonBgColor = isLoading 
          ? colorScheme.primary.withValues(alpha: 0.6)
          : colorScheme.primary;
        final buttonTextColor = colorScheme.onPrimary;
        
        return Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: buttonBgColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: isDark ? 0.15 : 0.1,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          buttonTextColor,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.g_mobiledata,
                      color: buttonTextColor,
                      size: 24.sp,
                    ),
                  SizedBox(width: 10.w),
                  Text(
                    AppStrings.withGoogle,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: buttonTextColor,
                      fontWeight: FontWeight.w700,
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
    final colorScheme = Theme.of(context).colorScheme;

    // Single clean container with no overlapping layers
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),
          // Icon on the left
          Icon(
            icon,
            color: colorScheme.onSurfaceVariant,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          // Transparent TextField with no background
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hintText,
                hintStyle: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                // Remove all borders and backgrounds
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
                filled: false,
              ),
            ),
          ),
          SizedBox(width: 14.w),
        ],
      ),
    );
  }



  Widget _buildGetStartedButton(BuildContext context) {
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
            color: isLoading ? Colors.white.withOpacity(0.7) : Colors.white,
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
                
                final email = _emailController.text.trim().toLowerCase();
                final password = _passwordController.text;
                
                // Validate fields
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
                
                try {
                  final authBloc = context.read<AuthBloc>();
                  if (!authBloc.isClosed) {
                    authBloc.add(
                      AuthEvent.signInWithEmail(email, password),
                    );
                  }
                } catch (e) {
                  debugPrint('Sign-in error: $e');
                  CustomSnackbar.showError(context, 'Failed to sign in. Please try again.');
                }
              },
              child: Center(
                child: isLoading 
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : Text(
                      AppStrings.getStarted,
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: 24.sp,
                        color: Theme.of(context).colorScheme.secondary,
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
}

