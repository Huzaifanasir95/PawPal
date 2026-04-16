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
    String? predicted,
    double? confidence,
    @Default([]) List<BreedPrediction> predictions,
    @Default(0.0) double processTime,
    @Default(false) bool usedTTA,
    String? message,
    String? error,
  }) = _PredictionResult;

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final rawPredictions = json['top_predictions'] ?? json['predictions'];

    final parsedPredictions =
        rawPredictions is List
            ? rawPredictions
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return BreedPrediction.fromJson(item);
                  }
                  if (item is Map) {
                    return BreedPrediction.fromJson(
                      Map<String, dynamic>.from(item),
                    );
                  }
                  return null;
                })
                .whereType<BreedPrediction>()
                .toList()
            : const <BreedPrediction>[];

    return PredictionResult(
      success: json['success'] as bool? ?? false,
      predicted: (json['predicted_breed'] ?? json['predicted']) as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      predictions: parsedPredictions,
      processTime:
          ((json['process_time_ms'] ?? json['processTime']) as num?)
              ?.toDouble() ??
          0.0,
      usedTTA: (json['used_tta'] ?? json['usedTTA']) as bool? ?? false,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}
