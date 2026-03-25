// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      parentCommentId: json['parentCommentId'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      likedBy:
          (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'userId': instance.userId,
      'content': instance.content,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'parentCommentId': instance.parentCommentId,
      'likesCount': instance.likesCount,
      'likedBy': instance.likedBy,
      'replies': instance.replies,
    };
