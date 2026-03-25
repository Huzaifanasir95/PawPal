// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caregiver_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CaregiverServiceTypeImpl _$$CaregiverServiceTypeImplFromJson(
  Map<String, dynamic> json,
) => _$CaregiverServiceTypeImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  displayName: json['displayName'] as String,
  description: json['description'] as String?,
  baseHourlyRate: (json['baseHourlyRate'] as num?)?.toDouble() ?? 0,
  iconName: json['iconName'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CaregiverServiceTypeImplToJson(
  _$CaregiverServiceTypeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'displayName': instance.displayName,
  'description': instance.description,
  'baseHourlyRate': instance.baseHourlyRate,
  'iconName': instance.iconName,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$CaregiverProfileImpl _$$CaregiverProfileImplFromJson(
  Map<String, dynamic> json,
) => _$CaregiverProfileImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  bio: json['bio'] as String?,
  yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt() ?? 0,
  headline: json['headline'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  postalCode: json['postalCode'] as String?,
  country: json['country'] as String? ?? 'Pakistan',
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toInt() ?? 10,
  isVerified: json['isVerified'] as bool? ?? false,
  verificationDate:
      json['verificationDate'] == null
          ? null
          : DateTime.parse(json['verificationDate'] as String),
  backgroundCheckStatus: json['backgroundCheckStatus'] as String? ?? 'pending',
  backgroundCheckDate:
      json['backgroundCheckDate'] == null
          ? null
          : DateTime.parse(json['backgroundCheckDate'] as String),
  idVerified: json['idVerified'] as bool? ?? false,
  idDocumentUrl: json['idDocumentUrl'] as String?,
  certifications:
      (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  petFirstAidCertified: json['petFirstAidCertified'] as bool? ?? false,
  insuranceVerified: json['insuranceVerified'] as bool? ?? false,
  insurancePolicyNumber: json['insurancePolicyNumber'] as String?,
  insuranceExpiry:
      json['insuranceExpiry'] == null
          ? null
          : DateTime.parse(json['insuranceExpiry'] as String),
  acceptedPetTypes:
      (json['acceptedPetTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['dog', 'cat'],
  acceptedPetSizes:
      (json['acceptedPetSizes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['small', 'medium', 'large'],
  maxPetsAtOnce: (json['maxPetsAtOnce'] as num?)?.toInt() ?? 3,
  hasFencedYard: json['hasFencedYard'] as bool? ?? false,
  hasOwnTransport: json['hasOwnTransport'] as bool? ?? false,
  smokeFreeHome: json['smokeFreeHome'] as bool? ?? true,
  hasChildren: json['hasChildren'] as bool? ?? false,
  hasOtherPets: json['hasOtherPets'] as bool? ?? false,
  otherPetsDescription: json['otherPetsDescription'] as String?,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
  totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
  completionRate: (json['completionRate'] as num?)?.toDouble() ?? 100.0,
  responseTimeHours: (json['responseTimeHours'] as num?)?.toInt() ?? 24,
  isActive: json['isActive'] as bool? ?? true,
  isAcceptingBookings: json['isAcceptingBookings'] as bool? ?? true,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  userName: json['userName'] as String?,
  userAvatar: json['userAvatar'] as String?,
  services:
      (json['services'] as List<dynamic>?)
          ?.map((e) => CaregiverService.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  availability:
      (json['availability'] as List<dynamic>?)
          ?.map(
            (e) => CaregiverAvailability.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  gallery:
      (json['gallery'] as List<dynamic>?)
          ?.map((e) => CaregiverGalleryItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$CaregiverProfileImplToJson(
  _$CaregiverProfileImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'bio': instance.bio,
  'yearsOfExperience': instance.yearsOfExperience,
  'headline': instance.headline,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'postalCode': instance.postalCode,
  'country': instance.country,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'serviceRadiusKm': instance.serviceRadiusKm,
  'isVerified': instance.isVerified,
  'verificationDate': instance.verificationDate?.toIso8601String(),
  'backgroundCheckStatus': instance.backgroundCheckStatus,
  'backgroundCheckDate': instance.backgroundCheckDate?.toIso8601String(),
  'idVerified': instance.idVerified,
  'idDocumentUrl': instance.idDocumentUrl,
  'certifications': instance.certifications,
  'petFirstAidCertified': instance.petFirstAidCertified,
  'insuranceVerified': instance.insuranceVerified,
  'insurancePolicyNumber': instance.insurancePolicyNumber,
  'insuranceExpiry': instance.insuranceExpiry?.toIso8601String(),
  'acceptedPetTypes': instance.acceptedPetTypes,
  'acceptedPetSizes': instance.acceptedPetSizes,
  'maxPetsAtOnce': instance.maxPetsAtOnce,
  'hasFencedYard': instance.hasFencedYard,
  'hasOwnTransport': instance.hasOwnTransport,
  'smokeFreeHome': instance.smokeFreeHome,
  'hasChildren': instance.hasChildren,
  'hasOtherPets': instance.hasOtherPets,
  'otherPetsDescription': instance.otherPetsDescription,
  'averageRating': instance.averageRating,
  'totalReviews': instance.totalReviews,
  'totalBookings': instance.totalBookings,
  'completionRate': instance.completionRate,
  'responseTimeHours': instance.responseTimeHours,
  'isActive': instance.isActive,
  'isAcceptingBookings': instance.isAcceptingBookings,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'userName': instance.userName,
  'userAvatar': instance.userAvatar,
  'services': instance.services,
  'availability': instance.availability,
  'gallery': instance.gallery,
};

_$CreateCaregiverProfileRequestImpl
_$$CreateCaregiverProfileRequestImplFromJson(Map<String, dynamic> json) =>
    _$CreateCaregiverProfileRequestImpl(
      bio: json['bio'] as String?,
      yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt(),
      headline: json['headline'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toInt(),
      certifications:
          (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      petFirstAidCertified: json['petFirstAidCertified'] as bool?,
      acceptedPetTypes:
          (json['acceptedPetTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      acceptedPetSizes:
          (json['acceptedPetSizes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      maxPetsAtOnce: (json['maxPetsAtOnce'] as num?)?.toInt(),
      hasFencedYard: json['hasFencedYard'] as bool?,
      hasOwnTransport: json['hasOwnTransport'] as bool?,
      smokeFreeHome: json['smokeFreeHome'] as bool?,
      hasChildren: json['hasChildren'] as bool?,
      hasOtherPets: json['hasOtherPets'] as bool?,
      otherPetsDescription: json['otherPetsDescription'] as String?,
    );

Map<String, dynamic> _$$CreateCaregiverProfileRequestImplToJson(
  _$CreateCaregiverProfileRequestImpl instance,
) => <String, dynamic>{
  'bio': instance.bio,
  'yearsOfExperience': instance.yearsOfExperience,
  'headline': instance.headline,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'postalCode': instance.postalCode,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'serviceRadiusKm': instance.serviceRadiusKm,
  'certifications': instance.certifications,
  'petFirstAidCertified': instance.petFirstAidCertified,
  'acceptedPetTypes': instance.acceptedPetTypes,
  'acceptedPetSizes': instance.acceptedPetSizes,
  'maxPetsAtOnce': instance.maxPetsAtOnce,
  'hasFencedYard': instance.hasFencedYard,
  'hasOwnTransport': instance.hasOwnTransport,
  'smokeFreeHome': instance.smokeFreeHome,
  'hasChildren': instance.hasChildren,
  'hasOtherPets': instance.hasOtherPets,
  'otherPetsDescription': instance.otherPetsDescription,
};

_$CaregiverServiceImpl _$$CaregiverServiceImplFromJson(
  Map<String, dynamic> json,
) => _$CaregiverServiceImpl(
  id: json['id'] as String,
  caregiverId: json['caregiverId'] as String,
  serviceTypeId: json['serviceTypeId'] as String,
  rateType: json['rateType'] as String? ?? 'hourly',
  rateAmount: (json['rateAmount'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'PKR',
  description: json['description'] as String?,
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  includes:
      (json['includes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  additionalPetRate: (json['additionalPetRate'] as num?)?.toDouble() ?? 0,
  isAvailable: json['isAvailable'] as bool? ?? true,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  serviceTypeName: json['serviceTypeName'] as String?,
  serviceTypeDisplayName: json['serviceTypeDisplayName'] as String?,
  serviceTypeIcon: json['serviceTypeIcon'] as String?,
);

Map<String, dynamic> _$$CaregiverServiceImplToJson(
  _$CaregiverServiceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'caregiverId': instance.caregiverId,
  'serviceTypeId': instance.serviceTypeId,
  'rateType': instance.rateType,
  'rateAmount': instance.rateAmount,
  'currency': instance.currency,
  'description': instance.description,
  'durationMinutes': instance.durationMinutes,
  'includes': instance.includes,
  'additionalPetRate': instance.additionalPetRate,
  'isAvailable': instance.isAvailable,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'serviceTypeName': instance.serviceTypeName,
  'serviceTypeDisplayName': instance.serviceTypeDisplayName,
  'serviceTypeIcon': instance.serviceTypeIcon,
};

_$AddCaregiverServiceRequestImpl _$$AddCaregiverServiceRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AddCaregiverServiceRequestImpl(
  serviceTypeId: json['serviceTypeId'] as String,
  rateType: json['rateType'] as String? ?? 'hourly',
  rateAmount: (json['rateAmount'] as num).toDouble(),
  description: json['description'] as String?,
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  includes:
      (json['includes'] as List<dynamic>?)?.map((e) => e as String).toList(),
  additionalPetRate: (json['additionalPetRate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$AddCaregiverServiceRequestImplToJson(
  _$AddCaregiverServiceRequestImpl instance,
) => <String, dynamic>{
  'serviceTypeId': instance.serviceTypeId,
  'rateType': instance.rateType,
  'rateAmount': instance.rateAmount,
  'description': instance.description,
  'durationMinutes': instance.durationMinutes,
  'includes': instance.includes,
  'additionalPetRate': instance.additionalPetRate,
};

_$CaregiverAvailabilityImpl _$$CaregiverAvailabilityImplFromJson(
  Map<String, dynamic> json,
) => _$CaregiverAvailabilityImpl(
  id: json['id'] as String,
  caregiverId: json['caregiverId'] as String,
  dayOfWeek: (json['dayOfWeek'] as num).toInt(),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  isAvailable: json['isAvailable'] as bool? ?? true,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CaregiverAvailabilityImplToJson(
  _$CaregiverAvailabilityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'caregiverId': instance.caregiverId,
  'dayOfWeek': instance.dayOfWeek,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'isAvailable': instance.isAvailable,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$AvailabilitySlotImpl _$$AvailabilitySlotImplFromJson(
  Map<String, dynamic> json,
) => _$AvailabilitySlotImpl(
  dayOfWeek: (json['dayOfWeek'] as num).toInt(),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  isAvailable: json['isAvailable'] as bool? ?? true,
);

Map<String, dynamic> _$$AvailabilitySlotImplToJson(
  _$AvailabilitySlotImpl instance,
) => <String, dynamic>{
  'dayOfWeek': instance.dayOfWeek,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'isAvailable': instance.isAvailable,
};

_$SetAvailabilityRequestImpl _$$SetAvailabilityRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SetAvailabilityRequestImpl(
  slots:
      (json['slots'] as List<dynamic>)
          .map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$SetAvailabilityRequestImplToJson(
  _$SetAvailabilityRequestImpl instance,
) => <String, dynamic>{'slots': instance.slots};

_$CaregiverBlockedDateImpl _$$CaregiverBlockedDateImplFromJson(
  Map<String, dynamic> json,
) => _$CaregiverBlockedDateImpl(
  id: json['id'] as String,
  caregiverId: json['caregiverId'] as String,
  blockedDate: json['blockedDate'] as String,
  reason: json['reason'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CaregiverBlockedDateImplToJson(
  _$CaregiverBlockedDateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'caregiverId': instance.caregiverId,
  'blockedDate': instance.blockedDate,
  'reason': instance.reason,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$CaregiverGalleryItemImpl _$$CaregiverGalleryItemImplFromJson(
  Map<String, dynamic> json,
) => _$CaregiverGalleryItemImpl(
  id: json['id'] as String,
  caregiverId: json['caregiverId'] as String,
  imageUrl: json['imageUrl'] as String,
  caption: json['caption'] as String?,
  imageType: json['imageType'] as String? ?? 'gallery',
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CaregiverGalleryItemImplToJson(
  _$CaregiverGalleryItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'caregiverId': instance.caregiverId,
  'imageUrl': instance.imageUrl,
  'caption': instance.caption,
  'imageType': instance.imageType,
  'displayOrder': instance.displayOrder,
  'createdAt': instance.createdAt?.toIso8601String(),
};
