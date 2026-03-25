import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/health_record_model.dart';
import '../models/health_journal_model.dart';

class HealthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HealthRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Reference to health records collection
  CollectionReference get _healthRecordsCollection =>
      _firestore.collection('health_records');

  /// Reference to health journals collection
  CollectionReference get _healthJournalsCollection =>
      _firestore.collection('health_journals');

  /// Create health record for a pet
  Future<String?> createHealthRecord({
    required String petId,
    required bool isVaccinated,
    String? vaccinationDate,
    String? vaccinationDetails,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? medications,
    String? vetName,
    String? vetClinic,
    String? vetPhone,
    String? vetAddress,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    String? additionalNotes,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Generate health record ID
      final doc = _healthRecordsCollection.doc();
      final recordId = doc.id;

      // Create health record model
      final healthRecord = HealthRecordModel(
        id: recordId,
        petId: petId,
        ownerId: userId,
        isVaccinated: isVaccinated,
        vaccinationDate: vaccinationDate,
        vaccinationDetails: vaccinationDetails,
        medicalConditions: medicalConditions,
        allergies: allergies,
        medications: medications,
        vetName: vetName,
        vetClinic: vetClinic,
        vetPhone: vetPhone,
        vetAddress: vetAddress,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        insuranceProvider: insuranceProvider,
        insurancePolicyNumber: insurancePolicyNumber,
        additionalNotes: additionalNotes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await doc.set(healthRecord.toJson());

      return recordId;
    } catch (e) {
      print('Error creating health record: $e');
      return null;
    }
  }

  /// Get health record for a pet
  Future<HealthRecordModel?> getHealthRecord(String petId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return null;

      final snapshot = await _healthRecordsCollection
          .where('petId', isEqualTo: petId)
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return HealthRecordModel.fromJson(
          snapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting health record: $e');
      return null;
    }
  }

  /// Update health record
  Future<bool> updateHealthRecord({
    required String recordId,
    bool? isVaccinated,
    String? vaccinationDate,
    String? vaccinationDetails,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? medications,
    String? vetName,
    String? vetClinic,
    String? vetPhone,
    String? vetAddress,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    String? additionalNotes,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isVaccinated != null) updateData['isVaccinated'] = isVaccinated;
      if (vaccinationDate != null) updateData['vaccinationDate'] = vaccinationDate;
      if (vaccinationDetails != null) updateData['vaccinationDetails'] = vaccinationDetails;
      if (medicalConditions != null) updateData['medicalConditions'] = medicalConditions;
      if (allergies != null) updateData['allergies'] = allergies;
      if (medications != null) updateData['medications'] = medications;
      if (vetName != null) updateData['vetName'] = vetName;
      if (vetClinic != null) updateData['vetClinic'] = vetClinic;
      if (vetPhone != null) updateData['vetPhone'] = vetPhone;
      if (vetAddress != null) updateData['vetAddress'] = vetAddress;
      if (emergencyContactName != null) updateData['emergencyContactName'] = emergencyContactName;
      if (emergencyContactPhone != null) updateData['emergencyContactPhone'] = emergencyContactPhone;
      if (insuranceProvider != null) updateData['insuranceProvider'] = insuranceProvider;
      if (insurancePolicyNumber != null) updateData['insurancePolicyNumber'] = insurancePolicyNumber;
      if (additionalNotes != null) updateData['additionalNotes'] = additionalNotes;

      await _healthRecordsCollection.doc(recordId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating health record: $e');
      return false;
    }
  }

  /// Create health journal entry
  Future<String?> createHealthJournalEntry({
    required String petId,
    required DateTime date,
    double? weight,
    String? weightUnit,
    String? activityLevel,
    String? energyLevel,
    String? mood,
    String? appetite,
    List<String>? symptoms,
    List<String>? medicationsTaken,
    bool? vetVisit,
    String? vetVisitReason,
    String? vetNotes,
    String? generalNotes,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Generate journal entry ID
      final doc = _healthJournalsCollection.doc();
      final entryId = doc.id;

      // Create health journal model
      final journalEntry = HealthJournalModel(
        id: entryId,
        petId: petId,
        ownerId: userId,
        date: date,
        weight: weight,
        weightUnit: weightUnit,
        activityLevel: activityLevel,
        energyLevel: energyLevel,
        mood: mood,
        appetite: appetite,
        symptoms: symptoms,
        medicationsTaken: medicationsTaken,
        vetVisit: vetVisit,
        vetVisitReason: vetVisitReason,
        vetNotes: vetNotes,
        generalNotes: generalNotes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await doc.set(journalEntry.toJson());

      return entryId;
    } catch (e) {
      print('Error creating health journal entry: $e');
      return null;
    }
  }

  /// Get health journal entries for a pet
  Stream<List<HealthJournalModel>> getHealthJournalEntries(String petId) {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _healthJournalsCollection
        .where('petId', isEqualTo: petId)
        .where('ownerId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HealthJournalModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get health journal entry by ID
  Future<HealthJournalModel?> getHealthJournalEntry(String entryId) async {
    try {
      final doc = await _healthJournalsCollection.doc(entryId).get();
      if (!doc.exists) return null;

      return HealthJournalModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting health journal entry: $e');
      return null;
    }
  }

  /// Update health journal entry
  Future<bool> updateHealthJournalEntry({
    required String entryId,
    double? weight,
    String? weightUnit,
    String? activityLevel,
    String? energyLevel,
    String? mood,
    String? appetite,
    List<String>? symptoms,
    List<String>? medicationsTaken,
    bool? vetVisit,
    String? vetVisitReason,
    String? vetNotes,
    String? generalNotes,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (weight != null) updateData['weight'] = weight;
      if (weightUnit != null) updateData['weightUnit'] = weightUnit;
      if (activityLevel != null) updateData['activityLevel'] = activityLevel;
      if (energyLevel != null) updateData['energyLevel'] = energyLevel;
      if (mood != null) updateData['mood'] = mood;
      if (appetite != null) updateData['appetite'] = appetite;
      if (symptoms != null) updateData['symptoms'] = symptoms;
      if (medicationsTaken != null) updateData['medicationsTaken'] = medicationsTaken;
      if (vetVisit != null) updateData['vetVisit'] = vetVisit;
      if (vetVisitReason != null) updateData['vetVisitReason'] = vetVisitReason;
      if (vetNotes != null) updateData['vetNotes'] = vetNotes;
      if (generalNotes != null) updateData['generalNotes'] = generalNotes;

      await _healthJournalsCollection.doc(entryId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating health journal entry: $e');
      return false;
    }
  }

  /// Delete health journal entry
  Future<bool> deleteHealthJournalEntry(String entryId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _healthJournalsCollection.doc(entryId).delete();
      return true;
    } catch (e) {
      print('Error deleting health journal entry: $e');
      return false;
    }
  }

  /// Get health journal entries for a specific date range
  Future<List<HealthJournalModel>> getHealthJournalEntriesInRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return [];

      final snapshot = await _healthJournalsCollection
          .where('petId', isEqualTo: petId)
          .where('ownerId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HealthJournalModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting health journal entries in range: $e');
      return [];
    }
  }
}