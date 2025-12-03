import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_drawer.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_card.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../../data/models/post.dart';
import 'post_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'createdAt';
  bool _descending = true;

  @override
  void initState() {
    super.initState();
    // Load posts when the page initializes
    context.read<CommunityBloc>().add(
      CommunityEvent.loadPosts(sortBy: _sortBy, descending: _descending),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityBloc, CommunityState>(
      listener: (context, state) {
        state.maybeWhen(
          initial: () {
            // Load posts when in initial state
            context.read<CommunityBloc>().add(
              CommunityEvent.loadPosts(sortBy: _sortBy, descending: _descending),
            );
          },
          error: (message) {
            CustomSnackbar.showError(context, message);
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF1F1F1), // Background color from design
          drawer: const CustomDrawer(),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: AppColors.accent,
                size: 24.sp,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: Text(
              'Community',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: state.maybeWhen(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (posts, comments, sortBy, descending, selectedPostId) =>
                _buildLoadedContent(posts),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $message'),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CommunityBloc>().add(
                          CommunityEvent.loadPosts(sortBy: _sortBy, descending: _descending),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              orElse: () => const Center(child: Text('Welcome to Community')),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: const Color(0xFFA1A1A1),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Community Page',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 32.sp,
            color: const Color(0xFF324B49),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // Search Box
        Expanded(
          child: Container(
            height: 58.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFA1A1A1),
                width: 1.w,
              ),
              borderRadius: BorderRadius.circular(47.r),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posts...',
                hintStyle: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: const Color(0xFFA1A1A1),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFFA1A1A1),
                  size: 17.w,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Filter Button
        Container(
          width: 49.w,
          height: 46.h,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(484.r),
          ),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'likes') {
                  _sortBy = 'likesCount';
                } else {
                  _sortBy = 'createdAt';
                }
              });
              context.read<CommunityBloc>().add(
                CommunityEvent.loadPosts(sortBy: _sortBy, descending: _descending),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'recent',
                child: Text('Most Recent'),
              ),
              const PopupMenuItem(
                value: 'likes',
                child: Text('Most Liked'),
              ),
            ],
            child: Icon(
              Icons.filter_list,
              color: AppColors.surface,
              size: 20.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedContent(List<Post> posts) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          SizedBox(height: 20.h),
          _buildHeader(),

          // Search and Filter Section
          SizedBox(height: 24.h),
          _buildSearchAndFilter(),

          // Create Post Card
          SizedBox(height: 20.h),
          const CreatePostCard(),

          // Posts Section
          SizedBox(height: 20.h),
          _buildPostsSection(posts),
        ],
      ),
    );
  }

  Widget _buildPostsSection(List<Post> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          'No posts yet. Be the first to share!',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: const Color(0xFFA1A1A1),
          ),
        ),
      );
    }

    return Column(
      children: posts.map((post) {
        return Column(
          children: [
            PostCard(
              post: post,
              onLike: () {
                context.read<CommunityBloc>().add(
                  CommunityEvent.likePost(post.id),
                );
              },
              onComment: (content) {
                context.read<CommunityBloc>().add(
                  CommunityEvent.addComment(
                    postId: post.id,
                    content: content,
                  ),
                );
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<CommunityBloc>(),
                      child: PostDetailPage(post: post),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
          ],
        );
      }).toList(),
    );
  }
}