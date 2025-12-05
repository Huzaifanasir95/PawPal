import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/vet_repository.dart';
import '../../data/models/vet_profile_model.dart';
import 'vet_event.dart';
import 'vet_state.dart';

@injectable
class VetBloc extends Bloc<VetEvent, VetState> {
  final VetRepository _repository;

  VetBloc(this._repository) : super(const VetState.initial()) {
    on<VetEvent>((event, emit) async {
      await event.when(
        loadVetProfile: (userId) => _onLoadVetProfile(userId, emit),
        loadMyProfile: () => _onLoadMyProfile(emit),
        createOrUpdateProfile: (request) => _onCreateOrUpdateProfile(request, emit),
        listVets: (city, specialization, minRating, page, limit) =>
            _onListVets(city, specialization, minRating, page, limit, emit),
        searchVets: (query) => _onSearchVets(query, emit),
        filterVets: (city, specialization, minRating) =>
            _onFilterVets(city, specialization, minRating, emit),
        clearFilters: () => _onClearFilters(emit),
      );
    });
  }

  Future<void> _onLoadVetProfile(
    String userId,
    Emitter<VetState> emit,
  ) async {
    emit(const VetState.loading());
    try {
      final profile = await _repository.getVetProfile(userId);
      emit(VetState.profileLoaded(profile));
    } catch (e) {
      emit(VetState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMyProfile(
    Emitter<VetState> emit,
  ) async {
    emit(const VetState.loading());
    try {
      final profile = await _repository.getMyProfile();
      emit(VetState.profileLoaded(profile));
    } catch (e) {
      emit(VetState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateOrUpdateProfile(
    VetProfileRequest request,
    Emitter<VetState> emit,
  ) async {
    emit(const VetState.loading());
    try {
      final profile = await _repository.createOrUpdateProfile(request);
      emit(VetState.profileSaved(profile));
    } catch (e) {
      emit(VetState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onListVets(
    String? city,
    String? specialization,
    double? minRating,
    int page,
    int limit,
    Emitter<VetState> emit,
  ) async {
    emit(const VetState.loading());
    try {
      final result = await _repository.listVets(
        city: city,
        specialization: specialization,
        minRating: minRating,
        page: page,
        limit: limit,
      );
      
      emit(VetState.vetsListLoaded(
        vets: result.vets,
        total: result.total,
        currentPage: result.page,
        limit: result.limit,
        hasMore: result.vets.length >= limit && result.page * limit < result.total,
        appliedCity: city,
        appliedSpecialization: specialization,
        appliedMinRating: minRating,
      ));
    } catch (e) {
      emit(VetState.error(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSearchVets(
    String query,
    Emitter<VetState> emit,
  ) async {
    // For now, just list all vets. You could add a search endpoint to backend later
    add(VetEvent.listVets());
  }

  Future<void> _onFilterVets(
    String? city,
    String? specialization,
    double? minRating,
    Emitter<VetState> emit,
  ) async {
    add(VetEvent.listVets(
      city: city,
      specialization: specialization,
      minRating: minRating,
    ));
  }

  Future<void> _onClearFilters(
    Emitter<VetState> emit,
  ) async {
    add(const VetEvent.listVets());
  }
}
