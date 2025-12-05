import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final bool isReply;

  const CommentCard({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 48.w : 0,
        top: 8.h,
        bottom: 8.h,
      ),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isReply ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Header
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary,
                child: Text(
                  comment.userName?.isNotEmpty == true
                      ? comment.userName![0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.onboardingBody.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // User name and timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName ?? 'Anonymous User',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF324B49),
                      ),
                    ),
                    Text(
                      _formatTimestamp(comment.createdAt),
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 10.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Comment Content
          Text(
            comment.content,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: const Color(0xFF324B49),
              height: 1.4,
            ),
          ),

          SizedBox(height: 8.h),

          // Action Buttons
          Row(
            children: [
              // Like Button
              InkWell(
                onTap: onLike,
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: comment.likesCount > 0 ? Colors.red : Colors.grey,
                        size: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${comment.likesCount}',
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 12.sp,
                          color: comment.likesCount > 0 ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // Reply Button (only for top-level comments)
              if (!isReply && onReply != null)
                InkWell(
                  onTap: onReply,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    child: Text(
                      'Reply',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}