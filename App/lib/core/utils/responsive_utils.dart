import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  /// Get responsive width
  static double width(double width) => width.w;

  /// Get responsive height
  static double height(double height) => height.h;

  /// Get responsive font size
  static double fontSize(double fontSize) => fontSize.sp;

  /// Get responsive radius
  static double radius(double radius) => radius.r;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get safe area padding
  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: (top ?? vertical ?? all ?? 0).h,
      bottom: (bottom ?? vertical ?? all ?? 0).h,
      left: (left ?? horizontal ?? all ?? 0).w,
      right: (right ?? horizontal ?? all ?? 0).w,
    );
  }

  /// Get responsive margin
  static EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: (top ?? vertical ?? all ?? 0).h,
      bottom: (bottom ?? vertical ?? all ?? 0).h,
      left: (left ?? horizontal ?? all ?? 0).w,
      right: (right ?? horizontal ?? all ?? 0).w,
    );
  }
}