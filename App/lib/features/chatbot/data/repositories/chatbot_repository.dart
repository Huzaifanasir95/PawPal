import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/api_client.dart';

@lazySingleton
class ChatbotRepository {
  final ApiClient _apiClient;

  ChatbotRepository(this._apiClient);

  /// Query the RAG chatbot
  Future<ChatbotResponse> query(String message) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/chatbot/query',
        data: {'message': message},
      );

      if (response.data['success'] == true) {
        return ChatbotResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get chatbot response');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data['error'] ?? 'Failed to get chatbot response';
        throw Exception(error);
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}

class ChatbotResponse {
  
  final String answer;
  final String query;
  final List<ChatbotSource> sources;

  ChatbotResponse({
    required this.answer,
    required this.query,
    required this.sources,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    print("Hello");
    return ChatbotResponse(
      answer: json['answer'] ?? '',
      query: json['query'] ?? json['enhanced_query'] ?? '',
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => ChatbotSource.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChatbotSource {
  final String content;
  final Map<String, dynamic> metadata;

  ChatbotSource({
    required this.content,
    required this.metadata,
  });

  factory ChatbotSource.fromJson(Map<String, dynamic> json) {
    return ChatbotSource(
      content: json['content'] ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}
