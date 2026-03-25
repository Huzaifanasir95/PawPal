import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_models.freezed.dart';
part 'booking_models.g.dart';

// ============================================
// SERVICE BOOKING
// ============================================

@freezed
class ServiceBooking with _$ServiceBooking {
  const factory ServiceBooking({
    required String id,
    required String bookingNumber,
    required String petOwnerId,
    required String caregiverId,
    required String serviceId,
    required List<String> petIds,
    required DateTime startDatetime,
    required DateTime endDatetime,
    @Default('owner_home') String serviceLocationType,
    String? serviceAddress,
    double? serviceLatitude,
    double? serviceLongitude,
    String? specialInstructions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    @Default(0) double baseAmount,
    @Default(0) double additionalPetsFee,
    @Default(0) double serviceFee,
    @Default(0) double discountAmount,
    @Default(0) double totalAmount,
    @Default('PKR') String currency,
    @Default('pending') String status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Joined fields
    String? ownerName,
    String? ownerAvatar,
    String? caregiverName,
    String? caregiverAvatar,
    String? serviceName,
  }) = _ServiceBooking;

  factory ServiceBooking.fromJson(Map<String, dynamic> json) =>
      _$ServiceBookingFromJson(json);
}

@freezed
class CreateBookingRequest with _$CreateBookingRequest {
  const factory CreateBookingRequest({
    required String caregiverId,
    required String serviceId,
    required List<String> petIds,
    required String startDatetime, // ISO 8601
    required String endDatetime,
    @Default('owner_home') String serviceLocationType,
    String? serviceAddress,
    double? serviceLatitude,
    double? serviceLongitude,
    String? specialInstructions,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) = _CreateBookingRequest;

  factory CreateBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingRequestFromJson(json);
}

@freezed
class RespondToBookingRequest with _$RespondToBookingRequest {
  const factory RespondToBookingRequest({
    required bool accept,
    String? reason,
  }) = _RespondToBookingRequest;

  factory RespondToBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$RespondToBookingRequestFromJson(json);
}

@freezed
class CancelBookingRequest with _$CancelBookingRequest {
  const factory CancelBookingRequest({
    required String reason,
  }) = _CancelBookingRequest;

  factory CancelBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelBookingRequestFromJson(json);
}

@freezed
class StartServiceRequest with _$StartServiceRequest {
  const factory StartServiceRequest({
    double? latitude,
    double? longitude,
  }) = _StartServiceRequest;

  factory StartServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$StartServiceRequestFromJson(json);
}

// ============================================
// BOOKING TRACKING
// ============================================

@freezed
class BookingTracking with _$BookingTracking {
  const factory BookingTracking({
    required String id,
    required String bookingId,
    required double latitude,
    required double longitude,
    String? activityType,
    String? note,
    String? photoUrl,
    DateTime? recordedAt,
  }) = _BookingTracking;

  factory BookingTracking.fromJson(Map<String, dynamic> json) =>
      _$BookingTrackingFromJson(json);
}

@freezed
class AddTrackingRequest with _$AddTrackingRequest {
  const factory AddTrackingRequest({
    required double latitude,
    required double longitude,
    String? activityType,
    String? note,
    String? photoUrl,
  }) = _AddTrackingRequest;

  factory AddTrackingRequest.fromJson(Map<String, dynamic> json) =>
      _$AddTrackingRequestFromJson(json);
}

// ============================================
// COMPLETION REPORT
// ============================================

@freezed
class CompletionReport with _$CompletionReport {
  const factory CompletionReport({
    required String id,
    required String bookingId,
    required String summary,
    @Default([]) List<String> activitiesPerformed,
    String? behaviorNotes,
    String? feedingNotes,
    String? medicationGiven,
    int? actualDurationMinutes,
    double? distanceWalkedKm,
    @Default([]) List<String> photos,
    DateTime? submittedAt,
  }) = _CompletionReport;

