class LostFoundPost {
  final String id;
  final String userId;
  final String type; // lost, found
  final String? petName;
  final String? petType;
  final String? breed;
  final String? color;
  final String description;
  final List<String> imageUrls;
  final String? lastSeenLocation;
  final double? lastSeenLat;
  final double? lastSeenLng;
  final String urgency; // low, medium, high, critical
  final String? contactPhone;
  final String? contactEmail;
  final String status; // active, resolved, expired
  final String? userName;
  final String? userAvatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LostFoundPost({
    required this.id,
    required this.userId,
    required this.type,
    this.petName,
    this.petType,
    this.breed,
    this.color,
    required this.description,
    this.imageUrls = const [],
    this.lastSeenLocation,
    this.lastSeenLat,
    this.lastSeenLng,
    required this.urgency,
    this.contactPhone,
    this.contactEmail,
    required this.status,
    this.userName,
    this.userAvatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LostFoundPost.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imageUrls'];
    List<String> images = [];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    }
    return LostFoundPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      petName: json['petName'] as String?,
      petType: json['petType'] as String?,
      breed: json['breed'] as String?,
      color: json['color'] as String?,
      description: json['description'] as String,
      imageUrls: images,
      lastSeenLocation: json['lastSeenLocation'] as String?,
      lastSeenLat: (json['lastSeenLat'] as num?)?.toDouble(),
      lastSeenLng: (json['lastSeenLng'] as num?)?.toDouble(),
      urgency: json['urgency'] as String? ?? 'medium',
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      status: json['status'] as String? ?? 'active',
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class AdoptionListing {
  final String id;
  final String userId;
  final String petName;
  final String petType;
  final String? breed;
  final String? age;
  final String? gender;
  final String? size;
  final String? color;
  final String description;
  final String? medicalInfo;
  final bool isVaccinated;
  final bool isNeutered;
  final bool isTrained;
  final bool? goodWithKids;
  final bool? goodWithPets;
  final List<String> imageUrls;
  final String? location;
  final String? contactPhone;
  final String? contactEmail;
  final double adoptionFee;
  final String status; // available, pending, adopted, removed
  final String? userName;
  final String? userAvatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdoptionListing({
    required this.id,
    required this.userId,
    required this.petName,
    required this.petType,
    this.breed,
    this.age,
    this.gender,
    this.size,
    this.color,
    required this.description,
    this.medicalInfo,
    this.isVaccinated = false,
    this.isNeutered = false,
    this.isTrained = false,
    this.goodWithKids,
    this.goodWithPets,
    this.imageUrls = const [],
    this.location,
    this.contactPhone,
    this.contactEmail,
    this.adoptionFee = 0,
    required this.status,
    this.userName,
    this.userAvatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdoptionListing.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imageUrls'];
    List<String> images = [];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    }
    return AdoptionListing(
      id: json['id'] as String,
      userId: json['userId'] as String,
      petName: json['petName'] as String,
      petType: json['petType'] as String,
      breed: json['breed'] as String?,
      age: json['age'] as String?,
      gender: json['gender'] as String?,
      size: json['size'] as String?,
      color: json['color'] as String?,
      description: json['description'] as String,
      medicalInfo: json['medicalInfo'] as String?,
      isVaccinated: json['isVaccinated'] as bool? ?? false,
      isNeutered: json['isNeutered'] as bool? ?? false,
      isTrained: json['isTrained'] as bool? ?? false,
      goodWithKids: json['goodWithKids'] as bool?,
      goodWithPets: json['goodWithPets'] as bool?,
      imageUrls: images,
      location: json['location'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      adoptionFee: (json['adoptionFee'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'available',
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class PetEvent {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final String eventType; // meetup, adoption_drive, training, competition, charity, other
  final String? imageUrl;
  final String? location;
  final double? locationLat;
  final double? locationLng;
  final DateTime startDate;
  final DateTime? endDate;
  final int? maxAttendees;
  final bool isPetFriendly;
  final List<String> petTypesAllowed;
  final String status; // upcoming, ongoing, completed, cancelled
  final String? organizerName;
  final String? organizerAvatar;
  final int rsvpCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetEvent({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.eventType,
    this.imageUrl,
    this.location,
    this.locationLat,
    this.locationLng,
    required this.startDate,
    this.endDate,
    this.maxAttendees,
    this.isPetFriendly = true,
    this.petTypesAllowed = const [],
    required this.status,
    this.organizerName,
    this.organizerAvatar,
    this.rsvpCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PetEvent.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['petTypesAllowed'];
    List<String> types = [];
    if (rawTypes is List) {
      types = rawTypes.map((e) => e.toString()).toList();
    }
    return PetEvent(
      id: json['id'] as String,
      organizerId: json['organizerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      eventType: json['eventType'] as String? ?? 'other',
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] as String?,
      locationLat: (json['locationLat'] as num?)?.toDouble(),
      locationLng: (json['locationLng'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      maxAttendees: json['maxAttendees'] as int?,
      isPetFriendly: json['isPetFriendly'] as bool? ?? true,
      petTypesAllowed: types,
      status: json['status'] as String? ?? 'upcoming',
      organizerName: json['organizerName'] as String?,
      organizerAvatar: json['organizerAvatar'] as String?,
      rsvpCount: json['rsvpCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class EventRSVP {
  final String id;
  final String eventId;
  final String userId;
  final String status; // going, interested, waitlisted
  final String? userName;
  final String? userAvatar;
  final DateTime createdAt;

  const EventRSVP({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    this.userName,
    this.userAvatar,
    required this.createdAt,
  });

  factory EventRSVP.fromJson(Map<String, dynamic> json) {
    return EventRSVP(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
