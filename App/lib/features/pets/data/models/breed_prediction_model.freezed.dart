// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'breed_prediction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BreedPrediction _$BreedPredictionFromJson(Map<String, dynamic> json) {
  return _BreedPrediction.fromJson(json);
}

/// @nodoc
mixin _$BreedPrediction {
  String get breed => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;

  /// Serializes this BreedPrediction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BreedPrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BreedPredictionCopyWith<BreedPrediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreedPredictionCopyWith<$Res> {
  factory $BreedPredictionCopyWith(
    BreedPrediction value,
    $Res Function(BreedPrediction) then,
  ) = _$BreedPredictionCopyWithImpl<$Res, BreedPrediction>;
  @useResult
  $Res call({String breed, double confidence, int rank});
}

/// @nodoc
class _$BreedPredictionCopyWithImpl<$Res, $Val extends BreedPrediction>
    implements $BreedPredictionCopyWith<$Res> {
  _$BreedPredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BreedPrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? breed = null,
    Object? confidence = null,
    Object? rank = null,
  }) {
    return _then(
      _value.copyWith(
            breed:
                null == breed
                    ? _value.breed
                    : breed // ignore: cast_nullable_to_non_nullable
                        as String,
            confidence:
                null == confidence
                    ? _value.confidence
                    : confidence // ignore: cast_nullable_to_non_nullable
                        as double,
            rank:
                null == rank
                    ? _value.rank
                    : rank // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BreedPredictionImplCopyWith<$Res>
    implements $BreedPredictionCopyWith<$Res> {
  factory _$$BreedPredictionImplCopyWith(
    _$BreedPredictionImpl value,
    $Res Function(_$BreedPredictionImpl) then,
  ) = __$$BreedPredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String breed, double confidence, int rank});
}

/// @nodoc
class __$$BreedPredictionImplCopyWithImpl<$Res>
    extends _$BreedPredictionCopyWithImpl<$Res, _$BreedPredictionImpl>
    implements _$$BreedPredictionImplCopyWith<$Res> {
  __$$BreedPredictionImplCopyWithImpl(
    _$BreedPredictionImpl _value,
    $Res Function(_$BreedPredictionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BreedPrediction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? breed = null,
    Object? confidence = null,
    Object? rank = null,
  }) {
    return _then(
      _$BreedPredictionImpl(
        breed:
            null == breed
                ? _value.breed
                : breed // ignore: cast_nullable_to_non_nullable
                    as String,
        confidence:
            null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                    as double,
        rank:
            null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BreedPredictionImpl implements _BreedPrediction {
  const _$BreedPredictionImpl({
    required this.breed,
    required this.confidence,
    required this.rank,
  });

  factory _$BreedPredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BreedPredictionImplFromJson(json);

  @override
  final String breed;
  @override
  final double confidence;
  @override
  final int rank;

  @override
  String toString() {
    return 'BreedPrediction(breed: $breed, confidence: $confidence, rank: $rank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BreedPredictionImpl &&
            (identical(other.breed, breed) || other.breed == breed) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.rank, rank) || other.rank == rank));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, breed, confidence, rank);

  /// Create a copy of BreedPrediction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BreedPredictionImplCopyWith<_$BreedPredictionImpl> get copyWith =>
      __$$BreedPredictionImplCopyWithImpl<_$BreedPredictionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BreedPredictionImplToJson(this);
  }
}

abstract class _BreedPrediction implements BreedPrediction {
  const factory _BreedPrediction({
    required final String breed,
    required final double confidence,
    required final int rank,
  }) = _$BreedPredictionImpl;

  factory _BreedPrediction.fromJson(Map<String, dynamic> json) =
      _$BreedPredictionImpl.fromJson;

  @override
  String get breed;
  @override
  double get confidence;
  @override
  int get rank;

  /// Create a copy of BreedPrediction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BreedPredictionImplCopyWith<_$BreedPredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PredictionResult _$PredictionResultFromJson(Map<String, dynamic> json) {
  return _PredictionResult.fromJson(json);
}

/// @nodoc
mixin _$PredictionResult {
  bool get success => throw _privateConstructorUsedError;
  @JsonKey(name: 'predicted_breed')
  String? get predicted => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'top_predictions')
  List<BreedPrediction> get predictions => throw _privateConstructorUsedError;
  @JsonKey(name: 'process_time_ms')
  double get processTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'used_tta')
  bool get usedTTA => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this PredictionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PredictionResultCopyWith<PredictionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionResultCopyWith<$Res> {
  factory $PredictionResultCopyWith(
    PredictionResult value,
    $Res Function(PredictionResult) then,
  ) = _$PredictionResultCopyWithImpl<$Res, PredictionResult>;
  @useResult
  $Res call({
    bool success,
    @JsonKey(name: 'predicted_breed') String? predicted,
    double? confidence,
    @JsonKey(name: 'top_predictions') List<BreedPrediction> predictions,
    @JsonKey(name: 'process_time_ms') double processTime,
    @JsonKey(name: 'used_tta') bool usedTTA,
    String? message,
    String? error,
  });
}

