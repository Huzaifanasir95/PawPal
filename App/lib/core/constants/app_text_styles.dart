import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Text Styles using Mulish font as primary
class AppTextStyles {
  AppTextStyles._();

  // Base text style with Mulish font
  static TextStyle get _baseTextStyle => GoogleFonts.mulish();

  // Display Styles
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.25, // 50px line height
        letterSpacing: -1.0,
      );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1.22, // 44px line height
        letterSpacing: -0.8,
      );

  static TextStyle get displaySmall => _baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.25, // 40px line height
        letterSpacing: -1.0,
      );

  // Headline Styles
  static TextStyle get headlineLarge => _baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29, // 36px line height
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.42, // 34px line height
        letterSpacing: -0.5,
      );

  static TextStyle get headlineSmall => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4, // 28px line height
        letterSpacing: -0.3,
      );

  // Title Styles
  static TextStyle get titleLarge => _baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27, // 28px line height
        letterSpacing: -0.3,
      );

  static TextStyle get titleMedium => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33, // 24px line height
        letterSpacing: -0.2,
      );

  static TextStyle get titleSmall => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.38, // 22px line height
        letterSpacing: -0.1,
      );

  // Body Styles
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.25, // 25px line height
        letterSpacing: -0.5,
      );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5, // 24px line height
        letterSpacing: -0.2,
      );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43, // 20px line height
        letterSpacing: -0.1,
      );

  // Label Styles
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.38, // 22px line height
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43, // 20px line height
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33, // 16px line height
        letterSpacing: 0.1,
      );

  // Button Styles
  static TextStyle get buttonLarge => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.33, // 24px line height
        letterSpacing: 0.2,
      );

  static TextStyle get buttonMedium => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.38, // 22px line height
        letterSpacing: 0.1,
      );

  static TextStyle get buttonSmall => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43, // 20px line height
        letterSpacing: 0.1,
      );

  // Custom Styles based on Figma design
  static TextStyle get onboardingTitle => _baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.25, // 40px line height
        letterSpacing: -1.0,
      );

  static TextStyle get onboardingBody => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.25, // 25px line height
        letterSpacing: -0.5,
      );

  static TextStyle get skipButton => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.4, // 28px line height
      );

  static TextStyle get nextButton => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.42, // 34px line height
      );

  static TextStyle get pageIndicator => _baseTextStyle.copyWith(
        fontSize: 20.303,
        fontWeight: FontWeight.w600,
        height: 1.23, // 25px line height
      );
}