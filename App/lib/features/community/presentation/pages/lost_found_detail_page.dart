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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image Section
          Stack(
            children: [
              // Image or placeholder
              Container(
                height: 280.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: post.type == 'lost' 
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFE8F5E9),
                ),
                child: post.imageUrls.isNotEmpty
                    ? PageView.builder(
                        itemCount: post.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            post.imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(post),
                          );
                        },
                      )
                    : _buildPlaceholder(post),
              ),
              // Image indicators at bottom
              if (post.imageUrls.length > 1)
                Positioned(
                  bottom: 12.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      post.imageUrls.length,
                      (index) => Container(
                        width: 8.w,
                        height: 8.h,
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Status badges below image
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: _buildTypeBadge(post),
          ),
          // Content section
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContentSection(post),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(post) {
    final isLost = post.type == 'lost';
    return Container(
      color: isLost ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80.sp,
              color: (isLost ? AppColors.error : AppColors.success).withOpacity(0.3),
            ),
            SizedBox(height: 12.h),
            Text(
              'No image available',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pet name
        if (post.petName != null) ...[
          Text(
            post.petName!,
            style: AppTextStyles.onboardingTitle.copyWith(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 16.h),
        ],
        // Pet info chips
        if (post.petType != null || post.breed != null || post.color != null)
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              if (post.petType != null) _infoChip(Icons.pets, post.petType!),
              if (post.breed != null) _infoChip(Icons.category, post.breed!),
              if (post.color != null) _infoChip(Icons.palette_outlined, post.color!),
            ],
          ),
        SizedBox(height: 32.h),
        // Description Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Description',
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                post.description,
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        // Location Card
        if (post.lastSeenLocation != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.error,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Last Seen Location',
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  post.lastSeenLocation!,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
        // Contact info Card
        if (post.contactPhone != null || post.contactEmail != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        color: AppColors.success,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Contact Information',
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                if (post.contactPhone != null) ...[
                  _contactActionRow(
                    Icons.phone,
                    'Phone',
                    post.contactPhone!,
                    AppColors.success,
                  ),
                ],
                if (post.contactPhone != null && post.contactEmail != null) 
                  SizedBox(height: 12.h),
                if (post.contactEmail != null) ...[
                  _contactActionRow(
                    Icons.email_outlined,
                    'Email',
                    post.contactEmail!,
                    AppColors.info,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
        // Posted by Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.primary,
                  backgroundImage: post.userAvatar != null 
                      ? NetworkImage(post.userAvatar!) 
                      : null,
                  child: post.userAvatar == null 
                      ? Icon(Icons.person, size: 28.sp, color: Colors.white) 
                      : null,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posted by',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      post.userName ?? 'Anonymous User',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatDate(post.createdAt),
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
      ],
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
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _urgencyColor(post.urgency).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '${post.urgency.toUpperCase()} URGENCY',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: _urgencyColor(post.urgency),
            ),
          ),
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            text,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 13.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactActionRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: color),
        ],
      ),
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
