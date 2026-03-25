import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/community_hub_repository.dart';
import '../../data/models/community_hub_models.dart';
import 'adoption_state.dart';

class AdoptionCubit extends Cubit<AdoptionState> {
  final CommunityHubRepository _repo;

  AdoptionCubit(this._repo) : super(const AdoptionState());

  Future<void> loadListings({String? petType}) async {
    emit(state.copyWith(isLoading: true, error: null, filterPetType: petType));
    try {
      final listings = await _repo.getAdoptionListings(petType: petType);
      emit(state.copyWith(isLoading: false, listings: listings));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> loadDetail(String id) async {
    emit(state.copyWith(isLoadingDetail: true, selectedListing: null, error: null));
    try {
      final listing = await _repo.getAdoptionById(id);
      emit(state.copyWith(isLoadingDetail: false, selectedListing: listing));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetail: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<bool> createListing({
    required String petName,
    required String petType,
    required String description,
    String? breed,
    String? age,
    String? gender,
    String? size,
    String? color,
    String? medicalInfo,
    bool isVaccinated = false,
    bool isNeutered = false,
    bool isTrained = false,
    bool? goodWithKids,
    bool? goodWithPets,
    List<String>? imageUrls,
    String? location,
    String? contactPhone,
    String? contactEmail,
    double? adoptionFee,
  }) async {
    emit(state.copyWith(isCreating: true, error: null));
    try {
      await _repo.createAdoption(
        petName: petName,
        petType: petType,
        description: description,
        breed: breed,
        age: age,
        gender: gender,
        size: size,
        color: color,
        medicalInfo: medicalInfo,
        isVaccinated: isVaccinated,
        isNeutered: isNeutered,
        isTrained: isTrained,
        goodWithKids: goodWithKids,
        goodWithPets: goodWithPets,
        imageUrls: imageUrls,
        location: location,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        adoptionFee: adoptionFee,
      );
      emit(state.copyWith(isCreating: false));
      await loadListings(petType: state.filterPetType);
      return true;
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _repo.deleteAdoption(id);
      await loadListings(petType: state.filterPetType);
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
  void clearSelectedListing() => emit(state.copyWith(selectedListing: null));
}
