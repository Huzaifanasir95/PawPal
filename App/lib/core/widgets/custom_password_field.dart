import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_text_styles.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isConfirmPassword;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isConfirmPassword = false,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: widget.controller,
          obscureText: _isObscured,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 20.w,
              ),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.w,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
