import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/api_client.dart';
import '../models/vet_profile_model.dart';
import '../models/vet_review_model.dart';

@lazySingleton
class VetRepository {
  final ApiClient _apiClient;

  VetRepository(this._apiClient);

  /// Create or update vet profile
  Future<VetProfile> createOrUpdateProfile(VetProfileRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/vets/profile',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return VetProfile.fromJson(response.data['vetProfile']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to save vet profile');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to save vet profile');
    }
  }

  /// Get my vet profile
  Future<VetProfile> getMyProfile() async {
    try {
      final response = await _apiClient.get('/api/v1/vets/profile/me');

      if (response.data['success'] == true) {
        return VetProfile.fromJson(response.data['vetProfile']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch vet profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Profile not found');
      }
      throw _handleError(e, 'Failed to fetch vet profile');
    }
  }

  /// Get vet profile by user ID
  Future<VetProfile> getVetProfile(String userId) async {
    try {
      final response = await _apiClient.get('/api/v1/vets/profile/$userId');

      if (response.data['success'] == true) {
        return VetProfile.fromJson(response.data['vetProfile']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch vet profile');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch vet profile');
    }
  }

  /// List all vets with optional filters
  Future<({List<VetProfile> vets, int total, int page, int limit})> listVets({
    String? city,
    String? specialization,
    double? minRating,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (specialization != null && specialization.isNotEmpty) {
        queryParams['specialization'] = specialization;
      }
      if (minRating != null) {
        queryParams['minRating'] = minRating;
      }

      final response = await _apiClient.get(
        '/api/v1/vets',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final vets = (response.data['vets'] as List)
            .map((json) => VetProfile.fromJson(json))
            .toList();
        
        final pagination = response.data['pagination'];
        
        return (
          vets: vets,
          total: pagination['total'] as int,
          page: pagination['page'] as int,
          limit: pagination['limit'] as int,
        );
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch vets');
      }
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch vets');
    }
  }

  Future<List<VetReview>> getVetReviews(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/vets/$userId/reviews',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final reviews = (response.data['reviews'] as List<dynamic>? ?? const [])
            .map((json) => VetReview.fromJson(json as Map<String, dynamic>))
            .toList();
        return reviews;
      }

      throw Exception(response.data['error'] ?? 'Failed to fetch vet reviews');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch vet reviews');
    }
  }

  Future<VetReview> addVetReview(
    String userId, {
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/vets/$userId/reviews',
        data: {
          'rating': rating,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
        },
      );

      if (response.data['success'] == true) {
        return VetReview.fromJson(response.data['review'] as Map<String, dynamic>);
      }

      throw Exception(response.data['error'] ?? 'Failed to submit vet review');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to submit vet review');
    }
  }

  Exception _handleError(DioException e, String defaultMessage) {
    final responseData = e.response?.data;

    if (responseData is Map) {
      final error =
          responseData['error'] ??
          responseData['message'] ??
          responseData['details'];
      if (error is String && error.trim().isNotEmpty) {
        return Exception(error.trim());
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return Exception(responseData.trim());
    }

    if (e.response != null) {
      return Exception(defaultMessage);
    }

    return Exception('Network error: ${e.message}');
  }
}