  factory CompletionReport.fromJson(Map<String, dynamic> json) =>
      _$CompletionReportFromJson(json);
}

@freezed
class SubmitCompletionReportRequest with _$SubmitCompletionReportRequest {
  const factory SubmitCompletionReportRequest({
    required String summary,
    List<String>? activitiesPerformed,
    String? behaviorNotes,
    String? feedingNotes,
    String? medicationGiven,
    int? actualDurationMinutes,
    double? distanceWalkedKm,
    List<String>? photos,
  }) = _SubmitCompletionReportRequest;

  factory SubmitCompletionReportRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitCompletionReportRequestFromJson(json);
}

// ============================================
// REVIEWS
// ============================================

@freezed
class ServiceReview with _$ServiceReview {
  const factory ServiceReview({
    required String id,
    required String bookingId,
    int? ownerRating,
    String? ownerReview,
    DateTime? ownerReviewAt,
    int? communicationRating,
    int? reliabilityRating,
    int? careQualityRating,
    int? caregiverRating,
    String? caregiverReview,
    DateTime? caregiverReviewAt,
    int? petBehaviorRating,
    String? petBehaviorNotes,
    @Default(true) bool isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ServiceReview;

  factory ServiceReview.fromJson(Map<String, dynamic> json) =>
      _$ServiceReviewFromJson(json);
}

@freezed
class SubmitOwnerReviewRequest with _$SubmitOwnerReviewRequest {
  const factory SubmitOwnerReviewRequest({
    required int rating,
    String? review,
    int? communicationRating,
    int? reliabilityRating,
    int? careQualityRating,
    @Default(true) bool isPublic,
  }) = _SubmitOwnerReviewRequest;

  factory SubmitOwnerReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitOwnerReviewRequestFromJson(json);
}

@freezed
class SubmitCaregiverReviewRequest with _$SubmitCaregiverReviewRequest {
  const factory SubmitCaregiverReviewRequest({
    required int rating,
    String? review,
    int? petBehaviorRating,
    String? petBehaviorNotes,
  }) = _SubmitCaregiverReviewRequest;

  factory SubmitCaregiverReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitCaregiverReviewRequestFromJson(json);
}

// ============================================
// PAYMENTS
// ============================================

@freezed
class BookingPayment with _$BookingPayment {
  const factory BookingPayment({
    required String id,
    required String bookingId,
    required double amount,
    @Default('PKR') String currency,
    required String paymentType, // deposit, final, refund, tip
    String? paymentMethod,
    String? transactionId,
    @Default('pending') String status,
    DateTime? escrowHeldAt,
    DateTime? escrowReleasedAt,
    @Default('pending') String payoutStatus,
    double? payoutAmount,
    double? platformFee,
    String? payoutTransactionId,
    DateTime? payoutAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BookingPayment;

  factory BookingPayment.fromJson(Map<String, dynamic> json) =>
      _$BookingPaymentFromJson(json);
}

@freezed
class ProcessPaymentRequest with _$ProcessPaymentRequest {
  const factory ProcessPaymentRequest({
    required double amount,
    @Default('final') String paymentType,
    required String paymentMethod,
    String? transactionId,
  }) = _ProcessPaymentRequest;

  factory ProcessPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$ProcessPaymentRequestFromJson(json);
}

// ============================================
// INCIDENTS
// ============================================

@freezed
class ServiceIncident with _$ServiceIncident {
  const factory ServiceIncident({
    required String id,
    required String bookingId,
    required String reportedBy,
    required String incidentType,
    required String severity,
    required String description,
    @Default([]) List<String> photos,
    String? vetVisitRequired,
    String? vetDetails,
    @Default('open') String status,
    String? resolution,
    DateTime? resolvedAt,
    DateTime? reportedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ServiceIncident;

  factory ServiceIncident.fromJson(Map<String, dynamic> json) =>
      _$ServiceIncidentFromJson(json);
}

@freezed
class ReportIncidentRequest with _$ReportIncidentRequest {
  const factory ReportIncidentRequest({
    required String incidentType,
    required String severity,
    required String description,
    List<String>? photos,
    bool? vetVisitRequired,
    String? vetDetails,
  }) = _ReportIncidentRequest;

  factory ReportIncidentRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportIncidentRequestFromJson(json);
}
