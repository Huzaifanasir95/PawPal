import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF1F6F8),
              Color(0xFFDDE9EE),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12.r,
              offset: Offset(0, 5.h),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFB9CBD4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 24.r,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
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
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 24.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
