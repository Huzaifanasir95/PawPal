import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/post.dart';
import '../../data/models/comment.dart';

part 'community_event.freezed.dart';

@freezed
class CommunityEvent with _$CommunityEvent {
  const factory CommunityEvent.loadPosts({
    @Default('createdAt') String sortBy,
    @Default(true) bool descending,
  }) = _LoadPosts;

  const factory CommunityEvent.createPost({
    required String title,
    required String content,
    List<String>? imageUrls,
  }) = _CreatePost;

  const factory CommunityEvent.likePost(String postId) = _LikePost;

  const factory CommunityEvent.addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) = _AddComment;

  const factory CommunityEvent.likeComment(String commentId) = _LikeComment;

  const factory CommunityEvent.editPost({
    required String postId,
    String? title,
    String? content,
  }) = _EditPost;

  const factory CommunityEvent.deletePost(String postId) = _DeletePost;

  const factory CommunityEvent.editComment({
    required String commentId,
    required String content,
  }) = _EditComment;

  const factory CommunityEvent.deleteComment(String commentId) = _DeleteComment;

  const factory CommunityEvent.loadComments(String postId) = _LoadComments;

  const factory CommunityEvent.commentsUpdated(List<Comment> comments) = _CommentsUpdated;

  const factory CommunityEvent.postsUpdated(List<Post> posts) = _PostsUpdated;
}