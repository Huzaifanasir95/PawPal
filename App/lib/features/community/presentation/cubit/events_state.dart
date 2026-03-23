import '../../data/models/community_hub_models.dart';

class EventsState {
  final bool isLoading;
  final bool isCreating;
  final bool isLoadingDetail;
  final bool isRsvping;
  final List<PetEvent> events;
  final PetEvent? selectedEvent;
  final EventRSVP? myRsvp;
  final List<EventRSVP> eventRsvps;
  final String? filterType;
  final String? error;

  const EventsState({
    this.isLoading = false,
    this.isCreating = false,
    this.isLoadingDetail = false,
    this.isRsvping = false,
    this.events = const [],
    this.selectedEvent,
    this.myRsvp,
    this.eventRsvps = const [],
    this.filterType,
    this.error,
  });

  EventsState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isLoadingDetail,
    bool? isRsvping,
    List<PetEvent>? events,
    PetEvent? selectedEvent,
    EventRSVP? myRsvp,
    List<EventRSVP>? eventRsvps,
    String? filterType,
    String? error,
  }) {
    return EventsState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isRsvping: isRsvping ?? this.isRsvping,
      events: events ?? this.events,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      myRsvp: myRsvp ?? this.myRsvp,
      eventRsvps: eventRsvps ?? this.eventRsvps,
      filterType: filterType ?? this.filterType,
      error: error,
    );
  }
}
