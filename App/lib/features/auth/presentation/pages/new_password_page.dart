import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/repositories/auth_repository.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String resetToken;

  const NewPasswordPage({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = getIt<AuthRepository>();
      await repo.confirmPasswordReset(
        token: widget.resetToken,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      CustomSnackbar.showSuccess(
          context, 'Password reset successfully! Please sign in.');
      // Pop all pages back to sign-in
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(
        context,
        'Invalid or expired reset code. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _hasMinLength(String v) => v.length >= 8;
  bool _hasUppercase(String v) => v.contains(RegExp(r'[A-Z]'));
  bool _hasNumber(String v) => v.contains(RegExp(r'[0-9]'));

  @override
  Widget build(BuildContext context) {
    final pw = _passwordController.text;

    return Scaffold(
      backgroundColor: const Color(0xFFECEFF3),
      body: SafeArea(
        child: Column(
          children: [
            // Hero header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4E9F9A),
                    Color(0xFF2F6E72),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(Icons.lock_open_rounded,
                        color: Colors.white, size: 36.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Create a strong password to\nkeep your account safe.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.88),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(() {}),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      // New password field
                      Text(
                        'New Password',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter new password',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.6),
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22.sp,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              size: 20.sp,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18.w, vertical: 16.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      // Password strength indicators
                      if (pw.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        _buildStrengthRow(
                            '8+ characters', _hasMinLength(pw)),
                        SizedBox(height: 6.h),
                        _buildStrengthRow(
                            'One uppercase letter', _hasUppercase(pw)),
                        SizedBox(height: 6.h),
                        _buildStrengthRow('One number', _hasNumber(pw)),
                      ],

                      SizedBox(height: 20.h),

                      // Confirm password field
                      Text(
                        'Confirm Password',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          hintText: 'Re-enter new password',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.6),
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22.sp,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              size: 20.sp,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18.w, vertical: 16.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 32.h),

                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            disabledBackgroundColor:
                                Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthRow(String label, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16.sp,
          color: met ? Colors.green : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: met ? Colors.green : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}


