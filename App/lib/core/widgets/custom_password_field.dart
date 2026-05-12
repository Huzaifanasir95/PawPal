import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_text_styles.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isConfirmPassword;
  final bool showLabel;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isConfirmPassword = false,
    this.showLabel = false,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final field = Container(
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
              controller: widget.controller,
              obscureText: _isObscured,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: widget.hintText ?? widget.labelText,
                hintStyle: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
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
          IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 40.w, height: 40.h),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );

    if (!widget.showLabel) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        field,
      ],
    );
  }
}
