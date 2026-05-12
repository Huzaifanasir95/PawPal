import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.pets,
                        size: 80,
                        color: Theme.of(context).colorScheme.secondary,
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
                color: Theme.of(context).colorScheme.surface,
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
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Icon(
                          Icons.pets,
                          color: Theme.of(context).colorScheme.primary,
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
                        color: Theme.of(context).colorScheme.onSurface,
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 20.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Bottom indicator bar
                  Container(
                    width: AppDimensions.onboardingIndicatorWidth.w,
                    height: AppDimensions.onboardingIndicatorHeight.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
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
