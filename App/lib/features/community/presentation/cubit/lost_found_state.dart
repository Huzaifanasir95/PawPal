import '../../data/models/community_hub_models.dart';

class LostFoundState {
  final bool isLoading;
  final bool isCreating;
  final bool isLoadingDetail;
  final List<LostFoundPost> posts;
  final LostFoundPost? selectedPost;
  final String? filterType; // 'lost' or 'found'
  final String? error;

  const LostFoundState({
    this.isLoading = false,
    this.isCreating = false,
    this.isLoadingDetail = false,
    this.posts = const [],
    this.selectedPost,
    this.filterType,
    this.error,
  });

  LostFoundState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isLoadingDetail,
    List<LostFoundPost>? posts,
    LostFoundPost? selectedPost,
    String? filterType,
    String? error,
  }) {
    return LostFoundState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      posts: posts ?? this.posts,
      selectedPost: selectedPost ?? this.selectedPost,
      filterType: filterType ?? this.filterType,
      error: error,
    );
  }
}
