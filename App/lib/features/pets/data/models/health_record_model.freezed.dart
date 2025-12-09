// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HealthRecordModel _$HealthRecordModelFromJson(Map<String, dynamic> json) {
  return _HealthRecordModel.fromJson(json);
}

/// @nodoc
mixin _$HealthRecordModel {
  String get id => throw _privateConstructorUsedError;
  String get petId => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError; // Vaccination
  bool get isVaccinated => throw _privateConstructorUsedError;
  String? get vaccinationDate => throw _privateConstructorUsedError;
  String? get vaccinationDetails =>
      throw _privateConstructorUsedError; // Medical conditions
  List<String>? get medicalConditions =>
      throw _privateConstructorUsedError; // Allergies
  List<String>? get allergies =>
      throw _privateConstructorUsedError; // Current medications
  List<String>? get medications =>
      throw _privateConstructorUsedError; // Vet information
  String? get vetName => throw _privateConstructorUsedError;
  String? get vetClinic => throw _privateConstructorUsedError;
  String? get vetPhone => throw _privateConstructorUsedError;
  String? get vetAddress =>
      throw _privateConstructorUsedError; // Emergency contact
  String? get emergencyContactName => throw _privateConstructorUsedError;
  String? get emergencyContactPhone =>
      throw _privateConstructorUsedError; // Insurance
  String? get insuranceProvider => throw _privateConstructorUsedError;
  String? get insurancePolicyNumber =>
      throw _privateConstructorUsedError; // Notes
  String? get additionalNotes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this HealthRecordModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthRecordModelCopyWith<HealthRecordModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthRecordModelCopyWith<$Res> {
  factory $HealthRecordModelCopyWith(
    HealthRecordModel value,
    $Res Function(HealthRecordModel) then,
  ) = _$HealthRecordModelCopyWithImpl<$Res, HealthRecordModel>;
  @useResult
  $Res call({
    String id,
    String petId,
    String ownerId,
    bool isVaccinated,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$HealthRecordModelCopyWithImpl<$Res, $Val extends HealthRecordModel>
    implements $HealthRecordModelCopyWith<$Res> {
  _$HealthRecordModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? petId = null,
    Object? ownerId = null,
    Object? isVaccinated = null,
    Object? vaccinationDate = freezed,
    Object? vaccinationDetails = freezed,
    Object? medicalConditions = freezed,
    Object? allergies = freezed,
    Object? medications = freezed,
    Object? vetName = freezed,
    Object? vetClinic = freezed,
    Object? vetPhone = freezed,
    Object? vetAddress = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? insuranceProvider = freezed,
    Object? insurancePolicyNumber = freezed,
    Object? additionalNotes = freezed,
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
            isVaccinated:
                null == isVaccinated
                    ? _value.isVaccinated
                    : isVaccinated // ignore: cast_nullable_to_non_nullable
                        as bool,
            vaccinationDate:
                freezed == vaccinationDate
                    ? _value.vaccinationDate
                    : vaccinationDate // ignore: cast_nullable_to_non_nullable
                        as String?,
            vaccinationDetails:
                freezed == vaccinationDetails
                    ? _value.vaccinationDetails
                    : vaccinationDetails // ignore: cast_nullable_to_non_nullable
                        as String?,
            medicalConditions:
                freezed == medicalConditions
                    ? _value.medicalConditions
                    : medicalConditions // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            allergies:
                freezed == allergies
                    ? _value.allergies
                    : allergies // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            medications:
                freezed == medications
                    ? _value.medications
                    : medications // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            vetName:
                freezed == vetName
                    ? _value.vetName
                    : vetName // ignore: cast_nullable_to_non_nullable
                        as String?,
            vetClinic:
                freezed == vetClinic
                    ? _value.vetClinic
                    : vetClinic // ignore: cast_nullable_to_non_nullable
                        as String?,
            vetPhone:
                freezed == vetPhone
                    ? _value.vetPhone
                    : vetPhone // ignore: cast_nullable_to_non_nullable
                        as String?,
            vetAddress:
                freezed == vetAddress
                    ? _value.vetAddress
                    : vetAddress // ignore: cast_nullable_to_non_nullable
                        as String?,
            emergencyContactName:
                freezed == emergencyContactName
                    ? _value.emergencyContactName
                    : emergencyContactName // ignore: cast_nullable_to_non_nullable
                        as String?,
            emergencyContactPhone:
                freezed == emergencyContactPhone
                    ? _value.emergencyContactPhone
                    : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
                        as String?,
            insuranceProvider:
                freezed == insuranceProvider
                    ? _value.insuranceProvider
                    : insuranceProvider // ignore: cast_nullable_to_non_nullable
                        as String?,
            insurancePolicyNumber:
                freezed == insurancePolicyNumber
                    ? _value.insurancePolicyNumber
                    : insurancePolicyNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            additionalNotes:
                freezed == additionalNotes
                    ? _value.additionalNotes
                    : additionalNotes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$HealthRecordModelImplCopyWith<$Res>
    implements $HealthRecordModelCopyWith<$Res> {
  factory _$$HealthRecordModelImplCopyWith(
    _$HealthRecordModelImpl value,
    $Res Function(_$HealthRecordModelImpl) then,
  ) = __$$HealthRecordModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String petId,
    String ownerId,
    bool isVaccinated,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$HealthRecordModelImplCopyWithImpl<$Res>
    extends _$HealthRecordModelCopyWithImpl<$Res, _$HealthRecordModelImpl>
    implements _$$HealthRecordModelImplCopyWith<$Res> {
  __$$HealthRecordModelImplCopyWithImpl(
    _$HealthRecordModelImpl _value,
    $Res Function(_$HealthRecordModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HealthRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? petId = null,
    Object? ownerId = null,
    Object? isVaccinated = null,
    Object? vaccinationDate = freezed,
    Object? vaccinationDetails = freezed,
    Object? medicalConditions = freezed,
    Object? allergies = freezed,
    Object? medications = freezed,
    Object? vetName = freezed,
    Object? vetClinic = freezed,
    Object? vetPhone = freezed,
    Object? vetAddress = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? insuranceProvider = freezed,
    Object? insurancePolicyNumber = freezed,
    Object? additionalNotes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$HealthRecordModelImpl(
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
        isVaccinated:
            null == isVaccinated
                ? _value.isVaccinated
                : isVaccinated // ignore: cast_nullable_to_non_nullable
                    as bool,
        vaccinationDate:
            freezed == vaccinationDate
                ? _value.vaccinationDate
                : vaccinationDate // ignore: cast_nullable_to_non_nullable
                    as String?,
        vaccinationDetails:
            freezed == vaccinationDetails
                ? _value.vaccinationDetails
                : vaccinationDetails // ignore: cast_nullable_to_non_nullable
                    as String?,
        medicalConditions:
            freezed == medicalConditions
                ? _value._medicalConditions
                : medicalConditions // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        allergies:
            freezed == allergies
                ? _value._allergies
                : allergies // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        medications:
            freezed == medications
                ? _value._medications
                : medications // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        vetName:
            freezed == vetName
                ? _value.vetName
                : vetName // ignore: cast_nullable_to_non_nullable
                    as String?,
        vetClinic:
            freezed == vetClinic
                ? _value.vetClinic
                : vetClinic // ignore: cast_nullable_to_non_nullable
                    as String?,
        vetPhone:
            freezed == vetPhone
                ? _value.vetPhone
                : vetPhone // ignore: cast_nullable_to_non_nullable
                    as String?,
        vetAddress:
            freezed == vetAddress
                ? _value.vetAddress
                : vetAddress // ignore: cast_nullable_to_non_nullable
                    as String?,
        emergencyContactName:
            freezed == emergencyContactName
                ? _value.emergencyContactName
                : emergencyContactName // ignore: cast_nullable_to_non_nullable
                    as String?,
        emergencyContactPhone:
            freezed == emergencyContactPhone
                ? _value.emergencyContactPhone
                : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
                    as String?,
        insuranceProvider:
            freezed == insuranceProvider
                ? _value.insuranceProvider
                : insuranceProvider // ignore: cast_nullable_to_non_nullable
                    as String?,
        insurancePolicyNumber:
            freezed == insurancePolicyNumber
                ? _value.insurancePolicyNumber
                : insurancePolicyNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        additionalNotes:
            freezed == additionalNotes
                ? _value.additionalNotes
                : additionalNotes // ignore: cast_nullable_to_non_nullable
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
class _$HealthRecordModelImpl implements _HealthRecordModel {
  const _$HealthRecordModelImpl({
    required this.id,
    required this.petId,
    required this.ownerId,
    this.isVaccinated = false,
    this.vaccinationDate,
    this.vaccinationDetails,
    final List<String>? medicalConditions,
    final List<String>? allergies,
    final List<String>? medications,
    this.vetName,
    this.vetClinic,
    this.vetPhone,
    this.vetAddress,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.additionalNotes,
    this.createdAt,
    this.updatedAt,
  }) : _medicalConditions = medicalConditions,
       _allergies = allergies,
       _medications = medications;

  factory _$HealthRecordModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthRecordModelImplFromJson(json);

  @override
  final String id;
  @override
  final String petId;
  @override
  final String ownerId;
  // Vaccination
  @override
  @JsonKey()
  final bool isVaccinated;
  @override
  final String? vaccinationDate;
  @override
  final String? vaccinationDetails;
  // Medical conditions
  final List<String>? _medicalConditions;
  // Medical conditions
  @override
  List<String>? get medicalConditions {
    final value = _medicalConditions;
    if (value == null) return null;
    if (_medicalConditions is EqualUnmodifiableListView)
      return _medicalConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // Allergies
  final List<String>? _allergies;
  // Allergies
  @override
  List<String>? get allergies {
    final value = _allergies;
    if (value == null) return null;
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // Current medications
  final List<String>? _medications;
  // Current medications
  @override
  List<String>? get medications {
    final value = _medications;
    if (value == null) return null;
    if (_medications is EqualUnmodifiableListView) return _medications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // Vet information
  @override
  final String? vetName;
  @override
  final String? vetClinic;
  @override
  final String? vetPhone;
  @override
  final String? vetAddress;
  // Emergency contact
  @override
  final String? emergencyContactName;
  @override
  final String? emergencyContactPhone;
  // Insurance
  @override
  final String? insuranceProvider;
  @override
  final String? insurancePolicyNumber;
  // Notes
  @override
  final String? additionalNotes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'HealthRecordModel(id: $id, petId: $petId, ownerId: $ownerId, isVaccinated: $isVaccinated, vaccinationDate: $vaccinationDate, vaccinationDetails: $vaccinationDetails, medicalConditions: $medicalConditions, allergies: $allergies, medications: $medications, vetName: $vetName, vetClinic: $vetClinic, vetPhone: $vetPhone, vetAddress: $vetAddress, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, insuranceProvider: $insuranceProvider, insurancePolicyNumber: $insurancePolicyNumber, additionalNotes: $additionalNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthRecordModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.petId, petId) || other.petId == petId) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.isVaccinated, isVaccinated) ||
                other.isVaccinated == isVaccinated) &&
            (identical(other.vaccinationDate, vaccinationDate) ||
                other.vaccinationDate == vaccinationDate) &&
            (identical(other.vaccinationDetails, vaccinationDetails) ||
                other.vaccinationDetails == vaccinationDetails) &&
            const DeepCollectionEquality().equals(
              other._medicalConditions,
              _medicalConditions,
            ) &&
            const DeepCollectionEquality().equals(
              other._allergies,
              _allergies,
            ) &&
            const DeepCollectionEquality().equals(
              other._medications,
              _medications,
            ) &&
            (identical(other.vetName, vetName) || other.vetName == vetName) &&
            (identical(other.vetClinic, vetClinic) ||
                other.vetClinic == vetClinic) &&
            (identical(other.vetPhone, vetPhone) ||
                other.vetPhone == vetPhone) &&
            (identical(other.vetAddress, vetAddress) ||
                other.vetAddress == vetAddress) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(other.emergencyContactPhone, emergencyContactPhone) ||
                other.emergencyContactPhone == emergencyContactPhone) &&
            (identical(other.insuranceProvider, insuranceProvider) ||
                other.insuranceProvider == insuranceProvider) &&
            (identical(other.insurancePolicyNumber, insurancePolicyNumber) ||
                other.insurancePolicyNumber == insurancePolicyNumber) &&
            (identical(other.additionalNotes, additionalNotes) ||
                other.additionalNotes == additionalNotes) &&
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
    petId,
    ownerId,
    isVaccinated,
    vaccinationDate,
    vaccinationDetails,
    const DeepCollectionEquality().hash(_medicalConditions),
    const DeepCollectionEquality().hash(_allergies),
    const DeepCollectionEquality().hash(_medications),
    vetName,
    vetClinic,
    vetPhone,
    vetAddress,
    emergencyContactName,
    emergencyContactPhone,
    insuranceProvider,
    insurancePolicyNumber,
    additionalNotes,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of HealthRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthRecordModelImplCopyWith<_$HealthRecordModelImpl> get copyWith =>
      __$$HealthRecordModelImplCopyWithImpl<_$HealthRecordModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthRecordModelImplToJson(this);
  }
}

abstract class _HealthRecordModel implements HealthRecordModel {
  const factory _HealthRecordModel({
    required final String id,
    required final String petId,
    required final String ownerId,
    final bool isVaccinated,
    final String? vaccinationDate,
    final String? vaccinationDetails,
    final List<String>? medicalConditions,
    final List<String>? allergies,
    final List<String>? medications,
    final String? vetName,
    final String? vetClinic,
    final String? vetPhone,
    final String? vetAddress,
    final String? emergencyContactName,
    final String? emergencyContactPhone,
    final String? insuranceProvider,
    final String? insurancePolicyNumber,
    final String? additionalNotes,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$HealthRecordModelImpl;

  factory _HealthRecordModel.fromJson(Map<String, dynamic> json) =
      _$HealthRecordModelImpl.fromJson;

  @override
  String get id;
  @override
  String get petId;
  @override
  String get ownerId; // Vaccination
  @override
  bool get isVaccinated;
  @override
  String? get vaccinationDate;
  @override
  String? get vaccinationDetails; // Medical conditions
  @override
  List<String>? get medicalConditions; // Allergies
  @override
  List<String>? get allergies; // Current medications
  @override
  List<String>? get medications; // Vet information
  @override
  String? get vetName;
  @override
  String? get vetClinic;
  @override
  String? get vetPhone;
  @override
  String? get vetAddress; // Emergency contact
  @override
  String? get emergencyContactName;
  @override
  String? get emergencyContactPhone; // Insurance
  @override
  String? get insuranceProvider;
  @override
  String? get insurancePolicyNumber; // Notes
  @override
  String? get additionalNotes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of HealthRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthRecordModelImplCopyWith<_$HealthRecordModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
