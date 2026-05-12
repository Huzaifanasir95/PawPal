import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/custom_password_field.dart';
import '../bloc/auth_bloc.dart';
import 'account_type_selection_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSignIn;

  const SignUpScreen({super.key, this.onNavigateToSignIn});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  DateTime? _lastButtonPress;

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              authenticated: (user) {
                // Don't handle here - let AuthFlow handle navigation
                print('🏠 SignUp: Authenticated - letting AuthFlow handle it');
              },
              unauthenticated: () {},
              error: (message) {
                // Don't show error for user cancellation
                if (!message.toLowerCase().contains('cancelled')) {
                  CustomSnackbar.showError(context, message);
                }
              },
              passwordResetSent: () {},
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

                // Sign up Title
                Text(
                  AppStrings.signUp,
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
                    Expanded(flex: 2, child: _buildGoogleSignInButton(context)),
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 30.h),

                // Name Input
                _buildInputField(
                  hintText: AppStrings.name,
                  icon: Icons.person,
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                ),

                SizedBox(height: 20.h),

                // Email Input
                _buildInputField(
                  hintText: AppStrings.yourEmail,
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          widget.onNavigateToSignIn ??
                          () {
                            // Fallback navigation if callback not provided
                            final authBloc = context.read<AuthBloc>();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (context) => BlocProvider.value(
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
        final foregroundColor =
            isLoading
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                : colorScheme.onSurface;

        return Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: isDark ? 0.18 : 0.08,
                ),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25.r),
              onTap:
                  isLoading
                      ? null
                      : () {
                        if (!mounted) return;

                        // Prevent rapid button presses
                        final now = DateTime.now();
                        if (_lastButtonPress != null &&
                            now.difference(_lastButtonPress!).inMilliseconds <
                                2000) {
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
                          CustomSnackbar.showError(
                            context,
                            'Failed to sign in with Google',
                          );
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
                          foregroundColor,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.g_mobiledata,
                      color: foregroundColor,
                      size: 30.sp,
                    ),
                  SizedBox(width: 8.w),
                  Text(
                    AppStrings.withGoogle,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
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
    TextInputType? keyboardType,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hintText,
                hintStyle: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Icon(icon, color: colorScheme.onSurfaceVariant, size: 18.sp),
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
            color:
                isLoading
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white,
            borderRadius: BorderRadius.circular(98.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(98.r),
              onTap:
                  isLoading
                      ? null
                      : () {
                        if (!mounted) return;

                        // Prevent rapid button presses
                        final now = DateTime.now();
                        if (_lastButtonPress != null &&
                            now.difference(_lastButtonPress!).inMilliseconds <
                                2000) {
                          return;
                        }
                        _lastButtonPress = now;

                        // Validate fields
                        final name = _nameController.text.trim();
                        final email = _emailController.text.trim().toLowerCase();
                        final password = _passwordController.text;
                        final confirmPassword = _confirmPasswordController.text;

                        if (name.isEmpty) {
                          CustomSnackbar.showError(
                            context,
                            'Please enter your name',
                          );
                          return;
                        }

                        if (email.isEmpty) {
                          CustomSnackbar.showError(
                            context,
                            'Please enter your email',
                          );
                          return;
                        }

                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(email)) {
                          CustomSnackbar.showError(
                            context,
                            'Please enter a valid email address',
                          );
                          return;
                        }

                        if (password.isEmpty) {
                          CustomSnackbar.showError(
                            context,
                            'Please enter your password',
                          );
                          return;
                        }

                        if (password.length < 6) {
                          CustomSnackbar.showError(
                            context,
                            'Password must be at least 6 characters long',
                          );
                          return;
                        }

                        if (password != confirmPassword) {
                          CustomSnackbar.showError(
                            context,
                            'Passwords do not match',
                          );
                          return;
                        }

                        // Continue to role selection before account creation.
                        try {
                          final authBloc = context.read<AuthBloc>();
                          if (authBloc.isClosed) return;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => BlocProvider.value(
                                    value: authBloc,
                                    child: AccountTypeSelectionScreen(
                                      pendingEmail: email,
                                      pendingPassword: password,
                                      pendingName: name,
                                    ),
                                  ),
                            ),
                          );
                        } catch (e) {
                          debugPrint('Sign-up error: $e');
                          CustomSnackbar.showError(
                            context,
                            'Failed to create account. Please try again.',
                          );
                        }
                      },
              child: Center(
                child:
                    isLoading
                        ? SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        )
                        : Text(
                          'Create Account',
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


