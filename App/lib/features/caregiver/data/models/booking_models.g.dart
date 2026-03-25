// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceBookingImpl _$$ServiceBookingImplFromJson(
  Map<String, dynamic> json,
) => _$ServiceBookingImpl(
  id: json['id'] as String,
  bookingNumber: json['bookingNumber'] as String,
  petOwnerId: json['petOwnerId'] as String,
  caregiverId: json['caregiverId'] as String,
  serviceId: json['serviceId'] as String,
  petIds: (json['petIds'] as List<dynamic>).map((e) => e as String).toList(),
  startDatetime: DateTime.parse(json['startDatetime'] as String),
  endDatetime: DateTime.parse(json['endDatetime'] as String),
  serviceLocationType: json['serviceLocationType'] as String? ?? 'owner_home',
  serviceAddress: json['serviceAddress'] as String?,
  serviceLatitude: (json['serviceLatitude'] as num?)?.toDouble(),
  serviceLongitude: (json['serviceLongitude'] as num?)?.toDouble(),
  specialInstructions: json['specialInstructions'] as String?,
  emergencyContactName: json['emergencyContactName'] as String?,
  emergencyContactPhone: json['emergencyContactPhone'] as String?,
  baseAmount: (json['baseAmount'] as num?)?.toDouble() ?? 0,
  additionalPetsFee: (json['additionalPetsFee'] as num?)?.toDouble() ?? 0,
  serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
  discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
  totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
  currency: json['currency'] as String? ?? 'PKR',
  status: json['status'] as String? ?? 'pending',
  requestedAt:
      json['requestedAt'] == null
          ? null
          : DateTime.parse(json['requestedAt'] as String),
  respondedAt:
      json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
  startedAt:
      json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
  completedAt:
      json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
  cancelledAt:
      json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
  cancellationReason: json['cancellationReason'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  ownerName: json['ownerName'] as String?,
  ownerAvatar: json['ownerAvatar'] as String?,
  caregiverName: json['caregiverName'] as String?,
  caregiverAvatar: json['caregiverAvatar'] as String?,
  serviceName: json['serviceName'] as String?,
);

Map<String, dynamic> _$$ServiceBookingImplToJson(
  _$ServiceBookingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'bookingNumber': instance.bookingNumber,
  'petOwnerId': instance.petOwnerId,
  'caregiverId': instance.caregiverId,
  'serviceId': instance.serviceId,
  'petIds': instance.petIds,
  'startDatetime': instance.startDatetime.toIso8601String(),
  'endDatetime': instance.endDatetime.toIso8601String(),
  'serviceLocationType': instance.serviceLocationType,
  'serviceAddress': instance.serviceAddress,
  'serviceLatitude': instance.serviceLatitude,
  'serviceLongitude': instance.serviceLongitude,
  'specialInstructions': instance.specialInstructions,
  'emergencyContactName': instance.emergencyContactName,
  'emergencyContactPhone': instance.emergencyContactPhone,
  'baseAmount': instance.baseAmount,
  'additionalPetsFee': instance.additionalPetsFee,
  'serviceFee': instance.serviceFee,
  'discountAmount': instance.discountAmount,
  'totalAmount': instance.totalAmount,
  'currency': instance.currency,
  'status': instance.status,
  'requestedAt': instance.requestedAt?.toIso8601String(),
  'respondedAt': instance.respondedAt?.toIso8601String(),
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
  'cancellationReason': instance.cancellationReason,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'ownerName': instance.ownerName,
  'ownerAvatar': instance.ownerAvatar,
  'caregiverName': instance.caregiverName,
  'caregiverAvatar': instance.caregiverAvatar,
  'serviceName': instance.serviceName,
};

_$CreateBookingRequestImpl _$$CreateBookingRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateBookingRequestImpl(
  caregiverId: json['caregiverId'] as String,
  serviceId: json['serviceId'] as String,
  petIds: (json['petIds'] as List<dynamic>).map((e) => e as String).toList(),
  startDatetime: json['startDatetime'] as String,
  endDatetime: json['endDatetime'] as String,
  serviceLocationType: json['serviceLocationType'] as String? ?? 'owner_home',
  serviceAddress: json['serviceAddress'] as String?,
  serviceLatitude: (json['serviceLatitude'] as num?)?.toDouble(),
  serviceLongitude: (json['serviceLongitude'] as num?)?.toDouble(),
  specialInstructions: json['specialInstructions'] as String?,
  emergencyContactName: json['emergencyContactName'] as String?,
  emergencyContactPhone: json['emergencyContactPhone'] as String?,
);

Map<String, dynamic> _$$CreateBookingRequestImplToJson(
  _$CreateBookingRequestImpl instance,
) => <String, dynamic>{
  'caregiverId': instance.caregiverId,
  'serviceId': instance.serviceId,
  'petIds': instance.petIds,
  'startDatetime': instance.startDatetime,
  'endDatetime': instance.endDatetime,
  'serviceLocationType': instance.serviceLocationType,
  'serviceAddress': instance.serviceAddress,
  'serviceLatitude': instance.serviceLatitude,
  'serviceLongitude': instance.serviceLongitude,
  'specialInstructions': instance.specialInstructions,
  'emergencyContactName': instance.emergencyContactName,
  'emergencyContactPhone': instance.emergencyContactPhone,
};

_$RespondToBookingRequestImpl _$$RespondToBookingRequestImplFromJson(
  Map<String, dynamic> json,
) => _$RespondToBookingRequestImpl(
  accept: json['accept'] as bool,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$$RespondToBookingRequestImplToJson(
  _$RespondToBookingRequestImpl instance,
) => <String, dynamic>{'accept': instance.accept, 'reason': instance.reason};

_$CancelBookingRequestImpl _$$CancelBookingRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CancelBookingRequestImpl(reason: json['reason'] as String);

Map<String, dynamic> _$$CancelBookingRequestImplToJson(
  _$CancelBookingRequestImpl instance,
) => <String, dynamic>{'reason': instance.reason};

_$StartServiceRequestImpl _$$StartServiceRequestImplFromJson(
  Map<String, dynamic> json,
) => _$StartServiceRequestImpl(
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$StartServiceRequestImplToJson(
  _$StartServiceRequestImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_$BookingTrackingImpl _$$BookingTrackingImplFromJson(
  Map<String, dynamic> json,
) => _$BookingTrackingImpl(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  activityType: json['activityType'] as String?,
  note: json['note'] as String?,
  photoUrl: json['photoUrl'] as String?,
  recordedAt:
      json['recordedAt'] == null
          ? null
          : DateTime.parse(json['recordedAt'] as String),
);

Map<String, dynamic> _$$BookingTrackingImplToJson(
  _$BookingTrackingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'activityType': instance.activityType,
  'note': instance.note,
  'photoUrl': instance.photoUrl,
  'recordedAt': instance.recordedAt?.toIso8601String(),
};

_$AddTrackingRequestImpl _$$AddTrackingRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AddTrackingRequestImpl(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  activityType: json['activityType'] as String?,
  note: json['note'] as String?,
  photoUrl: json['photoUrl'] as String?,
);

Map<String, dynamic> _$$AddTrackingRequestImplToJson(
  _$AddTrackingRequestImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'activityType': instance.activityType,
  'note': instance.note,
  'photoUrl': instance.photoUrl,
};

_$CompletionReportImpl _$$CompletionReportImplFromJson(
  Map<String, dynamic> json,
) => _$CompletionReportImpl(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  summary: json['summary'] as String,
  activitiesPerformed:
      (json['activitiesPerformed'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  behaviorNotes: json['behaviorNotes'] as String?,
  feedingNotes: json['feedingNotes'] as String?,
  medicationGiven: json['medicationGiven'] as String?,
  actualDurationMinutes: (json['actualDurationMinutes'] as num?)?.toInt(),
  distanceWalkedKm: (json['distanceWalkedKm'] as num?)?.toDouble(),
  photos:
      (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  submittedAt:
      json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
);

Map<String, dynamic> _$$CompletionReportImplToJson(
  _$CompletionReportImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'summary': instance.summary,
  'activitiesPerformed': instance.activitiesPerformed,
  'behaviorNotes': instance.behaviorNotes,
  'feedingNotes': instance.feedingNotes,
  'medicationGiven': instance.medicationGiven,
  'actualDurationMinutes': instance.actualDurationMinutes,
  'distanceWalkedKm': instance.distanceWalkedKm,
  'photos': instance.photos,
  'submittedAt': instance.submittedAt?.toIso8601String(),
};

_$SubmitCompletionReportRequestImpl
_$$SubmitCompletionReportRequestImplFromJson(Map<String, dynamic> json) =>
    _$SubmitCompletionReportRequestImpl(
      summary: json['summary'] as String,
      activitiesPerformed:
          (json['activitiesPerformed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      behaviorNotes: json['behaviorNotes'] as String?,
      feedingNotes: json['feedingNotes'] as String?,
      medicationGiven: json['medicationGiven'] as String?,
      actualDurationMinutes: (json['actualDurationMinutes'] as num?)?.toInt(),
      distanceWalkedKm: (json['distanceWalkedKm'] as num?)?.toDouble(),
      photos:
          (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$SubmitCompletionReportRequestImplToJson(
  _$SubmitCompletionReportRequestImpl instance,
) => <String, dynamic>{
  'summary': instance.summary,
  'activitiesPerformed': instance.activitiesPerformed,
  'behaviorNotes': instance.behaviorNotes,
  'feedingNotes': instance.feedingNotes,
  'medicationGiven': instance.medicationGiven,
  'actualDurationMinutes': instance.actualDurationMinutes,
  'distanceWalkedKm': instance.distanceWalkedKm,
  'photos': instance.photos,
};

_$ServiceReviewImpl _$$ServiceReviewImplFromJson(Map<String, dynamic> json) =>
    _$ServiceReviewImpl(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      ownerRating: (json['ownerRating'] as num?)?.toInt(),
      ownerReview: json['ownerReview'] as String?,
      ownerReviewAt:
          json['ownerReviewAt'] == null
              ? null
              : DateTime.parse(json['ownerReviewAt'] as String),
      communicationRating: (json['communicationRating'] as num?)?.toInt(),
      reliabilityRating: (json['reliabilityRating'] as num?)?.toInt(),
      careQualityRating: (json['careQualityRating'] as num?)?.toInt(),
      caregiverRating: (json['caregiverRating'] as num?)?.toInt(),
      caregiverReview: json['caregiverReview'] as String?,
      caregiverReviewAt:
          json['caregiverReviewAt'] == null
              ? null
              : DateTime.parse(json['caregiverReviewAt'] as String),
      petBehaviorRating: (json['petBehaviorRating'] as num?)?.toInt(),
      petBehaviorNotes: json['petBehaviorNotes'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ServiceReviewImplToJson(_$ServiceReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'ownerRating': instance.ownerRating,
      'ownerReview': instance.ownerReview,
      'ownerReviewAt': instance.ownerReviewAt?.toIso8601String(),
      'communicationRating': instance.communicationRating,
      'reliabilityRating': instance.reliabilityRating,
      'careQualityRating': instance.careQualityRating,
      'caregiverRating': instance.caregiverRating,
      'caregiverReview': instance.caregiverReview,
      'caregiverReviewAt': instance.caregiverReviewAt?.toIso8601String(),
      'petBehaviorRating': instance.petBehaviorRating,
      'petBehaviorNotes': instance.petBehaviorNotes,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$SubmitOwnerReviewRequestImpl _$$SubmitOwnerReviewRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SubmitOwnerReviewRequestImpl(
  rating: (json['rating'] as num).toInt(),
  review: json['review'] as String?,
  communicationRating: (json['communicationRating'] as num?)?.toInt(),
  reliabilityRating: (json['reliabilityRating'] as num?)?.toInt(),
  careQualityRating: (json['careQualityRating'] as num?)?.toInt(),
  isPublic: json['isPublic'] as bool? ?? true,
);

Map<String, dynamic> _$$SubmitOwnerReviewRequestImplToJson(
  _$SubmitOwnerReviewRequestImpl instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'review': instance.review,
  'communicationRating': instance.communicationRating,
  'reliabilityRating': instance.reliabilityRating,
  'careQualityRating': instance.careQualityRating,
  'isPublic': instance.isPublic,
};

_$SubmitCaregiverReviewRequestImpl _$$SubmitCaregiverReviewRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SubmitCaregiverReviewRequestImpl(
  rating: (json['rating'] as num).toInt(),
  review: json['review'] as String?,
  petBehaviorRating: (json['petBehaviorRating'] as num?)?.toInt(),
  petBehaviorNotes: json['petBehaviorNotes'] as String?,
);

Map<String, dynamic> _$$SubmitCaregiverReviewRequestImplToJson(
  _$SubmitCaregiverReviewRequestImpl instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'review': instance.review,
  'petBehaviorRating': instance.petBehaviorRating,
  'petBehaviorNotes': instance.petBehaviorNotes,
};

_$BookingPaymentImpl _$$BookingPaymentImplFromJson(Map<String, dynamic> json) =>
    _$BookingPaymentImpl(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'PKR',
      paymentType: json['paymentType'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      status: json['status'] as String? ?? 'pending',
      escrowHeldAt:
          json['escrowHeldAt'] == null
              ? null
              : DateTime.parse(json['escrowHeldAt'] as String),
      escrowReleasedAt:
          json['escrowReleasedAt'] == null
              ? null
              : DateTime.parse(json['escrowReleasedAt'] as String),
      payoutStatus: json['payoutStatus'] as String? ?? 'pending',
      payoutAmount: (json['payoutAmount'] as num?)?.toDouble(),
      platformFee: (json['platformFee'] as num?)?.toDouble(),
      payoutTransactionId: json['payoutTransactionId'] as String?,
      payoutAt:
          json['payoutAt'] == null
              ? null
              : DateTime.parse(json['payoutAt'] as String),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BookingPaymentImplToJson(
  _$BookingPaymentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'amount': instance.amount,
  'currency': instance.currency,
  'paymentType': instance.paymentType,
  'paymentMethod': instance.paymentMethod,
  'transactionId': instance.transactionId,
  'status': instance.status,
  'escrowHeldAt': instance.escrowHeldAt?.toIso8601String(),
  'escrowReleasedAt': instance.escrowReleasedAt?.toIso8601String(),
  'payoutStatus': instance.payoutStatus,
  'payoutAmount': instance.payoutAmount,
  'platformFee': instance.platformFee,
  'payoutTransactionId': instance.payoutTransactionId,
  'payoutAt': instance.payoutAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$ProcessPaymentRequestImpl _$$ProcessPaymentRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ProcessPaymentRequestImpl(
  amount: (json['amount'] as num).toDouble(),
  paymentType: json['paymentType'] as String? ?? 'final',
  paymentMethod: json['paymentMethod'] as String,
  transactionId: json['transactionId'] as String?,
);

Map<String, dynamic> _$$ProcessPaymentRequestImplToJson(
  _$ProcessPaymentRequestImpl instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'paymentType': instance.paymentType,
  'paymentMethod': instance.paymentMethod,
  'transactionId': instance.transactionId,
};

_$ServiceIncidentImpl _$$ServiceIncidentImplFromJson(
  Map<String, dynamic> json,
) => _$ServiceIncidentImpl(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  reportedBy: json['reportedBy'] as String,
  incidentType: json['incidentType'] as String,
  severity: json['severity'] as String,
  description: json['description'] as String,
  photos:
      (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  vetVisitRequired: json['vetVisitRequired'] as String?,
  vetDetails: json['vetDetails'] as String?,
  status: json['status'] as String? ?? 'open',
  resolution: json['resolution'] as String?,
  resolvedAt:
      json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
  reportedAt:
      json['reportedAt'] == null
          ? null
          : DateTime.parse(json['reportedAt'] as String),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ServiceIncidentImplToJson(
  _$ServiceIncidentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'reportedBy': instance.reportedBy,
  'incidentType': instance.incidentType,
  'severity': instance.severity,
  'description': instance.description,
  'photos': instance.photos,
  'vetVisitRequired': instance.vetVisitRequired,
  'vetDetails': instance.vetDetails,
  'status': instance.status,
  'resolution': instance.resolution,
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'reportedAt': instance.reportedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$ReportIncidentRequestImpl _$$ReportIncidentRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ReportIncidentRequestImpl(
  incidentType: json['incidentType'] as String,
  severity: json['severity'] as String,
  description: json['description'] as String,
  photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList(),
  vetVisitRequired: json['vetVisitRequired'] as bool?,
  vetDetails: json['vetDetails'] as String?,
);

Map<String, dynamic> _$$ReportIncidentRequestImplToJson(
  _$ReportIncidentRequestImpl instance,
) => <String, dynamic>{
  'incidentType': instance.incidentType,
  'severity': instance.severity,
  'description': instance.description,
  'photos': instance.photos,
  'vetVisitRequired': instance.vetVisitRequired,
  'vetDetails': instance.vetDetails,
};
