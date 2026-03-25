// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PetModel _$PetModelFromJson(Map<String, dynamic> json) {
  return _PetModel.fromJson(json);
}

/// @nodoc
mixin _$PetModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // 'dog' or 'cat'
  String get breed => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get ageUnit =>
      throw _privateConstructorUsedError; // 'months' or 'years'
  String get gender => throw _privateConstructorUsedError; // 'male' or 'female'
  String get color => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  String get weightUnit => throw _privateConstructorUsedError; // 'kg' or 'lbs'
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get imageLocalPath => throw _privateConstructorUsedError;
  List<String>? get imageUrls =>
      throw _privateConstructorUsedError; // Multiple images
  bool? get isVerified => throw _privateConstructorUsedError; // Verified by AI
  double? get verificationConfidence => throw _privateConstructorUsedError;
  String? get verifiedBreed => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get ownerId => throw _privateConstructorUsedError;
  HealthRecordModel? get healthRecord =>
      throw _privateConstructorUsedError; // Health records
  bool get isAdopted => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PetModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PetModelCopyWith<PetModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PetModelCopyWith<$Res> {
  factory $PetModelCopyWith(PetModel value, $Res Function(PetModel) then) =
      _$PetModelCopyWithImpl<$Res, PetModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String breed,
    int age,
    String ageUnit,
    String gender,
    String color,
    double weight,
    String weightUnit,
    String? imageUrl,
    String? imageLocalPath,
    List<String>? imageUrls,
    bool? isVerified,
    double? verificationConfidence,
    String? verifiedBreed,
    String? bio,
    String? ownerId,
    HealthRecordModel? healthRecord,
    bool isAdopted,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  $HealthRecordModelCopyWith<$Res>? get healthRecord;
}

