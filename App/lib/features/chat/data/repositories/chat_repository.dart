import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/api_client.dart';
import '../models/chat_model.dart';

@lazySingleton
class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  /// Start a new chat with a vet
  Future<Chat> startChat(StartChatRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/chats',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return Chat.fromJson(response.data['chat']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to start chat');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'] ?? 'Failed to start chat';
        throw Exception(error);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get all my chats
  Future<List<Chat>> getMyChats() async {
    try {
      final response = await _apiClient.get('/api/v1/chats');

      if (response.data['success'] == true) {
        final chats = (response.data['chats'] as List)
            .map((json) => Chat.fromJson(json))
            .toList();
        return chats;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch chats');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'] ?? 'Failed to fetch chats';
        throw Exception(error);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get a specific chat by ID
  Future<Chat> getChat(String chatId) async {
    try {
      final response = await _apiClient.get('/api/v1/chats/$chatId');

      if (response.data['success'] == true) {
        return Chat.fromJson(response.data['chat']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch chat');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'] ?? 'Failed to fetch chat';
        throw Exception(error);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Send a message in a chat
  Future<ChatMessage> sendMessage(SendMessageRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/messages',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return ChatMessage.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to send message');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'] ?? 'Failed to send message';
        throw Exception(error);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get messages for a chat
  Future<List<ChatMessage>> getChatMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/messages/$chatId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] == true) {
        final messages = (response.data['messages'] as List)
            .map((json) => ChatMessage.fromJson(json))
            .toList();
        return messages;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch messages');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'] ?? 'Failed to fetch messages';
        throw Exception(error);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Mark a message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final response = await _apiClient.put('/api/v1/messages/$messageId/read');

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to mark message as read');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'] ?? 'Failed to mark message as read';
        throw Exception(error);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      final response = await _apiClient.delete('/api/v1/chats/$chatId');

      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to delete chat');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'] ?? 'Failed to delete chat';
        throw Exception(error);
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
