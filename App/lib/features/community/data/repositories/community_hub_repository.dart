import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';
import '../models/community_hub_models.dart';

class CommunityHubRepository {
  final ApiClient _apiClient;

  CommunityHubRepository(this._apiClient);

  static CommunityHubRepository get instance =>
      CommunityHubRepository(ApiClient.instance);

  // ─── Lost & Found ─────────────────────────────────────────────

  Future<List<LostFoundPost>> getLostFoundPosts({
    String? type,
    String status = 'active',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'status': status,
        'limit': limit,
        'offset': offset,
        if (type != null) 'type': type,
      };
      final response = await _apiClient.get('/api/v1/lost-found',
          queryParameters: params);
      if (response.data['success'] == true) {
        final list = response.data['posts'] as List<dynamic>? ?? [];
        return list
            .map((e) => LostFoundPost.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load posts');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<LostFoundPost> getLostFoundById(String id) async {
    try {
      final response = await _apiClient.get('/api/v1/lost-found/$id');
      if (response.data['success'] == true) {
        return LostFoundPost.fromJson(
            response.data['post'] as Map<String, dynamic>);
      }
      throw Exception(response.data['message'] ?? 'Failed to load post');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<List<LostFoundPost>> getMyLostFoundPosts() async {
    try {
      final response = await _apiClient.get('/api/v1/lost-found/me');
      if (response.data['success'] == true) {
        final list = response.data['posts'] as List<dynamic>? ?? [];
        return list
            .map((e) => LostFoundPost.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load posts');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<LostFoundPost> createLostFound({
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
    try {
      final data = <String, dynamic>{
        'type': type,
        'description': description,
        if (petName != null) 'petName': petName,
        if (petType != null) 'petType': petType,
        if (breed != null) 'breed': breed,
        if (color != null) 'color': color,
        if (imageUrls != null) 'imageUrls': imageUrls,
        if (lastSeenLocation != null) 'lastSeenLocation': lastSeenLocation,
        if (lastSeenLat != null) 'lastSeenLat': lastSeenLat,
        if (lastSeenLng != null) 'lastSeenLng': lastSeenLng,
        if (urgency != null) 'urgency': urgency,
        if (contactPhone != null) 'contactPhone': contactPhone,
        if (contactEmail != null) 'contactEmail': contactEmail,
      };
      final response = await _apiClient.post('/api/v1/lost-found', data: data);
      if (response.data['success'] == true) {
        return LostFoundPost.fromJson(
            response.data['post'] as Map<String, dynamic>);
      }
      throw Exception(response.data['message'] ?? 'Failed to create post');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<void> updateLostFound(String id, Map<String, dynamic> updates) async {
    try {
      final response =
          await _apiClient.put('/api/v1/lost-found/$id', data: updates);
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<void> deleteLostFound(String id) async {
    try {
      final response = await _apiClient.delete('/api/v1/lost-found/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  // ─── Adoption Listings ────────────────────────────────────────

  Future<List<AdoptionListing>> getAdoptionListings({
    String? petType,
    String status = 'available',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'status': status,
        'limit': limit,
        'offset': offset,
        if (petType != null) 'petType': petType,
      };
      final response =
          await _apiClient.get('/api/v1/adoptions', queryParameters: params);
      if (response.data['success'] == true) {
        final list = response.data['listings'] as List<dynamic>? ?? [];
        return list
            .map((e) => AdoptionListing.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load listings');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<AdoptionListing> getAdoptionById(String id) async {
    try {
      final response = await _apiClient.get('/api/v1/adoptions/$id');
      if (response.data['success'] == true) {
        return AdoptionListing.fromJson(
            response.data['listing'] as Map<String, dynamic>);
      }
      throw Exception(response.data['message'] ?? 'Failed to load listing');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<List<AdoptionListing>> getMyAdoptionListings() async {
    try {
      final response = await _apiClient.get('/api/v1/adoptions/me');
      if (response.data['success'] == true) {
        final list = response.data['listings'] as List<dynamic>? ?? [];
        return list
            .map((e) => AdoptionListing.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load listings');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<AdoptionListing> createAdoption({
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
    try {
      final data = <String, dynamic>{
        'petName': petName,
        'petType': petType,
        'description': description,
        'isVaccinated': isVaccinated,
        'isNeutered': isNeutered,
        'isTrained': isTrained,
        'adoptionFee': adoptionFee ?? 0,
        if (breed != null) 'breed': breed,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (size != null) 'size': size,
        if (color != null) 'color': color,
        if (medicalInfo != null) 'medicalInfo': medicalInfo,
        if (goodWithKids != null) 'goodWithKids': goodWithKids,
        if (goodWithPets != null) 'goodWithPets': goodWithPets,
        if (imageUrls != null) 'imageUrls': imageUrls,
        if (location != null) 'location': location,
        if (contactPhone != null) 'contactPhone': contactPhone,
        if (contactEmail != null) 'contactEmail': contactEmail,
      };
      final response = await _apiClient.post('/api/v1/adoptions', data: data);
      if (response.data['success'] == true) {
        return AdoptionListing.fromJson(
            response.data['listing'] as Map<String, dynamic>);
      }
      throw Exception(response.data['message'] ?? 'Failed to create listing');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<void> updateAdoption(String id, Map<String, dynamic> updates) async {
    try {
      final response =
          await _apiClient.put('/api/v1/adoptions/$id', data: updates);
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<void> deleteAdoption(String id) async {
    try {
      final response = await _apiClient.delete('/api/v1/adoptions/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  // ─── Events ───────────────────────────────────────────────────

  Future<List<PetEvent>> getEvents({
    String? eventType,
    String status = 'upcoming',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'status': status,
        'limit': limit,
        'offset': offset,
        if (eventType != null) 'eventType': eventType,
      };
      final response =
          await _apiClient.get('/api/v1/events', queryParameters: params);
      if (response.data['success'] == true) {
        final list = response.data['events'] as List<dynamic>? ?? [];
        return list
            .map((e) => PetEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load events');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<PetEvent> getEventById(String id) async {
    try {
      final response = await _apiClient.get('/api/v1/events/$id');
      if (response.data['success'] == true) {
        return PetEvent.fromJson(
            response.data['event'] as Map<String, dynamic>);
      }
      throw Exception(response.data['message'] ?? 'Failed to load event');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<List<PetEvent>> getMyEvents() async {
    try {
      final response = await _apiClient.get('/api/v1/events/me');
      if (response.data['success'] == true) {
        final list = response.data['events'] as List<dynamic>? ?? [];
        return list
            .map((e) => PetEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load events');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<PetEvent> createEvent({
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
    try {
      final data = <String, dynamic>{
        'title': title,
        'description': description,
        'eventType': eventType,
        'startDate': startDate,
        'isPetFriendly': isPetFriendly,
        if (endDate != null) 'endDate': endDate,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (location != null) 'location': location,
        if (locationLat != null) 'locationLat': locationLat,
        if (locationLng != null) 'locationLng': locationLng,
        if (maxAttendees != null) 'maxAttendees': maxAttendees,
        if (petTypesAllowed != null) 'petTypesAllowed': petTypesAllowed,
      };
      final response = await _apiClient.post('/api/v1/events', data: data);
      if (response.data['success'] == true) {
        return PetEvent.fromJson(
            response.data['event'] as Map<String, dynamic>);
      }
      throw Exception(response.data['message'] ?? 'Failed to create event');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> updates) async {
    try {
      final response =
          await _apiClient.put('/api/v1/events/$id', data: updates);
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      final response = await _apiClient.delete('/api/v1/events/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  // ─── RSVPs ────────────────────────────────────────────────────

  Future<EventRSVP> rsvpEvent(String eventId, String status) async {
    try {
      final response = await _apiClient
          .post('/api/v1/events/$eventId/rsvp', data: {'status': status});
      if (response.data['success'] == true) {
        return EventRSVP.fromJson(
            response.data['rsvp'] as Map<String, dynamic>);
      }
      throw Exception(response.data['message'] ?? 'Failed to RSVP');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<void> cancelRSVP(String eventId) async {
    try {
      final response =
          await _apiClient.delete('/api/v1/events/$eventId/rsvp');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to cancel RSVP');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<List<EventRSVP>> getEventRSVPs(String eventId) async {
    try {
      final response =
          await _apiClient.get('/api/v1/events/$eventId/rsvps');
      if (response.data['success'] == true) {
        final list = response.data['rsvps'] as List<dynamic>? ?? [];
        return list
            .map((e) => EventRSVP.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load RSVPs');
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }

  Future<EventRSVP?> getMyRSVP(String eventId) async {
    try {
      final response =
          await _apiClient.get('/api/v1/events/$eventId/rsvp/me');
      if (response.data['success'] == true && response.data['rsvp'] != null) {
        return EventRSVP.fromJson(
            response.data['rsvp'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Network error: ${e.message}');
    }
  }
}
