import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/community_hub_repository.dart';
import '../../data/models/community_hub_models.dart';
import 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final CommunityHubRepository _repo;

  EventsCubit(this._repo) : super(const EventsState());

  Future<void> loadEvents({String? eventType}) async {
    emit(state.copyWith(isLoading: true, error: null, filterType: eventType));
    try {
      final events = await _repo.getEvents(eventType: eventType);
      emit(state.copyWith(isLoading: false, events: events));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> loadEventDetail(String id) async {
    emit(state.copyWith(isLoadingDetail: true, selectedEvent: null, error: null));
    try {
      final results = await Future.wait([
        _repo.getEventById(id),
        _repo.getMyRSVP(id),
        _repo.getEventRSVPs(id),
      ]);
      emit(state.copyWith(
        isLoadingDetail: false,
        selectedEvent: results[0] as PetEvent,
        myRsvp: results[1] as EventRSVP?,
        eventRsvps: results[2] as List<EventRSVP>,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetail: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required String eventType,
    required String startDate,
    String? endDate,
    String? imageUrl,
    String? location,
    double? locationLat,
    double? locationLng,
    int? maxAttendees,
    bool isPetFriendly = true,
    List<String>? petTypesAllowed,
  }) async {
    emit(state.copyWith(isCreating: true, error: null));
    try {
      await _repo.createEvent(
        title: title,
        description: description,
        eventType: eventType,
        startDate: startDate,
        endDate: endDate,
        imageUrl: imageUrl,
        location: location,
        locationLat: locationLat,
        locationLng: locationLng,
        maxAttendees: maxAttendees,
        isPetFriendly: isPetFriendly,
        petTypesAllowed: petTypesAllowed,
      );
      emit(state.copyWith(isCreating: false));
      await loadEvents(eventType: state.filterType);
      return true;
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<void> rsvpEvent(String eventId, String status) async {
    emit(state.copyWith(isRsvping: true, error: null));
    try {
      final rsvp = await _repo.rsvpEvent(eventId, status);
      emit(state.copyWith(isRsvping: false, myRsvp: rsvp));
      // Refresh RSVPs list
      final rsvps = await _repo.getEventRSVPs(eventId);
      emit(state.copyWith(eventRsvps: rsvps));
    } catch (e) {
      emit(state.copyWith(
        isRsvping: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> cancelRsvp(String eventId) async {
    emit(state.copyWith(isRsvping: true, error: null));
    try {
      await _repo.cancelRSVP(eventId);
      emit(state.copyWith(isRsvping: false));
      // Refresh
      final rsvps = await _repo.getEventRSVPs(eventId);
      emit(state.copyWith(eventRsvps: rsvps));
    } catch (e) {
      emit(state.copyWith(
        isRsvping: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repo.deleteEvent(id);
      await loadEvents(eventType: state.filterType);
    } catch (e) {
      emit(state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
}
