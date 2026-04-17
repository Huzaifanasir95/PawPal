import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/chat/data/models/chat_model.dart';

class ChatThreadCacheEntry {
  final Chat chat;
  final List<ChatMessage> messages;
  final DateTime savedAt;

  const ChatThreadCacheEntry({
    required this.chat,
    required this.messages,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'chat': chat.toJson(),
      'messages': messages.map((message) => message.toJson()).toList(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory ChatThreadCacheEntry.fromJson(Map<String, dynamic> json) {
    return ChatThreadCacheEntry(
      chat: Chat.fromJson(json['chat'] as Map<String, dynamic>),
      messages: (json['messages'] as List<dynamic>)
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}

class ChatCacheService {
  static const _threadPrefix = 'chat_thread_cache_';
  static const _chatsPrefix = 'chat_list_cache_';

  Future<ChatThreadCacheEntry?> readThread(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_threadKey(chatId));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return ChatThreadCacheEntry.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      await prefs.remove(_threadKey(chatId));
      return null;
    }
  }

  Future<void> writeThread(Chat chat, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final entry = ChatThreadCacheEntry(
      chat: chat,
      messages: messages,
      savedAt: DateTime.now(),
    );

    await prefs.setString(_threadKey(chat.id), jsonEncode(entry.toJson()));
  }

  Future<void> clearThread(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_threadKey(chatId));
  }

  Future<List<Chat>> readChatsList(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatsKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Chat.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      await prefs.remove(_chatsKey(userId));
      return const [];
    }
  }

  Future<void> writeChatsList(String userId, List<Chat> chats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chatsKey(userId),
      jsonEncode(chats.map((chat) => chat.toJson()).toList()),
    );
  }

  Future<void> clearChatsList(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatsKey(userId));
  }

  String _threadKey(String chatId) => '$_threadPrefix$chatId';
  String _chatsKey(String userId) => '$_chatsPrefix$userId';
}