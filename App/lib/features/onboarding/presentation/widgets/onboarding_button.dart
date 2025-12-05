import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';

class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isNext;

  const OnboardingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: ResponsiveUtils.screenWidth(context) * 0.859, // 335px / 390px
        height: AppDimensions.buttonHeight.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius.r),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Next text
            Positioned(
              left: ResponsiveUtils.screenWidth(context) * 0.07, // Approximate left position
              child: Text(
                text,
                style: AppTextStyles.nextButton.copyWith(
                  color: AppColors.textOnPrimary,
                  fontSize: 24.sp,
                ),
              ),
            ),
            // Icon container
            if (isNext)
              Positioned(
                right: ResponsiveUtils.screenWidth(context) * 0.013, // 4px from right
                child: Container(
                  width: AppDimensions.buttonIconSize.w,
                  height: AppDimensions.buttonIconSize.h,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppDimensions.buttonIconRadius.r),
                  ),
                  child: Transform.rotate(
                    angle: -0.27, // -15.5 degrees in radians
                    child: Icon(
                      Icons.pets,
                      color: AppColors.primary,
                      size: 24.w,
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