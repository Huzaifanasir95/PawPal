import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_drawer.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_card.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../../data/models/post.dart';
import '../../data/models/community_advanced_models.dart';
import '../../data/repositories/community_repository_api.dart';
import 'post_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final CommunityRepositoryApi _communityApi = CommunityRepositoryApi();
  String _sortBy = 'createdAt';
  final bool _descending = true;
  String _selectedCategory = PostCategory.all;
  String _searchQuery = '';
  List<TrendingHashtag> _trendingHashtags = const [];
  List<CommunityGroup> _groups = const [];
  bool _isLoadingCommunityMeta = false;

  @override
  void initState() {
    super.initState();
    // Load posts when the page initializes
    _loadPosts();
    _loadCommunityMeta();
  }

  void _loadPosts() {
    context.read<CommunityBloc>().add(
      CommunityEvent.loadPosts(
        sortBy: _sortBy,
        descending: _descending,
        category:
            _selectedCategory == PostCategory.all ? null : _selectedCategory,
      ),
    );
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _loadPosts();
  }

  Future<void> _loadCommunityMeta() async {
    if (_isLoadingCommunityMeta) return;
    setState(() => _isLoadingCommunityMeta = true);

    try {
      final hashtags = await _communityApi.getTrendingHashtags(limit: 10);
      final groupsResult = await _communityApi.getGroups(limit: 10);

      if (!mounted) return;

      setState(() {
        _trendingHashtags = hashtags;
        _groups = groupsResult.groups;
      });
    } catch (_) {
      // Keep feed usable even if metadata fails.
    } finally {
      if (mounted) {
        setState(() => _isLoadingCommunityMeta = false);
      }
    }
  }

  Future<void> _toggleGroupMembership(CommunityGroup group) async {
    try {
      if (group.isMember) {
        await _communityApi.leaveGroup(group.id);
        if (!mounted) return;
        CustomSnackbar.showSuccess(context, 'Left ${group.name}');
      } else {
        await _communityApi.joinGroup(group.id);
        if (!mounted) return;
        CustomSnackbar.showSuccess(context, 'Joined ${group.name}');
      }
      await _loadCommunityMeta();
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
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
              CommunityEvent.loadPosts(
                sortBy: _sortBy,
                descending: _descending,
              ),
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: const CustomDrawer(),
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onPrimary, size: 24.sp),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: Text(
              'Community',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: state.maybeWhen(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded:
                  (
                    posts,
                    comments,
                    sortBy,
                    descending,
                    category,
                    selectedPostId,
                  ) => _buildLoadedContent(posts),
              error:
                  (message) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $message'),
                        ElevatedButton(
                          onPressed: _loadPosts,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to the',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Community Page',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 32.sp,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Search Box
        Expanded(
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline.withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Row(
              children: [
                SizedBox(width: 16.w),
                Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search posts...',
                      hintStyle: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Filter Button
        Container(
          width: 46.w,
          height: 46.h,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(23.r),
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
                CommunityEvent.loadPosts(
                  sortBy: _sortBy,
                  descending: _descending,
                ),
              );
            },
            itemBuilder:
                (context) => [
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
              color: colorScheme.onPrimary,
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

          // Category Filter Chips
          SizedBox(height: 16.h),
          _buildCategoryChips(),

          // Trending hashtags
          SizedBox(height: 16.h),
          _buildTrendingHashtags(),

          // Groups
          SizedBox(height: 16.h),
          _buildGroupsSection(),

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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: PostCategory.values.length,
        itemBuilder: (context, index) {
          final category = PostCategory.values[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(
                PostCategory.getLabel(category),
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 12.sp,
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _onCategorySelected(category),
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primary,
              checkmarkColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color:
                      isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingHashtags() {
    if (_trendingHashtags.isEmpty) {
      if (_isLoadingCommunityMeta) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Hashtags',
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children:
              _trendingHashtags.map((trend) {
                final isSelected =
                    _searchQuery.isNotEmpty &&
                    _searchQuery == trend.tag.toLowerCase();

                return ActionChip(
                  label: Text(
                    '${trend.tag} (${trend.usageCount})',
                    style: AppTextStyles.labelSmall.copyWith(
                      color:
                          isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  backgroundColor:
                      isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                  side: BorderSide(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: () {
                    final value = trend.tag.toLowerCase();
                    _searchController.text = trend.tag;
                    setState(() => _searchQuery = value);
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildGroupsSection() {
    if (_groups.isEmpty) {
      if (_isLoadingCommunityMeta) {
        return const SizedBox.shrink();
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Popular Groups',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _loadCommunityMeta,
              child: const Text('Refresh'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 120.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _groups.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final group = _groups[index];
              return Container(
                width: 210.w,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${group.membersCount} members',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (group.description != null &&
                        group.description!.isNotEmpty)
                      Text(
                        group.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 30.h,
                        child: ElevatedButton(
                          onPressed: () => _toggleGroupMembership(group),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                group.isMember
                                    ? Colors.grey.shade300
                                    : Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                group.isMember
                                    ? const Color(0xFF324B49)
                                    : Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                          ),
                          child: Text(group.isMember ? 'Joined' : 'Join'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostsSection(List<Post> posts) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredPosts =
        query.isEmpty
            ? posts
            : posts.where((post) {
              final haystack =
                  [
                    post.title,
                    post.content,
                    post.category,
                    post.userName ?? '',
                  ].join(' ').toLowerCase();

              if (query.startsWith('#')) {
                return haystack.contains(query);
              }

              return haystack.contains(query);
            }).toList();

    if (posts.isEmpty) {
      return Center(
        child: Text(
          'No posts yet. Be the first to share!',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (filteredPosts.isEmpty) {
      return Center(
        child: Text(
          'No posts matched your search.',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 15.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children:
          filteredPosts.map((post) {
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
                        builder:
                            (context) => BlocProvider.value(
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

