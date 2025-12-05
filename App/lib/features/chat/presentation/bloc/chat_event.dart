import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_event.freezed.dart';

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent.loadChats() = _LoadChats;
  const factory ChatEvent.loadChat(String chatId) = _LoadChat;
  const factory ChatEvent.startChat({
    required String vetId,
    required String petId,
  }) = _StartChat;
  const factory ChatEvent.sendMessage({
    required String chatId,
    required String content,
  }) = _SendMessage;
  const factory ChatEvent.loadMessages({
    required String chatId,
    @Default(1) int page,
    @Default(50) int limit,
  }) = _LoadMessages;
  const factory ChatEvent.markAsRead(String messageId) = _MarkAsRead;
  const factory ChatEvent.deleteChat(String chatId) = _DeleteChat;
  const factory ChatEvent.refreshChats() = _RefreshChats;
}
