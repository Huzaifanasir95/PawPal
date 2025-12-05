// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChatState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'ChatState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ChatState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'ChatState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements ChatState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$ChatsLoadedImplCopyWith<$Res> {
  factory _$$ChatsLoadedImplCopyWith(
    _$ChatsLoadedImpl value,
    $Res Function(_$ChatsLoadedImpl) then,
  ) = __$$ChatsLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Chat> chats});
}

/// @nodoc
class __$$ChatsLoadedImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatsLoadedImpl>
    implements _$$ChatsLoadedImplCopyWith<$Res> {
  __$$ChatsLoadedImplCopyWithImpl(
    _$ChatsLoadedImpl _value,
    $Res Function(_$ChatsLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? chats = null}) {
    return _then(
      _$ChatsLoadedImpl(
        null == chats
            ? _value._chats
            : chats // ignore: cast_nullable_to_non_nullable
                as List<Chat>,
      ),
    );
  }
}

/// @nodoc

class _$ChatsLoadedImpl implements _ChatsLoaded {
  const _$ChatsLoadedImpl(final List<Chat> chats) : _chats = chats;

  final List<Chat> _chats;
  @override
  List<Chat> get chats {
    if (_chats is EqualUnmodifiableListView) return _chats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chats);
  }

  @override
  String toString() {
    return 'ChatState.chatsLoaded(chats: $chats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatsLoadedImpl &&
            const DeepCollectionEquality().equals(other._chats, _chats));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_chats));

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatsLoadedImplCopyWith<_$ChatsLoadedImpl> get copyWith =>
      __$$ChatsLoadedImplCopyWithImpl<_$ChatsLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) {
    return chatsLoaded(chats);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) {
    return chatsLoaded?.call(chats);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (chatsLoaded != null) {
      return chatsLoaded(chats);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) {
    return chatsLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) {
    return chatsLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (chatsLoaded != null) {
      return chatsLoaded(this);
    }
    return orElse();
  }
}

abstract class _ChatsLoaded implements ChatState {
  const factory _ChatsLoaded(final List<Chat> chats) = _$ChatsLoadedImpl;

  List<Chat> get chats;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatsLoadedImplCopyWith<_$ChatsLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatLoadedImplCopyWith<$Res> {
  factory _$$ChatLoadedImplCopyWith(
    _$ChatLoadedImpl value,
    $Res Function(_$ChatLoadedImpl) then,
  ) = __$$ChatLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    Chat chat,
    List<ChatMessage> messages,
    bool hasMore,
    int currentPage,
  });

  $ChatCopyWith<$Res> get chat;
}

