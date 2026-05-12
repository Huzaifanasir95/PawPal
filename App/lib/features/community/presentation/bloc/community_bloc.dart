import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pawpal/features/community/data/models/post.dart';

import '../../data/models/comment.dart';
import '../../data/repositories/community_repository_api.dart';
import 'community_event.dart';
import 'community_state.dart';

@injectable
class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepositoryApi _repository;
  StreamSubscription<List<Comment>>? _commentsSubscription;
  
  // Track pending like operations to prevent double-tap issues
  final Set<String> _pendingPostLikes = {};
  final Set<String> _pendingCommentLikes = {};
  
  // Track optimistic like states (true = liked, false = unliked)
  final Map<String, bool> _optimisticPostLikes = {};
  final Map<String, bool> _optimisticCommentLikes = {};

  CommunityBloc(this._repository) : super(const CommunityState.initial()) {
    on<CommunityEvent>((event, emit) async {
      await event.map(
        loadPosts: (e) => _onLoadPosts(e, emit),
        createPost: (e) => _onCreatePost(e, emit),
        likePost: (e) => _onLikePost(e, emit),
        addComment: (e) => _onAddComment(e, emit),
        likeComment: (e) => _onLikeComment(e, emit),
        editPost: (e) => _onEditPost(e, emit),
        deletePost: (e) => _onDeletePost(e, emit),
        editComment: (e) => _onEditComment(e, emit),
        deleteComment: (e) => _onDeleteComment(e, emit),
        loadComments: (e) => _onLoadComments(e, emit),
        commentsUpdated: (e) => _onCommentsUpdated(e, emit),
        postsUpdated: (e) async {}, // No-op, handled by emit.forEach in loadPosts
      );
    });
  }

  dynamic _onLoadPosts(dynamic event, Emitter<CommunityState> emit) {
    emit(const CommunityState.loading());
    return emit.forEach<List<Post>>(
      _repository.getPostsStream(sortBy: event.sortBy, descending: event.descending, category: event.category),
      onData: (posts) => CommunityState.loaded(
        posts: posts,
        comments: state.maybeWhen(
          loaded: (_, comments, __, ___, _____, ______) => comments,
          orElse: () => const [],
        ),
        sortBy: event.sortBy,
        descending: event.descending,
        category: event.category,
        selectedPostId: state.maybeWhen(
          loaded: (_, __, ___, ____, _____, selectedPostId) => selectedPostId,
          orElse: () => null,
        ),
      ),
      onError: (error, stackTrace) => CommunityState.error(error.toString()),
    );
  }

  Future<void> _onCreatePost(dynamic event, Emitter<CommunityState> emit) async {
    try {
      await _repository.createPost(
        title: event.title,
        content: event.content,
        category: event.category,
        imageUrls: event.imageUrls,
      );
      // Post creation will be reflected through the stream
    } catch (e) {
      emit(CommunityState.error(e.toString()));
    }
  }

  Future<void> _onLikePost(dynamic event, Emitter<CommunityState> emit) async {
    // Prevent duplicate like requests
    if (_pendingPostLikes.contains(event.postId)) {
      return;
    }

    _pendingPostLikes.add(event.postId);

    try {
      // Get current posts for optimistic updates
      final currentPosts = state.maybeWhen(
        loaded: (posts, _, __, ___, ____, _____) => posts,
        orElse: () => <Post>[],
      );

      if (currentPosts.isEmpty) {
        _pendingPostLikes.remove(event.postId);
        return;
      }

      // Get other state data
      final currentComments = state.maybeWhen(
        loaded: (_, comments, __, ___, ____, _____) => comments,
        orElse: () => <Comment>[],
      );

      final currentSortBy = state.maybeWhen(
        loaded: (_, __, sortBy, ___, ____, _____) => sortBy,
        orElse: () => 'createdAt',
      );

      final currentDescending = state.maybeWhen(
        loaded: (_, __, ___, descending, ____, _____) => descending,
        orElse: () => true,
      );

      final currentCategory = state.maybeWhen(
        loaded: (_, __, ___, ____, category, _____) => category,
        orElse: () => null,
      );

      final currentSelectedPostId = state.maybeWhen(
        loaded: (_, __, ___, ____, _____, selectedPostId) => selectedPostId,
        orElse: () => null,
      );

      // Find the post and check if it's currently liked
      final currentPost = currentPosts.firstWhere((p) => p.id == event.postId);
      final currentLikesCount = currentPost.likesCount;
      
      // Determine if we're liking or unliking based on optimistic state
      // If we have an optimistic state, use that, otherwise assume we're liking
      final currentlyLiked = _optimisticPostLikes[event.postId] ?? false;
      final willBeLiked = !currentlyLiked;
      
      // Update optimistic state
      _optimisticPostLikes[event.postId] = willBeLiked;
      
      // Calculate new count based on the toggle
      final newCount = willBeLiked 
          ? currentLikesCount + 1 
          : (currentLikesCount > 0 ? currentLikesCount - 1 : 0);
      
      // Optimistic update with correct count
      final optimisticPosts = currentPosts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(likesCount: newCount);
        }
        return post;
      }).toList();

      emit(CommunityState.loaded(
        posts: optimisticPosts,
        comments: currentComments,
        sortBy: currentSortBy,
        descending: currentDescending,
        category: currentCategory,
        selectedPostId: currentSelectedPostId,
      ));

      // Perform the actual like operation
      await _repository.toggleLike(event.postId);
    } catch (e) {
      // Revert optimistic state on error
      _optimisticPostLikes.remove(event.postId);
    } finally {
      _pendingPostLikes.remove(event.postId);
    }
  }

  Future<void> _onAddComment(dynamic event, Emitter<CommunityState> emit) async {
    try {
      await _repository.addComment(
        postId: event.postId,
        content: event.content,
        parentCommentId: event.parentCommentId,
      );
      // Comment changes will be reflected through the stream automatically
    } catch (e) {
      emit(CommunityState.error(e.toString()));
    }
  }

  Future<void> _onLikeComment(dynamic event, Emitter<CommunityState> emit) async {
    // Prevent duplicate like requests
    if (_pendingCommentLikes.contains(event.commentId)) {
      return;
    }

    _pendingCommentLikes.add(event.commentId);

    try {
      // Get current comments for optimistic updates
      final currentComments = state.maybeWhen(
        loaded: (_, comments, __, ___, ____, _____) => comments,
        orElse: () => <Comment>[],
      );

      if (currentComments.isEmpty) {
        _pendingCommentLikes.remove(event.commentId);
        return;
      }

      // Get other state data
      final currentPosts = state.maybeWhen(
        loaded: (posts, _, __, ___, ____, _____) => posts,
        orElse: () => <Post>[],
      );

      final currentSortBy = state.maybeWhen(
        loaded: (_, __, sortBy, ___, ____, _____) => sortBy,
        orElse: () => 'createdAt',
      );

      final currentDescending = state.maybeWhen(
        loaded: (_, __, ___, descending2, ____, _____) => descending2,
        orElse: () => true,
      );

      final currentCategory2 = state.maybeWhen(
        loaded: (_, __, ___, ____, category2, _____) => category2,
        orElse: () => null,
      );

      final currentSelectedPostId = state.maybeWhen(
        loaded: (_, __, ___, ____, _____, selectedPostId2) => selectedPostId2,
        orElse: () => null,
      );

      // Find the comment
      final currentComment = currentComments.firstWhere((c) => c.id == event.commentId);
      final currentLikesCount = currentComment.likesCount;

      // Determine if we're liking or unliking based on optimistic state
      final currentlyLiked = _optimisticCommentLikes[event.commentId] ?? false;
      final willBeLiked = !currentlyLiked;
      
      // Update optimistic state
      _optimisticCommentLikes[event.commentId] = willBeLiked;
      
      // Calculate new count based on the toggle
      final newCount = willBeLiked 
          ? currentLikesCount + 1 
          : (currentLikesCount > 0 ? currentLikesCount - 1 : 0);

      // Optimistic update with correct count
      final optimisticComments = currentComments.map((comment) {
        if (comment.id == event.commentId) {
          return comment.copyWith(likesCount: newCount);
        }
        return comment;
      }).toList();

      emit(CommunityState.loaded(
        posts: currentPosts,
        comments: optimisticComments,
        sortBy: currentSortBy,
        descending: currentDescending,
        category: currentCategory2,
        selectedPostId: currentSelectedPostId,
      ));

      // Perform the actual like operation
      await _repository.toggleCommentLike(event.commentId);
    } catch (e) {
      // Revert optimistic state on error
      _optimisticCommentLikes.remove(event.commentId);
    } finally {
      _pendingCommentLikes.remove(event.commentId);
    }
  }

  Future<void> _onEditPost(dynamic event, Emitter<CommunityState> emit) async {
    try {
      await _repository.editPost(
        postId: event.postId,
        title: event.title,
        content: event.content,
      );
      // Post edit will be reflected through the stream
    } catch (e) {
      emit(CommunityState.error(e.toString()));
    }
  }

  Future<void> _onDeletePost(dynamic event, Emitter<CommunityState> emit) async {
    try {
      await _repository.deletePost(event.postId);
      // Post deletion will be reflected through the stream
    } catch (e) {
      emit(CommunityState.error(e.toString()));
    }
  }

  Future<void> _onEditComment(dynamic event, Emitter<CommunityState> emit) async {
    try {
      await _repository.editComment(
        commentId: event.commentId,
        content: event.content,
      );
      // Comment edit will be reflected through the stream
    } catch (e) {
      emit(CommunityState.error(e.toString()));
    }
  }

  Future<void> _onDeleteComment(dynamic event, Emitter<CommunityState> emit) async {
    try {
      await _repository.deleteComment(event.commentId);
      // Comment deletion will be reflected through the stream
    } catch (e) {
      emit(CommunityState.error(e.toString()));
    }
  }

  Future<void> _onLoadComments(dynamic event, Emitter<CommunityState> emit) async {
    // Get current state data
    final currentPosts = state.maybeWhen(
      loaded: (posts, _, __, ___, ____, _____) => posts,
      orElse: () => <Post>[],
    );

    final currentSortBy = state.maybeWhen(
      loaded: (_, __, sortBy, ___, ____, _____) => sortBy,
      orElse: () => 'createdAt',
    );

    final currentDescending = state.maybeWhen(
      loaded: (_, __, ___, descending, ____, _____) => descending,
      orElse: () => true,
    );

    final currentCategory3 = state.maybeWhen(
      loaded: (_, __, ___, ____, category3, _____) => category3,
      orElse: () => null,
    );

    // Early return if not in loaded state
    if (currentPosts.isEmpty) return;

    try {
      // Cancel existing comments subscription
      await _commentsSubscription?.cancel();

      // Start listening to comments stream for this post
      _commentsSubscription = _repository
          .getCommentsForPost(event.postId)
          .listen(
            (comments) {
              add(CommunityEvent.commentsUpdated(comments));
            },
            onError: (error) {
              add(CommunityEvent.commentsUpdated(const []));
            },
          );

      // Get initial comments from the stream
      final newComments = await _repository.getCommentsForPost(event.postId).first;

      emit(CommunityState.loaded(
        posts: currentPosts,
        comments: newComments,
        sortBy: currentSortBy,
        descending: currentDescending,
        category: currentCategory3,
        selectedPostId: event.postId,
      ));
    } catch (e) {
      emit(CommunityState.error(e.toString()));
    }
  }

  Future<void> _onCommentsUpdated(dynamic event, Emitter<CommunityState> emit) async {
    final currentState = state;
    currentState.maybeWhen(
      loaded: (posts, comments, sortBy, descending, category, selectedPostId) {
        emit(CommunityState.loaded(
          posts: posts,
          comments: event.comments,
          sortBy: sortBy,
          descending: descending,
          category: category,
          selectedPostId: selectedPostId,
        ));
      },
      orElse: () {}, // Do nothing if not in loaded state
    );
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }
}