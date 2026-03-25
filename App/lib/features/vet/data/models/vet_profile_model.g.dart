// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vet_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VetProfileImpl _$$VetProfileImplFromJson(Map<String, dynamic> json) =>
    _$VetProfileImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      degree: json['degree'] as String,
      licenseNumber: json['licenseNumber'] as String?,
      specialization:
          (json['specialization'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      experience: (json['experience'] as num).toInt(),
      clinicName: json['clinicName'] as String?,
      clinicAddress: json['clinicAddress'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      phone: json['phone'] as String,
      consultationFee: (json['consultationFee'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      bio: json['bio'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      availabilityHours: json['availabilityHours'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$VetProfileImplToJson(_$VetProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'degree': instance.degree,
      'licenseNumber': instance.licenseNumber,
      'specialization': instance.specialization,
      'experience': instance.experience,
      'clinicName': instance.clinicName,
      'clinicAddress': instance.clinicAddress,
      'city': instance.city,
      'state': instance.state,
      'zipCode': instance.zipCode,
      'phone': instance.phone,
      'consultationFee': instance.consultationFee,
      'currency': instance.currency,
      'bio': instance.bio,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'availabilityHours': instance.availabilityHours,
      'rating': instance.rating,
      'totalReviews': instance.totalReviews,
      'isVerified': instance.isVerified,
      'isAvailable': instance.isAvailable,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$VetProfileRequestImpl _$$VetProfileRequestImplFromJson(
  Map<String, dynamic> json,
) => _$VetProfileRequestImpl(
  fullName: json['fullName'] as String,
  degree: json['degree'] as String,
  licenseNumber: json['licenseNumber'] as String?,
  specialization:
      (json['specialization'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  experience: (json['experience'] as num).toInt(),
  clinicName: json['clinicName'] as String?,
  clinicAddress: json['clinicAddress'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['zipCode'] as String?,
  phone: json['phone'] as String,
  consultationFee: (json['consultationFee'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  bio: json['bio'] as String?,
  profilePhotoUrl: json['profilePhotoUrl'] as String?,
  availabilityHours: json['availabilityHours'] as String?,
  isAvailable: json['isAvailable'] as bool? ?? true,
);

Map<String, dynamic> _$$VetProfileRequestImplToJson(
  _$VetProfileRequestImpl instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'degree': instance.degree,
  'licenseNumber': instance.licenseNumber,
  'specialization': instance.specialization,
  'experience': instance.experience,
  'clinicName': instance.clinicName,
  'clinicAddress': instance.clinicAddress,
  'city': instance.city,
  'state': instance.state,
  'zipCode': instance.zipCode,
  'phone': instance.phone,
  'consultationFee': instance.consultationFee,
  'currency': instance.currency,
  'bio': instance.bio,
  'profilePhotoUrl': instance.profilePhotoUrl,
  'availabilityHours': instance.availabilityHours,
  'isAvailable': instance.isAvailable,
};
