import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/repositories/auth_repository.dart';
import 'verify_reset_code_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = getIt<AuthRepository>();
      final token = await repo.resetPassword(_emailController.text.trim());
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyResetCodePage(
            email: _emailController.text.trim(),
            resetToken: token,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Icon(Icons.lock_reset_rounded,
                        color: Colors.white, size: 36.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter your email and we\'ll send\na reset code to your inbox.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.88),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Form section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      Text(
                        'Email Address',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          hintText: 'you@example.com',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.darkTeal,
                            size: 22.sp,
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
                                color: AppColors.border, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: AppColors.darkTeal, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: AppColors.error, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                                color: AppColors.error, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendResetCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkTeal,
                            disabledBackgroundColor:
                                AppColors.darkTeal.withOpacity(0.5),
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
                                  'Send Reset Code',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary),
                              children: [
                                const TextSpan(text: 'Remember your password? '),
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: AppColors.darkTeal,
                                    fontWeight: FontWeight.w700,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