/// @nodoc
class _$PredictionResultCopyWithImpl<$Res, $Val extends PredictionResult>
    implements $PredictionResultCopyWith<$Res> {
  _$PredictionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? predicted = freezed,
    Object? confidence = freezed,
    Object? predictions = null,
    Object? processTime = null,
    Object? usedTTA = null,
    Object? message = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            success:
                null == success
                    ? _value.success
                    : success // ignore: cast_nullable_to_non_nullable
                        as bool,
            predicted:
                freezed == predicted
                    ? _value.predicted
                    : predicted // ignore: cast_nullable_to_non_nullable
                        as String?,
            confidence:
                freezed == confidence
                    ? _value.confidence
                    : confidence // ignore: cast_nullable_to_non_nullable
                        as double?,
            predictions:
                null == predictions
                    ? _value.predictions
                    : predictions // ignore: cast_nullable_to_non_nullable
                        as List<BreedPrediction>,
            processTime:
                null == processTime
                    ? _value.processTime
                    : processTime // ignore: cast_nullable_to_non_nullable
                        as double,
            usedTTA:
                null == usedTTA
                    ? _value.usedTTA
                    : usedTTA // ignore: cast_nullable_to_non_nullable
                        as bool,
            message:
                freezed == message
                    ? _value.message
                    : message // ignore: cast_nullable_to_non_nullable
                        as String?,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PredictionResultImplCopyWith<$Res>
    implements $PredictionResultCopyWith<$Res> {
  factory _$$PredictionResultImplCopyWith(
    _$PredictionResultImpl value,
    $Res Function(_$PredictionResultImpl) then,
  ) = __$$PredictionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    @JsonKey(name: 'predicted_breed') String? predicted,
    double? confidence,
    @JsonKey(name: 'top_predictions') List<BreedPrediction> predictions,
    @JsonKey(name: 'process_time_ms') double processTime,
    @JsonKey(name: 'used_tta') bool usedTTA,
    String? message,
    String? error,
  });
}

/// @nodoc
class __$$PredictionResultImplCopyWithImpl<$Res>
    extends _$PredictionResultCopyWithImpl<$Res, _$PredictionResultImpl>
    implements _$$PredictionResultImplCopyWith<$Res> {
  __$$PredictionResultImplCopyWithImpl(
    _$PredictionResultImpl _value,
    $Res Function(_$PredictionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? predicted = freezed,
    Object? confidence = freezed,
    Object? predictions = null,
    Object? processTime = null,
    Object? usedTTA = null,
    Object? message = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$PredictionResultImpl(
        success:
            null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                    as bool,
        predicted:
            freezed == predicted
                ? _value.predicted
                : predicted // ignore: cast_nullable_to_non_nullable
                    as String?,
        confidence:
            freezed == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                    as double?,
        predictions:
            null == predictions
                ? _value._predictions
                : predictions // ignore: cast_nullable_to_non_nullable
                    as List<BreedPrediction>,
        processTime:
            null == processTime
                ? _value.processTime
                : processTime // ignore: cast_nullable_to_non_nullable
                    as double,
        usedTTA:
            null == usedTTA
                ? _value.usedTTA
                : usedTTA // ignore: cast_nullable_to_non_nullable
                    as bool,
        message:
            freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String?,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PredictionResultImpl implements _PredictionResult {
  const _$PredictionResultImpl({
    required this.success,
    @JsonKey(name: 'predicted_breed') this.predicted,
    this.confidence,
    @JsonKey(name: 'top_predictions')
    final List<BreedPrediction> predictions = const [],
    @JsonKey(name: 'process_time_ms') this.processTime = 0.0,
    @JsonKey(name: 'used_tta') this.usedTTA = false,
    this.message,
    this.error,
  }) : _predictions = predictions;

  factory _$PredictionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PredictionResultImplFromJson(json);

  @override
  final bool success;
  @override
  @JsonKey(name: 'predicted_breed')
  final String? predicted;
  @override
  final double? confidence;
  final List<BreedPrediction> _predictions;
  @override
  @JsonKey(name: 'top_predictions')
  List<BreedPrediction> get predictions {
    if (_predictions is EqualUnmodifiableListView) return _predictions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_predictions);
  }

  @override
  @JsonKey(name: 'process_time_ms')
  final double processTime;
  @override
  @JsonKey(name: 'used_tta')
  final bool usedTTA;
  @override
  final String? message;
  @override
  final String? error;

  @override
  String toString() {
    return 'PredictionResult(success: $success, predicted: $predicted, confidence: $confidence, predictions: $predictions, processTime: $processTime, usedTTA: $usedTTA, message: $message, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.predicted, predicted) ||
                other.predicted == predicted) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality().equals(
              other._predictions,
              _predictions,
            ) &&
            (identical(other.processTime, processTime) ||
                other.processTime == processTime) &&
            (identical(other.usedTTA, usedTTA) || other.usedTTA == usedTTA) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    predicted,
    confidence,
    const DeepCollectionEquality().hash(_predictions),
    processTime,
    usedTTA,
    message,
    error,
  );

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionResultImplCopyWith<_$PredictionResultImpl> get copyWith =>
      __$$PredictionResultImplCopyWithImpl<_$PredictionResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PredictionResultImplToJson(this);
  }
}

abstract class _PredictionResult implements PredictionResult {
  const factory _PredictionResult({
    required final bool success,
    @JsonKey(name: 'predicted_breed') final String? predicted,
    final double? confidence,
    @JsonKey(name: 'top_predictions') final List<BreedPrediction> predictions,
    @JsonKey(name: 'process_time_ms') final double processTime,
    @JsonKey(name: 'used_tta') final bool usedTTA,
    final String? message,
    final String? error,
  }) = _$PredictionResultImpl;

  factory _PredictionResult.fromJson(Map<String, dynamic> json) =
      _$PredictionResultImpl.fromJson;

  @override
  bool get success;
  @override
  @JsonKey(name: 'predicted_breed')
  String? get predicted;
  @override
  double? get confidence;
  @override
  @JsonKey(name: 'top_predictions')
  List<BreedPrediction> get predictions;
  @override
  @JsonKey(name: 'process_time_ms')
  double get processTime;
  @override
  @JsonKey(name: 'used_tta')
  bool get usedTTA;
  @override
  String? get message;
  @override
  String? get error;

  /// Create a copy of PredictionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PredictionResultImplCopyWith<_$PredictionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
