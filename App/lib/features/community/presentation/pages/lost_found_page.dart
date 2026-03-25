import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/community_hub_models.dart';
import '../cubit/lost_found_cubit.dart';
import '../cubit/lost_found_state.dart';
import 'lost_found_detail_page.dart';
import 'create_lost_found_page.dart';

class LostFoundPage extends StatelessWidget {
  const LostFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LostFoundCubit, LostFoundState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<LostFoundCubit>(),
                    child: const CreateLostFoundPage(),
                  ),
                ),
              );
              if (created == true) {
                context.read<LostFoundCubit>().loadPosts();
              }
            },
            child: Icon(Icons.add, color: AppColors.accent, size: 28.sp),
          ),
          body: Column(
            children: [
              _buildFilterChips(context, state.filterType),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context, String? activeType) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Row(
        children: [
          _chip(context, 'All', null, activeType),
          SizedBox(width: 8.w),
          _chip(context, 'Lost', 'lost', activeType),
          SizedBox(width: 8.w),
          _chip(context, 'Found', 'found', activeType),
        ],
      ),
    );
  }

  Widget _chip(
      BuildContext context, String label, String? type, String? active) {
    final isActive = active == type;
    return GestureDetector(
      onTap: () => context.read<LostFoundCubit>().loadPosts(type: type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 13.sp,
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LostFoundState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => context.read<LostFoundCubit>().loadPosts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.sp, color: AppColors.textSecondary),
            SizedBox(height: 12.h),
            Text(
              'No lost & found posts yet',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () =>
          context.read<LostFoundCubit>().loadPosts(type: state.filterType),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: state.posts.length,
        itemBuilder: (context, index) =>
            _buildPostCard(context, state.posts[index]),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, LostFoundPost post) {
    final isLost = post.type == 'lost';
    final urgencyColor = _urgencyColor(post.urgency);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<LostFoundCubit>(),
              child: LostFoundDetailPage(postId: post.id),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type badge + urgency
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isLost
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isLost ? Icons.pets : Icons.check_circle_outline,
                    color: isLost ? AppColors.error : AppColors.success,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isLost ? 'LOST' : 'FOUND',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isLost ? AppColors.error : AppColors.success,
                    ),
                  ),
                  if (post.petType != null) ...[
                    SizedBox(width: 8.w),
                    Text(
                      '• ${post.petType}',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (post.urgency != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: urgencyColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        post.urgency!.toUpperCase(),
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: urgencyColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.petName != null)
                    Text(
                      post.petName!,
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  if (post.petName != null) SizedBox(height: 4.h),
                  Text(
                    post.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      if (post.lastSeenLocation != null) ...[
                        Icon(Icons.location_on_outlined,
                            size: 14.sp, color: AppColors.textSecondary),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            post.lastSeenLocation!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _timeAgo(post.createdAt),
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
