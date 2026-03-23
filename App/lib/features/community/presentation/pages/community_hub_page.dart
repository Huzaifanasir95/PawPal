import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_drawer.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/post.dart';
import '../../data/repositories/community_hub_repository.dart';
import '../cubit/lost_found_cubit.dart';
import '../cubit/adoption_cubit.dart';
import '../cubit/events_cubit.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_card.dart';
import 'post_detail_page.dart';
import 'lost_found_page.dart';
import 'adoption_page.dart';
import 'events_page.dart';

class CommunityHubPage extends StatelessWidget {
  const CommunityHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = CommunityHubRepository.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LostFoundCubit(repo)..loadPosts()),
        BlocProvider(create: (_) => AdoptionCubit(repo)..loadListings()),
        BlocProvider(create: (_) => EventsCubit(repo)..loadEvents()),
      ],
      child: const _CommunityHubView(),
    );
  }
}

class _CommunityHubView extends StatefulWidget {
  const _CommunityHubView();

  @override
  State<_CommunityHubView> createState() => _CommunityHubViewState();
}

class _CommunityHubViewState extends State<_CommunityHubView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F6F2),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.accent, size: 24.sp),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Community Hub',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.onboardingBody.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.onboardingBody.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Forum'),
            Tab(text: 'Lost & Found'),
            Tab(text: 'Adoption'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ForumTab(),
          LostFoundPage(),
          AdoptionPage(),
          EventsPage(),
        ],
      ),
    );
  }
}

/// Embeds the existing community forum posts feed as a tab
class _ForumTab extends StatefulWidget {
  const _ForumTab();

  @override
  State<_ForumTab> createState() => _ForumTabState();
}

class _ForumTabState extends State<_ForumTab> {
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    try {
      context.read<CommunityBloc>().add(
            const CommunityEvent.loadPosts(
                sortBy: 'createdAt', descending: true),
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityBloc, CommunityState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) => CustomSnackbar.showError(context, message),
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (posts, comments, sortBy, descending, selectedPostId) =>
              _buildForumContent(posts),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $message'),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: _loadPosts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          orElse: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildForumContent(List<Post> posts) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          const CreatePostCard(),
          SizedBox(height: 16.h),
          if (posts.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: Text(
                  'No posts yet. Be the first to share!',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...posts.map((post) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: PostCard(
                    post: post,
                    onLike: () {
                      context
                          .read<CommunityBloc>()
                          .add(CommunityEvent.likePost(post.id));
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
                          builder: (ctx) => BlocProvider.value(
                            value: context.read<CommunityBloc>(),
                            child: PostDetailPage(post: post),
                          ),
                        ),
                      );
                    },
                  ),
                )),
        ],
      ),
    );
  }
}
