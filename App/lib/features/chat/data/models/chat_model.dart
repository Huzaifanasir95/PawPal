import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
class Chat with _$Chat {
  const factory Chat({
    required String id,
    required String petOwnerId,
    required String vetId,
    String? petId,
    String? petName,
    String? lastMessage,
    DateTime? lastMessageAt,
    @Default(0) int unreadCountOwner,
    @Default(0) int unreadCountVet,
    String? otherUserName,
    String? otherUserPhoto,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String chatId,
    required String senderId,
    String? senderName,
    String? senderPhoto,
    required String content,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class StartChatRequest with _$StartChatRequest {
  const factory StartChatRequest({
    required String vetId,
    String? petId,
    String? message,
  }) = _StartChatRequest;

  factory StartChatRequest.fromJson(Map<String, dynamic> json) =>
      _$StartChatRequestFromJson(json);
}

@freezed
class SendMessageRequest with _$SendMessageRequest {
  const factory SendMessageRequest({
    required String chatId,
    required String content,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
}
