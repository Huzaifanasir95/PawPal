import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    required String userId,
    required String title,
    required String content,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    String? userName,
    String? userAvatar,
    List<String>? imageUrls,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}