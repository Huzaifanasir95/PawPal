import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            backgroundColor: Theme.of(context).colorScheme.primary,
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
            child: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary, size: 28.sp),
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
          color: isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 13.sp,
            color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
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
            Icon(Icons.search_off, size: 64.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            SizedBox(height: 12.h),
            Text(
              'No lost & found posts yet',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Info Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Image
                if (post.imageUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                    ),
                    child: Image.network(
                      post.imageUrls.first,
                      width: 120.w,
                      height: 140.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120.w,
                        height: 140.h,
                        color: isLost ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.pets,
                          size: 40.sp,
                          color: isLost ? Theme.of(context).colorScheme.error.withOpacity(0.5) : Colors.green.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 120.w,
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: isLost ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        bottomLeft: Radius.circular(16.r),
                      ),
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 40.sp,
                      color: isLost ? Theme.of(context).colorScheme.error.withOpacity(0.5) : Colors.green.withOpacity(0.5),
                    ),
                  ),
                // Info section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type badge + urgency row
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: isLost ? Theme.of(context).colorScheme.error : Colors.green,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                isLost ? 'LOST' : 'FOUND',
                                style: AppTextStyles.onboardingBody.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (post.petType != null) ...[
                              SizedBox(width: 6.w),
                              Text(
                                '• ${post.petType}',
                                style: AppTextStyles.onboardingBody.copyWith(
                                  fontSize: 12.sp,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: urgencyColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                post.urgency.toUpperCase(),
                                style: AppTextStyles.onboardingBody.copyWith(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: urgencyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        // Pet name
                        if (post.petName != null)
                          Text(
                            post.petName!,
                            style: AppTextStyles.onboardingTitle.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        SizedBox(height: 4.h),
                        // Description
                        Text(
                          post.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Location + time
                        Row(
                          children: [
                            if (post.lastSeenLocation != null) ...[
                              Icon(Icons.location_on_outlined,
                                  size: 12.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  post.lastSeenLocation!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 11.sp,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                            Text(
                              _timeAgo(post.createdAt),
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 11.sp,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}


