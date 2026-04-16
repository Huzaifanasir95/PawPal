import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/api_client.dart';
import '../models/booking_models.dart';

@lazySingleton
class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository(this._apiClient);

  // ============================================
  // BOOKINGS CRUD
  // ============================================

  Future<ServiceBooking> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/bookings',
        data: request.toJson(),
      );
      return ServiceBooking.fromJson(response.data['booking']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create booking');
    }
  }

  Future<ServiceBooking> getBooking(String bookingId) async {
    try {
      final response = await _apiClient.get('/api/v1/bookings/$bookingId');
      return ServiceBooking.fromJson(response.data['booking']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch booking');
    }
  }

  Future<
    ({
      ServiceBooking booking,
      CompletionReport? completionReport,
      List<ServiceIncident>? incidents,
      List<BookingPayment>? payments,
    })
  >
  getBookingDetails(String bookingId) async {
    try {
      final response = await _apiClient.get('/api/v1/bookings/$bookingId');

      final booking = ServiceBooking.fromJson(response.data['booking']);

      CompletionReport? completionReport;
      if (response.data['completionReport'] != null) {
        completionReport = CompletionReport.fromJson(
          response.data['completionReport'],
        );
      }

      List<ServiceIncident>? incidents;
      if (response.data['incidents'] != null) {
        incidents =
            (response.data['incidents'] as List)
                .map((json) => ServiceIncident.fromJson(json))
                .toList();
      }

      List<BookingPayment>? payments;
      if (response.data['payments'] != null) {
        payments =
            (response.data['payments'] as List)
                .map((json) => BookingPayment.fromJson(json))
                .toList();
      }

      return (
        booking: booking,
        completionReport: completionReport,
        incidents: incidents,
        payments: payments,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch booking details');
    }
  }

  Future<({List<ServiceBooking> bookings, int total, int page, int limit})>
  getMyBookings({
    required String role, // 'owner' or 'caregiver'
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'role': role,
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get(
        '/api/v1/bookings',
        queryParameters: queryParams,
      );

      final bookings =
          (response.data['bookings'] as List? ?? [])
              .map((json) => ServiceBooking.fromJson(json))
              .toList();

      return (
        bookings: bookings,
        total: (response.data['total'] as int?) ?? bookings.length,
        page: (response.data['page'] as int?) ?? page,
        limit: (response.data['limit'] as int?) ?? limit,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch bookings');
    }
  }

  // ============================================
  // BOOKING ACTIONS
  // ============================================

  Future<void> respondToBooking(
    String bookingId,
    RespondToBookingRequest request,
  ) async {
    try {
      await _apiClient.post(
        '/api/v1/bookings/$bookingId/respond',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to respond to booking');
    }
  }

  Future<void> cancelBooking(
    String bookingId,
    CancelBookingRequest request,
  ) async {
    try {
      await _apiClient.post(
        '/api/v1/bookings/$bookingId/cancel',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to cancel booking');
    }
  }

  Future<void> startService(
    String bookingId,
    StartServiceRequest request,
  ) async {
    try {
      await _apiClient.post(
        '/api/v1/bookings/$bookingId/start',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to start service');
    }
  }

  // ============================================
  // TRACKING
  // ============================================

  Future<BookingTracking> addTracking(
    String bookingId,
    AddTrackingRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/bookings/$bookingId/tracking',
        data: request.toJson(),
      );
      return BookingTracking.fromJson(response.data['tracking']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to add tracking point');
    }
  }

  Future<List<BookingTracking>> getTracking(String bookingId) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/bookings/$bookingId/tracking',
      );
      return (response.data['tracking'] as List? ?? [])
          .map((json) => BookingTracking.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch tracking');
    }
  }

  // ============================================
  // COMPLETION
  // ============================================

  Future<CompletionReport> completeService(
    String bookingId,
    SubmitCompletionReportRequest request,
  ) async {
    try {
      final payload = <String, dynamic>{
        'summary': request.summary,
        if (request.activitiesPerformed != null)
          'activitiesPerformed': request.activitiesPerformed,
        if (request.behaviorNotes != null)
          'behaviorNotes': request.behaviorNotes,
        if (request.feedingNotes != null) 'feedingNotes': request.feedingNotes,
        if (request.actualDurationMinutes != null)
          'actualDurationMinutes': request.actualDurationMinutes,
        if (request.distanceWalkedKm != null)
          'distanceWalkedKm': request.distanceWalkedKm,
        if (request.photos != null && request.photos!.isNotEmpty)
          'photoUrls': request.photos,
      };

      final response = await _apiClient.post(
        '/api/v1/bookings/$bookingId/complete',
        data: payload,
      );
      return CompletionReport.fromJson(response.data['report']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to complete service');
    }
  }

  // ============================================
  // REVIEWS
  // ============================================

  Future<void> submitOwnerReview(
    String bookingId,
    SubmitOwnerReviewRequest request,
  ) async {
    try {
      final payload = <String, dynamic>{
        'overallRating': request.rating,
        if (request.review != null && request.review!.trim().isNotEmpty)
          'review': request.review,
        if (request.communicationRating != null)
          'communicationRating': request.communicationRating,
        if (request.reliabilityRating != null)
          'reliabilityRating': request.reliabilityRating,
        if (request.careQualityRating != null)
          'careQualityRating': request.careQualityRating,
      };

      await _apiClient.post(
        '/api/v1/bookings/$bookingId/review/owner',
        data: payload,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to submit review');
    }
  }

  Future<void> submitCaregiverReview(
    String bookingId,
    SubmitCaregiverReviewRequest request,
  ) async {
    try {
      final payload = <String, dynamic>{
        'overallRating': request.rating,
        if (request.review != null && request.review!.trim().isNotEmpty)
          'review': request.review,
        if (request.petBehaviorRating != null)
          'petBehaviorRating': request.petBehaviorRating,
      };

      await _apiClient.post(
        '/api/v1/bookings/$bookingId/review/caregiver',
        data: payload,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to submit review');
    }
  }

  // ============================================
  // PAYMENTS
  // ============================================

  Future<BookingPayment> processPayment(
    String bookingId,
    ProcessPaymentRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/bookings/$bookingId/payments',
        data: {
          'paymentMethod': request.paymentMethod,
          'paymentType': request.paymentType,
        },
      );
      return BookingPayment.fromJson(response.data['payment']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to process payment');
    }
  }

  Future<List<BookingPayment>> getPayments(String bookingId) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/bookings/$bookingId/payments',
      );
      return (response.data['payments'] as List? ?? [])
          .map((json) => BookingPayment.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch payments');
    }
  }

  // ============================================
  // INCIDENTS
  // ============================================

  Future<ServiceIncident> reportIncident(
    String bookingId,
    ReportIncidentRequest request,
  ) async {
    try {
      final payload = <String, dynamic>{
        'incidentType': request.incidentType,
        'severity': request.severity,
        'description': request.description,
        if (request.photos != null && request.photos!.isNotEmpty)
          'photoUrls': request.photos,
      };

      final response = await _apiClient.post(
        '/api/v1/bookings/$bookingId/incidents',
        data: payload,
      );
      return ServiceIncident.fromJson(response.data['incident']);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to report incident');
    }
  }

  // ============================================
  // HELPER
  // ============================================

  Exception _handleError(DioException e, String defaultMessage) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        final error = data['error'] ?? data['message'] ?? data['details'];
        if (error is String && error.trim().isNotEmpty) {
          return Exception(error.trim());
        }
      }
      return Exception(defaultMessage);
    }
    return Exception('Network error: ${e.message}');
  }
}