/// @nodoc
class _$PetModelCopyWithImpl<$Res, $Val extends PetModel>
    implements $PetModelCopyWith<$Res> {
  _$PetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? breed = null,
    Object? age = null,
    Object? ageUnit = null,
    Object? gender = null,
    Object? color = null,
    Object? weight = null,
    Object? weightUnit = null,
    Object? imageUrl = freezed,
    Object? imageLocalPath = freezed,
    Object? imageUrls = freezed,
    Object? isVerified = freezed,
    Object? verificationConfidence = freezed,
    Object? verifiedBreed = freezed,
    Object? bio = freezed,
    Object? ownerId = freezed,
    Object? healthRecord = freezed,
    Object? isAdopted = null,
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
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            breed:
                null == breed
                    ? _value.breed
                    : breed // ignore: cast_nullable_to_non_nullable
                        as String,
            age:
                null == age
                    ? _value.age
                    : age // ignore: cast_nullable_to_non_nullable
                        as int,
            ageUnit:
                null == ageUnit
                    ? _value.ageUnit
                    : ageUnit // ignore: cast_nullable_to_non_nullable
                        as String,
            gender:
                null == gender
                    ? _value.gender
                    : gender // ignore: cast_nullable_to_non_nullable
                        as String,
            color:
                null == color
                    ? _value.color
                    : color // ignore: cast_nullable_to_non_nullable
                        as String,
            weight:
                null == weight
                    ? _value.weight
                    : weight // ignore: cast_nullable_to_non_nullable
                        as double,
            weightUnit:
                null == weightUnit
                    ? _value.weightUnit
                    : weightUnit // ignore: cast_nullable_to_non_nullable
                        as String,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            imageLocalPath:
                freezed == imageLocalPath
                    ? _value.imageLocalPath
                    : imageLocalPath // ignore: cast_nullable_to_non_nullable
                        as String?,
            imageUrls:
                freezed == imageUrls
                    ? _value.imageUrls
                    : imageUrls // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            isVerified:
                freezed == isVerified
                    ? _value.isVerified
                    : isVerified // ignore: cast_nullable_to_non_nullable
                        as bool?,
            verificationConfidence:
                freezed == verificationConfidence
                    ? _value.verificationConfidence
                    : verificationConfidence // ignore: cast_nullable_to_non_nullable
                        as double?,
            verifiedBreed:
                freezed == verifiedBreed
                    ? _value.verifiedBreed
                    : verifiedBreed // ignore: cast_nullable_to_non_nullable
                        as String?,
            bio:
                freezed == bio
                    ? _value.bio
                    : bio // ignore: cast_nullable_to_non_nullable
                        as String?,
            ownerId:
                freezed == ownerId
                    ? _value.ownerId
                    : ownerId // ignore: cast_nullable_to_non_nullable
                        as String?,
            healthRecord:
                freezed == healthRecord
                    ? _value.healthRecord
                    : healthRecord // ignore: cast_nullable_to_non_nullable
                        as HealthRecordModel?,
            isAdopted:
                null == isAdopted
                    ? _value.isAdopted
                    : isAdopted // ignore: cast_nullable_to_non_nullable
                        as bool,
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

  /// Create a copy of PetModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthRecordModelCopyWith<$Res>? get healthRecord {
    if (_value.healthRecord == null) {
      return null;
    }

    return $HealthRecordModelCopyWith<$Res>(_value.healthRecord!, (value) {
      return _then(_value.copyWith(healthRecord: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PetModelImplCopyWith<$Res>
    implements $PetModelCopyWith<$Res> {
  factory _$$PetModelImplCopyWith(
    _$PetModelImpl value,
    $Res Function(_$PetModelImpl) then,
  ) = __$$PetModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String breed,
    int age,
    String ageUnit,
    String gender,
    String color,
    double weight,
    String weightUnit,
    String? imageUrl,
    String? imageLocalPath,
    List<String>? imageUrls,
    bool? isVerified,
    double? verificationConfidence,
    String? verifiedBreed,
    String? bio,
    String? ownerId,
    HealthRecordModel? healthRecord,
    bool isAdopted,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  $HealthRecordModelCopyWith<$Res>? get healthRecord;
}

/// @nodoc
class __$$PetModelImplCopyWithImpl<$Res>
    extends _$PetModelCopyWithImpl<$Res, _$PetModelImpl>
    implements _$$PetModelImplCopyWith<$Res> {
  __$$PetModelImplCopyWithImpl(
    _$PetModelImpl _value,
    $Res Function(_$PetModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? breed = null,
    Object? age = null,
    Object? ageUnit = null,
    Object? gender = null,
    Object? color = null,
    Object? weight = null,
    Object? weightUnit = null,
    Object? imageUrl = freezed,
    Object? imageLocalPath = freezed,
    Object? imageUrls = freezed,
    Object? isVerified = freezed,
    Object? verificationConfidence = freezed,
    Object? verifiedBreed = freezed,
    Object? bio = freezed,
    Object? ownerId = freezed,
    Object? healthRecord = freezed,
    Object? isAdopted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PetModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        breed:
            null == breed
                ? _value.breed
                : breed // ignore: cast_nullable_to_non_nullable
                    as String,
        age:
            null == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                    as int,
        ageUnit:
            null == ageUnit
                ? _value.ageUnit
                : ageUnit // ignore: cast_nullable_to_non_nullable
                    as String,
        gender:
            null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                    as String,
        color:
            null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                    as String,
        weight:
            null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                    as double,
        weightUnit:
            null == weightUnit
                ? _value.weightUnit
                : weightUnit // ignore: cast_nullable_to_non_nullable
                    as String,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        imageLocalPath:
            freezed == imageLocalPath
                ? _value.imageLocalPath
                : imageLocalPath // ignore: cast_nullable_to_non_nullable
                    as String?,
        imageUrls:
            freezed == imageUrls
                ? _value._imageUrls
                : imageUrls // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        isVerified:
            freezed == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                    as bool?,
        verificationConfidence:
            freezed == verificationConfidence
                ? _value.verificationConfidence
                : verificationConfidence // ignore: cast_nullable_to_non_nullable
                    as double?,
        verifiedBreed:
            freezed == verifiedBreed
                ? _value.verifiedBreed
                : verifiedBreed // ignore: cast_nullable_to_non_nullable
                    as String?,
        bio:
            freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                    as String?,
        ownerId:
            freezed == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                    as String?,
        healthRecord:
            freezed == healthRecord
                ? _value.healthRecord
                : healthRecord // ignore: cast_nullable_to_non_nullable
                    as HealthRecordModel?,
        isAdopted:
            null == isAdopted
                ? _value.isAdopted
                : isAdopted // ignore: cast_nullable_to_non_nullable
                    as bool,
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
class _$PetModelImpl implements _PetModel {
  const _$PetModelImpl({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.ageUnit,
    required this.gender,
    required this.color,
    required this.weight,
    required this.weightUnit,
    this.imageUrl,
    this.imageLocalPath,
    final List<String>? imageUrls,
    this.isVerified,
    this.verificationConfidence,
    this.verifiedBreed,
    this.bio,
    this.ownerId,
    this.healthRecord,
    this.isAdopted = false,
    this.createdAt,
    this.updatedAt,
  }) : _imageUrls = imageUrls;

  factory _$PetModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PetModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  // 'dog' or 'cat'
  @override
  final String breed;
  @override
  final int age;
  @override
  final String ageUnit;
  // 'months' or 'years'
  @override
  final String gender;
  // 'male' or 'female'
  @override
  final String color;
  @override
  final double weight;
  @override
  final String weightUnit;
  // 'kg' or 'lbs'
  @override
  final String? imageUrl;
  @override
  final String? imageLocalPath;
  final List<String>? _imageUrls;
  @override
  List<String>? get imageUrls {
    final value = _imageUrls;
    if (value == null) return null;
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // Multiple images
  @override
  final bool? isVerified;
  // Verified by AI
  @override
  final double? verificationConfidence;
  @override
  final String? verifiedBreed;
  @override
  final String? bio;
  @override
  final String? ownerId;
  @override
  final HealthRecordModel? healthRecord;
  // Health records
  @override
  @JsonKey()
  final bool isAdopted;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PetModel(id: $id, name: $name, type: $type, breed: $breed, age: $age, ageUnit: $ageUnit, gender: $gender, color: $color, weight: $weight, weightUnit: $weightUnit, imageUrl: $imageUrl, imageLocalPath: $imageLocalPath, imageUrls: $imageUrls, isVerified: $isVerified, verificationConfidence: $verificationConfidence, verifiedBreed: $verifiedBreed, bio: $bio, ownerId: $ownerId, healthRecord: $healthRecord, isAdopted: $isAdopted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PetModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.breed, breed) || other.breed == breed) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.ageUnit, ageUnit) || other.ageUnit == ageUnit) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imageLocalPath, imageLocalPath) ||
                other.imageLocalPath == imageLocalPath) &&
            const DeepCollectionEquality().equals(
              other._imageUrls,
              _imageUrls,
            ) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.verificationConfidence, verificationConfidence) ||
                other.verificationConfidence == verificationConfidence) &&
            (identical(other.verifiedBreed, verifiedBreed) ||
                other.verifiedBreed == verifiedBreed) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.healthRecord, healthRecord) ||
                other.healthRecord == healthRecord) &&
            (identical(other.isAdopted, isAdopted) ||
                other.isAdopted == isAdopted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    type,
    breed,
    age,
    ageUnit,
    gender,
    color,
    weight,
    weightUnit,
    imageUrl,
    imageLocalPath,
    const DeepCollectionEquality().hash(_imageUrls),
    isVerified,
    verificationConfidence,
    verifiedBreed,
    bio,
    ownerId,
    healthRecord,
    isAdopted,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of PetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PetModelImplCopyWith<_$PetModelImpl> get copyWith =>
      __$$PetModelImplCopyWithImpl<_$PetModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PetModelImplToJson(this);
  }
}

