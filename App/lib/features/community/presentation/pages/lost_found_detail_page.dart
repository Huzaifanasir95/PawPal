import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<LostFoundCubit, LostFoundState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onPrimary,
                size: 24.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Details',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: colorScheme.onPrimary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final lostSurface = colorScheme.errorContainer;
    final foundSurface = colorScheme.primaryContainer;
    final shadowColor = colorScheme.shadow.withValues(alpha: 0.12);
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
                  color: post.type == 'lost' ? lostSurface : foundSurface,
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
                          color: colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor,
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
      color:
          isLost
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80.sp,
              color:
                  (isLost
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.3),
            ),
            SizedBox(height: 12.h),
            Text(
              'No image available',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(post) {
    final colorScheme = Theme.of(context).colorScheme;
    final shadowColor = colorScheme.shadow.withValues(alpha: 0.12);
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
              color: Theme.of(context).colorScheme.onSurface,
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
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
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
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Description',
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                post.description,
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 15.sp,
                  color: Theme.of(context).colorScheme.onSurface,
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
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
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
                        color: colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: colorScheme.error,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Last Seen Location',
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  post.lastSeenLocation!,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 15.sp,
                    color: Theme.of(context).colorScheme.onSurface,
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
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
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
                        color: colorScheme.tertiary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        color: colorScheme.tertiary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Contact Information',
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
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
                    colorScheme.tertiary,
                  ),
                ],
                if (post.contactPhone != null && post.contactEmail != null) 
                  SizedBox(height: 12.h),
                if (post.contactEmail != null) ...[
                  _contactActionRow(
                    Icons.email_outlined,
                    'Email',
                    post.contactEmail!,
                    Theme.of(context).colorScheme.primary,
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
              color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                  color: shadowColor,
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28.r,
                  backgroundColor: colorScheme.primary,
                  backgroundImage: post.userAvatar != null 
                      ? NetworkImage(post.userAvatar!) 
                      : null,
                  child: post.userAvatar == null 
                      ? Icon(Icons.person, size: 28.sp, color: colorScheme.onPrimary) 
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      post.userName ?? 'Anonymous User',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatDate(post.createdAt),
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
            color: isLost ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            isLost ? 'LOST' : 'FOUND',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color:
                  isLost
                      ? Theme.of(context).colorScheme.onError
                      : Theme.of(context).colorScheme.onTertiary,
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
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            post.status.toUpperCase(),
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 13.sp,
              color: Theme.of(context).colorScheme.onPrimary,
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 15.sp,
                    color: Theme.of(context).colorScheme.onSurface,
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
        return Theme.of(context).colorScheme.error;
      case 'medium':
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}


