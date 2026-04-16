import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
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
  final int initialTabIndex;

  const CommunityHubPage({
    super.key,
    this.initialTabIndex = 0,
  });

  int _normalizedTabIndex() {
    if (initialTabIndex < 0) return 0;
    if (initialTabIndex > 3) return 3;
    return initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final repo = CommunityHubRepository.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LostFoundCubit(repo)..loadPosts()),
        BlocProvider(create: (_) => AdoptionCubit(repo)..loadListings()),
        BlocProvider(create: (_) => EventsCubit(repo)..loadEvents()),
      ],
      child: _CommunityHubView(initialTabIndex: _normalizedTabIndex()),
    );
  }
}

class _CommunityHubView extends StatefulWidget {
  final int initialTabIndex;

  const _CommunityHubView({required this.initialTabIndex});

  @override
  State<_CommunityHubView> createState() => _CommunityHubViewState();
}

class _CommunityHubViewState extends State<_CommunityHubView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? colorScheme.surfaceContainerHighest : colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDark
                    ? colorScheme.onSurface
                    : colorScheme.onPrimary,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Community Hub',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color:
                isDark
                    ? colorScheme.onSurface
                    : colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicatorColor:
              isDark ? colorScheme.primary : colorScheme.onPrimary,
          indicatorWeight: 2.6,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor:
              isDark ? colorScheme.onSurface : colorScheme.onPrimary,
          unselectedLabelColor:
              (isDark ? colorScheme.onSurface : colorScheme.onPrimary)
                  .withValues(alpha: 0.68),
          labelStyle: AppTextStyles.onboardingBody.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTextStyles.onboardingBody.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
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
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = PostCategory.all;
  String _selectedDateFilter = 'all_time';

  static const Map<String, String> _dateFilterLabels = {
    'all_time': 'All Time',
    'today': 'Today',
    'this_week': 'This Week',
    'this_month': 'This Month',
  };

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          loaded: (posts, comments, sortBy, descending, category, selectedPostId) =>
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
    final filteredPosts = _applyFilters(posts);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDark
                  ? <Color>[
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest,
                  ]
                  : const <Color>[
                    Color(0xFFDDE8ED),
                    Color(0xFFD2DEE5),
                  ],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? <Color>[
                            colorScheme.surfaceContainer,
                            colorScheme.surfaceContainerHighest,
                          ]
                          : const <Color>[
                            Color(0xFFF1F6F8),
                            Color(0xFFDDE9EE),
                          ],
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color:
                      isDark
                          ? colorScheme.outline.withValues(alpha: 0.35)
                          : const Color(0xFFB9CBD4),
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search forum posts',
                      hintStyle: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 13.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.primary,
                        size: 20.sp,
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? colorScheme.surface.withValues(alpha: 0.75)
                              : Colors.white.withValues(alpha: 0.78),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.35),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.35),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterDropdown(
                          label: 'Category',
                          value: _selectedCategory,
                          items: PostCategory.values,
                          itemLabelBuilder: _categoryLabel,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedCategory = value);
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildFilterDropdown(
                          label: 'Date',
                          value: _selectedDateFilter,
                          items: _dateFilterLabels.keys.toList(),
                          itemLabelBuilder: (value) => _dateFilterLabels[value]!,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedDateFilter = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            const CreatePostCard(),
            SizedBox(height: 14.h),
            if (filteredPosts.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: Text(
                    'No posts found for current filters.',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 16.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...filteredPosts.map(
                (post) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
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
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Post> _applyFilters(List<Post> posts) {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();

    return posts.where((post) {
      final matchesSearch =
          query.isEmpty ||
          post.title.toLowerCase().contains(query) ||
          post.content.toLowerCase().contains(query) ||
          (post.userName ?? '').toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == PostCategory.all ||
          post.category == _selectedCategory;

      bool matchesDate = true;
      if (_selectedDateFilter == 'today') {
        matchesDate = post.createdAt.year == now.year &&
            post.createdAt.month == now.month &&
            post.createdAt.day == now.day;
      } else if (_selectedDateFilter == 'this_week') {
        final weekAgo = now.subtract(const Duration(days: 7));
        matchesDate = post.createdAt.isAfter(weekAgo);
      } else if (_selectedDateFilter == 'this_month') {
        matchesDate = post.createdAt.year == now.year &&
            post.createdAt.month == now.month;
      }

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }

  String _categoryLabel(String category) {
    switch (category) {
      case PostCategory.all:
        return 'All';
      case PostCategory.general:
        return 'General';
      case PostCategory.dogs:
        return 'Dogs';
      case PostCategory.cats:
        return 'Cats';
      case PostCategory.health:
        return 'Health';
      case PostCategory.training:
        return 'Training';
      case PostCategory.nutrition:
        return 'Nutrition';
      case PostCategory.funny:
        return 'Funny';
      case PostCategory.questions:
        return 'Questions';
      default:
        return category;
    }
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required String Function(String value) itemLabelBuilder,
    required ValueChanged<String?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color:
            isDark
                ? colorScheme.surface.withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.32),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 12.sp,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18.sp,
            color: colorScheme.onSurfaceVariant,
          ),
          onChanged: onChanged,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text('$label: ${itemLabelBuilder(item)}'),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
