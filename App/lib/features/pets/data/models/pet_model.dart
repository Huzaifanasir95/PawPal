import 'package:freezed_annotation/freezed_annotation.dart';
import 'health_record_model.dart';

part 'pet_model.freezed.dart';
part 'pet_model.g.dart';

@freezed
class PetModel with _$PetModel {
  const factory PetModel({
    required String id,
    required String name,
    required String type, // 'dog' or 'cat'
    required String breed,
    required int age,
    required String ageUnit, // 'months' or 'years'
    required String gender, // 'male' or 'female'
    required String color,
    required double weight,
    required String weightUnit, // 'kg' or 'lbs'
    String? imageUrl,
    String? imageLocalPath,
    List<String>? imageUrls, // Multiple images
    bool? isVerified, // Verified by AI
    double? verificationConfidence,
    String? verifiedBreed,
    String? bio,
    String? ownerId,
    HealthRecordModel? healthRecord, // Health records
    @Default(false) bool isAdopted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PetModel;

  factory PetModel.fromJson(Map<String, dynamic> json) =>
      _$PetModelFromJson(json);
}
