import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/api_client.dart';
import '../models/pet_model.dart';
import '../models/health_record_model.dart';

@injectable
class PetRepositoryApi {
  final ApiClient _apiClient = ApiClient.instance;

  // ==================== STREAM METHODS ====================

  /// Get user's pets as a stream (one-time fetch)
  Stream<List<PetModel>> getUserPets() {
    return Stream.fromFuture(getPets());
  }

  // ==================== PETS OPERATIONS ====================

  /// Create a new pet
  Future<String?> createPet({
    required String name,
    required String type,
    required String breed,
    required int age,
    required String ageUnit,
    required String gender,
    required String color,
    required double weight,
    required String weightUnit,
    File? imageFile,
    String? imageLocalPath,
    List<String>? imageUrls,
    bool? isVerified,
    double? verificationConfidence,
    String? verifiedBreed,
    String? bio,
    HealthRecordModel? healthRecord,
  }) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final petData = {
        'name': name,
        'type': type,
        'breed': breed,
        'age': age,
        'ageUnit': ageUnit,
        'gender': gender,
        'color': color,
        'weight': weight,
        'weightUnit': weightUnit,
        if (imageLocalPath != null) 'imageLocalPath': imageLocalPath,
        if (imageUrls != null) 'imageUrls': imageUrls,
        if (bio != null) 'bio': bio,
      };

      final response = await _apiClient.post('/api/v1/pets', data: petData);
      // API returns {success: true, message: ..., pet: {...}} - extract ID from pet object
      print('🐾 CREATE PET RESPONSE: ${response.data}');
      
      final pet = response.data['pet'] as Map<String, dynamic>?;
      if (pet != null) {
        final petId = pet['id'] as String?;
        print('🐾 EXTRACTED PET ID: $petId');
        return petId;
      }
      print('🐾 NO PET IN RESPONSE');
      return null;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get all pets for current user
  Future<List<PetModel>> getPets() async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _apiClient.get('/api/v1/pets');
      final List<dynamic> petsData = response.data['pets'] ?? [];
      
      return petsData.map((pet) => PetModel.fromJson(pet as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get a specific pet by ID
  Future<PetModel?> getPetById(String petId) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _apiClient.get('/api/v1/pets/$petId');
      return PetModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  /// Update pet information
  Future<void> updatePet({
    required String petId,
    required String name,
    required String type,
    required String breed,
    required int age,
    required String ageUnit,
    required String gender,
    required String color,
    required double weight,
    required String weightUnit,
    String? imageLocalPath,
    List<String>? imageUrls,
    String? bio,
  }) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final petData = {
        'name': name,
        'type': type,
        'breed': breed,
        'age': age,
        'ageUnit': ageUnit,
        'gender': gender,
        'color': color,
        'weight': weight,
        'weightUnit': weightUnit,
        if (imageLocalPath != null) 'imageLocalPath': imageLocalPath,
        if (imageUrls != null) 'imageUrls': imageUrls,
        if (bio != null) 'bio': bio,
      };

      await _apiClient.put('/api/v1/pets/$petId', data: petData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a pet
  Future<void> deletePet(String petId) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      await _apiClient.delete('/api/v1/pets/$petId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get verified pets
  Future<List<PetModel>> getVerifiedPets() async {
    try {
      final response = await _apiClient.get('/api/v1/pets/verified');
      final List<dynamic> petsData = response.data['pets'] ?? [];
      
      return petsData.map((pet) => PetModel.fromJson(pet as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Search pets by breed
  Future<List<PetModel>> searchPetsByBreed(String breed, {String? type}) async {
    try {
      final params = {
        'breed': breed,
        if (type != null) 'type': type,
      };

      final response = await _apiClient.get('/api/v1/pets/search', queryParameters: params);
      final List<dynamic> petsData = response.data['pets'] ?? [];
      
      return petsData.map((pet) => PetModel.fromJson(pet as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get pet count
  Future<int> getPetCount() async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _apiClient.get('/api/v1/pets/count');
      return response.data['count'] as int? ?? 0;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Add health record for a pet (with individual parameters)
  Future<void> addHealthRecord({
    required String petId,
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
    HealthRecordModel? healthRecord,
  }) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Use healthRecord if provided, otherwise construct from individual parameters
      late Map<String, dynamic> data;
      if (healthRecord != null) {
        data = {
          'isVaccinated': healthRecord.isVaccinated,
          if (healthRecord.vaccinationDate != null) 'vaccinationDate': healthRecord.vaccinationDate,
          if (healthRecord.vaccinationDetails != null) 'vaccinationDetails': healthRecord.vaccinationDetails,
          if (healthRecord.medicalConditions != null) 'medicalConditions': healthRecord.medicalConditions,
          if (healthRecord.allergies != null) 'allergies': healthRecord.allergies,
          if (healthRecord.medications != null) 'medications': healthRecord.medications,
          if (healthRecord.vetName != null) 'vetName': healthRecord.vetName,
          if (healthRecord.vetClinic != null) 'vetClinic': healthRecord.vetClinic,
          if (healthRecord.vetPhone != null) 'vetPhone': healthRecord.vetPhone,
          if (healthRecord.vetAddress != null) 'vetAddress': healthRecord.vetAddress,
          if (healthRecord.emergencyContactName != null) 'emergencyContactName': healthRecord.emergencyContactName,
          if (healthRecord.emergencyContactPhone != null) 'emergencyContactPhone': healthRecord.emergencyContactPhone,
        };
      } else {
        data = {
          if (isVaccinated != null) 'isVaccinated': isVaccinated,
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
      }

      await _apiClient.post('/api/v1/health-records', data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get health record for a pet
  Future<HealthRecordModel?> getHealthRecord(String petId) async {
    try {
      if (!_apiClient.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _apiClient.get('/api/v1/health-records/pet/$petId');
      final data = response.data;
      
      if (data == null) return null;
      return HealthRecordModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  /// Error handler
  String _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'] as String;
      }
    }
    return error.message ?? 'An error occurred';
  }
}
