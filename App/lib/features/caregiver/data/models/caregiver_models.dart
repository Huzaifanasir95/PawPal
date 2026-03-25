import 'package:freezed_annotation/freezed_annotation.dart';

part 'caregiver_models.freezed.dart';
part 'caregiver_models.g.dart';

// ============================================
// SERVICE TYPES
// ============================================

@freezed
class CaregiverServiceType with _$CaregiverServiceType {
  const factory CaregiverServiceType({
    required String id,
    required String name,
    required String displayName,
    String? description,
    @Default(0) double baseHourlyRate,
    String? iconName,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _CaregiverServiceType;

  factory CaregiverServiceType.fromJson(Map<String, dynamic> json) =>
      _$CaregiverServiceTypeFromJson(json);
}

// ============================================
// CAREGIVER PROFILE
// ============================================

@freezed
class CaregiverProfile with _$CaregiverProfile {
  const factory CaregiverProfile({
    required String id,
    required String userId,
    String? bio,
    @Default(0) int yearsOfExperience,
    String? headline,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    @Default('Pakistan') String country,
    double? latitude,
    double? longitude,
    @Default(10) int serviceRadiusKm,
    @Default(false) bool isVerified,
    DateTime? verificationDate,
    @Default('pending') String backgroundCheckStatus,
    DateTime? backgroundCheckDate,
    @Default(false) bool idVerified,
    String? idDocumentUrl,
    @Default([]) List<String> certifications,
    @Default(false) bool petFirstAidCertified,
    @Default(false) bool insuranceVerified,
    String? insurancePolicyNumber,
    DateTime? insuranceExpiry,
    @Default(['dog', 'cat']) List<String> acceptedPetTypes,
    @Default(['small', 'medium', 'large']) List<String> acceptedPetSizes,
    @Default(3) int maxPetsAtOnce,
    @Default(false) bool hasFencedYard,
    @Default(false) bool hasOwnTransport,
    @Default(true) bool smokeFreeHome,
    @Default(false) bool hasChildren,
    @Default(false) bool hasOtherPets,
    String? otherPetsDescription,
    @Default(0.0) double averageRating,
    @Default(0) int totalReviews,
    @Default(0) int totalBookings,
    @Default(100.0) double completionRate,
    @Default(24) int responseTimeHours,
    @Default(true) bool isActive,
    @Default(true) bool isAcceptingBookings,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Joined fields
    String? userName,
    String? userAvatar,
    @Default([]) List<CaregiverService> services,
    @Default([]) List<CaregiverAvailability> availability,
    @Default([]) List<CaregiverGalleryItem> gallery,
  }) = _CaregiverProfile;

  factory CaregiverProfile.fromJson(Map<String, dynamic> json) =>
      _$CaregiverProfileFromJson(json);
}

@freezed
class CreateCaregiverProfileRequest with _$CreateCaregiverProfileRequest {
  const factory CreateCaregiverProfileRequest({
    String? bio,
    int? yearsOfExperience,
    String? headline,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    double? latitude,
    double? longitude,
    int? serviceRadiusKm,
    List<String>? certifications,
    bool? petFirstAidCertified,
    List<String>? acceptedPetTypes,
    List<String>? acceptedPetSizes,
    int? maxPetsAtOnce,
    bool? hasFencedYard,
    bool? hasOwnTransport,
    bool? smokeFreeHome,
    bool? hasChildren,
    bool? hasOtherPets,
    String? otherPetsDescription,
  }) = _CreateCaregiverProfileRequest;

  factory CreateCaregiverProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCaregiverProfileRequestFromJson(json);
}

// ============================================
// CAREGIVER SERVICES
// ============================================

@freezed
class CaregiverService with _$CaregiverService {
  const factory CaregiverService({
    required String id,
    required String caregiverId,
    required String serviceTypeId,
    @Default('hourly') String rateType,
    required double rateAmount,
    @Default('PKR') String currency,
    String? description,
    int? durationMinutes,
    @Default([]) List<String> includes,
    @Default(0) double additionalPetRate,
    @Default(true) bool isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Joined fields
    String? serviceTypeName,
    String? serviceTypeDisplayName,
    String? serviceTypeIcon,
  }) = _CaregiverService;

  factory CaregiverService.fromJson(Map<String, dynamic> json) =>
      _$CaregiverServiceFromJson(json);
}

@freezed
class AddCaregiverServiceRequest with _$AddCaregiverServiceRequest {
  const factory AddCaregiverServiceRequest({
    required String serviceTypeId,
    @Default('hourly') String rateType,
    required double rateAmount,
    String? description,
    int? durationMinutes,
    List<String>? includes,
    double? additionalPetRate,
  }) = _AddCaregiverServiceRequest;

  factory AddCaregiverServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$AddCaregiverServiceRequestFromJson(json);
}

// ============================================
// CAREGIVER AVAILABILITY
// ============================================

@freezed
class CaregiverAvailability with _$CaregiverAvailability {
  const factory CaregiverAvailability({
    required String id,
    required String caregiverId,
    required int dayOfWeek, // 0=Sunday, 6=Saturday
    required String startTime, // "HH:mm"
    required String endTime,
    @Default(true) bool isAvailable,
    DateTime? createdAt,
  }) = _CaregiverAvailability;

  factory CaregiverAvailability.fromJson(Map<String, dynamic> json) =>
      _$CaregiverAvailabilityFromJson(json);
}

@freezed
class AvailabilitySlot with _$AvailabilitySlot {
  const factory AvailabilitySlot({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    @Default(true) bool isAvailable,
  }) = _AvailabilitySlot;

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      _$AvailabilitySlotFromJson(json);
}

@freezed
class SetAvailabilityRequest with _$SetAvailabilityRequest {
  const factory SetAvailabilityRequest({
    required List<AvailabilitySlot> slots,
  }) = _SetAvailabilityRequest;

  factory SetAvailabilityRequest.fromJson(Map<String, dynamic> json) =>
      _$SetAvailabilityRequestFromJson(json);
}

// ============================================
// BLOCKED DATES
// ============================================

@freezed
class CaregiverBlockedDate with _$CaregiverBlockedDate {
  const factory CaregiverBlockedDate({
    required String id,
    required String caregiverId,
    required String blockedDate, // "YYYY-MM-DD"
    String? reason,
    DateTime? createdAt,
  }) = _CaregiverBlockedDate;

  factory CaregiverBlockedDate.fromJson(Map<String, dynamic> json) =>
      _$CaregiverBlockedDateFromJson(json);
}

// ============================================
// GALLERY
// ============================================

@freezed
class CaregiverGalleryItem with _$CaregiverGalleryItem {
  const factory CaregiverGalleryItem({
    required String id,
    required String caregiverId,
    required String imageUrl,
    String? caption,
    @Default('gallery') String imageType,
    @Default(0) int displayOrder,
    DateTime? createdAt,
  }) = _CaregiverGalleryItem;

  factory CaregiverGalleryItem.fromJson(Map<String, dynamic> json) =>
      _$CaregiverGalleryItemFromJson(json);
}
