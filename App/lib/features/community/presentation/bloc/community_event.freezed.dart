// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityEventCopyWith<$Res> {
  factory $CommunityEventCopyWith(
    CommunityEvent value,
    $Res Function(CommunityEvent) then,
  ) = _$CommunityEventCopyWithImpl<$Res, CommunityEvent>;
}

/// @nodoc
class _$CommunityEventCopyWithImpl<$Res, $Val extends CommunityEvent>
    implements $CommunityEventCopyWith<$Res> {
  _$CommunityEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadPostsImplCopyWith<$Res> {
  factory _$$LoadPostsImplCopyWith(
    _$LoadPostsImpl value,
    $Res Function(_$LoadPostsImpl) then,
  ) = __$$LoadPostsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String sortBy, bool descending});
}

/// @nodoc
class __$$LoadPostsImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$LoadPostsImpl>
    implements _$$LoadPostsImplCopyWith<$Res> {
  __$$LoadPostsImplCopyWithImpl(
    _$LoadPostsImpl _value,
    $Res Function(_$LoadPostsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sortBy = null, Object? descending = null}) {
    return _then(
      _$LoadPostsImpl(
        sortBy:
            null == sortBy
                ? _value.sortBy
                : sortBy // ignore: cast_nullable_to_non_nullable
                    as String,
        descending:
            null == descending
                ? _value.descending
                : descending // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$LoadPostsImpl implements _LoadPosts {
  const _$LoadPostsImpl({this.sortBy = 'createdAt', this.descending = true});

  @override
  @JsonKey()
  final String sortBy;
  @override
  @JsonKey()
  final bool descending;

  @override
  String toString() {
    return 'CommunityEvent.loadPosts(sortBy: $sortBy, descending: $descending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadPostsImpl &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.descending, descending) ||
                other.descending == descending));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sortBy, descending);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadPostsImplCopyWith<_$LoadPostsImpl> get copyWith =>
      __$$LoadPostsImplCopyWithImpl<_$LoadPostsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return loadPosts(sortBy, descending);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return loadPosts?.call(sortBy, descending);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (loadPosts != null) {
      return loadPosts(sortBy, descending);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return loadPosts(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return loadPosts?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (loadPosts != null) {
      return loadPosts(this);
    }
    return orElse();
  }
}

abstract class _LoadPosts implements CommunityEvent {
  const factory _LoadPosts({final String sortBy, final bool descending}) =
      _$LoadPostsImpl;

  String get sortBy;
  bool get descending;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadPostsImplCopyWith<_$LoadPostsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CreatePostImplCopyWith<$Res> {
  factory _$$CreatePostImplCopyWith(
    _$CreatePostImpl value,
    $Res Function(_$CreatePostImpl) then,
  ) = __$$CreatePostImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String title, String content, List<String>? imageUrls});
}

/// @nodoc
class __$$CreatePostImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$CreatePostImpl>
    implements _$$CreatePostImplCopyWith<$Res> {
  __$$CreatePostImplCopyWithImpl(
    _$CreatePostImpl _value,
    $Res Function(_$CreatePostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? imageUrls = freezed,
  }) {
    return _then(
      _$CreatePostImpl(
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        imageUrls:
            freezed == imageUrls
                ? _value._imageUrls
                : imageUrls // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
      ),
    );
  }
}

/// @nodoc

class _$CreatePostImpl implements _CreatePost {
  const _$CreatePostImpl({
    required this.title,
    required this.content,
    final List<String>? imageUrls,
  }) : _imageUrls = imageUrls;

  @override
  final String title;
  @override
  final String content;
  final List<String>? _imageUrls;
  @override
  List<String>? get imageUrls {
    final value = _imageUrls;
    if (value == null) return null;
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CommunityEvent.createPost(title: $title, content: $content, imageUrls: $imageUrls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePostImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(
              other._imageUrls,
              _imageUrls,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    content,
    const DeepCollectionEquality().hash(_imageUrls),
  );

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePostImplCopyWith<_$CreatePostImpl> get copyWith =>
      __$$CreatePostImplCopyWithImpl<_$CreatePostImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return createPost(title, content, imageUrls);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return createPost?.call(title, content, imageUrls);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (createPost != null) {
      return createPost(title, content, imageUrls);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return createPost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return createPost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (createPost != null) {
      return createPost(this);
    }
    return orElse();
  }
}

abstract class _CreatePost implements CommunityEvent {
  const factory _CreatePost({
    required final String title,
    required final String content,
    final List<String>? imageUrls,
  }) = _$CreatePostImpl;

  String get title;
  String get content;
  List<String>? get imageUrls;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatePostImplCopyWith<_$CreatePostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LikePostImplCopyWith<$Res> {
  factory _$$LikePostImplCopyWith(
    _$LikePostImpl value,
    $Res Function(_$LikePostImpl) then,
  ) = __$$LikePostImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String postId});
}

/// @nodoc
class __$$LikePostImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$LikePostImpl>
    implements _$$LikePostImplCopyWith<$Res> {
  __$$LikePostImplCopyWithImpl(
    _$LikePostImpl _value,
    $Res Function(_$LikePostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? postId = null}) {
    return _then(
      _$LikePostImpl(
        null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$LikePostImpl implements _LikePost {
  const _$LikePostImpl(this.postId);

  @override
  final String postId;

  @override
  String toString() {
    return 'CommunityEvent.likePost(postId: $postId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikePostImpl &&
            (identical(other.postId, postId) || other.postId == postId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LikePostImplCopyWith<_$LikePostImpl> get copyWith =>
      __$$LikePostImplCopyWithImpl<_$LikePostImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return likePost(postId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return likePost?.call(postId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (likePost != null) {
      return likePost(postId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return likePost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return likePost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (likePost != null) {
      return likePost(this);
    }
    return orElse();
  }
}

abstract class _LikePost implements CommunityEvent {
  const factory _LikePost(final String postId) = _$LikePostImpl;

  String get postId;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LikePostImplCopyWith<_$LikePostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AddCommentImplCopyWith<$Res> {
  factory _$$AddCommentImplCopyWith(
    _$AddCommentImpl value,
    $Res Function(_$AddCommentImpl) then,
  ) = __$$AddCommentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String postId, String content, String? parentCommentId});
}

/// @nodoc
class __$$AddCommentImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$AddCommentImpl>
    implements _$$AddCommentImplCopyWith<$Res> {
  __$$AddCommentImplCopyWithImpl(
    _$AddCommentImpl _value,
    $Res Function(_$AddCommentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? content = null,
    Object? parentCommentId = freezed,
  }) {
    return _then(
      _$AddCommentImpl(
        postId:
            null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        parentCommentId:
            freezed == parentCommentId
                ? _value.parentCommentId
                : parentCommentId // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$AddCommentImpl implements _AddComment {
  const _$AddCommentImpl({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });

  @override
  final String postId;
  @override
  final String content;
  @override
  final String? parentCommentId;

  @override
  String toString() {
    return 'CommunityEvent.addComment(postId: $postId, content: $content, parentCommentId: $parentCommentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddCommentImpl &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.parentCommentId, parentCommentId) ||
                other.parentCommentId == parentCommentId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, postId, content, parentCommentId);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddCommentImplCopyWith<_$AddCommentImpl> get copyWith =>
      __$$AddCommentImplCopyWithImpl<_$AddCommentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return addComment(postId, content, parentCommentId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return addComment?.call(postId, content, parentCommentId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (addComment != null) {
      return addComment(postId, content, parentCommentId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return addComment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return addComment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (addComment != null) {
      return addComment(this);
    }
    return orElse();
  }
}

abstract class _AddComment implements CommunityEvent {
  const factory _AddComment({
    required final String postId,
    required final String content,
    final String? parentCommentId,
  }) = _$AddCommentImpl;

  String get postId;
  String get content;
  String? get parentCommentId;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddCommentImplCopyWith<_$AddCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LikeCommentImplCopyWith<$Res> {
  factory _$$LikeCommentImplCopyWith(
    _$LikeCommentImpl value,
    $Res Function(_$LikeCommentImpl) then,
  ) = __$$LikeCommentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String commentId});
}

/// @nodoc
class __$$LikeCommentImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$LikeCommentImpl>
    implements _$$LikeCommentImplCopyWith<$Res> {
  __$$LikeCommentImplCopyWithImpl(
    _$LikeCommentImpl _value,
    $Res Function(_$LikeCommentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? commentId = null}) {
    return _then(
      _$LikeCommentImpl(
        null == commentId
            ? _value.commentId
            : commentId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$LikeCommentImpl implements _LikeComment {
  const _$LikeCommentImpl(this.commentId);

  @override
  final String commentId;

  @override
  String toString() {
    return 'CommunityEvent.likeComment(commentId: $commentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikeCommentImpl &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentId);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LikeCommentImplCopyWith<_$LikeCommentImpl> get copyWith =>
      __$$LikeCommentImplCopyWithImpl<_$LikeCommentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return likeComment(commentId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return likeComment?.call(commentId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (likeComment != null) {
      return likeComment(commentId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return likeComment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return likeComment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (likeComment != null) {
      return likeComment(this);
    }
    return orElse();
  }
}

abstract class _LikeComment implements CommunityEvent {
  const factory _LikeComment(final String commentId) = _$LikeCommentImpl;

  String get commentId;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LikeCommentImplCopyWith<_$LikeCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EditPostImplCopyWith<$Res> {
  factory _$$EditPostImplCopyWith(
    _$EditPostImpl value,
    $Res Function(_$EditPostImpl) then,
  ) = __$$EditPostImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String postId, String? title, String? content});
}

/// @nodoc
class __$$EditPostImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$EditPostImpl>
    implements _$$EditPostImplCopyWith<$Res> {
  __$$EditPostImplCopyWithImpl(
    _$EditPostImpl _value,
    $Res Function(_$EditPostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postId = null,
    Object? title = freezed,
    Object? content = freezed,
  }) {
    return _then(
      _$EditPostImpl(
        postId:
            null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String?,
        content:
            freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$EditPostImpl implements _EditPost {
  const _$EditPostImpl({required this.postId, this.title, this.content});

  @override
  final String postId;
  @override
  final String? title;
  @override
  final String? content;

  @override
  String toString() {
    return 'CommunityEvent.editPost(postId: $postId, title: $title, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditPostImpl &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId, title, content);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditPostImplCopyWith<_$EditPostImpl> get copyWith =>
      __$$EditPostImplCopyWithImpl<_$EditPostImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return editPost(postId, title, content);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return editPost?.call(postId, title, content);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (editPost != null) {
      return editPost(postId, title, content);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return editPost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return editPost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (editPost != null) {
      return editPost(this);
    }
    return orElse();
  }
}

abstract class _EditPost implements CommunityEvent {
  const factory _EditPost({
    required final String postId,
    final String? title,
    final String? content,
  }) = _$EditPostImpl;

  String get postId;
  String? get title;
  String? get content;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditPostImplCopyWith<_$EditPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeletePostImplCopyWith<$Res> {
  factory _$$DeletePostImplCopyWith(
    _$DeletePostImpl value,
    $Res Function(_$DeletePostImpl) then,
  ) = __$$DeletePostImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String postId});
}

/// @nodoc
class __$$DeletePostImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$DeletePostImpl>
    implements _$$DeletePostImplCopyWith<$Res> {
  __$$DeletePostImplCopyWithImpl(
    _$DeletePostImpl _value,
    $Res Function(_$DeletePostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? postId = null}) {
    return _then(
      _$DeletePostImpl(
        null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$DeletePostImpl implements _DeletePost {
  const _$DeletePostImpl(this.postId);

  @override
  final String postId;

  @override
  String toString() {
    return 'CommunityEvent.deletePost(postId: $postId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeletePostImpl &&
            (identical(other.postId, postId) || other.postId == postId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeletePostImplCopyWith<_$DeletePostImpl> get copyWith =>
      __$$DeletePostImplCopyWithImpl<_$DeletePostImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return deletePost(postId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return deletePost?.call(postId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (deletePost != null) {
      return deletePost(postId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return deletePost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return deletePost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (deletePost != null) {
      return deletePost(this);
    }
    return orElse();
  }
}

abstract class _DeletePost implements CommunityEvent {
  const factory _DeletePost(final String postId) = _$DeletePostImpl;

  String get postId;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeletePostImplCopyWith<_$DeletePostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EditCommentImplCopyWith<$Res> {
  factory _$$EditCommentImplCopyWith(
    _$EditCommentImpl value,
    $Res Function(_$EditCommentImpl) then,
  ) = __$$EditCommentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String commentId, String content});
}

/// @nodoc
class __$$EditCommentImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$EditCommentImpl>
    implements _$$EditCommentImplCopyWith<$Res> {
  __$$EditCommentImplCopyWithImpl(
    _$EditCommentImpl _value,
    $Res Function(_$EditCommentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? commentId = null, Object? content = null}) {
    return _then(
      _$EditCommentImpl(
        commentId:
            null == commentId
                ? _value.commentId
                : commentId // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

class _$EditCommentImpl implements _EditComment {
  const _$EditCommentImpl({required this.commentId, required this.content});

  @override
  final String commentId;
  @override
  final String content;

  @override
  String toString() {
    return 'CommunityEvent.editComment(commentId: $commentId, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditCommentImpl &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentId, content);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditCommentImplCopyWith<_$EditCommentImpl> get copyWith =>
      __$$EditCommentImplCopyWithImpl<_$EditCommentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return editComment(commentId, content);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return editComment?.call(commentId, content);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (editComment != null) {
      return editComment(commentId, content);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return editComment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return editComment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (editComment != null) {
      return editComment(this);
    }
    return orElse();
  }
}

abstract class _EditComment implements CommunityEvent {
  const factory _EditComment({
    required final String commentId,
    required final String content,
  }) = _$EditCommentImpl;

  String get commentId;
  String get content;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditCommentImplCopyWith<_$EditCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeleteCommentImplCopyWith<$Res> {
  factory _$$DeleteCommentImplCopyWith(
    _$DeleteCommentImpl value,
    $Res Function(_$DeleteCommentImpl) then,
  ) = __$$DeleteCommentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String commentId});
}

/// @nodoc
class __$$DeleteCommentImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$DeleteCommentImpl>
    implements _$$DeleteCommentImplCopyWith<$Res> {
  __$$DeleteCommentImplCopyWithImpl(
    _$DeleteCommentImpl _value,
    $Res Function(_$DeleteCommentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? commentId = null}) {
    return _then(
      _$DeleteCommentImpl(
        null == commentId
            ? _value.commentId
            : commentId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$DeleteCommentImpl implements _DeleteComment {
  const _$DeleteCommentImpl(this.commentId);

  @override
  final String commentId;

  @override
  String toString() {
    return 'CommunityEvent.deleteComment(commentId: $commentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteCommentImpl &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentId);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteCommentImplCopyWith<_$DeleteCommentImpl> get copyWith =>
      __$$DeleteCommentImplCopyWithImpl<_$DeleteCommentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return deleteComment(commentId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return deleteComment?.call(commentId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (deleteComment != null) {
      return deleteComment(commentId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return deleteComment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return deleteComment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (deleteComment != null) {
      return deleteComment(this);
    }
    return orElse();
  }
}

abstract class _DeleteComment implements CommunityEvent {
  const factory _DeleteComment(final String commentId) = _$DeleteCommentImpl;

  String get commentId;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteCommentImplCopyWith<_$DeleteCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadCommentsImplCopyWith<$Res> {
  factory _$$LoadCommentsImplCopyWith(
    _$LoadCommentsImpl value,
    $Res Function(_$LoadCommentsImpl) then,
  ) = __$$LoadCommentsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String postId});
}

/// @nodoc
class __$$LoadCommentsImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$LoadCommentsImpl>
    implements _$$LoadCommentsImplCopyWith<$Res> {
  __$$LoadCommentsImplCopyWithImpl(
    _$LoadCommentsImpl _value,
    $Res Function(_$LoadCommentsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? postId = null}) {
    return _then(
      _$LoadCommentsImpl(
        null == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$LoadCommentsImpl implements _LoadComments {
  const _$LoadCommentsImpl(this.postId);

  @override
  final String postId;

  @override
  String toString() {
    return 'CommunityEvent.loadComments(postId: $postId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadCommentsImpl &&
            (identical(other.postId, postId) || other.postId == postId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadCommentsImplCopyWith<_$LoadCommentsImpl> get copyWith =>
      __$$LoadCommentsImplCopyWithImpl<_$LoadCommentsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return loadComments(postId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return loadComments?.call(postId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (loadComments != null) {
      return loadComments(postId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return loadComments(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return loadComments?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (loadComments != null) {
      return loadComments(this);
    }
    return orElse();
  }
}

abstract class _LoadComments implements CommunityEvent {
  const factory _LoadComments(final String postId) = _$LoadCommentsImpl;

  String get postId;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadCommentsImplCopyWith<_$LoadCommentsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CommentsUpdatedImplCopyWith<$Res> {
  factory _$$CommentsUpdatedImplCopyWith(
    _$CommentsUpdatedImpl value,
    $Res Function(_$CommentsUpdatedImpl) then,
  ) = __$$CommentsUpdatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Comment> comments});
}

/// @nodoc
class __$$CommentsUpdatedImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$CommentsUpdatedImpl>
    implements _$$CommentsUpdatedImplCopyWith<$Res> {
  __$$CommentsUpdatedImplCopyWithImpl(
    _$CommentsUpdatedImpl _value,
    $Res Function(_$CommentsUpdatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? comments = null}) {
    return _then(
      _$CommentsUpdatedImpl(
        null == comments
            ? _value._comments
            : comments // ignore: cast_nullable_to_non_nullable
                as List<Comment>,
      ),
    );
  }
}

/// @nodoc

class _$CommentsUpdatedImpl implements _CommentsUpdated {
  const _$CommentsUpdatedImpl(final List<Comment> comments)
    : _comments = comments;

  final List<Comment> _comments;
  @override
  List<Comment> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  @override
  String toString() {
    return 'CommunityEvent.commentsUpdated(comments: $comments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentsUpdatedImpl &&
            const DeepCollectionEquality().equals(other._comments, _comments));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_comments));

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentsUpdatedImplCopyWith<_$CommentsUpdatedImpl> get copyWith =>
      __$$CommentsUpdatedImplCopyWithImpl<_$CommentsUpdatedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return commentsUpdated(comments);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return commentsUpdated?.call(comments);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (commentsUpdated != null) {
      return commentsUpdated(comments);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return commentsUpdated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return commentsUpdated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (commentsUpdated != null) {
      return commentsUpdated(this);
    }
    return orElse();
  }
}

abstract class _CommentsUpdated implements CommunityEvent {
  const factory _CommentsUpdated(final List<Comment> comments) =
      _$CommentsUpdatedImpl;

  List<Comment> get comments;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentsUpdatedImplCopyWith<_$CommentsUpdatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PostsUpdatedImplCopyWith<$Res> {
  factory _$$PostsUpdatedImplCopyWith(
    _$PostsUpdatedImpl value,
    $Res Function(_$PostsUpdatedImpl) then,
  ) = __$$PostsUpdatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Post> posts});
}

/// @nodoc
class __$$PostsUpdatedImplCopyWithImpl<$Res>
    extends _$CommunityEventCopyWithImpl<$Res, _$PostsUpdatedImpl>
    implements _$$PostsUpdatedImplCopyWith<$Res> {
  __$$PostsUpdatedImplCopyWithImpl(
    _$PostsUpdatedImpl _value,
    $Res Function(_$PostsUpdatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? posts = null}) {
    return _then(
      _$PostsUpdatedImpl(
        null == posts
            ? _value._posts
            : posts // ignore: cast_nullable_to_non_nullable
                as List<Post>,
      ),
    );
  }
}

/// @nodoc

class _$PostsUpdatedImpl implements _PostsUpdated {
  const _$PostsUpdatedImpl(final List<Post> posts) : _posts = posts;

  final List<Post> _posts;
  @override
  List<Post> get posts {
    if (_posts is EqualUnmodifiableListView) return _posts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posts);
  }

  @override
  String toString() {
    return 'CommunityEvent.postsUpdated(posts: $posts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostsUpdatedImpl &&
            const DeepCollectionEquality().equals(other._posts, _posts));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_posts));

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostsUpdatedImplCopyWith<_$PostsUpdatedImpl> get copyWith =>
      __$$PostsUpdatedImplCopyWithImpl<_$PostsUpdatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String sortBy, bool descending) loadPosts,
    required TResult Function(
      String title,
      String content,
      List<String>? imageUrls,
    )
    createPost,
    required TResult Function(String postId) likePost,
    required TResult Function(
      String postId,
      String content,
      String? parentCommentId,
    )
    addComment,
    required TResult Function(String commentId) likeComment,
    required TResult Function(String postId, String? title, String? content)
    editPost,
    required TResult Function(String postId) deletePost,
    required TResult Function(String commentId, String content) editComment,
    required TResult Function(String commentId) deleteComment,
    required TResult Function(String postId) loadComments,
    required TResult Function(List<Comment> comments) commentsUpdated,
    required TResult Function(List<Post> posts) postsUpdated,
  }) {
    return postsUpdated(posts);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String sortBy, bool descending)? loadPosts,
    TResult? Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult? Function(String postId)? likePost,
    TResult? Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult? Function(String commentId)? likeComment,
    TResult? Function(String postId, String? title, String? content)? editPost,
    TResult? Function(String postId)? deletePost,
    TResult? Function(String commentId, String content)? editComment,
    TResult? Function(String commentId)? deleteComment,
    TResult? Function(String postId)? loadComments,
    TResult? Function(List<Comment> comments)? commentsUpdated,
    TResult? Function(List<Post> posts)? postsUpdated,
  }) {
    return postsUpdated?.call(posts);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sortBy, bool descending)? loadPosts,
    TResult Function(String title, String content, List<String>? imageUrls)?
    createPost,
    TResult Function(String postId)? likePost,
    TResult Function(String postId, String content, String? parentCommentId)?
    addComment,
    TResult Function(String commentId)? likeComment,
    TResult Function(String postId, String? title, String? content)? editPost,
    TResult Function(String postId)? deletePost,
    TResult Function(String commentId, String content)? editComment,
    TResult Function(String commentId)? deleteComment,
    TResult Function(String postId)? loadComments,
    TResult Function(List<Comment> comments)? commentsUpdated,
    TResult Function(List<Post> posts)? postsUpdated,
    required TResult orElse(),
  }) {
    if (postsUpdated != null) {
      return postsUpdated(posts);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadPosts value) loadPosts,
    required TResult Function(_CreatePost value) createPost,
    required TResult Function(_LikePost value) likePost,
    required TResult Function(_AddComment value) addComment,
    required TResult Function(_LikeComment value) likeComment,
    required TResult Function(_EditPost value) editPost,
    required TResult Function(_DeletePost value) deletePost,
    required TResult Function(_EditComment value) editComment,
    required TResult Function(_DeleteComment value) deleteComment,
    required TResult Function(_LoadComments value) loadComments,
    required TResult Function(_CommentsUpdated value) commentsUpdated,
    required TResult Function(_PostsUpdated value) postsUpdated,
  }) {
    return postsUpdated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadPosts value)? loadPosts,
    TResult? Function(_CreatePost value)? createPost,
    TResult? Function(_LikePost value)? likePost,
    TResult? Function(_AddComment value)? addComment,
    TResult? Function(_LikeComment value)? likeComment,
    TResult? Function(_EditPost value)? editPost,
    TResult? Function(_DeletePost value)? deletePost,
    TResult? Function(_EditComment value)? editComment,
    TResult? Function(_DeleteComment value)? deleteComment,
    TResult? Function(_LoadComments value)? loadComments,
    TResult? Function(_CommentsUpdated value)? commentsUpdated,
    TResult? Function(_PostsUpdated value)? postsUpdated,
  }) {
    return postsUpdated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadPosts value)? loadPosts,
    TResult Function(_CreatePost value)? createPost,
    TResult Function(_LikePost value)? likePost,
    TResult Function(_AddComment value)? addComment,
    TResult Function(_LikeComment value)? likeComment,
    TResult Function(_EditPost value)? editPost,
    TResult Function(_DeletePost value)? deletePost,
    TResult Function(_EditComment value)? editComment,
    TResult Function(_DeleteComment value)? deleteComment,
    TResult Function(_LoadComments value)? loadComments,
    TResult Function(_CommentsUpdated value)? commentsUpdated,
    TResult Function(_PostsUpdated value)? postsUpdated,
    required TResult orElse(),
  }) {
    if (postsUpdated != null) {
      return postsUpdated(this);
    }
    return orElse();
  }
}

abstract class _PostsUpdated implements CommunityEvent {
  const factory _PostsUpdated(final List<Post> posts) = _$PostsUpdatedImpl;

  List<Post> get posts;

  /// Create a copy of CommunityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostsUpdatedImplCopyWith<_$PostsUpdatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
