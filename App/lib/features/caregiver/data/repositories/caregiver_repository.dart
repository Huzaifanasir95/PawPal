import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/api_client.dart';
import '../models/caregiver_models.dart';
import '../models/booking_models.dart';

@lazySingleton
class CaregiverRepository {
  final ApiClient _apiClient;

  CaregiverRepository(this._apiClient);

  // ============================================
  // SERVICE TYPES
  // ============================================

  Future<List<CaregiverServiceType>> getServiceTypes() async {
    try {
      final response = await _apiClient.get('/api/v1/caregivers/service-types');
      final types =
          (response.data['serviceTypes'] as List)
              .map((json) => CaregiverServiceType.fromJson(json))
              .toList();
      return types;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch service types');
    }
  }

  // ============================================
  // CAREGIVER PROFILE
  // ============================================

  Future<CaregiverProfile> createProfile(
    CreateCaregiverProfileRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/caregivers/profile',
        data: request.toJson(),
      );
      return CaregiverProfile.fromJson(response.data['profile']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create caregiver profile');
    }
  }

  Future<
    ({
      CaregiverProfile profile,
      List<CaregiverAvailability>? availability,
      List<CaregiverGalleryItem>? gallery,
    })
  >
  getMyProfile() async {
    try {
      final response = await _apiClient.get('/api/v1/caregivers/profile');

      final baseProfile = CaregiverProfile.fromJson(response.data['profile']);

      List<CaregiverService> services = const [];
      if (response.data['services'] != null) {
        services =
            (response.data['services'] as List)
                .map((json) => CaregiverService.fromJson(json))
                .toList();
      }

      final profile = baseProfile.copyWith(services: services);

      List<CaregiverAvailability>? availability;
      if (response.data['availability'] != null) {
        availability =
            (response.data['availability'] as List)
                .map((json) => CaregiverAvailability.fromJson(json))
                .toList();
      }

      List<CaregiverGalleryItem>? gallery;
      if (response.data['gallery'] != null) {
        gallery =
            (response.data['gallery'] as List)
                .map((json) => CaregiverGalleryItem.fromJson(json))
                .toList();
      }

      return (profile: profile, availability: availability, gallery: gallery);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch caregiver profile');
    }
  }

  Future<void> updateProfile(CreateCaregiverProfileRequest request) async {
    try {
      await _apiClient.put(
        '/api/v1/caregivers/profile',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update caregiver profile');
    }
  }

  Future<
    ({
      CaregiverProfile profile,
      List<CaregiverService> services,
      List<CaregiverAvailability>? availability,
      List<CaregiverGalleryItem>? gallery,
      List<CaregiverBlockedDate>? blockedDates,
    })
  >
  getCaregiverById(String caregiverId) async {
    try {
      final response = await _apiClient.get('/api/v1/caregivers/$caregiverId');

      final profile = CaregiverProfile.fromJson(response.data['profile']);

      final services =
          (response.data['services'] as List? ?? [])
              .map((json) => CaregiverService.fromJson(json))
              .toList();

      List<CaregiverAvailability>? availability;
      if (response.data['availability'] != null) {
        availability =
            (response.data['availability'] as List)
                .map((json) => CaregiverAvailability.fromJson(json))
                .toList();
      }

      List<CaregiverGalleryItem>? gallery;
      if (response.data['gallery'] != null) {
        gallery =
            (response.data['gallery'] as List)
                .map((json) => CaregiverGalleryItem.fromJson(json))
                .toList();
      }

      List<CaregiverBlockedDate>? blockedDates;
      if (response.data['blockedDates'] != null) {
        blockedDates =
            (response.data['blockedDates'] as List)
                .map((json) => CaregiverBlockedDate.fromJson(json))
                .toList();
      }

      return (
        profile: profile,
        services: services,
        availability: availability,
        gallery: gallery,
        blockedDates: blockedDates,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch caregiver');
    }
  }

  Future<({List<CaregiverProfile> caregivers, int total, int page, int limit})>
  searchCaregivers({
    String? city,
    String? serviceType,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? petType,
    double? minRating,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (serviceType != null) queryParams['serviceType'] = serviceType;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radiusKm != null) {
        queryParams['radius'] = radiusKm;
        queryParams['radiusKm'] = radiusKm;
      }
      if (petType != null) queryParams['petType'] = petType;
      if (minRating != null) queryParams['minRating'] = minRating;

      final response = await _apiClient.get(
        '/api/v1/caregivers/search',
        queryParameters: queryParams,
      );

      final caregivers =
          (response.data['caregivers'] as List? ?? [])
              .map((json) => CaregiverProfile.fromJson(json))
              .toList();

      return (
        caregivers: caregivers,
        total: (response.data['total'] as int?) ?? caregivers.length,
        page: (response.data['page'] as int?) ?? page,
        limit: (response.data['limit'] as int?) ?? limit,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to search caregivers');
    }
  }

  // ============================================
  // SERVICES
  // ============================================

  Future<CaregiverService> addService(
    AddCaregiverServiceRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/caregivers/services',
        data: request.toJson(),
      );
      return CaregiverService.fromJson(response.data['service']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to add service');
    }
  }

  Future<void> updateService(
    String serviceId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _apiClient.put(
        '/api/v1/caregivers/services/$serviceId',
        data: updates,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update service');
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _apiClient.delete('/api/v1/caregivers/services/$serviceId');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete service');
    }
  }

  // ============================================
  // AVAILABILITY
  // ============================================

  Future<List<CaregiverAvailability>> getAvailability() async {
    try {
      final response = await _apiClient.get('/api/v1/caregivers/availability');
      return (response.data['availability'] as List? ?? [])
          .map((json) => CaregiverAvailability.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch availability');
    }
  }

  Future<void> setAvailability(SetAvailabilityRequest request) async {
    try {
      await _apiClient.post(
        '/api/v1/caregivers/availability',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to set availability');
    }
  }

  Future<void> addBlockedDate(String date, String? reason) async {
    try {
      await _apiClient.post(
        '/api/v1/caregivers/blocked-dates',
        data: {'blockedDate': date, if (reason != null) 'reason': reason},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to add blocked date');
    }
  }

  Future<void> removeBlockedDate(String dateId) async {
    try {
      await _apiClient.delete('/api/v1/caregivers/blocked-dates/$dateId');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to remove blocked date');
    }
  }

  // ============================================
  // GALLERY
  // ============================================

  Future<CaregiverGalleryItem> addGalleryImage(
    String imageUrl,
    String? caption,
    String imageType,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/caregivers/gallery',
        data: {
          'imageUrl': imageUrl,
          if (caption != null) 'caption': caption,
          'imageType': imageType,
        },
      );
      return CaregiverGalleryItem.fromJson(response.data['image']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to add gallery image');
    }
  }

  Future<void> deleteGalleryImage(String imageId) async {
    try {
      await _apiClient.delete('/api/v1/caregivers/gallery/$imageId');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete gallery image');
    }
  }

  // ============================================
  // REVIEWS
  // ============================================

  Future<({List<ServiceReview> reviews, int total, int page, int limit})>
  getCaregiverReviews(
    String caregiverId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/caregivers/$caregiverId/reviews',
        queryParameters: {'page': page, 'limit': limit},
      );

      final reviews =
          (response.data['reviews'] as List? ?? [])
              .map((json) => ServiceReview.fromJson(json))
              .toList();

      return (
        reviews: reviews,
        total: (response.data['total'] as int?) ?? reviews.length,
        page: (response.data['page'] as int?) ?? page,
        limit: (response.data['limit'] as int?) ?? limit,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch reviews');
    }
  }

  // ============================================
  // HELPER
  // ============================================

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