/// @nodoc
class __$$ChatLoadedImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatLoadedImpl>
    implements _$$ChatLoadedImplCopyWith<$Res> {
  __$$ChatLoadedImplCopyWithImpl(
    _$ChatLoadedImpl _value,
    $Res Function(_$ChatLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chat = null,
    Object? messages = null,
    Object? hasMore = null,
    Object? currentPage = null,
  }) {
    return _then(
      _$ChatLoadedImpl(
        chat:
            null == chat
                ? _value.chat
                : chat // ignore: cast_nullable_to_non_nullable
                    as Chat,
        messages:
            null == messages
                ? _value._messages
                : messages // ignore: cast_nullable_to_non_nullable
                    as List<ChatMessage>,
        hasMore:
            null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                    as bool,
        currentPage:
            null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatCopyWith<$Res> get chat {
    return $ChatCopyWith<$Res>(_value.chat, (value) {
      return _then(_value.copyWith(chat: value));
    });
  }
}

/// @nodoc

class _$ChatLoadedImpl implements _ChatLoaded {
  const _$ChatLoadedImpl({
    required this.chat,
    required final List<ChatMessage> messages,
    required this.hasMore,
    required this.currentPage,
  }) : _messages = messages;

  @override
  final Chat chat;
  final List<ChatMessage> _messages;
  @override
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final bool hasMore;
  @override
  final int currentPage;

  @override
  String toString() {
    return 'ChatState.chatLoaded(chat: $chat, messages: $messages, hasMore: $hasMore, currentPage: $currentPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatLoadedImpl &&
            (identical(other.chat, chat) || other.chat == chat) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    chat,
    const DeepCollectionEquality().hash(_messages),
    hasMore,
    currentPage,
  );

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatLoadedImplCopyWith<_$ChatLoadedImpl> get copyWith =>
      __$$ChatLoadedImplCopyWithImpl<_$ChatLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) {
    return chatLoaded(chat, messages, hasMore, currentPage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) {
    return chatLoaded?.call(chat, messages, hasMore, currentPage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (chatLoaded != null) {
      return chatLoaded(chat, messages, hasMore, currentPage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) {
    return chatLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) {
    return chatLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (chatLoaded != null) {
      return chatLoaded(this);
    }
    return orElse();
  }
}

abstract class _ChatLoaded implements ChatState {
  const factory _ChatLoaded({
    required final Chat chat,
    required final List<ChatMessage> messages,
    required final bool hasMore,
    required final int currentPage,
  }) = _$ChatLoadedImpl;

  Chat get chat;
  List<ChatMessage> get messages;
  bool get hasMore;
  int get currentPage;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatLoadedImplCopyWith<_$ChatLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatStartedImplCopyWith<$Res> {
  factory _$$ChatStartedImplCopyWith(
    _$ChatStartedImpl value,
    $Res Function(_$ChatStartedImpl) then,
  ) = __$$ChatStartedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Chat chat});

  $ChatCopyWith<$Res> get chat;
}

/// @nodoc
class __$$ChatStartedImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStartedImpl>
    implements _$$ChatStartedImplCopyWith<$Res> {
  __$$ChatStartedImplCopyWithImpl(
    _$ChatStartedImpl _value,
    $Res Function(_$ChatStartedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? chat = null}) {
    return _then(
      _$ChatStartedImpl(
        null == chat
            ? _value.chat
            : chat // ignore: cast_nullable_to_non_nullable
                as Chat,
      ),
    );
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatCopyWith<$Res> get chat {
    return $ChatCopyWith<$Res>(_value.chat, (value) {
      return _then(_value.copyWith(chat: value));
    });
  }
}

/// @nodoc

class _$ChatStartedImpl implements _ChatStarted {
  const _$ChatStartedImpl(this.chat);

  @override
  final Chat chat;

  @override
  String toString() {
    return 'ChatState.chatStarted(chat: $chat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStartedImpl &&
            (identical(other.chat, chat) || other.chat == chat));
  }

  @override
  int get hashCode => Object.hash(runtimeType, chat);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStartedImplCopyWith<_$ChatStartedImpl> get copyWith =>
      __$$ChatStartedImplCopyWithImpl<_$ChatStartedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) {
    return chatStarted(chat);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) {
    return chatStarted?.call(chat);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (chatStarted != null) {
      return chatStarted(chat);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) {
    return chatStarted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) {
    return chatStarted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (chatStarted != null) {
      return chatStarted(this);
    }
    return orElse();
  }
}

abstract class _ChatStarted implements ChatState {
  const factory _ChatStarted(final Chat chat) = _$ChatStartedImpl;

  Chat get chat;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStartedImplCopyWith<_$ChatStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MessageSentImplCopyWith<$Res> {
  factory _$$MessageSentImplCopyWith(
    _$MessageSentImpl value,
    $Res Function(_$MessageSentImpl) then,
  ) = __$$MessageSentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ChatMessage message});

  $ChatMessageCopyWith<$Res> get message;
}

/// @nodoc
class __$$MessageSentImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$MessageSentImpl>
    implements _$$MessageSentImplCopyWith<$Res> {
  __$$MessageSentImplCopyWithImpl(
    _$MessageSentImpl _value,
    $Res Function(_$MessageSentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$MessageSentImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as ChatMessage,
      ),
    );
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatMessageCopyWith<$Res> get message {
    return $ChatMessageCopyWith<$Res>(_value.message, (value) {
      return _then(_value.copyWith(message: value));
    });
  }
}

/// @nodoc

class _$MessageSentImpl implements _MessageSent {
  const _$MessageSentImpl(this.message);

  @override
  final ChatMessage message;

  @override
  String toString() {
    return 'ChatState.messageSent(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageSentImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageSentImplCopyWith<_$MessageSentImpl> get copyWith =>
      __$$MessageSentImplCopyWithImpl<_$MessageSentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) {
    return messageSent(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) {
    return messageSent?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (messageSent != null) {
      return messageSent(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) {
    return messageSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) {
    return messageSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (messageSent != null) {
      return messageSent(this);
    }
    return orElse();
  }
}

abstract class _MessageSent implements ChatState {
  const factory _MessageSent(final ChatMessage message) = _$MessageSentImpl;

  ChatMessage get message;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageSentImplCopyWith<_$MessageSentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MessageMarkedAsReadImplCopyWith<$Res> {
  factory _$$MessageMarkedAsReadImplCopyWith(
    _$MessageMarkedAsReadImpl value,
    $Res Function(_$MessageMarkedAsReadImpl) then,
  ) = __$$MessageMarkedAsReadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String messageId});
}

/// @nodoc
class __$$MessageMarkedAsReadImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$MessageMarkedAsReadImpl>
    implements _$$MessageMarkedAsReadImplCopyWith<$Res> {
  __$$MessageMarkedAsReadImplCopyWithImpl(
    _$MessageMarkedAsReadImpl _value,
    $Res Function(_$MessageMarkedAsReadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? messageId = null}) {
    return _then(
      _$MessageMarkedAsReadImpl(
        null == messageId
            ? _value.messageId
            : messageId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$MessageMarkedAsReadImpl implements _MessageMarkedAsRead {
  const _$MessageMarkedAsReadImpl(this.messageId);

  @override
  final String messageId;

  @override
  String toString() {
    return 'ChatState.messageMarkedAsRead(messageId: $messageId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageMarkedAsReadImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, messageId);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageMarkedAsReadImplCopyWith<_$MessageMarkedAsReadImpl> get copyWith =>
      __$$MessageMarkedAsReadImplCopyWithImpl<_$MessageMarkedAsReadImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) {
    return messageMarkedAsRead(messageId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) {
    return messageMarkedAsRead?.call(messageId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (messageMarkedAsRead != null) {
      return messageMarkedAsRead(messageId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) {
    return messageMarkedAsRead(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) {
    return messageMarkedAsRead?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (messageMarkedAsRead != null) {
      return messageMarkedAsRead(this);
    }
    return orElse();
  }
}

abstract class _MessageMarkedAsRead implements ChatState {
  const factory _MessageMarkedAsRead(final String messageId) =
      _$MessageMarkedAsReadImpl;

  String get messageId;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageMarkedAsReadImplCopyWith<_$MessageMarkedAsReadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatDeletedImplCopyWith<$Res> {
  factory _$$ChatDeletedImplCopyWith(
    _$ChatDeletedImpl value,
    $Res Function(_$ChatDeletedImpl) then,
  ) = __$$ChatDeletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String chatId});
}

/// @nodoc
class __$$ChatDeletedImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatDeletedImpl>
    implements _$$ChatDeletedImplCopyWith<$Res> {
  __$$ChatDeletedImplCopyWithImpl(
    _$ChatDeletedImpl _value,
    $Res Function(_$ChatDeletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? chatId = null}) {
    return _then(
      _$ChatDeletedImpl(
        null == chatId
            ? _value.chatId
            : chatId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ChatDeletedImpl implements _ChatDeleted {
  const _$ChatDeletedImpl(this.chatId);

  @override
  final String chatId;

  @override
  String toString() {
    return 'ChatState.chatDeleted(chatId: $chatId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatDeletedImpl &&
            (identical(other.chatId, chatId) || other.chatId == chatId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, chatId);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatDeletedImplCopyWith<_$ChatDeletedImpl> get copyWith =>
      __$$ChatDeletedImplCopyWithImpl<_$ChatDeletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) {
    return chatDeleted(chatId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) {
    return chatDeleted?.call(chatId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (chatDeleted != null) {
      return chatDeleted(chatId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) {
    return chatDeleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) {
    return chatDeleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (chatDeleted != null) {
      return chatDeleted(this);
    }
    return orElse();
  }
}

abstract class _ChatDeleted implements ChatState {
  const factory _ChatDeleted(final String chatId) = _$ChatDeletedImpl;

  String get chatId;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatDeletedImplCopyWith<_$ChatDeletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'ChatState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Chat> chats) chatsLoaded,
    required TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )
    chatLoaded,
    required TResult Function(Chat chat) chatStarted,
    required TResult Function(ChatMessage message) messageSent,
    required TResult Function(String messageId) messageMarkedAsRead,
    required TResult Function(String chatId) chatDeleted,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Chat> chats)? chatsLoaded,
    TResult? Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult? Function(Chat chat)? chatStarted,
    TResult? Function(ChatMessage message)? messageSent,
    TResult? Function(String messageId)? messageMarkedAsRead,
    TResult? Function(String chatId)? chatDeleted,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Chat> chats)? chatsLoaded,
    TResult Function(
      Chat chat,
      List<ChatMessage> messages,
      bool hasMore,
      int currentPage,
    )?
    chatLoaded,
    TResult Function(Chat chat)? chatStarted,
    TResult Function(ChatMessage message)? messageSent,
    TResult Function(String messageId)? messageMarkedAsRead,
    TResult Function(String chatId)? chatDeleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ChatsLoaded value) chatsLoaded,
    required TResult Function(_ChatLoaded value) chatLoaded,
    required TResult Function(_ChatStarted value) chatStarted,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessageMarkedAsRead value) messageMarkedAsRead,
    required TResult Function(_ChatDeleted value) chatDeleted,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ChatsLoaded value)? chatsLoaded,
    TResult? Function(_ChatLoaded value)? chatLoaded,
    TResult? Function(_ChatStarted value)? chatStarted,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult? Function(_ChatDeleted value)? chatDeleted,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ChatsLoaded value)? chatsLoaded,
    TResult Function(_ChatLoaded value)? chatLoaded,
    TResult Function(_ChatStarted value)? chatStarted,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessageMarkedAsRead value)? messageMarkedAsRead,
    TResult Function(_ChatDeleted value)? chatDeleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements ChatState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
