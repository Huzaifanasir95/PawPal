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
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() {}); // Rebuild on focus change
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFocused = _focusNode.hasFocus;

    final field = Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: isFocused
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
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
                fillColor: Colors.transparent,
                filled: false,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
            child: Container(
              width: 44.w,
              height: 60.h,
              alignment: Alignment.center,
              child: Icon(
                _isObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isFocused
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );

    if (!widget.showLabel) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 14.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        field,
      ],
    );
  }
}