import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/chat_model.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.chatsLoaded(List<Chat> chats) = _ChatsLoaded;
  const factory ChatState.chatLoaded({
    required Chat chat,
    required List<ChatMessage> messages,
    required bool hasMore,
    required int currentPage,
  }) = _ChatLoaded;
  const factory ChatState.chatStarted(Chat chat) = _ChatStarted;
  const factory ChatState.messageSent(ChatMessage message) = _MessageSent;
  const factory ChatState.messageMarkedAsRead(String messageId) = _MessageMarkedAsRead;
  const factory ChatState.chatDeleted(String chatId) = _ChatDeleted;
  const factory ChatState.error(String message) = _Error;
}
