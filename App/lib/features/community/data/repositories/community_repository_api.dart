import 'dart:async';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/api_client.dart';
import '../models/post.dart';
import '../models/comment.dart';

@injectable
class CommunityRepositoryApi {
  final ApiClient _apiClient = ApiClient.instance;
  
  // Cache for broadcast stream controllers (broadcast allows multiple listeners)
  final Map<String, StreamController<List<Post>>> _postsStreamControllers = {};
  final Map<String, StreamController<List<Comment>>> _commentsStreamControllers = {};
  Timer? _postsRefreshTimer;
  Timer? _commentsRefreshTimer;

  // ==================== STREAM METHODS ====================

  /// Get posts as a stream that updates periodically
  Stream<List<Post>> getPostsStream({String sortBy = 'createdAt', bool descending = true, String? category}) {
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
    _loadPostsIntoStream(controller, sortBy: sortBy, descending: descending, category: category);
    
    // Refresh every 5 seconds
    _postsRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!controller.isClosed) {
        _loadPostsIntoStream(controller, sortBy: sortBy, descending: descending, category: category);
      }
    });
    
    return controller.stream;
  }
  
  Future<void> _loadPostsIntoStream(StreamController<List<Post>> controller, {required String sortBy, required bool descending, String? category}) async {
    try {
      final posts = await getPosts(category: category);
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
  
  Future<void> _loadCommentsIntoStream(StreamController<List<Comment>> controller, String postId) async {
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
  Future<List<Post>> getPosts({int page = 1, int limit = 10, String? category}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (category != null && category.isNotEmpty && category != 'all') {
        queryParams['category'] = category;
      }
      
      final response = await _apiClient.get(
        '/api/v1/posts',
        queryParameters: queryParams,
      );

      final List<dynamic> postsData = response.data['posts'] ?? [];
      return postsData.map((post) => Post.fromJson(post as Map<String, dynamic>)).toList();
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
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> postsData = response.data['posts'] ?? [];
      return postsData.map((post) => Post.fromJson(post as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get posts by specific user
  Future<List<Post>> getUserPosts(String userId, {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/posts/user/$userId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> postsData = response.data['posts'] ?? [];
      return postsData.map((post) => Post.fromJson(post as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get specific post by ID
  Future<Post?> getPostById(String postId) async {
    try {
      final response = await _apiClient.get('/api/v1/posts/$postId');
      return Post.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
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

      final response = await _apiClient.post('/api/v1/comments', data: commentData);
      return Comment.fromJson(response.data['comment'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get comments for a post
  Future<List<Comment>> getComments(String postId, {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/comments/post/$postId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> commentsData = response.data['comments'] ?? [];
      return commentsData.map((comment) => Comment.fromJson(comment as Map<String, dynamic>)).toList();
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
      final updateData = {
        'content': content,
      };

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
