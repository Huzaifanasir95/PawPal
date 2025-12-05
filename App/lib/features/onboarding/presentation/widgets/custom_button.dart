import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_dimensions.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final Widget? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? AppDimensions.onboardingButtonWidth,
      height: height ?? AppDimensions.buttonHeight,
      child: Stack(
        children: [
          // Main Button Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isSecondary ? AppColors.surface : AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
              border: isSecondary 
                ? Border.all(color: AppColors.border, width: 1)
                : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                child: Center(
                  child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textOnPrimary,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         
                          Text(
                            text,
                            style: AppTextStyles.nextButton.copyWith(
                              color: isSecondary 
                                ? AppColors.textPrimary
                                : AppColors.textOnPrimary,
                            ),
                          ),
                        ],
                      ),
                ),
              ),
            ),
          ),
          
          // Icon Button (Arrow)
          if (!isLoading && !isSecondary)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                width: AppDimensions.buttonIconSize,
                height: AppDimensions.buttonIconSize,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.buttonIconRadius),
                  ),
                ),
                child: icon ?? const Icon(
                  Icons.arrow_forward,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}