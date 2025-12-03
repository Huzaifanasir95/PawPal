import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/post.dart';
import '../../data/models/comment.dart';

part 'community_state.freezed.dart';

@freezed
class CommunityState with _$CommunityState {
  const factory CommunityState.initial() = _Initial;

  const factory CommunityState.loading() = _Loading;

  const factory CommunityState.loaded({
    required List<Post> posts,
    required List<Comment> comments,
    required String sortBy,
    required bool descending,
    String? selectedPostId,
  }) = _Loaded;

  const factory CommunityState.error(String message) = _Error;
}