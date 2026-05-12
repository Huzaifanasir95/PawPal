import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A theme-aware snackbar helper.
/// Colors are pulled from the ambient [Theme] so they automatically
/// adapt to both light/dark mode and role-specific palettes.
class CustomSnackbar {
  // ── Error ────────────────────────────────────────────────────────────────
  static void showError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context: context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: colorScheme.error,
      iconColor: colorScheme.onError,
      textColor: colorScheme.onError,
      duration: const Duration(seconds: 4),
    );
  }

  // ── Success ──────────────────────────────────────────────────────────────
  static void showSuccess(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: const Color(0xFF16A34A),
      iconColor: Colors.white,
      textColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ── Info ─────────────────────────────────────────────────────────────────
  static void showInfo(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context: context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: colorScheme.primary,
      iconColor: colorScheme.onPrimary,
      textColor: colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
    );
  }

  // ── Warning ──────────────────────────────────────────────────────────────
  static void showWarning(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFFD97706),
      iconColor: Colors.white,
      textColor: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // ── Core ─────────────────────────────────────────────────────────────────
  static void _show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          duration: duration,
          elevation: 6,
          content: Row(
            children: [
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}