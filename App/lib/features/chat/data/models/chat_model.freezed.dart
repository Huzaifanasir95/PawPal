// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Chat _$ChatFromJson(Map<String, dynamic> json) {
  return _Chat.fromJson(json);
}

/// @nodoc
mixin _$Chat {
  String get id => throw _privateConstructorUsedError;
  String get petOwnerId => throw _privateConstructorUsedError;
  String get vetId => throw _privateConstructorUsedError;
  String? get petId => throw _privateConstructorUsedError;
  String? get petName => throw _privateConstructorUsedError;
  String? get lastMessage => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  int get unreadCountOwner => throw _privateConstructorUsedError;
  int get unreadCountVet => throw _privateConstructorUsedError;
  String? get otherUserName => throw _privateConstructorUsedError;
  String? get otherUserPhoto => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Chat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatCopyWith<Chat> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatCopyWith<$Res> {
  factory $ChatCopyWith(Chat value, $Res Function(Chat) then) =
      _$ChatCopyWithImpl<$Res, Chat>;
  @useResult
  $Res call({
    String id,
    String petOwnerId,
    String vetId,
    String? petId,
    String? petName,
    String? lastMessage,
    DateTime? lastMessageAt,
    int unreadCountOwner,
    int unreadCountVet,
    String? otherUserName,
    String? otherUserPhoto,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ChatCopyWithImpl<$Res, $Val extends Chat>
    implements $ChatCopyWith<$Res> {
  _$ChatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? petOwnerId = null,
    Object? vetId = null,
    Object? petId = freezed,
    Object? petName = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCountOwner = null,
    Object? unreadCountVet = null,
    Object? otherUserName = freezed,
    Object? otherUserPhoto = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            petOwnerId:
                null == petOwnerId
                    ? _value.petOwnerId
                    : petOwnerId // ignore: cast_nullable_to_non_nullable
                        as String,
            vetId:
                null == vetId
                    ? _value.vetId
                    : vetId // ignore: cast_nullable_to_non_nullable
                        as String,
            petId:
                freezed == petId
                    ? _value.petId
                    : petId // ignore: cast_nullable_to_non_nullable
                        as String?,
            petName:
                freezed == petName
                    ? _value.petName
                    : petName // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastMessage:
                freezed == lastMessage
                    ? _value.lastMessage
                    : lastMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastMessageAt:
                freezed == lastMessageAt
                    ? _value.lastMessageAt
                    : lastMessageAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            unreadCountOwner:
                null == unreadCountOwner
                    ? _value.unreadCountOwner
                    : unreadCountOwner // ignore: cast_nullable_to_non_nullable
                        as int,
            unreadCountVet:
                null == unreadCountVet
                    ? _value.unreadCountVet
                    : unreadCountVet // ignore: cast_nullable_to_non_nullable
                        as int,
            otherUserName:
                freezed == otherUserName
                    ? _value.otherUserName
                    : otherUserName // ignore: cast_nullable_to_non_nullable
                        as String?,
            otherUserPhoto:
                freezed == otherUserPhoto
                    ? _value.otherUserPhoto
                    : otherUserPhoto // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatImplCopyWith<$Res> implements $ChatCopyWith<$Res> {
  factory _$$ChatImplCopyWith(
    _$ChatImpl value,
    $Res Function(_$ChatImpl) then,
  ) = __$$ChatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String petOwnerId,
    String vetId,
    String? petId,
    String? petName,
    String? lastMessage,
    DateTime? lastMessageAt,
    int unreadCountOwner,
    int unreadCountVet,
    String? otherUserName,
    String? otherUserPhoto,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ChatImplCopyWithImpl<$Res>
    extends _$ChatCopyWithImpl<$Res, _$ChatImpl>
    implements _$$ChatImplCopyWith<$Res> {
  __$$ChatImplCopyWithImpl(_$ChatImpl _value, $Res Function(_$ChatImpl) _then)
    : super(_value, _then);

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? petOwnerId = null,
    Object? vetId = null,
    Object? petId = freezed,
    Object? petName = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCountOwner = null,
    Object? unreadCountVet = null,
    Object? otherUserName = freezed,
    Object? otherUserPhoto = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ChatImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        petOwnerId:
            null == petOwnerId
                ? _value.petOwnerId
                : petOwnerId // ignore: cast_nullable_to_non_nullable
                    as String,
        vetId:
            null == vetId
                ? _value.vetId
                : vetId // ignore: cast_nullable_to_non_nullable
                    as String,
        petId:
            freezed == petId
                ? _value.petId
                : petId // ignore: cast_nullable_to_non_nullable
                    as String?,
        petName:
            freezed == petName
                ? _value.petName
                : petName // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastMessage:
            freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastMessageAt:
            freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        unreadCountOwner:
            null == unreadCountOwner
                ? _value.unreadCountOwner
                : unreadCountOwner // ignore: cast_nullable_to_non_nullable
                    as int,
        unreadCountVet:
            null == unreadCountVet
                ? _value.unreadCountVet
                : unreadCountVet // ignore: cast_nullable_to_non_nullable
                    as int,
        otherUserName:
            freezed == otherUserName
                ? _value.otherUserName
                : otherUserName // ignore: cast_nullable_to_non_nullable
                    as String?,
        otherUserPhoto:
            freezed == otherUserPhoto
                ? _value.otherUserPhoto
                : otherUserPhoto // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatImpl implements _Chat {
  const _$ChatImpl({
    required this.id,
    required this.petOwnerId,
    required this.vetId,
    this.petId,
    this.petName,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCountOwner = 0,
    this.unreadCountVet = 0,
    this.otherUserName,
    this.otherUserPhoto,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$ChatImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatImplFromJson(json);

  @override
  final String id;
  @override
  final String petOwnerId;
  @override
  final String vetId;
  @override
  final String? petId;
  @override
  final String? petName;
  @override
  final String? lastMessage;
  @override
  final DateTime? lastMessageAt;
  @override
  @JsonKey()
  final int unreadCountOwner;
  @override
  @JsonKey()
  final int unreadCountVet;
  @override
  final String? otherUserName;
  @override
  final String? otherUserPhoto;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Chat(id: $id, petOwnerId: $petOwnerId, vetId: $vetId, petId: $petId, petName: $petName, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, unreadCountOwner: $unreadCountOwner, unreadCountVet: $unreadCountVet, otherUserName: $otherUserName, otherUserPhoto: $otherUserPhoto, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.petOwnerId, petOwnerId) ||
                other.petOwnerId == petOwnerId) &&
            (identical(other.vetId, vetId) || other.vetId == vetId) &&
            (identical(other.petId, petId) || other.petId == petId) &&
            (identical(other.petName, petName) || other.petName == petName) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCountOwner, unreadCountOwner) ||
                other.unreadCountOwner == unreadCountOwner) &&
            (identical(other.unreadCountVet, unreadCountVet) ||
                other.unreadCountVet == unreadCountVet) &&
            (identical(other.otherUserName, otherUserName) ||
                other.otherUserName == otherUserName) &&
            (identical(other.otherUserPhoto, otherUserPhoto) ||
                other.otherUserPhoto == otherUserPhoto) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    petOwnerId,
    vetId,
    petId,
    petName,
    lastMessage,
    lastMessageAt,
    unreadCountOwner,
    unreadCountVet,
    otherUserName,
    otherUserPhoto,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatImplCopyWith<_$ChatImpl> get copyWith =>
      __$$ChatImplCopyWithImpl<_$ChatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatImplToJson(this);
  }
}

abstract class _Chat implements Chat {
  const factory _Chat({
    required final String id,
    required final String petOwnerId,
    required final String vetId,
    final String? petId,
    final String? petName,
    final String? lastMessage,
    final DateTime? lastMessageAt,
    final int unreadCountOwner,
    final int unreadCountVet,
    final String? otherUserName,
    final String? otherUserPhoto,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ChatImpl;

  factory _Chat.fromJson(Map<String, dynamic> json) = _$ChatImpl.fromJson;

  @override
  String get id;
  @override
  String get petOwnerId;
  @override
  String get vetId;
  @override
  String? get petId;
  @override
  String? get petName;
  @override
  String? get lastMessage;
  @override
  DateTime? get lastMessageAt;
  @override
  int get unreadCountOwner;
  @override
  int get unreadCountVet;
  @override
  String? get otherUserName;
  @override
  String? get otherUserPhoto;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatImplCopyWith<_$ChatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get chatId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String? get senderName => throw _privateConstructorUsedError;
  String? get senderPhoto => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String chatId,
    String senderId,
    String? senderName,
    String? senderPhoto,
    String content,
    bool isRead,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? senderName = freezed,
    Object? senderPhoto = freezed,
    Object? content = null,
    Object? isRead = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            chatId:
                null == chatId
                    ? _value.chatId
                    : chatId // ignore: cast_nullable_to_non_nullable
                        as String,
            senderId:
                null == senderId
                    ? _value.senderId
                    : senderId // ignore: cast_nullable_to_non_nullable
                        as String,
            senderName:
                freezed == senderName
                    ? _value.senderName
                    : senderName // ignore: cast_nullable_to_non_nullable
                        as String?,
            senderPhoto:
                freezed == senderPhoto
                    ? _value.senderPhoto
                    : senderPhoto // ignore: cast_nullable_to_non_nullable
                        as String?,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            isRead:
                null == isRead
                    ? _value.isRead
                    : isRead // ignore: cast_nullable_to_non_nullable
                        as bool,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String chatId,
    String senderId,
    String? senderName,
    String? senderPhoto,
    String content,
    bool isRead,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? senderName = freezed,
    Object? senderPhoto = freezed,
    Object? content = null,
    Object? isRead = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        chatId:
            null == chatId
                ? _value.chatId
                : chatId // ignore: cast_nullable_to_non_nullable
                    as String,
        senderId:
            null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                    as String,
        senderName:
            freezed == senderName
                ? _value.senderName
                : senderName // ignore: cast_nullable_to_non_nullable
                    as String?,
        senderPhoto:
            freezed == senderPhoto
                ? _value.senderPhoto
                : senderPhoto // ignore: cast_nullable_to_non_nullable
                    as String?,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        isRead:
            null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                    as bool,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.senderName,
    this.senderPhoto,
    required this.content,
    this.isRead = false,
    required this.createdAt,
  });

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String chatId;
  @override
  final String senderId;
  @override
  final String? senderName;
  @override
  final String? senderPhoto;
  @override
  final String content;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ChatMessage(id: $id, chatId: $chatId, senderId: $senderId, senderName: $senderName, senderPhoto: $senderPhoto, content: $content, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderPhoto, senderPhoto) ||
                other.senderPhoto == senderPhoto) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    chatId,
    senderId,
    senderName,
    senderPhoto,
    content,
    isRead,
    createdAt,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String chatId,
    required final String senderId,
    final String? senderName,
    final String? senderPhoto,
    required final String content,
    final bool isRead,
    required final DateTime createdAt,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get chatId;
  @override
  String get senderId;
  @override
  String? get senderName;
  @override
  String? get senderPhoto;
  @override
  String get content;
  @override
  bool get isRead;
  @override
  DateTime get createdAt;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StartChatRequest _$StartChatRequestFromJson(Map<String, dynamic> json) {
  return _StartChatRequest.fromJson(json);
}

/// @nodoc
mixin _$StartChatRequest {
  String get vetId => throw _privateConstructorUsedError;
  String? get petId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this StartChatRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StartChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StartChatRequestCopyWith<StartChatRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StartChatRequestCopyWith<$Res> {
  factory $StartChatRequestCopyWith(
    StartChatRequest value,
    $Res Function(StartChatRequest) then,
  ) = _$StartChatRequestCopyWithImpl<$Res, StartChatRequest>;
  @useResult
  $Res call({String vetId, String? petId, String? message});
}

/// @nodoc
class _$StartChatRequestCopyWithImpl<$Res, $Val extends StartChatRequest>
    implements $StartChatRequestCopyWith<$Res> {
  _$StartChatRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StartChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vetId = null,
    Object? petId = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            vetId:
                null == vetId
                    ? _value.vetId
                    : vetId // ignore: cast_nullable_to_non_nullable
                        as String,
            petId:
                freezed == petId
                    ? _value.petId
                    : petId // ignore: cast_nullable_to_non_nullable
                        as String?,
            message:
                freezed == message
                    ? _value.message
                    : message // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StartChatRequestImplCopyWith<$Res>
    implements $StartChatRequestCopyWith<$Res> {
  factory _$$StartChatRequestImplCopyWith(
    _$StartChatRequestImpl value,
    $Res Function(_$StartChatRequestImpl) then,
  ) = __$$StartChatRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String vetId, String? petId, String? message});
}

/// @nodoc
class __$$StartChatRequestImplCopyWithImpl<$Res>
    extends _$StartChatRequestCopyWithImpl<$Res, _$StartChatRequestImpl>
    implements _$$StartChatRequestImplCopyWith<$Res> {
  __$$StartChatRequestImplCopyWithImpl(
    _$StartChatRequestImpl _value,
    $Res Function(_$StartChatRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StartChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vetId = null,
    Object? petId = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _$StartChatRequestImpl(
        vetId:
            null == vetId
                ? _value.vetId
                : vetId // ignore: cast_nullable_to_non_nullable
                    as String,
        petId:
            freezed == petId
                ? _value.petId
                : petId // ignore: cast_nullable_to_non_nullable
                    as String?,
        message:
            freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StartChatRequestImpl implements _StartChatRequest {
  const _$StartChatRequestImpl({required this.vetId, this.petId, this.message});

  factory _$StartChatRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$StartChatRequestImplFromJson(json);

  @override
  final String vetId;
  @override
  final String? petId;
  @override
  final String? message;

  @override
  String toString() {
    return 'StartChatRequest(vetId: $vetId, petId: $petId, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StartChatRequestImpl &&
            (identical(other.vetId, vetId) || other.vetId == vetId) &&
            (identical(other.petId, petId) || other.petId == petId) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, vetId, petId, message);

  /// Create a copy of StartChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StartChatRequestImplCopyWith<_$StartChatRequestImpl> get copyWith =>
      __$$StartChatRequestImplCopyWithImpl<_$StartChatRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StartChatRequestImplToJson(this);
  }
}

abstract class _StartChatRequest implements StartChatRequest {
  const factory _StartChatRequest({
    required final String vetId,
    final String? petId,
    final String? message,
  }) = _$StartChatRequestImpl;

  factory _StartChatRequest.fromJson(Map<String, dynamic> json) =
      _$StartChatRequestImpl.fromJson;

  @override
  String get vetId;
  @override
  String? get petId;
  @override
  String? get message;

  /// Create a copy of StartChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StartChatRequestImplCopyWith<_$StartChatRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) {
  return _SendMessageRequest.fromJson(json);
}

/// @nodoc
mixin _$SendMessageRequest {
  String get chatId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// Serializes this SendMessageRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SendMessageRequestCopyWith<SendMessageRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendMessageRequestCopyWith<$Res> {
  factory $SendMessageRequestCopyWith(
    SendMessageRequest value,
    $Res Function(SendMessageRequest) then,
  ) = _$SendMessageRequestCopyWithImpl<$Res, SendMessageRequest>;
  @useResult
  $Res call({String chatId, String content});
}

/// @nodoc
class _$SendMessageRequestCopyWithImpl<$Res, $Val extends SendMessageRequest>
    implements $SendMessageRequestCopyWith<$Res> {
  _$SendMessageRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? chatId = null, Object? content = null}) {
    return _then(
      _value.copyWith(
            chatId:
                null == chatId
                    ? _value.chatId
                    : chatId // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SendMessageRequestImplCopyWith<$Res>
    implements $SendMessageRequestCopyWith<$Res> {
  factory _$$SendMessageRequestImplCopyWith(
    _$SendMessageRequestImpl value,
    $Res Function(_$SendMessageRequestImpl) then,
  ) = __$$SendMessageRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String chatId, String content});
}

/// @nodoc
class __$$SendMessageRequestImplCopyWithImpl<$Res>
    extends _$SendMessageRequestCopyWithImpl<$Res, _$SendMessageRequestImpl>
    implements _$$SendMessageRequestImplCopyWith<$Res> {
  __$$SendMessageRequestImplCopyWithImpl(
    _$SendMessageRequestImpl _value,
    $Res Function(_$SendMessageRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? chatId = null, Object? content = null}) {
    return _then(
      _$SendMessageRequestImpl(
        chatId:
            null == chatId
                ? _value.chatId
                : chatId // ignore: cast_nullable_to_non_nullable
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
@JsonSerializable()
class _$SendMessageRequestImpl implements _SendMessageRequest {
  const _$SendMessageRequestImpl({required this.chatId, required this.content});

  factory _$SendMessageRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SendMessageRequestImplFromJson(json);

  @override
  final String chatId;
  @override
  final String content;

  @override
  String toString() {
    return 'SendMessageRequest(chatId: $chatId, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendMessageRequestImpl &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, chatId, content);

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendMessageRequestImplCopyWith<_$SendMessageRequestImpl> get copyWith =>
      __$$SendMessageRequestImplCopyWithImpl<_$SendMessageRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SendMessageRequestImplToJson(this);
  }
}

abstract class _SendMessageRequest implements SendMessageRequest {
  const factory _SendMessageRequest({
    required final String chatId,
    required final String content,
  }) = _$SendMessageRequestImpl;

  factory _SendMessageRequest.fromJson(Map<String, dynamic> json) =
      _$SendMessageRequestImpl.fromJson;

  @override
  String get chatId;
  @override
  String get content;

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendMessageRequestImplCopyWith<_$SendMessageRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
