import 'package:freezed_annotation/freezed_annotation.dart';

part 'vet_profile_model.freezed.dart';
part 'vet_profile_model.g.dart';

@freezed
class VetProfile with _$VetProfile {
  const factory VetProfile({
    required String id,
    required String userId,
    required String fullName,
    required String degree,
    String? licenseNumber,
    @Default([]) List<String> specialization,
    required int experience,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? state,
    String? zipCode,
    required String phone,
    required double consultationFee,
    @Default('USD') String currency,
    String? bio,
    String? profilePhotoUrl,
    String? availabilityHours,
    @Default(0.0) double rating,
    @Default(0) int totalReviews,
    @Default(false) bool isVerified,
    @Default(true) bool isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _VetProfile;

  factory VetProfile.fromJson(Map<String, dynamic> json) =>
      _$VetProfileFromJson(json);
}

@freezed
class VetProfileRequest with _$VetProfileRequest {
  const factory VetProfileRequest({
    required String fullName,
    required String degree,
    String? licenseNumber,
    @Default([]) List<String> specialization,
    required int experience,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? state,
    String? zipCode,
    required String phone,
    required double consultationFee,
    @Default('USD') String currency,
    String? bio,
    String? profilePhotoUrl,
    String? availabilityHours,
    @Default(true) bool isAvailable,
  }) = _VetProfileRequest;

  factory VetProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$VetProfileRequestFromJson(json);
}