abstract class _PetModel implements PetModel {
  const factory _PetModel({
    required final String id,
    required final String name,
    required final String type,
    required final String breed,
    required final int age,
    required final String ageUnit,
    required final String gender,
    required final String color,
    required final double weight,
    required final String weightUnit,
    final String? imageUrl,
    final String? imageLocalPath,
    final List<String>? imageUrls,
    final bool? isVerified,
    final double? verificationConfidence,
    final String? verifiedBreed,
    final String? bio,
    final String? ownerId,
    final HealthRecordModel? healthRecord,
    final bool isAdopted,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$PetModelImpl;

  factory _PetModel.fromJson(Map<String, dynamic> json) =
      _$PetModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type; // 'dog' or 'cat'
  @override
  String get breed;
  @override
  int get age;
  @override
  String get ageUnit; // 'months' or 'years'
  @override
  String get gender; // 'male' or 'female'
  @override
  String get color;
  @override
  double get weight;
  @override
  String get weightUnit; // 'kg' or 'lbs'
  @override
  String? get imageUrl;
  @override
  String? get imageLocalPath;
  @override
  List<String>? get imageUrls; // Multiple images
  @override
  bool? get isVerified; // Verified by AI
  @override
  double? get verificationConfidence;
  @override
  String? get verifiedBreed;
  @override
  String? get bio;
  @override
  String? get ownerId;
  @override
  HealthRecordModel? get healthRecord; // Health records
  @override
  bool get isAdopted;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PetModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PetModelImplCopyWith<_$PetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
