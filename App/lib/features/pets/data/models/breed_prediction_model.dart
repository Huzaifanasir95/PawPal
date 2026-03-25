import 'package:freezed_annotation/freezed_annotation.dart';

part 'breed_prediction_model.freezed.dart';
part 'breed_prediction_model.g.dart';

@freezed
class BreedPrediction with _$BreedPrediction {
  const factory BreedPrediction({
    required String breed,
    required double confidence,
    required int rank,
  }) = _BreedPrediction;

  factory BreedPrediction.fromJson(Map<String, dynamic> json) =>
      _$BreedPredictionFromJson(json);
}

@freezed
class PredictionResult with _$PredictionResult {
  const factory PredictionResult({
    required bool success,
    @JsonKey(name: 'predicted_breed') String? predicted,
    double? confidence,
    @JsonKey(name: 'top_predictions') @Default([]) List<BreedPrediction> predictions,
    @JsonKey(name: 'process_time_ms') @Default(0.0) double processTime,
    @JsonKey(name: 'used_tta') @Default(false) bool usedTTA,
    String? message,
    String? error,
  }) = _PredictionResult;

  factory PredictionResult.fromJson(Map<String, dynamic> json) =>
      _$PredictionResultFromJson(json);
}
