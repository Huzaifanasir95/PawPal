import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/community_hub_repository.dart';
import 'lost_found_state.dart';

class LostFoundCubit extends Cubit<LostFoundState> {
  final CommunityHubRepository _repo;

  LostFoundCubit(this._repo) : super(const LostFoundState());

  Future<void> loadPosts({String? type}) async {
    emit(state.copyWith(isLoading: true, error: null, filterType: type));
    try {
      final posts = await _repo.getLostFoundPosts(type: type);
      emit(state.copyWith(isLoading: false, posts: posts));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> loadPostDetail(String id) async {
    emit(state.copyWith(isLoadingDetail: true, selectedPost: null, error: null));
    try {
      final post = await _repo.getLostFoundById(id);
      emit(state.copyWith(isLoadingDetail: false, selectedPost: post));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetail: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<bool> createPost({
    required String type,
    required String description,
    String? petName,
    String? petType,
    String? breed,
    String? color,
    List<String>? imageUrls,
    String? lastSeenLocation,
    double? lastSeenLat,
    double? lastSeenLng,
    String? urgency,
    String? contactPhone,
    String? contactEmail,
  }) async {
    emit(state.copyWith(isCreating: true, error: null));
    try {
      await _repo.createLostFound(
        type: type,
        description: description,
        petName: petName,
        petType: petType,
        breed: breed,
        color: color,
        imageUrls: imageUrls,
        lastSeenLocation: lastSeenLocation,
        lastSeenLat: lastSeenLat,
        lastSeenLng: lastSeenLng,
        urgency: urgency,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
      );
      emit(state.copyWith(isCreating: false));
      await loadPosts(type: state.filterType);
      return true;
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await _repo.deleteLostFound(id);
      await loadPosts(type: state.filterType);
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
  void clearSelectedPost() => emit(state.copyWith(selectedPost: null));
}
