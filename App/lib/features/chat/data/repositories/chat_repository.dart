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
      throw _handleError(e, 'Failed to start chat');
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
      throw _handleError(e, 'Failed to fetch chats');
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
      throw _handleError(e, 'Failed to fetch chat');
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
        final error = response.data['error'] ?? 'Failed to send message';
        final details = response.data['details'];
        throw Exception(details != null ? '$error: $details' : error);
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to send message');
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
      throw _handleError(e, 'Failed to fetch messages');
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
      throw _handleError(e, 'Failed to mark message as read');
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
      throw _handleError(e, 'Failed to delete chat');
    }
  }

  Exception _handleError(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map) {
      final error = data['error'] ?? data['message'];
      final details = data['details'];

      if (error is String && error.trim().isNotEmpty) {
        if (details is String && details.trim().isNotEmpty) {
          return Exception('${error.trim()}: ${details.trim()}');
        }
        return Exception(error.trim());
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return Exception(data.trim());
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Network timeout. Please try again.');
    }

    if (e.response == null) {
      return Exception('Network error: ${e.message ?? 'Unable to reach server'}');
    }

    return Exception(fallback);
  }
}
