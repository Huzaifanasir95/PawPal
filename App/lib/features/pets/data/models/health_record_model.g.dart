// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthRecordModelImpl _$$HealthRecordModelImplFromJson(
  Map<String, dynamic> json,
) => _$HealthRecordModelImpl(
  id: json['id'] as String,
  petId: json['petId'] as String,
  ownerId: json['ownerId'] as String,
  isVaccinated: json['isVaccinated'] as bool? ?? false,
  vaccinationDate: json['vaccinationDate'] as String?,
  vaccinationDetails: json['vaccinationDetails'] as String?,
  medicalConditions:
      (json['medicalConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  allergies:
      (json['allergies'] as List<dynamic>?)?.map((e) => e as String).toList(),
  medications:
      (json['medications'] as List<dynamic>?)?.map((e) => e as String).toList(),
  vetName: json['vetName'] as String?,
  vetClinic: json['vetClinic'] as String?,
  vetPhone: json['vetPhone'] as String?,
  vetAddress: json['vetAddress'] as String?,
  emergencyContactName: json['emergencyContactName'] as String?,
  emergencyContactPhone: json['emergencyContactPhone'] as String?,
  insuranceProvider: json['insuranceProvider'] as String?,
  insurancePolicyNumber: json['insurancePolicyNumber'] as String?,
  additionalNotes: json['additionalNotes'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$HealthRecordModelImplToJson(
  _$HealthRecordModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'petId': instance.petId,
  'ownerId': instance.ownerId,
  'isVaccinated': instance.isVaccinated,
  'vaccinationDate': instance.vaccinationDate,
  'vaccinationDetails': instance.vaccinationDetails,
  'medicalConditions': instance.medicalConditions,
  'allergies': instance.allergies,
  'medications': instance.medications,
  'vetName': instance.vetName,
  'vetClinic': instance.vetClinic,
  'vetPhone': instance.vetPhone,
  'vetAddress': instance.vetAddress,
  'emergencyContactName': instance.emergencyContactName,
  'emergencyContactPhone': instance.emergencyContactPhone,
  'insuranceProvider': instance.insuranceProvider,
  'insurancePolicyNumber': instance.insurancePolicyNumber,
  'additionalNotes': instance.additionalNotes,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
