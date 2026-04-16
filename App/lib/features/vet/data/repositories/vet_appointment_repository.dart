import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';
import '../models/vet_appointment_model.dart';

class VetAppointmentRepository {
  final ApiClient _apiClient;

  VetAppointmentRepository([ApiClient? apiClient])
    : _apiClient = apiClient ?? ApiClient.instance;

  Future<VetAppointment> createAppointment(
    CreateVetAppointmentRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/vet-appointments',
        data: request.toJson(),
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw Exception('Unexpected server response while creating appointment');
      }

      final success = payload['success'];
      if (success is bool && !success) {
        throw Exception(
          (payload['error'] ?? payload['message'] ?? 'Failed to create appointment')
              .toString(),
        );
      }

      final nestedData = payload['data'];
      final dynamic appointmentJson =
          payload['appointment'] ??
          (nestedData is Map ? nestedData['appointment'] : null) ??
          (nestedData is Map ? nestedData : null);

      if (appointmentJson is! Map) {
        throw Exception('Appointment was created but response payload was incomplete');
      }

      return VetAppointment.fromJson(
        Map<String, dynamic>.from(appointmentJson as Map),
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create appointment');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<({List<VetAppointment> appointments, int total, int page, int limit})>
  getMyAppointments({
    String role = 'owner',
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final query = <String, dynamic>{
        'role': role,
        'page': page,
        'limit': limit,
        if (status != null && status.trim().isNotEmpty) 'status': status,
      };

      final response = await _apiClient.get(
        '/api/v1/vet-appointments',
        queryParameters: query,
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw Exception('Unexpected server response while loading appointments');
      }

      if (payload['success'] != true) {
        throw Exception(
          payload['error'] ?? 'Failed to fetch appointments',
        );
      }

      final items =
          (payload['appointments'] as List? ?? [])
              .map(
                (item) => VetAppointment.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();

      final pagination =
          (payload['pagination'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};

      return (
        appointments: items,
        total: (pagination['total'] as int?) ?? items.length,
        page: (pagination['page'] as int?) ?? page,
        limit: (pagination['limit'] as int?) ?? limit,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch appointments');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _apiClient.post(
        '/api/v1/vet-appointments/$appointmentId/cancel',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to cancel appointment');
    }
  }

  Exception _handleError(DioException e, String fallbackMessage) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['error'] ?? data['message'] ?? data['details'];
      if (message is String && message.trim().isNotEmpty) {
        return Exception(message.trim());
      }
    }

    if (e.response != null) {
      return Exception(fallbackMessage);
    }

    return Exception('Network error: ${e.message}');
  }
}
