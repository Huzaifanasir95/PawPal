// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PetModelImpl _$$PetModelImplFromJson(
  Map<String, dynamic> json,
) => _$PetModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  breed: json['breed'] as String,
  age: (json['age'] as num).toInt(),
  ageUnit: json['ageUnit'] as String,
  gender: json['gender'] as String,
  color: json['color'] as String,
  weight: (json['weight'] as num).toDouble(),
  weightUnit: json['weightUnit'] as String,
  imageUrl: json['imageUrl'] as String?,
  imageLocalPath: json['imageLocalPath'] as String?,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isVerified: json['isVerified'] as bool?,
  verificationConfidence: (json['verificationConfidence'] as num?)?.toDouble(),
  verifiedBreed: json['verifiedBreed'] as String?,
  bio: json['bio'] as String?,
  ownerId: json['ownerId'] as String?,
  healthRecord:
      json['healthRecord'] == null
          ? null
          : HealthRecordModel.fromJson(
            json['healthRecord'] as Map<String, dynamic>,
          ),
  isAdopted: json['isAdopted'] as bool? ?? false,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$PetModelImplToJson(_$PetModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'breed': instance.breed,
      'age': instance.age,
      'ageUnit': instance.ageUnit,
      'gender': instance.gender,
      'color': instance.color,
      'weight': instance.weight,
      'weightUnit': instance.weightUnit,
      'imageUrl': instance.imageUrl,
      'imageLocalPath': instance.imageLocalPath,
      'imageUrls': instance.imageUrls,
      'isVerified': instance.isVerified,
      'verificationConfidence': instance.verificationConfidence,
      'verifiedBreed': instance.verifiedBreed,
      'bio': instance.bio,
      'ownerId': instance.ownerId,
      'healthRecord': instance.healthRecord,
      'isAdopted': instance.isAdopted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
