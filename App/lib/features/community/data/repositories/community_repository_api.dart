import 'dart:async';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/api_client.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/community_advanced_models.dart';

@injectable
class CommunityRepositoryApi {
  final ApiClient _apiClient = ApiClient.instance;

  // Cache for broadcast stream controllers (broadcast allows multiple listeners)
  final Map<String, StreamController<List<Post>>> _postsStreamControllers = {};
  final Map<String, StreamController<List<Comment>>>
  _commentsStreamControllers = {};
  Timer? _postsRefreshTimer;
  Timer? _commentsRefreshTimer;

  // ==================== STREAM METHODS ====================

  /// Get posts as a stream that updates periodically
  Stream<List<Post>> getPostsStream({
    String sortBy = 'createdAt',
    bool descending = true,
    String? category,
  }) {
    final key = '$sortBy-$descending-${category ?? 'all'}';

    // Close existing stream controller if key changed
    if (_postsStreamControllers.containsKey(key)) {
      return _postsStreamControllers[key]!.stream;
    }

    // Close old timers when creating new stream with different parameters
    _postsRefreshTimer?.cancel();

    final controller = StreamController<List<Post>>.broadcast();
    _postsStreamControllers[key] = controller;

    // Initial load
    _loadPostsIntoStream(
      controller,
      sortBy: sortBy,
      descending: descending,
      category: category,
    );

    // Refresh every 5 seconds
    _postsRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!controller.isClosed) {
        _loadPostsIntoStream(
          controller,
          sortBy: sortBy,
          descending: descending,
          category: category,
        );
      }
    });

    return controller.stream;
  }

  Future<void> _loadPostsIntoStream(
    StreamController<List<Post>> controller, {
    required String sortBy,
    required bool descending,
    String? category,
  }) async {
    try {
      final posts = await getPosts(
        category: category,
        sortBy: sortBy,
        descending: descending,
      );
      if (!controller.isClosed) {
        controller.add(posts);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }

  /// Get comments for a specific post as a stream
  Stream<List<Comment>> getCommentsForPost(String postId) {
    // Return existing stream controller if it exists
    if (_commentsStreamControllers.containsKey(postId)) {
      return _commentsStreamControllers[postId]!.stream;
    }

    final controller = StreamController<List<Comment>>.broadcast();
    _commentsStreamControllers[postId] = controller;

    // Initial load
    _loadCommentsIntoStream(controller, postId);

    // Refresh every 3 seconds
    _commentsRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!controller.isClosed) {
        _loadCommentsIntoStream(controller, postId);
      }
    });

    return controller.stream;
  }

  Future<void> _loadCommentsIntoStream(
    StreamController<List<Comment>> controller,
    String postId,
  ) async {
    try {
      final comments = await getComments(postId);
      if (!controller.isClosed) {
        controller.add(comments);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }

  // ==================== POSTS OPERATIONS ====================

  /// Create a new post
  Future<Post> createPost({
    required String title,
    required String content,
    String category = 'general',
    List<String>? imageUrls,
  }) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final postData = {
        'title': title,
        'content': content,
        'category': category,
        if (imageUrls != null) 'imageUrls': imageUrls,
      };

      final response = await _apiClient.post('/api/v1/posts', data: postData);
      return Post.fromJson(response.data['post'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get all posts (feed)
  Future<List<Post>> getPosts({
    int page = 1,
    int limit = 10,
    String? category,
    String sortBy = 'createdAt',
    bool descending = true,
    String? hashtag,
  }) async {
    try {
      if (hashtag != null && hashtag.trim().isNotEmpty) {
        final cleanTag = hashtag.trim().replaceFirst('#', '');
        final response = await _apiClient.get(
          '/api/v1/community/hashtags/$cleanTag/posts',
          queryParameters: {'limit': limit, 'offset': (page - 1) * limit},
        );

        final List<dynamic> taggedPosts = response.data['posts'] ?? [];
        return taggedPosts
            .map((post) => Post.fromJson(post as Map<String, dynamic>))
            .toList();
      }

      var normalizedSortBy = sortBy;
      if (sortBy == 'createdAt') {
        normalizedSortBy = 'created_at';
      } else if (sortBy == 'likesCount') {
        normalizedSortBy = 'likes_count';
      } else if (sortBy == 'updatedAt') {
        normalizedSortBy = 'updated_at';
      }

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': normalizedSortBy,
        'descending': descending,
      };
      if (category != null && category.isNotEmpty && category != 'all') {
        queryParams['category'] = category;
      }

      final response = await _apiClient.get(
        '/api/v1/posts',
        queryParameters: queryParams,
      );

      final List<dynamic> postsData = response.data['posts'] ?? [];
      return postsData
          .map((post) => Post.fromJson(post as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get current user's posts
  Future<List<Post>> getMyPosts({int page = 1, int limit = 10}) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _apiClient.get(
        '/api/v1/posts/me',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> postsData = response.data['posts'] ?? [];
      return postsData
          .map((post) => Post.fromJson(post as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get posts by specific user
  Future<List<Post>> getUserPosts(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/posts/user/$userId',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> postsData = response.data['posts'] ?? [];
      return postsData
          .map((post) => Post.fromJson(post as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get specific post by ID
  Future<Post?> getPostById(String postId) async {
    try {
      final response = await _apiClient.get('/api/v1/posts/$postId');
      final postData = response.data['post'] as Map<String, dynamic>?;
      if (postData == null) return null;
      return Post.fromJson(postData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  // ==================== ADVANCED COMMUNITY ====================

  Future<List<Post>> getTrendingPosts({int limit = 20, int offset = 0}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/community/trending/posts',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final List<dynamic> postsData = response.data['posts'] ?? [];
      return postsData
          .map((post) => Post.fromJson(post as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<TrendingHashtag>> getTrendingHashtags({int limit = 12}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/community/trending/hashtags',
        queryParameters: {'limit': limit},
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .map((item) => TrendingHashtag.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<({List<CommunityGroup> groups, int total, int page, int limit})>
  getGroups({int page = 1, int limit = 20, String? query}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/community/groups',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
      );

      final List<dynamic> groupData = response.data['groups'] ?? [];
      final groups =
          groupData
              .map(
                (item) => CommunityGroup.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      final pagination = (response.data['pagination'] as Map?) ?? const {};

      return (
        groups: groups,
        total: (pagination['total'] as int?) ?? groups.length,
        page: (pagination['page'] as int?) ?? page,
        limit: (pagination['limit'] as int?) ?? limit,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<CommunityGroup>> getMyGroups() async {
    try {
      final response = await _apiClient.get('/api/v1/community/groups/me');
      final List<dynamic> groupData = response.data['groups'] ?? [];
      return groupData
          .map((item) => CommunityGroup.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<CommunityGroup> createGroup({
    required String name,
    String? description,
    String? icon,
    bool isPrivate = false,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/community/groups',
        data: {
          'name': name,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          if (icon != null && icon.trim().isNotEmpty) 'icon': icon.trim(),
          'isPrivate': isPrivate,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Failed to create group');
      }

      return CommunityGroup.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> joinGroup(String groupId) async {
    try {
      await _apiClient.post('/api/v1/community/groups/$groupId/join', data: {});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      await _apiClient.post(
        '/api/v1/community/groups/$groupId/leave',
        data: {},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> addPostToGroup({
    required String groupId,
    required String postId,
  }) async {
    try {
      await _apiClient.post(
        '/api/v1/community/groups/$groupId/posts',
        data: {'postId': postId},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Edit post (alias for updatePost)
  Future<void> editPost({
    required String postId,
    required String title,
    required String content,
    List<String>? imageUrls,
  }) => updatePost(
    postId: postId,
    title: title,
    content: content,
    imageUrls: imageUrls,
  );

  /// Update post
  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    List<String>? imageUrls,
  }) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final updateData = {
        'title': title,
        'content': content,
        if (imageUrls != null) 'imageUrls': imageUrls,
      };

      await _apiClient.put('/api/v1/posts/$postId', data: updateData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      await _apiClient.delete('/api/v1/posts/$postId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== COMMENTS OPERATIONS ====================

  /// Add a comment on a post (alias for createComment)
  Future<Comment> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) => createComment(
    postId: postId,
    content: content,
    parentCommentId: parentCommentId,
  );

  /// Create a comment on a post
  Future<Comment> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final commentData = {
        'postId': postId,
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      };

      final response = await _apiClient.post(
        '/api/v1/comments',
        data: commentData,
      );
      return Comment.fromJson(response.data['comment'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get comments for a post
  Future<List<Comment>> getComments(
    String postId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/comments/post/$postId',
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> commentsData = response.data['comments'] ?? [];
      return commentsData
          .map((comment) => Comment.fromJson(comment as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Edit a comment
  Future<void> editComment({
    required String commentId,
    required String content,
  }) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final updateData = {'content': content};

      await _apiClient.put('/api/v1/comments/$commentId', data: updateData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      await _apiClient.delete('/api/v1/comments/$commentId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== LIKES OPERATIONS ====================

  /// Toggle like on post (alias for compatibility with BLoC)
  Future<void> toggleLike(String postId) => togglePostLike(postId);

  /// Toggle like on post
  Future<void> togglePostLike(String postId) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      await _apiClient.post('/api/v1/posts/$postId/like', data: {});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Check if current user liked a post
  Future<bool> hasUserLikedPost(String postId) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _apiClient.get('/api/v1/posts/$postId/liked');
      return response.data['liked'] as bool? ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Toggle like on comment
  Future<void> toggleCommentLike(String commentId) async {
    if (!_apiClient.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      await _apiClient.post('/api/v1/comments/$commentId/like', data: {});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Error handler
  String _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'] as String;
      }
    }
    return error.message ?? 'An error occurred';
  }

  /// Cleanup resources
  void dispose() {
    _postsRefreshTimer?.cancel();
    _commentsRefreshTimer?.cancel();

    for (var controller in _postsStreamControllers.values) {
      controller.close();
    }
    for (var controller in _commentsStreamControllers.values) {
      controller.close();
    }

    _postsStreamControllers.clear();
    _commentsStreamControllers.clear();
  }
}
