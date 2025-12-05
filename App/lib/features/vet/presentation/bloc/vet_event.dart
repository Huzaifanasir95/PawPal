import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/vet_profile_model.dart';

part 'vet_event.freezed.dart';

@freezed
class VetEvent with _$VetEvent {
  const factory VetEvent.loadVetProfile(String userId) = _LoadVetProfile;
  const factory VetEvent.loadMyProfile() = _LoadMyProfile;
  const factory VetEvent.createOrUpdateProfile(VetProfileRequest request) = _CreateOrUpdateProfile;
  const factory VetEvent.listVets({
    String? city,
    String? specialization,
    double? minRating,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _ListVets;
  const factory VetEvent.searchVets(String query) = _SearchVets;
  const factory VetEvent.filterVets({
    String? city,
    String? specialization,
    double? minRating,
  }) = _FilterVets;
  const factory VetEvent.clearFilters() = _ClearFilters;
}
