import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_journal_model.freezed.dart';
part 'health_journal_model.g.dart';

@freezed
class HealthJournalModel with _$HealthJournalModel {
  const factory HealthJournalModel({
    required String id,
    required String petId,
    required String ownerId,
    required DateTime date,
    // Physical health
    double? weight,
    String? weightUnit, // 'kg' or 'lbs'
    String? activityLevel, // 'low', 'moderate', 'high'
    String? energyLevel, // 'low', 'normal', 'high'
    // Mood and behavior
    String? mood, // 'happy', 'sad', 'anxious', 'aggressive', 'calm'
    String? appetite, // 'good', 'poor', 'normal'
    // Health observations
    List<String>? symptoms,
    List<String>? medicationsTaken,
    // Vet visits
    bool? vetVisit,
    String? vetVisitReason,
    String? vetNotes,
    // Notes
    String? generalNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _HealthJournalModel;

  factory HealthJournalModel.fromJson(Map<String, dynamic> json) =>
      _$HealthJournalModelFromJson(json);
}