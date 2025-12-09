// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_journal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthJournalModelImpl _$$HealthJournalModelImplFromJson(
  Map<String, dynamic> json,
) => _$HealthJournalModelImpl(
  id: json['id'] as String,
  petId: json['petId'] as String,
  ownerId: json['ownerId'] as String,
  date: DateTime.parse(json['date'] as String),
  weight: (json['weight'] as num?)?.toDouble(),
  weightUnit: json['weightUnit'] as String?,
  activityLevel: json['activityLevel'] as String?,
  energyLevel: json['energyLevel'] as String?,
  mood: json['mood'] as String?,
  appetite: json['appetite'] as String?,
  symptoms:
      (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList(),
  medicationsTaken:
      (json['medicationsTaken'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  vetVisit: json['vetVisit'] as bool?,
  vetVisitReason: json['vetVisitReason'] as String?,
  vetNotes: json['vetNotes'] as String?,
  generalNotes: json['generalNotes'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$HealthJournalModelImplToJson(
  _$HealthJournalModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'petId': instance.petId,
  'ownerId': instance.ownerId,
  'date': instance.date.toIso8601String(),
  'weight': instance.weight,
  'weightUnit': instance.weightUnit,
  'activityLevel': instance.activityLevel,
  'energyLevel': instance.energyLevel,
  'mood': instance.mood,
  'appetite': instance.appetite,
  'symptoms': instance.symptoms,
  'medicationsTaken': instance.medicationsTaken,
  'vetVisit': instance.vetVisit,
  'vetVisitReason': instance.vetVisitReason,
  'vetNotes': instance.vetNotes,
  'generalNotes': instance.generalNotes,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
