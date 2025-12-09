// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_journal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HealthJournalModel _$HealthJournalModelFromJson(Map<String, dynamic> json) {
  return _HealthJournalModel.fromJson(json);
}

/// @nodoc
mixin _$HealthJournalModel {
  String get id => throw _privateConstructorUsedError;
  String get petId => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError; // Physical health
  double? get weight => throw _privateConstructorUsedError;
  String? get weightUnit => throw _privateConstructorUsedError; // 'kg' or 'lbs'
  String? get activityLevel =>
      throw _privateConstructorUsedError; // 'low', 'moderate', 'high'
  String? get energyLevel =>
      throw _privateConstructorUsedError; // 'low', 'normal', 'high'
  // Mood and behavior
  String? get mood =>
      throw _privateConstructorUsedError; // 'happy', 'sad', 'anxious', 'aggressive', 'calm'
  String? get appetite =>
      throw _privateConstructorUsedError; // 'good', 'poor', 'normal'
  // Health observations
  List<String>? get symptoms => throw _privateConstructorUsedError;
  List<String>? get medicationsTaken =>
      throw _privateConstructorUsedError; // Vet visits
  bool? get vetVisit => throw _privateConstructorUsedError;
  String? get vetVisitReason => throw _privateConstructorUsedError;
  String? get vetNotes => throw _privateConstructorUsedError; // Notes
  String? get generalNotes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this HealthJournalModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthJournalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthJournalModelCopyWith<HealthJournalModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthJournalModelCopyWith<$Res> {
  factory $HealthJournalModelCopyWith(
    HealthJournalModel value,
    $Res Function(HealthJournalModel) then,
  ) = _$HealthJournalModelCopyWithImpl<$Res, HealthJournalModel>;
  @useResult
  $Res call({
    String id,
    String petId,
    String ownerId,
    DateTime date,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$HealthJournalModelCopyWithImpl<$Res, $Val extends HealthJournalModel>
    implements $HealthJournalModelCopyWith<$Res> {
  _$HealthJournalModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthJournalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? petId = null,
    Object? ownerId = null,
    Object? date = null,
    Object? weight = freezed,
    Object? weightUnit = freezed,
    Object? activityLevel = freezed,
    Object? energyLevel = freezed,
    Object? mood = freezed,
    Object? appetite = freezed,
    Object? symptoms = freezed,
    Object? medicationsTaken = freezed,
    Object? vetVisit = freezed,
    Object? vetVisitReason = freezed,
    Object? vetNotes = freezed,
    Object? generalNotes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            petId:
                null == petId
                    ? _value.petId
                    : petId // ignore: cast_nullable_to_non_nullable
                        as String,
            ownerId:
                null == ownerId
                    ? _value.ownerId
                    : ownerId // ignore: cast_nullable_to_non_nullable
                        as String,
            date:
                null == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            weight:
                freezed == weight
                    ? _value.weight
                    : weight // ignore: cast_nullable_to_non_nullable
                        as double?,
            weightUnit:
                freezed == weightUnit
                    ? _value.weightUnit
                    : weightUnit // ignore: cast_nullable_to_non_nullable
                        as String?,
            activityLevel:
                freezed == activityLevel
                    ? _value.activityLevel
                    : activityLevel // ignore: cast_nullable_to_non_nullable
                        as String?,
            energyLevel:
                freezed == energyLevel
                    ? _value.energyLevel
                    : energyLevel // ignore: cast_nullable_to_non_nullable
                        as String?,
            mood:
                freezed == mood
                    ? _value.mood
                    : mood // ignore: cast_nullable_to_non_nullable
                        as String?,
            appetite:
                freezed == appetite
                    ? _value.appetite
                    : appetite // ignore: cast_nullable_to_non_nullable
                        as String?,
            symptoms:
                freezed == symptoms
                    ? _value.symptoms
                    : symptoms // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            medicationsTaken:
                freezed == medicationsTaken
                    ? _value.medicationsTaken
                    : medicationsTaken // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            vetVisit:
                freezed == vetVisit
                    ? _value.vetVisit
                    : vetVisit // ignore: cast_nullable_to_non_nullable
                        as bool?,
            vetVisitReason:
                freezed == vetVisitReason
                    ? _value.vetVisitReason
                    : vetVisitReason // ignore: cast_nullable_to_non_nullable
                        as String?,
            vetNotes:
                freezed == vetNotes
                    ? _value.vetNotes
                    : vetNotes // ignore: cast_nullable_to_non_nullable
                        as String?,
            generalNotes:
                freezed == generalNotes
                    ? _value.generalNotes
                    : generalNotes // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HealthJournalModelImplCopyWith<$Res>
    implements $HealthJournalModelCopyWith<$Res> {
  factory _$$HealthJournalModelImplCopyWith(
    _$HealthJournalModelImpl value,
    $Res Function(_$HealthJournalModelImpl) then,
  ) = __$$HealthJournalModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String petId,
    String ownerId,
    DateTime date,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$HealthJournalModelImplCopyWithImpl<$Res>
    extends _$HealthJournalModelCopyWithImpl<$Res, _$HealthJournalModelImpl>
    implements _$$HealthJournalModelImplCopyWith<$Res> {
  __$$HealthJournalModelImplCopyWithImpl(
    _$HealthJournalModelImpl _value,
    $Res Function(_$HealthJournalModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HealthJournalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? petId = null,
    Object? ownerId = null,
    Object? date = null,
    Object? weight = freezed,
    Object? weightUnit = freezed,
    Object? activityLevel = freezed,
    Object? energyLevel = freezed,
    Object? mood = freezed,
    Object? appetite = freezed,
    Object? symptoms = freezed,
    Object? medicationsTaken = freezed,
    Object? vetVisit = freezed,
    Object? vetVisitReason = freezed,
    Object? vetNotes = freezed,
    Object? generalNotes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$HealthJournalModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        petId:
            null == petId
                ? _value.petId
                : petId // ignore: cast_nullable_to_non_nullable
                    as String,
        ownerId:
            null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                    as String,
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        weight:
            freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                    as double?,
        weightUnit:
            freezed == weightUnit
                ? _value.weightUnit
                : weightUnit // ignore: cast_nullable_to_non_nullable
                    as String?,
        activityLevel:
            freezed == activityLevel
                ? _value.activityLevel
                : activityLevel // ignore: cast_nullable_to_non_nullable
                    as String?,
        energyLevel:
            freezed == energyLevel
                ? _value.energyLevel
                : energyLevel // ignore: cast_nullable_to_non_nullable
                    as String?,
        mood:
            freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                    as String?,
        appetite:
            freezed == appetite
                ? _value.appetite
                : appetite // ignore: cast_nullable_to_non_nullable
                    as String?,
        symptoms:
            freezed == symptoms
                ? _value._symptoms
                : symptoms // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        medicationsTaken:
            freezed == medicationsTaken
                ? _value._medicationsTaken
                : medicationsTaken // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        vetVisit:
            freezed == vetVisit
                ? _value.vetVisit
                : vetVisit // ignore: cast_nullable_to_non_nullable
                    as bool?,
        vetVisitReason:
            freezed == vetVisitReason
                ? _value.vetVisitReason
                : vetVisitReason // ignore: cast_nullable_to_non_nullable
                    as String?,
        vetNotes:
            freezed == vetNotes
                ? _value.vetNotes
                : vetNotes // ignore: cast_nullable_to_non_nullable
                    as String?,
        generalNotes:
            freezed == generalNotes
                ? _value.generalNotes
                : generalNotes // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthJournalModelImpl implements _HealthJournalModel {
  const _$HealthJournalModelImpl({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.date,
    this.weight,
    this.weightUnit,
    this.activityLevel,
    this.energyLevel,
    this.mood,
    this.appetite,
    final List<String>? symptoms,
    final List<String>? medicationsTaken,
    this.vetVisit,
    this.vetVisitReason,
    this.vetNotes,
    this.generalNotes,
    this.createdAt,
    this.updatedAt,
  }) : _symptoms = symptoms,
       _medicationsTaken = medicationsTaken;

  factory _$HealthJournalModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthJournalModelImplFromJson(json);

  @override
  final String id;
  @override
  final String petId;
  @override
  final String ownerId;
  @override
  final DateTime date;
  // Physical health
  @override
  final double? weight;
  @override
  final String? weightUnit;
  // 'kg' or 'lbs'
  @override
  final String? activityLevel;
  // 'low', 'moderate', 'high'
  @override
  final String? energyLevel;
  // 'low', 'normal', 'high'
  // Mood and behavior
  @override
  final String? mood;
  // 'happy', 'sad', 'anxious', 'aggressive', 'calm'
  @override
  final String? appetite;
  // 'good', 'poor', 'normal'
  // Health observations
  final List<String>? _symptoms;
  // 'good', 'poor', 'normal'
  // Health observations
  @override
  List<String>? get symptoms {
    final value = _symptoms;
    if (value == null) return null;
    if (_symptoms is EqualUnmodifiableListView) return _symptoms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _medicationsTaken;
  @override
  List<String>? get medicationsTaken {
    final value = _medicationsTaken;
    if (value == null) return null;
    if (_medicationsTaken is EqualUnmodifiableListView)
      return _medicationsTaken;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // Vet visits
  @override
  final bool? vetVisit;
  @override
  final String? vetVisitReason;
  @override
  final String? vetNotes;
  // Notes
  @override
  final String? generalNotes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'HealthJournalModel(id: $id, petId: $petId, ownerId: $ownerId, date: $date, weight: $weight, weightUnit: $weightUnit, activityLevel: $activityLevel, energyLevel: $energyLevel, mood: $mood, appetite: $appetite, symptoms: $symptoms, medicationsTaken: $medicationsTaken, vetVisit: $vetVisit, vetVisitReason: $vetVisitReason, vetNotes: $vetNotes, generalNotes: $generalNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthJournalModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.petId, petId) || other.petId == petId) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.energyLevel, energyLevel) ||
                other.energyLevel == energyLevel) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.appetite, appetite) ||
                other.appetite == appetite) &&
            const DeepCollectionEquality().equals(other._symptoms, _symptoms) &&
            const DeepCollectionEquality().equals(
              other._medicationsTaken,
              _medicationsTaken,
            ) &&
            (identical(other.vetVisit, vetVisit) ||
                other.vetVisit == vetVisit) &&
            (identical(other.vetVisitReason, vetVisitReason) ||
                other.vetVisitReason == vetVisitReason) &&
            (identical(other.vetNotes, vetNotes) ||
                other.vetNotes == vetNotes) &&
            (identical(other.generalNotes, generalNotes) ||
                other.generalNotes == generalNotes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    petId,
    ownerId,
    date,
    weight,
    weightUnit,
    activityLevel,
    energyLevel,
    mood,
    appetite,
    const DeepCollectionEquality().hash(_symptoms),
    const DeepCollectionEquality().hash(_medicationsTaken),
    vetVisit,
    vetVisitReason,
    vetNotes,
    generalNotes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of HealthJournalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthJournalModelImplCopyWith<_$HealthJournalModelImpl> get copyWith =>
      __$$HealthJournalModelImplCopyWithImpl<_$HealthJournalModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthJournalModelImplToJson(this);
  }
}

abstract class _HealthJournalModel implements HealthJournalModel {
  const factory _HealthJournalModel({
    required final String id,
    required final String petId,
    required final String ownerId,
    required final DateTime date,
    final double? weight,
    final String? weightUnit,
    final String? activityLevel,
    final String? energyLevel,
    final String? mood,
    final String? appetite,
    final List<String>? symptoms,
    final List<String>? medicationsTaken,
    final bool? vetVisit,
    final String? vetVisitReason,
    final String? vetNotes,
    final String? generalNotes,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$HealthJournalModelImpl;

  factory _HealthJournalModel.fromJson(Map<String, dynamic> json) =
      _$HealthJournalModelImpl.fromJson;

  @override
  String get id;
  @override
  String get petId;
  @override
  String get ownerId;
  @override
  DateTime get date; // Physical health
  @override
  double? get weight;
  @override
  String? get weightUnit; // 'kg' or 'lbs'
  @override
  String? get activityLevel; // 'low', 'moderate', 'high'
  @override
  String? get energyLevel; // 'low', 'normal', 'high'
  // Mood and behavior
  @override
  String? get mood; // 'happy', 'sad', 'anxious', 'aggressive', 'calm'
  @override
  String? get appetite; // 'good', 'poor', 'normal'
  // Health observations
  @override
  List<String>? get symptoms;
  @override
  List<String>? get medicationsTaken; // Vet visits
  @override
  bool? get vetVisit;
  @override
  String? get vetVisitReason;
  @override
  String? get vetNotes; // Notes
  @override
  String? get generalNotes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of HealthJournalModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthJournalModelImplCopyWith<_$HealthJournalModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
