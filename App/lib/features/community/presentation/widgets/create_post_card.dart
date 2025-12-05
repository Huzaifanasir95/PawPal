import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../pages/create_post_page.dart';

class CreatePostCard extends StatelessWidget {
  const CreatePostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreatePostPage(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                color: AppColors.surface,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            // Text and Icon
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share your thoughts...',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 16.sp,
                      color: const Color(0xFFA1A1A1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Start a conversation with the community',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: const Color(0xFFA1A1A1),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            // Add Icon
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                Icons.add,
                color: AppColors.surface,
                size: 24.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}