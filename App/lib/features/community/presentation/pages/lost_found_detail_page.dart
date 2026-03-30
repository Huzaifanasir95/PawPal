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
              // Gradient overlay for better badge visibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                ),
              ),
              // Status badges at top
              Positioned(
                top: 16.h,
                left: 16.w,
                right: 16.w,
                child: _buildTypeBadge(post),
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
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
        ],
        // Pet info chips
        if (post.petType != null || post.breed != null || post.color != null)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (post.petType != null) _infoChip(Icons.pets, post.petType!),
              if (post.breed != null) _infoChip(Icons.category, post.breed!),
              if (post.color != null) _infoChip(Icons.palette_outlined, post.color!),
            ],
          ),
        SizedBox(height: 24.h),
        // Description
        _sectionTitle('Description'),
        SizedBox(height: 12.h),
        Text(
          post.description,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 15.sp,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24.h),
        // Location
        if (post.lastSeenLocation != null) ...[
          _sectionTitle('Last Seen Location'),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors.error, size: 22.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    post.lastSeenLocation!,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
        // Contact info
        if (post.contactPhone != null || post.contactEmail != null) ...[
          _sectionTitle('Contact Information'),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                if (post.contactPhone != null) _contactRow(Icons.phone, post.contactPhone!),
                if (post.contactPhone != null && post.contactEmail != null) SizedBox(height: 12.h),
                if (post.contactEmail != null) _contactRow(Icons.email_outlined, post.contactEmail!),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
        // Posted by
        _sectionTitle('Posted by'),
        SizedBox(height: 12.h),
        Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.primary,
              backgroundImage: post.userAvatar != null ? NetworkImage(post.userAvatar!) : null,
              child: post.userAvatar == null ? Icon(Icons.person, size: 24.sp, color: Colors.white) : null,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName ?? 'Unknown',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
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
          ],
        ),
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
