// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breed_prediction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BreedPredictionImpl _$$BreedPredictionImplFromJson(
  Map<String, dynamic> json,
) => _$BreedPredictionImpl(
  breed: json['breed'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  rank: (json['rank'] as num).toInt(),
);

Map<String, dynamic> _$$BreedPredictionImplToJson(
  _$BreedPredictionImpl instance,
) => <String, dynamic>{
  'breed': instance.breed,
  'confidence': instance.confidence,
  'rank': instance.rank,
};

_$PredictionResultImpl _$$PredictionResultImplFromJson(
  Map<String, dynamic> json,
) => _$PredictionResultImpl(
  success: json['success'] as bool,
  predicted: json['predicted_breed'] as String?,
  confidence: (json['confidence'] as num?)?.toDouble(),
  predictions:
      (json['top_predictions'] as List<dynamic>?)
          ?.map((e) => BreedPrediction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  processTime: (json['process_time_ms'] as num?)?.toDouble() ?? 0.0,
  usedTTA: json['used_tta'] as bool? ?? false,
  message: json['message'] as String?,
  error: json['error'] as String?,
);

Map<String, dynamic> _$$PredictionResultImplToJson(
  _$PredictionResultImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'predicted_breed': instance.predicted,
  'confidence': instance.confidence,
  'top_predictions': instance.predictions,
  'process_time_ms': instance.processTime,
  'used_tta': instance.usedTTA,
  'message': instance.message,
  'error': instance.error,
};
