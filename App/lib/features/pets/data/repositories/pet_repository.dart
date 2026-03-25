import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pet_model.dart';
import '../models/health_record_model.dart';

class PetRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PetRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Reference to pets collection
  CollectionReference get _petsCollection => _firestore.collection('pets');

  /// Create a new pet
  Future<String?> createPet({
    required String name,
    required String type,
    required String breed,
    required int age,
    required String ageUnit,
    required String gender,
    required String color,
    required double weight,
    required String weightUnit,
    File? imageFile,
    String? imageLocalPath,
    List<String>? imageUrls,
    bool? isVerified,
    double? verificationConfidence,
    String? verifiedBreed,
    String? bio,
    HealthRecordModel? healthRecord,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Generate pet ID
      final petDoc = _petsCollection.doc();
      final petId = petDoc.id;

      // Create pet model
      final pet = PetModel(
        id: petId,
        name: name,
        type: type,
        breed: breed,
        age: age,
        ageUnit: ageUnit,
        gender: gender,
        color: color,
        weight: weight,
        weightUnit: weightUnit,
        imageUrl: null, // Not using Firebase Storage
        imageLocalPath: imageLocalPath,
        imageUrls: imageUrls,
        isVerified: isVerified,
        verificationConfidence: verificationConfidence,
        verifiedBreed: verifiedBreed,
        bio: bio,
        ownerId: userId,
        healthRecord: healthRecord,
        isAdopted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await petDoc.set(pet.toJson());

      return petId;
    } catch (e) {
      print('Error creating pet: $e');
      return null;
    }
  }

  /// Get all pets for current user
  Stream<List<PetModel>> getUserPets() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _petsCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PetModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get a specific pet by ID
  Future<PetModel?> getPetById(String petId) async {
    try {
      final doc = await _petsCollection.doc(petId).get();
      if (!doc.exists) return null;

      return PetModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting pet: $e');
      return null;
    }
  }

  /// Update a pet
  Future<bool> updatePet({
    required String petId,
    String? name,
    String? breed,
    int? age,
    String? ageUnit,
    String? gender,
    String? color,
    double? weight,
    String? weightUnit,
    File? newImageFile,
    List<String>? imageUrls,
    String? bio,
    HealthRecordModel? healthRecord,
    bool? isAdopted,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (breed != null) updateData['breed'] = breed;
      if (age != null) updateData['age'] = age;
      if (ageUnit != null) updateData['ageUnit'] = ageUnit;
      if (gender != null) updateData['gender'] = gender;
      if (color != null) updateData['color'] = color;
      if (weight != null) updateData['weight'] = weight;
      if (weightUnit != null) updateData['weightUnit'] = weightUnit;
      if (imageUrls != null) updateData['imageUrls'] = imageUrls;
      if (bio != null) updateData['bio'] = bio;
      if (healthRecord != null) updateData['healthRecord'] = healthRecord.toJson();
      if (isAdopted != null) updateData['isAdopted'] = isAdopted;

      await _petsCollection.doc(petId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating pet: $e');
      return false;
    }
  }

  /// Delete a pet
  Future<bool> deletePet(String petId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Delete pet document
      await _petsCollection.doc(petId).delete();

      return true;
    } catch (e) {
      print('Error deleting pet: $e');
      return false;
    }
  }

  /// Get pet count for current user
  Future<int> getUserPetCount() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return 0;

      final snapshot = await _petsCollection
          .where('ownerId', isEqualTo: userId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting pet count: $e');
      return 0;
    }
  }

  /// Search pets by breed
  Future<List<PetModel>> searchPetsByBreed(String breed) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return [];

      final snapshot = await _petsCollection
          .where('ownerId', isEqualTo: userId)
          .where('breed', isEqualTo: breed)
          .get();

      return snapshot.docs
          .map((doc) => PetModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching pets: $e');
      return [];
    }
  }

  /// Get all verified pets
  Stream<List<PetModel>> getVerifiedPets() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _petsCollection
        .where('ownerId', isEqualTo: userId)
        .where('isVerified', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PetModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
