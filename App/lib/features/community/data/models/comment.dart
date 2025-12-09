import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String postId,
    required String userId,
    required String content,
    @TimestampConverter() required DateTime createdAt,
    String? userName,
    String? userAvatar,
    String? parentCommentId, // For nested replies
    @Default(0) int likesCount,
    @Default([]) List<String> likedBy,
    List<Comment>? replies, // Nested replies
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}