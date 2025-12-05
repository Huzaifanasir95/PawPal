import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/vet_profile_model.dart';

part 'vet_state.freezed.dart';

@freezed
class VetState with _$VetState {
  const factory VetState.initial() = _Initial;
  const factory VetState.loading() = _Loading;
  const factory VetState.profileLoaded(VetProfile profile) = _ProfileLoaded;
  const factory VetState.vetsListLoaded({
    required List<VetProfile> vets,
    required int total,
    required int currentPage,
    required int limit,
    required bool hasMore,
    String? appliedCity,
    String? appliedSpecialization,
    double? appliedMinRating,
  }) = _VetsListLoaded;
  const factory VetState.profileSaved(VetProfile profile) = _ProfileSaved;
  const factory VetState.error(String message) = _Error;
}
