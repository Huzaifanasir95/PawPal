import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_record_model.freezed.dart';
part 'health_record_model.g.dart';

@freezed
class HealthRecordModel with _$HealthRecordModel {
  const factory HealthRecordModel({
    required String id,
    required String petId,
    required String ownerId,
    // Vaccination
    @Default(false) bool isVaccinated,
    String? vaccinationDate,
    String? vaccinationDetails,
    // Medical conditions
    List<String>? medicalConditions,
    // Allergies
    List<String>? allergies,
    // Current medications
    List<String>? medications,
    // Vet information
    String? vetName,
    String? vetClinic,
    String? vetPhone,
    String? vetAddress,
    // Emergency contact
    String? emergencyContactName,
    String? emergencyContactPhone,
    // Insurance
    String? insuranceProvider,
    String? insurancePolicyNumber,
    // Notes
    String? additionalNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _HealthRecordModel;

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) =>
      _$HealthRecordModelFromJson(json);
}