import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'like.freezed.dart';
part 'like.g.dart';

@freezed
class Like with _$Like {
  const factory Like({
    required String id,
    required String userId,
    required String targetId, // Post or Comment ID
    required String targetType, // 'post' or 'comment'
    @TimestampConverter() required DateTime createdAt,
  }) = _Like;

  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);
}