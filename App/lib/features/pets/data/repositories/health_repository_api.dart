import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';
import '../models/health_record_model.dart';
import '../models/health_journal_model.dart';

class HealthRepositoryApi {
  final ApiClient _apiClient = ApiClient.instance;

  /// Create health record for a pet
  Future<String?> createHealthRecord({
    required String petId,
    required bool isVaccinated,
    String? vaccinationDate,
    String? vaccinationDetails,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? medications,
    String? vetName,
    String? vetClinic,
    String? vetPhone,
    String? vetAddress,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    String? additionalNotes,
  }) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final data = {
        'petId': petId,
        'isVaccinated': isVaccinated,
        if (vaccinationDate != null) 'vaccinationDate': vaccinationDate,
        if (vaccinationDetails != null) 'vaccinationDetails': vaccinationDetails,
        if (medicalConditions != null) 'medicalConditions': medicalConditions,
        if (allergies != null) 'allergies': allergies,
        if (medications != null) 'medications': medications,
        if (vetName != null) 'vetName': vetName,
        if (vetClinic != null) 'vetClinic': vetClinic,
        if (vetPhone != null) 'vetPhone': vetPhone,
        if (vetAddress != null) 'vetAddress': vetAddress,
        if (emergencyContactName != null) 'emergencyContactName': emergencyContactName,
        if (emergencyContactPhone != null) 'emergencyContactPhone': emergencyContactPhone,
        if (insuranceProvider != null) 'insuranceProvider': insuranceProvider,
        if (insurancePolicyNumber != null) 'insurancePolicyNumber': insurancePolicyNumber,
        if (additionalNotes != null) 'additionalNotes': additionalNotes,
      };

      final response = await _apiClient.post('/api/v1/health-records', data: data);
      
