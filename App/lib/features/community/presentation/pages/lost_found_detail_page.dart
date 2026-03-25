import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/community_hub_models.dart';
import '../cubit/lost_found_cubit.dart';
import '../cubit/lost_found_state.dart';

class LostFoundDetailPage extends StatefulWidget {
  final String postId;
  const LostFoundDetailPage({super.key, required this.postId});

  @override
  State<LostFoundDetailPage> createState() => _LostFoundDetailPageState();
}

class _LostFoundDetailPageState extends State<LostFoundDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<LostFoundCubit>().loadPostDetail(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LostFoundCubit, LostFoundState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F6F2),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.accent, size: 24.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Details',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(LostFoundState state) {
    if (state.isLoadingDetail) {
      return const Center(child: CircularProgressIndicator());
    }
    final post = state.selectedPost;
    if (post == null) {
      return Center(
        child: Text(
          state.error ?? 'Post not found',
          style: TextStyle(fontSize: 14.sp),
        ),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeBadge(post),
          SizedBox(height: 16.h),
          if (post.petName != null) ...[
            Text(
              post.petName!,
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          // Pet info row
          if (post.petType != null || post.breed != null || post.color != null)
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (post.petType != null) _infoChip(Icons.pets, post.petType!),
                if (post.breed != null) _infoChip(Icons.category, post.breed!),
                if (post.color != null)
                  _infoChip(Icons.palette_outlined, post.color!),
              ],
            ),
          SizedBox(height: 20.h),
          // Description
          _sectionTitle('Description'),
          SizedBox(height: 8.h),
          Text(
            post.description,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 15.sp,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),
          // Location
          if (post.lastSeenLocation != null) ...[
            _sectionTitle('Last Seen Location'),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on,
                      color: AppColors.error, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      post.lastSeenLocation!,
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
          // Contact info
          if (post.contactPhone != null || post.contactEmail != null) ...[
            _sectionTitle('Contact Information'),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (post.contactPhone != null)
                    _contactRow(Icons.phone, post.contactPhone!),
                  if (post.contactPhone != null && post.contactEmail != null)
                    SizedBox(height: 8.h),
                  if (post.contactEmail != null)
                    _contactRow(Icons.email_outlined, post.contactEmail!),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
          // Posted by & time
          _sectionTitle('Posted by'),
          SizedBox(height: 8.h),
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary,
                backgroundImage: post.userAvatar != null
                    ? NetworkImage(post.userAvatar!)
                    : null,
                child: post.userAvatar == null
                    ? Icon(Icons.person, size: 20.sp)
                    : null,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.userName ?? 'Unknown',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _formatDate(post.createdAt),
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(LostFoundPost post) {
    final isLost = post.type == 'lost';
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isLost ? AppColors.error : AppColors.success,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            isLost ? 'LOST' : 'FOUND',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        if (post.urgency != null) ...[
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _urgencyColor(post.urgency).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${post.urgency!.toUpperCase()} URGENCY',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _urgencyColor(post.urgency),
              ),
            ),
          ),
        ],
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            post.status.toUpperCase(),
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF2C6E69)),
          SizedBox(width: 4.w),
          Text(
            text,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
              color: const Color(0xFF2C6E69),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.onboardingTitle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),
        SizedBox(width: 10.w),
        Text(
          text,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _urgencyColor(String? urgency) {
    switch (urgency) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
