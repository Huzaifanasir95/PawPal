import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../models/onboarding_page_config.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageConfig config;

  const OnboardingPageWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    final petConfig = config.petImageConfig;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Stack(
        children: [
          // Pet image (conditional rendering with flexible positioning)
          if (petConfig.showImage)
            Positioned(
              left: petConfig.left.w,
              top: (safePadding.top + petConfig.top).h,
              child: Container(
                width: petConfig.width.w,
                height: petConfig.height.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.asset(
                    petConfig.imagePath,
                    width: petConfig.width.w,
                    height: petConfig.height.h,
                    fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 431.w,
                      height: 419.h,
                      color: AppColors.primary,
                      child: const Icon(
                        Icons.pets,
                        size: 80,
                        color: AppColors.accent,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottom content container
          Positioned(  
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: AppDimensions.onboardingPageWidth.w,
              height: 437.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.onboardingContentRadius.r),
                  topRight: Radius.circular(AppDimensions.onboardingContentRadius.r),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  
                  // Logo before title
                  Image.asset(
                    config.logoImage,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Icon(
                          Icons.pets,
                          color: AppColors.primary,
                          size: 30.w,
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 10.h),
                  
                  // Title
                  Container(
                    width: 350.w,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      config.title,
                      style: AppTextStyles.onboardingTitle.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 32.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  SizedBox(height: 28.h),
                  
                  // Body text
                  Container(
                    width: 350.w,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      config.body,
                      style: AppTextStyles.onboardingBody.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 20.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Bottom indicator bar
                  Container(
                    width: AppDimensions.onboardingIndicatorWidth.w,
                    height: AppDimensions.onboardingIndicatorHeight.h,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppDimensions.onboardingIndicatorRadius.r),
                    ),
                  ),
                  
                  SizedBox(height: 17.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}