      // Extract ID from response
      final healthRecord = response.data['healthRecord'] as Map<String, dynamic>?;
      return healthRecord?['id'] as String?;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get health record for a pet
  Future<HealthRecordModel?> getHealthRecord(String petId) async {
    try {
      if (!_apiClient.isAuthenticated) {
        return null;
      }

      final response = await _apiClient.get('/api/v1/health-records/pet/$petId');
      
      final healthRecordData = response.data['healthRecord'] as Map<String, dynamic>?;
      if (healthRecordData == null) return null;
      
      return HealthRecordModel.fromJson(healthRecordData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleDioError(e);
    }
  }

  /// Update health record
  Future<bool> updateHealthRecord({
    required String recordId,
    bool? isVaccinated,
    String? vaccinationDate,
    String? vaccinationDetails,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? medications,
    String? vetName,
    String? vetClinic,
    String? vetPhone,
    String? vetAddress,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    String? additionalNotes,
  }) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final data = <String, dynamic>{};
      if (isVaccinated != null) data['isVaccinated'] = isVaccinated;
      if (vaccinationDate != null) data['vaccinationDate'] = vaccinationDate;
      if (vaccinationDetails != null) data['vaccinationDetails'] = vaccinationDetails;
      if (medicalConditions != null) data['medicalConditions'] = medicalConditions;
      if (allergies != null) data['allergies'] = allergies;
      if (medications != null) data['medications'] = medications;
      if (vetName != null) data['vetName'] = vetName;
      if (vetClinic != null) data['vetClinic'] = vetClinic;
      if (vetPhone != null) data['vetPhone'] = vetPhone;
      if (vetAddress != null) data['vetAddress'] = vetAddress;
      if (emergencyContactName != null) data['emergencyContactName'] = emergencyContactName;
      if (emergencyContactPhone != null) data['emergencyContactPhone'] = emergencyContactPhone;
      if (insuranceProvider != null) data['insuranceProvider'] = insuranceProvider;
      if (insurancePolicyNumber != null) data['insurancePolicyNumber'] = insurancePolicyNumber;
      if (additionalNotes != null) data['additionalNotes'] = additionalNotes;

      await _apiClient.put('/api/v1/health-records/$recordId', data: data);
      return true;
    } on DioException catch (e) {
      print('Error updating health record: $e');
      return false;
    }
  }

  /// Delete health record
  Future<bool> deleteHealthRecord(String recordId) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      await _apiClient.delete('/api/v1/health-records/$recordId');
      return true;
    } on DioException catch (e) {
      print('Error deleting health record: $e');
      return false;
    }
  }

  /// Create health journal entry
  Future<String?> createHealthJournalEntry({
    required String petId,
    required DateTime date,
    double? weight,
    String? weightUnit,
    String? activityLevel,
    String? energyLevel,
    String? mood,
    String? appetite,
    List<String>? symptoms,
    List<String>? medicationsTaken,
    bool? vetVisit,
    String? vetVisitReason,
    String? vetNotes,
    String? generalNotes,
  }) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final data = {
        'petId': petId,
        'date': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}', // YYYY-MM-DD format
        if (weight != null) 'weight': weight,
        if (weightUnit != null) 'weightUnit': weightUnit,
        if (activityLevel != null) 'activityLevel': activityLevel,
        if (energyLevel != null) 'energyLevel': energyLevel,
        if (mood != null) 'mood': mood,
        if (appetite != null) 'appetite': appetite,
        if (symptoms != null) 'symptoms': symptoms,
        if (medicationsTaken != null) 'medicationsTaken': medicationsTaken,
        if (vetVisit != null) 'vetVisit': vetVisit,
        if (vetVisitReason != null) 'vetVisitReason': vetVisitReason,
        if (vetNotes != null) 'vetNotes': vetNotes,
        if (generalNotes != null) 'generalNotes': generalNotes,
      };

      final response = await _apiClient.post('/api/v1/health-journals', data: data);
      
      // Extract ID from response
      final healthJournal = response.data['healthJournal'] as Map<String, dynamic>?;
      return healthJournal?['id'] as String?;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get health journal entries for a pet (as Stream for compatibility)
  Stream<List<HealthJournalModel>> getHealthJournalEntries(String petId) {
    return Stream.fromFuture(_fetchHealthJournals(petId));
  }

  /// Fetch health journals from API
  Future<List<HealthJournalModel>> _fetchHealthJournals(String petId) async {
    try {
      if (!_apiClient.isAuthenticated) {
        return [];
      }

      final response = await _apiClient.get('/api/v1/health-journals/pet/$petId');
      
      final List<dynamic> journalsData = response.data['healthJournals'] ?? [];
      return journalsData
          .map((data) => HealthJournalModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw _handleDioError(e);
    }
  }

  /// Get health journal entries (non-stream version)
  Future<List<HealthJournalModel>> getHealthJournalEntriesList(String petId) async {
    return _fetchHealthJournals(petId);
  }

  /// Get a specific health journal entry
  Future<HealthJournalModel?> getHealthJournalEntry(String entryId) async {
    try {
      if (!_apiClient.isAuthenticated) {
        return null;
      }

      final response = await _apiClient.get('/api/v1/health-journals/$entryId');
      
      final journalData = response.data['healthJournal'] as Map<String, dynamic>?;
      if (journalData == null) return null;
      
      return HealthJournalModel.fromJson(journalData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleDioError(e);
    }
  }

  /// Delete health journal entry
  Future<bool> deleteHealthJournalEntry(String entryId) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      await _apiClient.delete('/api/v1/health-journals/$entryId');
      return true;
    } on DioException catch (e) {
      print('Error deleting health journal entry: $e');
      return false;
    }
  }

  /// Get health journal entries for a specific date range
  Future<List<HealthJournalModel>> getHealthJournalEntriesInRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (!_apiClient.isAuthenticated) {
        return [];
      }

      // Fetch all and filter client-side (backend can be enhanced to support date filtering)
      final journals = await _fetchHealthJournals(petId);
      return journals.where((journal) {
        return journal.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               journal.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      print('Error getting health journal entries in range: $e');
      return [];
    }
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['error'] ?? e.response?.data['message'] ?? 'Request failed';
      return Exception(message);
    }
    return Exception(e.message ?? 'Network error occurred');
  }
}
