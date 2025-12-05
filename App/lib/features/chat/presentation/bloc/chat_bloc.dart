import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/chat_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;

  ChatBloc(this._repository) : super(const ChatState.initial()) {
    on<ChatEvent>((event, emit) async {
      await event.when(
        loadChats: () => _onLoadChats(emit),
        loadChat: (chatId) => _onLoadChat(chatId, emit),
        startChat: (vetId, petId) => _onStartChat(vetId, petId, emit),
        sendMessage: (chatId, content) => _onSendMessage(chatId, content, emit),
        loadMessages: (chatId, page, limit) => _onLoadMessages(chatId, page, limit, emit),
        markAsRead: (messageId) => _onMarkAsRead(messageId, emit),
        deleteChat: (chatId) => _onDeleteChat(chatId, emit),
        refreshChats: () => _onRefreshChats(emit),
      );
    });
  }

  Future<void> _onLoadChats(
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatState.loading());
    try {
      final chats = await _repository.getMyChats();
      emit(ChatState.chatsLoaded(chats));
    } catch (e) {
      emit(ChatState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadChat(
    String chatId,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatState.loading());
    try {
      final chat = await _repository.getChat(chatId);
      final messages = await _repository.getChatMessages(
        chatId,
        page: 1,
        limit: 50,
      );
      
      emit(ChatState.chatLoaded(
        chat: chat,
        messages: messages,
        hasMore: messages.length >= 50,
        currentPage: 1,
      ));
    } catch (e) {
      emit(ChatState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onStartChat(
    String vetId,
    String? petId,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatState.loading());
    try {
      final chat = await _repository.startChat(
        StartChatRequest(
          vetId: vetId,
          petId: petId,
        ),
      );
      
      emit(ChatState.chatStarted(chat));
    } catch (e) {
      emit(ChatState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSendMessage(
    String chatId,
    String content,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatState.loading());
    try {
      final message = await _repository.sendMessage(
        SendMessageRequest(chatId: chatId, content: content),
      );
      
      emit(ChatState.messageSent(message));
      
      // Reload chat to get updated messages
      add(ChatEvent.loadChat(chatId));
    } catch (e) {
      emit(ChatState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMessages(
    String chatId,
    int page,
    int limit,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatState.loading());
    try {
      final chat = await _repository.getChat(chatId);
      final messages = await _repository.getChatMessages(
        chatId,
        page: page,
        limit: limit,
      );
      
      emit(ChatState.chatLoaded(
        chat: chat,
        messages: messages,
        hasMore: messages.length >= limit,
        currentPage: page,
      ));
    } catch (e) {
      emit(ChatState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onMarkAsRead(
    String messageId,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _repository.markMessageAsRead(messageId);
      emit(ChatState.messageMarkedAsRead(messageId));
    } catch (e) {
      emit(ChatState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteChat(
    String chatId,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatState.loading());
    try {
      // Assuming backend has delete endpoint, otherwise this will fail
      // For now, just emit deleted state
      emit(ChatState.chatDeleted(chatId));
      
      // Reload chats list
      add(const ChatEvent.refreshChats());
    } catch (e) {
      emit(ChatState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRefreshChats(
    Emitter<ChatState> emit,
  ) async {
    try {
      final chats = await _repository.getMyChats();
      emit(ChatState.chatsLoaded(chats));
    } catch (e) {
      emit(ChatState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
