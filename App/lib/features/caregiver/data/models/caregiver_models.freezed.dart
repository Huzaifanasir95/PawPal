// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caregiver_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CaregiverServiceType _$CaregiverServiceTypeFromJson(Map<String, dynamic> json) {
  return _CaregiverServiceType.fromJson(json);
}

/// @nodoc
mixin _$CaregiverServiceType {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get baseHourlyRate => throw _privateConstructorUsedError;
  String? get iconName => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CaregiverServiceType to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CaregiverServiceType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaregiverServiceTypeCopyWith<CaregiverServiceType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaregiverServiceTypeCopyWith<$Res> {
  factory $CaregiverServiceTypeCopyWith(
    CaregiverServiceType value,
    $Res Function(CaregiverServiceType) then,
  ) = _$CaregiverServiceTypeCopyWithImpl<$Res, CaregiverServiceType>;
  @useResult
  $Res call({
    String id,
    String name,
    String displayName,
    String? description,
    double baseHourlyRate,
    String? iconName,
    bool isActive,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CaregiverServiceTypeCopyWithImpl<
  $Res,
  $Val extends CaregiverServiceType
>
    implements $CaregiverServiceTypeCopyWith<$Res> {
  _$CaregiverServiceTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaregiverServiceType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = null,
    Object? description = freezed,
    Object? baseHourlyRate = null,
    Object? iconName = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
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
            displayName:
                null == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            baseHourlyRate:
                null == baseHourlyRate
                    ? _value.baseHourlyRate
                    : baseHourlyRate // ignore: cast_nullable_to_non_nullable
                        as double,
            iconName:
                freezed == iconName
                    ? _value.iconName
                    : iconName // ignore: cast_nullable_to_non_nullable
                        as String?,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaregiverServiceTypeImplCopyWith<$Res>
    implements $CaregiverServiceTypeCopyWith<$Res> {
  factory _$$CaregiverServiceTypeImplCopyWith(
    _$CaregiverServiceTypeImpl value,
    $Res Function(_$CaregiverServiceTypeImpl) then,
  ) = __$$CaregiverServiceTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String displayName,
    String? description,
    double baseHourlyRate,
    String? iconName,
    bool isActive,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CaregiverServiceTypeImplCopyWithImpl<$Res>
    extends _$CaregiverServiceTypeCopyWithImpl<$Res, _$CaregiverServiceTypeImpl>
    implements _$$CaregiverServiceTypeImplCopyWith<$Res> {
  __$$CaregiverServiceTypeImplCopyWithImpl(
    _$CaregiverServiceTypeImpl _value,
    $Res Function(_$CaregiverServiceTypeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaregiverServiceType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? displayName = null,
    Object? description = freezed,
    Object? baseHourlyRate = null,
    Object? iconName = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CaregiverServiceTypeImpl(
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
        displayName:
            null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        baseHourlyRate:
            null == baseHourlyRate
                ? _value.baseHourlyRate
                : baseHourlyRate // ignore: cast_nullable_to_non_nullable
                    as double,
        iconName:
            freezed == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                    as String?,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CaregiverServiceTypeImpl implements _CaregiverServiceType {
  const _$CaregiverServiceTypeImpl({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.baseHourlyRate = 0,
    this.iconName,
    this.isActive = true,
    this.createdAt,
  });

  factory _$CaregiverServiceTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaregiverServiceTypeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String displayName;
  @override
  final String? description;
  @override
  @JsonKey()
  final double baseHourlyRate;
  @override
  final String? iconName;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CaregiverServiceType(id: $id, name: $name, displayName: $displayName, description: $description, baseHourlyRate: $baseHourlyRate, iconName: $iconName, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaregiverServiceTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.baseHourlyRate, baseHourlyRate) ||
                other.baseHourlyRate == baseHourlyRate) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    displayName,
    description,
    baseHourlyRate,
    iconName,
    isActive,
    createdAt,
  );

  /// Create a copy of CaregiverServiceType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaregiverServiceTypeImplCopyWith<_$CaregiverServiceTypeImpl>
  get copyWith =>
      __$$CaregiverServiceTypeImplCopyWithImpl<_$CaregiverServiceTypeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CaregiverServiceTypeImplToJson(this);
  }
}

abstract class _CaregiverServiceType implements CaregiverServiceType {
  const factory _CaregiverServiceType({
    required final String id,
    required final String name,
    required final String displayName,
    final String? description,
    final double baseHourlyRate,
    final String? iconName,
    final bool isActive,
    final DateTime? createdAt,
  }) = _$CaregiverServiceTypeImpl;

  factory _CaregiverServiceType.fromJson(Map<String, dynamic> json) =
      _$CaregiverServiceTypeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get displayName;
  @override
  String? get description;
  @override
  double get baseHourlyRate;
  @override
  String? get iconName;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;

  /// Create a copy of CaregiverServiceType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaregiverServiceTypeImplCopyWith<_$CaregiverServiceTypeImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CaregiverProfile _$CaregiverProfileFromJson(Map<String, dynamic> json) {
  return _CaregiverProfile.fromJson(json);
}

/// @nodoc
mixin _$CaregiverProfile {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  int get yearsOfExperience => throw _privateConstructorUsedError;
  String? get headline => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get postalCode => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  int get serviceRadiusKm => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  DateTime? get verificationDate => throw _privateConstructorUsedError;
  String get backgroundCheckStatus => throw _privateConstructorUsedError;
  DateTime? get backgroundCheckDate => throw _privateConstructorUsedError;
  bool get idVerified => throw _privateConstructorUsedError;
  String? get idDocumentUrl => throw _privateConstructorUsedError;
  List<String> get certifications => throw _privateConstructorUsedError;
  bool get petFirstAidCertified => throw _privateConstructorUsedError;
  bool get insuranceVerified => throw _privateConstructorUsedError;
  String? get insurancePolicyNumber => throw _privateConstructorUsedError;
  DateTime? get insuranceExpiry => throw _privateConstructorUsedError;
  List<String> get acceptedPetTypes => throw _privateConstructorUsedError;
  List<String> get acceptedPetSizes => throw _privateConstructorUsedError;
  int get maxPetsAtOnce => throw _privateConstructorUsedError;
  bool get hasFencedYard => throw _privateConstructorUsedError;
  bool get hasOwnTransport => throw _privateConstructorUsedError;
  bool get smokeFreeHome => throw _privateConstructorUsedError;
  bool get hasChildren => throw _privateConstructorUsedError;
  bool get hasOtherPets => throw _privateConstructorUsedError;
  String? get otherPetsDescription => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError;
  int get totalReviews => throw _privateConstructorUsedError;
  int get totalBookings => throw _privateConstructorUsedError;
  double get completionRate => throw _privateConstructorUsedError;
  int get responseTimeHours => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isAcceptingBookings => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Joined fields
  String? get userName => throw _privateConstructorUsedError;
  String? get userAvatar => throw _privateConstructorUsedError;
  List<CaregiverService> get services => throw _privateConstructorUsedError;
  List<CaregiverAvailability> get availability =>
      throw _privateConstructorUsedError;
  List<CaregiverGalleryItem> get gallery => throw _privateConstructorUsedError;

  /// Serializes this CaregiverProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CaregiverProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaregiverProfileCopyWith<CaregiverProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaregiverProfileCopyWith<$Res> {
  factory $CaregiverProfileCopyWith(
    CaregiverProfile value,
    $Res Function(CaregiverProfile) then,
  ) = _$CaregiverProfileCopyWithImpl<$Res, CaregiverProfile>;
  @useResult
  $Res call({
    String id,
    String userId,
    String? bio,
    int yearsOfExperience,
    String? headline,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String country,
    double? latitude,
    double? longitude,
    int serviceRadiusKm,
    bool isVerified,
    DateTime? verificationDate,
    String backgroundCheckStatus,
    DateTime? backgroundCheckDate,
    bool idVerified,
    String? idDocumentUrl,
    List<String> certifications,
    bool petFirstAidCertified,
    bool insuranceVerified,
    String? insurancePolicyNumber,
    DateTime? insuranceExpiry,
    List<String> acceptedPetTypes,
    List<String> acceptedPetSizes,
    int maxPetsAtOnce,
    bool hasFencedYard,
    bool hasOwnTransport,
    bool smokeFreeHome,
    bool hasChildren,
    bool hasOtherPets,
    String? otherPetsDescription,
    double averageRating,
    int totalReviews,
    int totalBookings,
    double completionRate,
    int responseTimeHours,
    bool isActive,
    bool isAcceptingBookings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
    List<CaregiverService> services,
    List<CaregiverAvailability> availability,
    List<CaregiverGalleryItem> gallery,
  });
}

/// @nodoc
class _$CaregiverProfileCopyWithImpl<$Res, $Val extends CaregiverProfile>
    implements $CaregiverProfileCopyWith<$Res> {
  _$CaregiverProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaregiverProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bio = freezed,
    Object? yearsOfExperience = null,
    Object? headline = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? postalCode = freezed,
    Object? country = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? serviceRadiusKm = null,
    Object? isVerified = null,
    Object? verificationDate = freezed,
    Object? backgroundCheckStatus = null,
    Object? backgroundCheckDate = freezed,
    Object? idVerified = null,
    Object? idDocumentUrl = freezed,
    Object? certifications = null,
    Object? petFirstAidCertified = null,
    Object? insuranceVerified = null,
    Object? insurancePolicyNumber = freezed,
    Object? insuranceExpiry = freezed,
    Object? acceptedPetTypes = null,
    Object? acceptedPetSizes = null,
    Object? maxPetsAtOnce = null,
    Object? hasFencedYard = null,
    Object? hasOwnTransport = null,
    Object? smokeFreeHome = null,
    Object? hasChildren = null,
    Object? hasOtherPets = null,
    Object? otherPetsDescription = freezed,
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? totalBookings = null,
    Object? completionRate = null,
    Object? responseTimeHours = null,
    Object? isActive = null,
    Object? isAcceptingBookings = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userName = freezed,
    Object? userAvatar = freezed,
    Object? services = null,
    Object? availability = null,
    Object? gallery = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            bio:
                freezed == bio
                    ? _value.bio
                    : bio // ignore: cast_nullable_to_non_nullable
                        as String?,
            yearsOfExperience:
                null == yearsOfExperience
                    ? _value.yearsOfExperience
                    : yearsOfExperience // ignore: cast_nullable_to_non_nullable
                        as int,
            headline:
                freezed == headline
                    ? _value.headline
                    : headline // ignore: cast_nullable_to_non_nullable
                        as String?,
            address:
                freezed == address
                    ? _value.address
                    : address // ignore: cast_nullable_to_non_nullable
                        as String?,
            city:
                freezed == city
                    ? _value.city
                    : city // ignore: cast_nullable_to_non_nullable
                        as String?,
            state:
                freezed == state
                    ? _value.state
                    : state // ignore: cast_nullable_to_non_nullable
                        as String?,
            postalCode:
                freezed == postalCode
                    ? _value.postalCode
                    : postalCode // ignore: cast_nullable_to_non_nullable
                        as String?,
            country:
                null == country
                    ? _value.country
                    : country // ignore: cast_nullable_to_non_nullable
                        as String,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            serviceRadiusKm:
                null == serviceRadiusKm
                    ? _value.serviceRadiusKm
                    : serviceRadiusKm // ignore: cast_nullable_to_non_nullable
                        as int,
            isVerified:
                null == isVerified
                    ? _value.isVerified
                    : isVerified // ignore: cast_nullable_to_non_nullable
                        as bool,
            verificationDate:
                freezed == verificationDate
                    ? _value.verificationDate
                    : verificationDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            backgroundCheckStatus:
                null == backgroundCheckStatus
                    ? _value.backgroundCheckStatus
                    : backgroundCheckStatus // ignore: cast_nullable_to_non_nullable
                        as String,
            backgroundCheckDate:
                freezed == backgroundCheckDate
                    ? _value.backgroundCheckDate
                    : backgroundCheckDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            idVerified:
                null == idVerified
                    ? _value.idVerified
                    : idVerified // ignore: cast_nullable_to_non_nullable
                        as bool,
            idDocumentUrl:
                freezed == idDocumentUrl
                    ? _value.idDocumentUrl
                    : idDocumentUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            certifications:
                null == certifications
                    ? _value.certifications
                    : certifications // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            petFirstAidCertified:
                null == petFirstAidCertified
                    ? _value.petFirstAidCertified
                    : petFirstAidCertified // ignore: cast_nullable_to_non_nullable
                        as bool,
            insuranceVerified:
                null == insuranceVerified
                    ? _value.insuranceVerified
                    : insuranceVerified // ignore: cast_nullable_to_non_nullable
                        as bool,
            insurancePolicyNumber:
                freezed == insurancePolicyNumber
                    ? _value.insurancePolicyNumber
                    : insurancePolicyNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            insuranceExpiry:
                freezed == insuranceExpiry
                    ? _value.insuranceExpiry
                    : insuranceExpiry // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            acceptedPetTypes:
                null == acceptedPetTypes
                    ? _value.acceptedPetTypes
                    : acceptedPetTypes // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            acceptedPetSizes:
                null == acceptedPetSizes
                    ? _value.acceptedPetSizes
                    : acceptedPetSizes // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            maxPetsAtOnce:
                null == maxPetsAtOnce
                    ? _value.maxPetsAtOnce
                    : maxPetsAtOnce // ignore: cast_nullable_to_non_nullable
                        as int,
            hasFencedYard:
                null == hasFencedYard
                    ? _value.hasFencedYard
                    : hasFencedYard // ignore: cast_nullable_to_non_nullable
                        as bool,
            hasOwnTransport:
                null == hasOwnTransport
                    ? _value.hasOwnTransport
                    : hasOwnTransport // ignore: cast_nullable_to_non_nullable
                        as bool,
            smokeFreeHome:
                null == smokeFreeHome
                    ? _value.smokeFreeHome
                    : smokeFreeHome // ignore: cast_nullable_to_non_nullable
                        as bool,
            hasChildren:
                null == hasChildren
                    ? _value.hasChildren
                    : hasChildren // ignore: cast_nullable_to_non_nullable
                        as bool,
            hasOtherPets:
                null == hasOtherPets
                    ? _value.hasOtherPets
                    : hasOtherPets // ignore: cast_nullable_to_non_nullable
                        as bool,
            otherPetsDescription:
                freezed == otherPetsDescription
                    ? _value.otherPetsDescription
                    : otherPetsDescription // ignore: cast_nullable_to_non_nullable
                        as String?,
            averageRating:
                null == averageRating
                    ? _value.averageRating
                    : averageRating // ignore: cast_nullable_to_non_nullable
                        as double,
            totalReviews:
                null == totalReviews
                    ? _value.totalReviews
                    : totalReviews // ignore: cast_nullable_to_non_nullable
                        as int,
            totalBookings:
                null == totalBookings
                    ? _value.totalBookings
                    : totalBookings // ignore: cast_nullable_to_non_nullable
                        as int,
            completionRate:
                null == completionRate
                    ? _value.completionRate
                    : completionRate // ignore: cast_nullable_to_non_nullable
                        as double,
            responseTimeHours:
                null == responseTimeHours
                    ? _value.responseTimeHours
                    : responseTimeHours // ignore: cast_nullable_to_non_nullable
                        as int,
            isActive:
                null == isActive
                    ? _value.isActive
                    : isActive // ignore: cast_nullable_to_non_nullable
                        as bool,
            isAcceptingBookings:
                null == isAcceptingBookings
                    ? _value.isAcceptingBookings
                    : isAcceptingBookings // ignore: cast_nullable_to_non_nullable
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
            userName:
                freezed == userName
                    ? _value.userName
                    : userName // ignore: cast_nullable_to_non_nullable
                        as String?,
            userAvatar:
                freezed == userAvatar
                    ? _value.userAvatar
                    : userAvatar // ignore: cast_nullable_to_non_nullable
                        as String?,
            services:
                null == services
                    ? _value.services
                    : services // ignore: cast_nullable_to_non_nullable
                        as List<CaregiverService>,
            availability:
                null == availability
                    ? _value.availability
                    : availability // ignore: cast_nullable_to_non_nullable
                        as List<CaregiverAvailability>,
            gallery:
                null == gallery
                    ? _value.gallery
                    : gallery // ignore: cast_nullable_to_non_nullable
                        as List<CaregiverGalleryItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaregiverProfileImplCopyWith<$Res>
    implements $CaregiverProfileCopyWith<$Res> {
  factory _$$CaregiverProfileImplCopyWith(
    _$CaregiverProfileImpl value,
    $Res Function(_$CaregiverProfileImpl) then,
  ) = __$$CaregiverProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String? bio,
    int yearsOfExperience,
    String? headline,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String country,
    double? latitude,
    double? longitude,
    int serviceRadiusKm,
    bool isVerified,
    DateTime? verificationDate,
    String backgroundCheckStatus,
    DateTime? backgroundCheckDate,
    bool idVerified,
    String? idDocumentUrl,
    List<String> certifications,
    bool petFirstAidCertified,
    bool insuranceVerified,
    String? insurancePolicyNumber,
    DateTime? insuranceExpiry,
    List<String> acceptedPetTypes,
    List<String> acceptedPetSizes,
    int maxPetsAtOnce,
    bool hasFencedYard,
    bool hasOwnTransport,
    bool smokeFreeHome,
    bool hasChildren,
    bool hasOtherPets,
    String? otherPetsDescription,
    double averageRating,
    int totalReviews,
    int totalBookings,
    double completionRate,
    int responseTimeHours,
    bool isActive,
    bool isAcceptingBookings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
    List<CaregiverService> services,
    List<CaregiverAvailability> availability,
    List<CaregiverGalleryItem> gallery,
  });
}

/// @nodoc
class __$$CaregiverProfileImplCopyWithImpl<$Res>
    extends _$CaregiverProfileCopyWithImpl<$Res, _$CaregiverProfileImpl>
    implements _$$CaregiverProfileImplCopyWith<$Res> {
  __$$CaregiverProfileImplCopyWithImpl(
    _$CaregiverProfileImpl _value,
    $Res Function(_$CaregiverProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaregiverProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bio = freezed,
    Object? yearsOfExperience = null,
    Object? headline = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? postalCode = freezed,
    Object? country = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? serviceRadiusKm = null,
    Object? isVerified = null,
    Object? verificationDate = freezed,
    Object? backgroundCheckStatus = null,
    Object? backgroundCheckDate = freezed,
    Object? idVerified = null,
    Object? idDocumentUrl = freezed,
    Object? certifications = null,
    Object? petFirstAidCertified = null,
    Object? insuranceVerified = null,
    Object? insurancePolicyNumber = freezed,
    Object? insuranceExpiry = freezed,
    Object? acceptedPetTypes = null,
    Object? acceptedPetSizes = null,
    Object? maxPetsAtOnce = null,
    Object? hasFencedYard = null,
    Object? hasOwnTransport = null,
    Object? smokeFreeHome = null,
    Object? hasChildren = null,
    Object? hasOtherPets = null,
    Object? otherPetsDescription = freezed,
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? totalBookings = null,
    Object? completionRate = null,
    Object? responseTimeHours = null,
    Object? isActive = null,
    Object? isAcceptingBookings = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userName = freezed,
    Object? userAvatar = freezed,
    Object? services = null,
    Object? availability = null,
    Object? gallery = null,
  }) {
    return _then(
      _$CaregiverProfileImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        bio:
            freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                    as String?,
        yearsOfExperience:
            null == yearsOfExperience
                ? _value.yearsOfExperience
                : yearsOfExperience // ignore: cast_nullable_to_non_nullable
                    as int,
        headline:
            freezed == headline
                ? _value.headline
                : headline // ignore: cast_nullable_to_non_nullable
                    as String?,
        address:
            freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String?,
        city:
            freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                    as String?,
        state:
            freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                    as String?,
        postalCode:
            freezed == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                    as String?,
        country:
            null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                    as String,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        serviceRadiusKm:
            null == serviceRadiusKm
                ? _value.serviceRadiusKm
                : serviceRadiusKm // ignore: cast_nullable_to_non_nullable
                    as int,
        isVerified:
            null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                    as bool,
        verificationDate:
            freezed == verificationDate
                ? _value.verificationDate
                : verificationDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        backgroundCheckStatus:
            null == backgroundCheckStatus
                ? _value.backgroundCheckStatus
                : backgroundCheckStatus // ignore: cast_nullable_to_non_nullable
                    as String,
        backgroundCheckDate:
            freezed == backgroundCheckDate
                ? _value.backgroundCheckDate
                : backgroundCheckDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        idVerified:
            null == idVerified
                ? _value.idVerified
                : idVerified // ignore: cast_nullable_to_non_nullable
                    as bool,
        idDocumentUrl:
            freezed == idDocumentUrl
                ? _value.idDocumentUrl
                : idDocumentUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        certifications:
            null == certifications
                ? _value._certifications
                : certifications // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        petFirstAidCertified:
            null == petFirstAidCertified
                ? _value.petFirstAidCertified
                : petFirstAidCertified // ignore: cast_nullable_to_non_nullable
                    as bool,
        insuranceVerified:
            null == insuranceVerified
                ? _value.insuranceVerified
                : insuranceVerified // ignore: cast_nullable_to_non_nullable
                    as bool,
        insurancePolicyNumber:
            freezed == insurancePolicyNumber
                ? _value.insurancePolicyNumber
                : insurancePolicyNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        insuranceExpiry:
            freezed == insuranceExpiry
                ? _value.insuranceExpiry
                : insuranceExpiry // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        acceptedPetTypes:
            null == acceptedPetTypes
                ? _value._acceptedPetTypes
                : acceptedPetTypes // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        acceptedPetSizes:
            null == acceptedPetSizes
                ? _value._acceptedPetSizes
                : acceptedPetSizes // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        maxPetsAtOnce:
            null == maxPetsAtOnce
                ? _value.maxPetsAtOnce
                : maxPetsAtOnce // ignore: cast_nullable_to_non_nullable
                    as int,
        hasFencedYard:
            null == hasFencedYard
                ? _value.hasFencedYard
                : hasFencedYard // ignore: cast_nullable_to_non_nullable
                    as bool,
        hasOwnTransport:
            null == hasOwnTransport
                ? _value.hasOwnTransport
                : hasOwnTransport // ignore: cast_nullable_to_non_nullable
                    as bool,
        smokeFreeHome:
            null == smokeFreeHome
                ? _value.smokeFreeHome
                : smokeFreeHome // ignore: cast_nullable_to_non_nullable
                    as bool,
        hasChildren:
            null == hasChildren
                ? _value.hasChildren
                : hasChildren // ignore: cast_nullable_to_non_nullable
                    as bool,
        hasOtherPets:
            null == hasOtherPets
                ? _value.hasOtherPets
                : hasOtherPets // ignore: cast_nullable_to_non_nullable
                    as bool,
        otherPetsDescription:
            freezed == otherPetsDescription
                ? _value.otherPetsDescription
                : otherPetsDescription // ignore: cast_nullable_to_non_nullable
                    as String?,
        averageRating:
            null == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                    as double,
        totalReviews:
            null == totalReviews
                ? _value.totalReviews
                : totalReviews // ignore: cast_nullable_to_non_nullable
                    as int,
        totalBookings:
            null == totalBookings
                ? _value.totalBookings
                : totalBookings // ignore: cast_nullable_to_non_nullable
                    as int,
        completionRate:
            null == completionRate
                ? _value.completionRate
                : completionRate // ignore: cast_nullable_to_non_nullable
                    as double,
        responseTimeHours:
            null == responseTimeHours
                ? _value.responseTimeHours
                : responseTimeHours // ignore: cast_nullable_to_non_nullable
                    as int,
        isActive:
            null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                    as bool,
        isAcceptingBookings:
            null == isAcceptingBookings
                ? _value.isAcceptingBookings
                : isAcceptingBookings // ignore: cast_nullable_to_non_nullable
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
        userName:
            freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                    as String?,
        userAvatar:
            freezed == userAvatar
                ? _value.userAvatar
                : userAvatar // ignore: cast_nullable_to_non_nullable
                    as String?,
        services:
            null == services
                ? _value._services
                : services // ignore: cast_nullable_to_non_nullable
                    as List<CaregiverService>,
        availability:
            null == availability
                ? _value._availability
                : availability // ignore: cast_nullable_to_non_nullable
                    as List<CaregiverAvailability>,
        gallery:
            null == gallery
                ? _value._gallery
                : gallery // ignore: cast_nullable_to_non_nullable
                    as List<CaregiverGalleryItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CaregiverProfileImpl implements _CaregiverProfile {
  const _$CaregiverProfileImpl({
    required this.id,
    required this.userId,
    this.bio,
    this.yearsOfExperience = 0,
    this.headline,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country = 'Pakistan',
    this.latitude,
    this.longitude,
    this.serviceRadiusKm = 10,
    this.isVerified = false,
    this.verificationDate,
    this.backgroundCheckStatus = 'pending',
    this.backgroundCheckDate,
    this.idVerified = false,
    this.idDocumentUrl,
    final List<String> certifications = const [],
    this.petFirstAidCertified = false,
    this.insuranceVerified = false,
    this.insurancePolicyNumber,
    this.insuranceExpiry,
    final List<String> acceptedPetTypes = const ['dog', 'cat'],
    final List<String> acceptedPetSizes = const ['small', 'medium', 'large'],
    this.maxPetsAtOnce = 3,
    this.hasFencedYard = false,
    this.hasOwnTransport = false,
    this.smokeFreeHome = true,
    this.hasChildren = false,
    this.hasOtherPets = false,
    this.otherPetsDescription,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalBookings = 0,
    this.completionRate = 100.0,
    this.responseTimeHours = 24,
    this.isActive = true,
    this.isAcceptingBookings = true,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userAvatar,
    final List<CaregiverService> services = const [],
    final List<CaregiverAvailability> availability = const [],
    final List<CaregiverGalleryItem> gallery = const [],
  }) : _certifications = certifications,
       _acceptedPetTypes = acceptedPetTypes,
       _acceptedPetSizes = acceptedPetSizes,
       _services = services,
       _availability = availability,
       _gallery = gallery;

  factory _$CaregiverProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaregiverProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? bio;
  @override
  @JsonKey()
  final int yearsOfExperience;
  @override
  final String? headline;
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? postalCode;
  @override
  @JsonKey()
  final String country;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final int serviceRadiusKm;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  final DateTime? verificationDate;
  @override
  @JsonKey()
  final String backgroundCheckStatus;
  @override
  final DateTime? backgroundCheckDate;
  @override
  @JsonKey()
  final bool idVerified;
  @override
  final String? idDocumentUrl;
  final List<String> _certifications;
  @override
  @JsonKey()
  List<String> get certifications {
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_certifications);
  }

  @override
  @JsonKey()
  final bool petFirstAidCertified;
  @override
  @JsonKey()
  final bool insuranceVerified;
  @override
  final String? insurancePolicyNumber;
  @override
  final DateTime? insuranceExpiry;
  final List<String> _acceptedPetTypes;
  @override
  @JsonKey()
  List<String> get acceptedPetTypes {
    if (_acceptedPetTypes is EqualUnmodifiableListView)
      return _acceptedPetTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acceptedPetTypes);
  }

  final List<String> _acceptedPetSizes;
  @override
  @JsonKey()
  List<String> get acceptedPetSizes {
    if (_acceptedPetSizes is EqualUnmodifiableListView)
      return _acceptedPetSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acceptedPetSizes);
  }

  @override
  @JsonKey()
  final int maxPetsAtOnce;
  @override
  @JsonKey()
  final bool hasFencedYard;
  @override
  @JsonKey()
  final bool hasOwnTransport;
  @override
  @JsonKey()
  final bool smokeFreeHome;
  @override
  @JsonKey()
  final bool hasChildren;
  @override
  @JsonKey()
  final bool hasOtherPets;
  @override
  final String? otherPetsDescription;
  @override
  @JsonKey()
  final double averageRating;
  @override
  @JsonKey()
  final int totalReviews;
  @override
  @JsonKey()
  final int totalBookings;
  @override
  @JsonKey()
  final double completionRate;
  @override
  @JsonKey()
  final int responseTimeHours;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isAcceptingBookings;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // Joined fields
  @override
  final String? userName;
  @override
  final String? userAvatar;
  final List<CaregiverService> _services;
  @override
  @JsonKey()
  List<CaregiverService> get services {
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_services);
  }

  final List<CaregiverAvailability> _availability;
  @override
  @JsonKey()
  List<CaregiverAvailability> get availability {
    if (_availability is EqualUnmodifiableListView) return _availability;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availability);
  }

  final List<CaregiverGalleryItem> _gallery;
  @override
  @JsonKey()
  List<CaregiverGalleryItem> get gallery {
    if (_gallery is EqualUnmodifiableListView) return _gallery;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gallery);
  }

  @override
  String toString() {
    return 'CaregiverProfile(id: $id, userId: $userId, bio: $bio, yearsOfExperience: $yearsOfExperience, headline: $headline, address: $address, city: $city, state: $state, postalCode: $postalCode, country: $country, latitude: $latitude, longitude: $longitude, serviceRadiusKm: $serviceRadiusKm, isVerified: $isVerified, verificationDate: $verificationDate, backgroundCheckStatus: $backgroundCheckStatus, backgroundCheckDate: $backgroundCheckDate, idVerified: $idVerified, idDocumentUrl: $idDocumentUrl, certifications: $certifications, petFirstAidCertified: $petFirstAidCertified, insuranceVerified: $insuranceVerified, insurancePolicyNumber: $insurancePolicyNumber, insuranceExpiry: $insuranceExpiry, acceptedPetTypes: $acceptedPetTypes, acceptedPetSizes: $acceptedPetSizes, maxPetsAtOnce: $maxPetsAtOnce, hasFencedYard: $hasFencedYard, hasOwnTransport: $hasOwnTransport, smokeFreeHome: $smokeFreeHome, hasChildren: $hasChildren, hasOtherPets: $hasOtherPets, otherPetsDescription: $otherPetsDescription, averageRating: $averageRating, totalReviews: $totalReviews, totalBookings: $totalBookings, completionRate: $completionRate, responseTimeHours: $responseTimeHours, isActive: $isActive, isAcceptingBookings: $isAcceptingBookings, createdAt: $createdAt, updatedAt: $updatedAt, userName: $userName, userAvatar: $userAvatar, services: $services, availability: $availability, gallery: $gallery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaregiverProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.yearsOfExperience, yearsOfExperience) ||
                other.yearsOfExperience == yearsOfExperience) &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.serviceRadiusKm, serviceRadiusKm) ||
                other.serviceRadiusKm == serviceRadiusKm) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.verificationDate, verificationDate) ||
                other.verificationDate == verificationDate) &&
            (identical(other.backgroundCheckStatus, backgroundCheckStatus) ||
                other.backgroundCheckStatus == backgroundCheckStatus) &&
            (identical(other.backgroundCheckDate, backgroundCheckDate) ||
                other.backgroundCheckDate == backgroundCheckDate) &&
            (identical(other.idVerified, idVerified) ||
                other.idVerified == idVerified) &&
            (identical(other.idDocumentUrl, idDocumentUrl) ||
                other.idDocumentUrl == idDocumentUrl) &&
            const DeepCollectionEquality().equals(
              other._certifications,
              _certifications,
            ) &&
            (identical(other.petFirstAidCertified, petFirstAidCertified) ||
                other.petFirstAidCertified == petFirstAidCertified) &&
            (identical(other.insuranceVerified, insuranceVerified) ||
                other.insuranceVerified == insuranceVerified) &&
            (identical(other.insurancePolicyNumber, insurancePolicyNumber) ||
                other.insurancePolicyNumber == insurancePolicyNumber) &&
            (identical(other.insuranceExpiry, insuranceExpiry) ||
                other.insuranceExpiry == insuranceExpiry) &&
            const DeepCollectionEquality().equals(
              other._acceptedPetTypes,
              _acceptedPetTypes,
            ) &&
            const DeepCollectionEquality().equals(
              other._acceptedPetSizes,
              _acceptedPetSizes,
            ) &&
            (identical(other.maxPetsAtOnce, maxPetsAtOnce) ||
                other.maxPetsAtOnce == maxPetsAtOnce) &&
            (identical(other.hasFencedYard, hasFencedYard) ||
                other.hasFencedYard == hasFencedYard) &&
            (identical(other.hasOwnTransport, hasOwnTransport) ||
                other.hasOwnTransport == hasOwnTransport) &&
            (identical(other.smokeFreeHome, smokeFreeHome) ||
                other.smokeFreeHome == smokeFreeHome) &&
            (identical(other.hasChildren, hasChildren) ||
                other.hasChildren == hasChildren) &&
            (identical(other.hasOtherPets, hasOtherPets) ||
                other.hasOtherPets == hasOtherPets) &&
            (identical(other.otherPetsDescription, otherPetsDescription) ||
                other.otherPetsDescription == otherPetsDescription) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.responseTimeHours, responseTimeHours) ||
                other.responseTimeHours == responseTimeHours) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isAcceptingBookings, isAcceptingBookings) ||
                other.isAcceptingBookings == isAcceptingBookings) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatar, userAvatar) ||
                other.userAvatar == userAvatar) &&
            const DeepCollectionEquality().equals(other._services, _services) &&
            const DeepCollectionEquality().equals(
              other._availability,
              _availability,
            ) &&
            const DeepCollectionEquality().equals(other._gallery, _gallery));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    bio,
    yearsOfExperience,
    headline,
    address,
    city,
    state,
    postalCode,
    country,
    latitude,
    longitude,
    serviceRadiusKm,
    isVerified,
    verificationDate,
    backgroundCheckStatus,
    backgroundCheckDate,
    idVerified,
    idDocumentUrl,
    const DeepCollectionEquality().hash(_certifications),
    petFirstAidCertified,
    insuranceVerified,
    insurancePolicyNumber,
    insuranceExpiry,
    const DeepCollectionEquality().hash(_acceptedPetTypes),
    const DeepCollectionEquality().hash(_acceptedPetSizes),
    maxPetsAtOnce,
    hasFencedYard,
    hasOwnTransport,
    smokeFreeHome,
    hasChildren,
    hasOtherPets,
    otherPetsDescription,
    averageRating,
    totalReviews,
    totalBookings,
    completionRate,
    responseTimeHours,
    isActive,
    isAcceptingBookings,
    createdAt,
    updatedAt,
    userName,
    userAvatar,
    const DeepCollectionEquality().hash(_services),
    const DeepCollectionEquality().hash(_availability),
    const DeepCollectionEquality().hash(_gallery),
  ]);

  /// Create a copy of CaregiverProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaregiverProfileImplCopyWith<_$CaregiverProfileImpl> get copyWith =>
      __$$CaregiverProfileImplCopyWithImpl<_$CaregiverProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CaregiverProfileImplToJson(this);
  }
}

abstract class _CaregiverProfile implements CaregiverProfile {
  const factory _CaregiverProfile({
    required final String id,
    required final String userId,
    final String? bio,
    final int yearsOfExperience,
    final String? headline,
    final String? address,
    final String? city,
    final String? state,
    final String? postalCode,
    final String country,
    final double? latitude,
    final double? longitude,
    final int serviceRadiusKm,
    final bool isVerified,
    final DateTime? verificationDate,
    final String backgroundCheckStatus,
    final DateTime? backgroundCheckDate,
    final bool idVerified,
    final String? idDocumentUrl,
    final List<String> certifications,
    final bool petFirstAidCertified,
    final bool insuranceVerified,
    final String? insurancePolicyNumber,
    final DateTime? insuranceExpiry,
    final List<String> acceptedPetTypes,
    final List<String> acceptedPetSizes,
    final int maxPetsAtOnce,
    final bool hasFencedYard,
    final bool hasOwnTransport,
    final bool smokeFreeHome,
    final bool hasChildren,
    final bool hasOtherPets,
    final String? otherPetsDescription,
    final double averageRating,
    final int totalReviews,
    final int totalBookings,
    final double completionRate,
    final int responseTimeHours,
    final bool isActive,
    final bool isAcceptingBookings,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? userName,
    final String? userAvatar,
    final List<CaregiverService> services,
    final List<CaregiverAvailability> availability,
    final List<CaregiverGalleryItem> gallery,
  }) = _$CaregiverProfileImpl;

  factory _CaregiverProfile.fromJson(Map<String, dynamic> json) =
      _$CaregiverProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get bio;
  @override
  int get yearsOfExperience;
  @override
  String? get headline;
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get state;
  @override
  String? get postalCode;
  @override
  String get country;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  int get serviceRadiusKm;
  @override
  bool get isVerified;
  @override
  DateTime? get verificationDate;
  @override
  String get backgroundCheckStatus;
  @override
  DateTime? get backgroundCheckDate;
  @override
  bool get idVerified;
  @override
  String? get idDocumentUrl;
  @override
  List<String> get certifications;
  @override
  bool get petFirstAidCertified;
  @override
  bool get insuranceVerified;
  @override
  String? get insurancePolicyNumber;
  @override
  DateTime? get insuranceExpiry;
  @override
  List<String> get acceptedPetTypes;
  @override
  List<String> get acceptedPetSizes;
  @override
  int get maxPetsAtOnce;
  @override
  bool get hasFencedYard;
  @override
  bool get hasOwnTransport;
  @override
  bool get smokeFreeHome;
  @override
  bool get hasChildren;
  @override
  bool get hasOtherPets;
  @override
  String? get otherPetsDescription;
  @override
  double get averageRating;
  @override
  int get totalReviews;
  @override
  int get totalBookings;
  @override
  double get completionRate;
  @override
  int get responseTimeHours;
  @override
  bool get isActive;
  @override
  bool get isAcceptingBookings;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Joined fields
  @override
  String? get userName;
  @override
  String? get userAvatar;
  @override
  List<CaregiverService> get services;
  @override
  List<CaregiverAvailability> get availability;
  @override
  List<CaregiverGalleryItem> get gallery;

  /// Create a copy of CaregiverProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaregiverProfileImplCopyWith<_$CaregiverProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateCaregiverProfileRequest _$CreateCaregiverProfileRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CreateCaregiverProfileRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateCaregiverProfileRequest {
  String? get bio => throw _privateConstructorUsedError;
  int? get yearsOfExperience => throw _privateConstructorUsedError;
  String? get headline => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get postalCode => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  int? get serviceRadiusKm => throw _privateConstructorUsedError;
  List<String>? get certifications => throw _privateConstructorUsedError;
  bool? get petFirstAidCertified => throw _privateConstructorUsedError;
  List<String>? get acceptedPetTypes => throw _privateConstructorUsedError;
  List<String>? get acceptedPetSizes => throw _privateConstructorUsedError;
  int? get maxPetsAtOnce => throw _privateConstructorUsedError;
  bool? get hasFencedYard => throw _privateConstructorUsedError;
  bool? get hasOwnTransport => throw _privateConstructorUsedError;
  bool? get smokeFreeHome => throw _privateConstructorUsedError;
  bool? get hasChildren => throw _privateConstructorUsedError;
  bool? get hasOtherPets => throw _privateConstructorUsedError;
  String? get otherPetsDescription => throw _privateConstructorUsedError;

  /// Serializes this CreateCaregiverProfileRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateCaregiverProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateCaregiverProfileRequestCopyWith<CreateCaregiverProfileRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateCaregiverProfileRequestCopyWith<$Res> {
  factory $CreateCaregiverProfileRequestCopyWith(
    CreateCaregiverProfileRequest value,
    $Res Function(CreateCaregiverProfileRequest) then,
  ) =
      _$CreateCaregiverProfileRequestCopyWithImpl<
        $Res,
        CreateCaregiverProfileRequest
      >;
  @useResult
  $Res call({
    String? bio,
    int? yearsOfExperience,
    String? headline,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    double? latitude,
    double? longitude,
    int? serviceRadiusKm,
    List<String>? certifications,
    bool? petFirstAidCertified,
    List<String>? acceptedPetTypes,
    List<String>? acceptedPetSizes,
    int? maxPetsAtOnce,
    bool? hasFencedYard,
    bool? hasOwnTransport,
    bool? smokeFreeHome,
    bool? hasChildren,
    bool? hasOtherPets,
    String? otherPetsDescription,
  });
}

/// @nodoc
class _$CreateCaregiverProfileRequestCopyWithImpl<
  $Res,
  $Val extends CreateCaregiverProfileRequest
>
    implements $CreateCaregiverProfileRequestCopyWith<$Res> {
  _$CreateCaregiverProfileRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateCaregiverProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bio = freezed,
    Object? yearsOfExperience = freezed,
    Object? headline = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? postalCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? serviceRadiusKm = freezed,
    Object? certifications = freezed,
    Object? petFirstAidCertified = freezed,
    Object? acceptedPetTypes = freezed,
    Object? acceptedPetSizes = freezed,
    Object? maxPetsAtOnce = freezed,
    Object? hasFencedYard = freezed,
    Object? hasOwnTransport = freezed,
    Object? smokeFreeHome = freezed,
    Object? hasChildren = freezed,
    Object? hasOtherPets = freezed,
    Object? otherPetsDescription = freezed,
  }) {
    return _then(
      _value.copyWith(
            bio:
                freezed == bio
                    ? _value.bio
                    : bio // ignore: cast_nullable_to_non_nullable
                        as String?,
            yearsOfExperience:
                freezed == yearsOfExperience
                    ? _value.yearsOfExperience
                    : yearsOfExperience // ignore: cast_nullable_to_non_nullable
                        as int?,
            headline:
                freezed == headline
                    ? _value.headline
                    : headline // ignore: cast_nullable_to_non_nullable
                        as String?,
            address:
                freezed == address
                    ? _value.address
                    : address // ignore: cast_nullable_to_non_nullable
                        as String?,
            city:
                freezed == city
                    ? _value.city
                    : city // ignore: cast_nullable_to_non_nullable
                        as String?,
            state:
                freezed == state
                    ? _value.state
                    : state // ignore: cast_nullable_to_non_nullable
                        as String?,
            postalCode:
                freezed == postalCode
                    ? _value.postalCode
                    : postalCode // ignore: cast_nullable_to_non_nullable
                        as String?,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            serviceRadiusKm:
                freezed == serviceRadiusKm
                    ? _value.serviceRadiusKm
                    : serviceRadiusKm // ignore: cast_nullable_to_non_nullable
                        as int?,
            certifications:
                freezed == certifications
                    ? _value.certifications
                    : certifications // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            petFirstAidCertified:
                freezed == petFirstAidCertified
                    ? _value.petFirstAidCertified
                    : petFirstAidCertified // ignore: cast_nullable_to_non_nullable
                        as bool?,
            acceptedPetTypes:
                freezed == acceptedPetTypes
                    ? _value.acceptedPetTypes
                    : acceptedPetTypes // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            acceptedPetSizes:
                freezed == acceptedPetSizes
                    ? _value.acceptedPetSizes
                    : acceptedPetSizes // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            maxPetsAtOnce:
                freezed == maxPetsAtOnce
                    ? _value.maxPetsAtOnce
                    : maxPetsAtOnce // ignore: cast_nullable_to_non_nullable
                        as int?,
            hasFencedYard:
                freezed == hasFencedYard
                    ? _value.hasFencedYard
                    : hasFencedYard // ignore: cast_nullable_to_non_nullable
                        as bool?,
            hasOwnTransport:
                freezed == hasOwnTransport
                    ? _value.hasOwnTransport
                    : hasOwnTransport // ignore: cast_nullable_to_non_nullable
                        as bool?,
            smokeFreeHome:
                freezed == smokeFreeHome
                    ? _value.smokeFreeHome
                    : smokeFreeHome // ignore: cast_nullable_to_non_nullable
                        as bool?,
            hasChildren:
                freezed == hasChildren
                    ? _value.hasChildren
                    : hasChildren // ignore: cast_nullable_to_non_nullable
                        as bool?,
            hasOtherPets:
                freezed == hasOtherPets
                    ? _value.hasOtherPets
                    : hasOtherPets // ignore: cast_nullable_to_non_nullable
                        as bool?,
            otherPetsDescription:
                freezed == otherPetsDescription
                    ? _value.otherPetsDescription
                    : otherPetsDescription // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateCaregiverProfileRequestImplCopyWith<$Res>
    implements $CreateCaregiverProfileRequestCopyWith<$Res> {
  factory _$$CreateCaregiverProfileRequestImplCopyWith(
    _$CreateCaregiverProfileRequestImpl value,
    $Res Function(_$CreateCaregiverProfileRequestImpl) then,
  ) = __$$CreateCaregiverProfileRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? bio,
    int? yearsOfExperience,
    String? headline,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    double? latitude,
    double? longitude,
    int? serviceRadiusKm,
    List<String>? certifications,
    bool? petFirstAidCertified,
    List<String>? acceptedPetTypes,
    List<String>? acceptedPetSizes,
    int? maxPetsAtOnce,
    bool? hasFencedYard,
    bool? hasOwnTransport,
    bool? smokeFreeHome,
    bool? hasChildren,
    bool? hasOtherPets,
    String? otherPetsDescription,
  });
}

/// @nodoc
class __$$CreateCaregiverProfileRequestImplCopyWithImpl<$Res>
    extends
        _$CreateCaregiverProfileRequestCopyWithImpl<
          $Res,
          _$CreateCaregiverProfileRequestImpl
        >
    implements _$$CreateCaregiverProfileRequestImplCopyWith<$Res> {
  __$$CreateCaregiverProfileRequestImplCopyWithImpl(
    _$CreateCaregiverProfileRequestImpl _value,
    $Res Function(_$CreateCaregiverProfileRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateCaregiverProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bio = freezed,
    Object? yearsOfExperience = freezed,
    Object? headline = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? postalCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? serviceRadiusKm = freezed,
    Object? certifications = freezed,
    Object? petFirstAidCertified = freezed,
    Object? acceptedPetTypes = freezed,
    Object? acceptedPetSizes = freezed,
    Object? maxPetsAtOnce = freezed,
    Object? hasFencedYard = freezed,
    Object? hasOwnTransport = freezed,
    Object? smokeFreeHome = freezed,
    Object? hasChildren = freezed,
    Object? hasOtherPets = freezed,
    Object? otherPetsDescription = freezed,
  }) {
    return _then(
      _$CreateCaregiverProfileRequestImpl(
        bio:
            freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                    as String?,
        yearsOfExperience:
            freezed == yearsOfExperience
                ? _value.yearsOfExperience
                : yearsOfExperience // ignore: cast_nullable_to_non_nullable
                    as int?,
        headline:
            freezed == headline
                ? _value.headline
                : headline // ignore: cast_nullable_to_non_nullable
                    as String?,
        address:
            freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String?,
        city:
            freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                    as String?,
        state:
            freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                    as String?,
        postalCode:
            freezed == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                    as String?,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        serviceRadiusKm:
            freezed == serviceRadiusKm
                ? _value.serviceRadiusKm
                : serviceRadiusKm // ignore: cast_nullable_to_non_nullable
                    as int?,
        certifications:
            freezed == certifications
                ? _value._certifications
                : certifications // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        petFirstAidCertified:
            freezed == petFirstAidCertified
                ? _value.petFirstAidCertified
                : petFirstAidCertified // ignore: cast_nullable_to_non_nullable
                    as bool?,
        acceptedPetTypes:
            freezed == acceptedPetTypes
                ? _value._acceptedPetTypes
                : acceptedPetTypes // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        acceptedPetSizes:
            freezed == acceptedPetSizes
                ? _value._acceptedPetSizes
                : acceptedPetSizes // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        maxPetsAtOnce:
            freezed == maxPetsAtOnce
                ? _value.maxPetsAtOnce
                : maxPetsAtOnce // ignore: cast_nullable_to_non_nullable
                    as int?,
        hasFencedYard:
            freezed == hasFencedYard
                ? _value.hasFencedYard
                : hasFencedYard // ignore: cast_nullable_to_non_nullable
                    as bool?,
        hasOwnTransport:
            freezed == hasOwnTransport
                ? _value.hasOwnTransport
                : hasOwnTransport // ignore: cast_nullable_to_non_nullable
                    as bool?,
        smokeFreeHome:
            freezed == smokeFreeHome
                ? _value.smokeFreeHome
                : smokeFreeHome // ignore: cast_nullable_to_non_nullable
                    as bool?,
        hasChildren:
            freezed == hasChildren
                ? _value.hasChildren
                : hasChildren // ignore: cast_nullable_to_non_nullable
                    as bool?,
        hasOtherPets:
            freezed == hasOtherPets
                ? _value.hasOtherPets
                : hasOtherPets // ignore: cast_nullable_to_non_nullable
                    as bool?,
        otherPetsDescription:
            freezed == otherPetsDescription
                ? _value.otherPetsDescription
                : otherPetsDescription // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateCaregiverProfileRequestImpl
    implements _CreateCaregiverProfileRequest {
  const _$CreateCaregiverProfileRequestImpl({
    this.bio,
    this.yearsOfExperience,
    this.headline,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.serviceRadiusKm,
    final List<String>? certifications,
    this.petFirstAidCertified,
    final List<String>? acceptedPetTypes,
    final List<String>? acceptedPetSizes,
    this.maxPetsAtOnce,
    this.hasFencedYard,
    this.hasOwnTransport,
    this.smokeFreeHome,
    this.hasChildren,
    this.hasOtherPets,
    this.otherPetsDescription,
  }) : _certifications = certifications,
       _acceptedPetTypes = acceptedPetTypes,
       _acceptedPetSizes = acceptedPetSizes;

  factory _$CreateCaregiverProfileRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CreateCaregiverProfileRequestImplFromJson(json);

  @override
  final String? bio;
  @override
  final int? yearsOfExperience;
  @override
  final String? headline;
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? postalCode;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final int? serviceRadiusKm;
  final List<String>? _certifications;
  @override
  List<String>? get certifications {
    final value = _certifications;
    if (value == null) return null;
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? petFirstAidCertified;
  final List<String>? _acceptedPetTypes;
  @override
  List<String>? get acceptedPetTypes {
    final value = _acceptedPetTypes;
    if (value == null) return null;
    if (_acceptedPetTypes is EqualUnmodifiableListView)
      return _acceptedPetTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _acceptedPetSizes;
  @override
  List<String>? get acceptedPetSizes {
    final value = _acceptedPetSizes;
    if (value == null) return null;
    if (_acceptedPetSizes is EqualUnmodifiableListView)
      return _acceptedPetSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? maxPetsAtOnce;
  @override
  final bool? hasFencedYard;
  @override
  final bool? hasOwnTransport;
  @override
  final bool? smokeFreeHome;
  @override
  final bool? hasChildren;
  @override
  final bool? hasOtherPets;
  @override
  final String? otherPetsDescription;

  @override
  String toString() {
    return 'CreateCaregiverProfileRequest(bio: $bio, yearsOfExperience: $yearsOfExperience, headline: $headline, address: $address, city: $city, state: $state, postalCode: $postalCode, latitude: $latitude, longitude: $longitude, serviceRadiusKm: $serviceRadiusKm, certifications: $certifications, petFirstAidCertified: $petFirstAidCertified, acceptedPetTypes: $acceptedPetTypes, acceptedPetSizes: $acceptedPetSizes, maxPetsAtOnce: $maxPetsAtOnce, hasFencedYard: $hasFencedYard, hasOwnTransport: $hasOwnTransport, smokeFreeHome: $smokeFreeHome, hasChildren: $hasChildren, hasOtherPets: $hasOtherPets, otherPetsDescription: $otherPetsDescription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateCaregiverProfileRequestImpl &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.yearsOfExperience, yearsOfExperience) ||
                other.yearsOfExperience == yearsOfExperience) &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.serviceRadiusKm, serviceRadiusKm) ||
                other.serviceRadiusKm == serviceRadiusKm) &&
            const DeepCollectionEquality().equals(
              other._certifications,
              _certifications,
            ) &&
            (identical(other.petFirstAidCertified, petFirstAidCertified) ||
                other.petFirstAidCertified == petFirstAidCertified) &&
            const DeepCollectionEquality().equals(
              other._acceptedPetTypes,
              _acceptedPetTypes,
            ) &&
            const DeepCollectionEquality().equals(
              other._acceptedPetSizes,
              _acceptedPetSizes,
            ) &&
            (identical(other.maxPetsAtOnce, maxPetsAtOnce) ||
                other.maxPetsAtOnce == maxPetsAtOnce) &&
            (identical(other.hasFencedYard, hasFencedYard) ||
                other.hasFencedYard == hasFencedYard) &&
            (identical(other.hasOwnTransport, hasOwnTransport) ||
                other.hasOwnTransport == hasOwnTransport) &&
            (identical(other.smokeFreeHome, smokeFreeHome) ||
                other.smokeFreeHome == smokeFreeHome) &&
            (identical(other.hasChildren, hasChildren) ||
                other.hasChildren == hasChildren) &&
            (identical(other.hasOtherPets, hasOtherPets) ||
                other.hasOtherPets == hasOtherPets) &&
            (identical(other.otherPetsDescription, otherPetsDescription) ||
                other.otherPetsDescription == otherPetsDescription));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    bio,
    yearsOfExperience,
    headline,
    address,
    city,
    state,
    postalCode,
    latitude,
    longitude,
    serviceRadiusKm,
    const DeepCollectionEquality().hash(_certifications),
    petFirstAidCertified,
    const DeepCollectionEquality().hash(_acceptedPetTypes),
    const DeepCollectionEquality().hash(_acceptedPetSizes),
    maxPetsAtOnce,
    hasFencedYard,
    hasOwnTransport,
    smokeFreeHome,
    hasChildren,
    hasOtherPets,
    otherPetsDescription,
  ]);

  /// Create a copy of CreateCaregiverProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateCaregiverProfileRequestImplCopyWith<
    _$CreateCaregiverProfileRequestImpl
  >
  get copyWith => __$$CreateCaregiverProfileRequestImplCopyWithImpl<
    _$CreateCaregiverProfileRequestImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateCaregiverProfileRequestImplToJson(this);
  }
}

abstract class _CreateCaregiverProfileRequest
    implements CreateCaregiverProfileRequest {
  const factory _CreateCaregiverProfileRequest({
    final String? bio,
    final int? yearsOfExperience,
    final String? headline,
    final String? address,
    final String? city,
    final String? state,
    final String? postalCode,
    final double? latitude,
    final double? longitude,
    final int? serviceRadiusKm,
    final List<String>? certifications,
    final bool? petFirstAidCertified,
    final List<String>? acceptedPetTypes,
    final List<String>? acceptedPetSizes,
    final int? maxPetsAtOnce,
    final bool? hasFencedYard,
    final bool? hasOwnTransport,
    final bool? smokeFreeHome,
    final bool? hasChildren,
    final bool? hasOtherPets,
    final String? otherPetsDescription,
  }) = _$CreateCaregiverProfileRequestImpl;

  factory _CreateCaregiverProfileRequest.fromJson(Map<String, dynamic> json) =
      _$CreateCaregiverProfileRequestImpl.fromJson;

  @override
  String? get bio;
  @override
  int? get yearsOfExperience;
  @override
  String? get headline;
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get state;
  @override
  String? get postalCode;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  int? get serviceRadiusKm;
  @override
  List<String>? get certifications;
  @override
  bool? get petFirstAidCertified;
  @override
  List<String>? get acceptedPetTypes;
  @override
  List<String>? get acceptedPetSizes;
  @override
  int? get maxPetsAtOnce;
  @override
  bool? get hasFencedYard;
  @override
  bool? get hasOwnTransport;
  @override
  bool? get smokeFreeHome;
  @override
  bool? get hasChildren;
  @override
  bool? get hasOtherPets;
  @override
  String? get otherPetsDescription;

  /// Create a copy of CreateCaregiverProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateCaregiverProfileRequestImplCopyWith<
    _$CreateCaregiverProfileRequestImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CaregiverService _$CaregiverServiceFromJson(Map<String, dynamic> json) {
  return _CaregiverService.fromJson(json);
}

/// @nodoc
mixin _$CaregiverService {
  String get id => throw _privateConstructorUsedError;
  String get caregiverId => throw _privateConstructorUsedError;
  String get serviceTypeId => throw _privateConstructorUsedError;
  String get rateType => throw _privateConstructorUsedError;
  double get rateAmount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  List<String> get includes => throw _privateConstructorUsedError;
  double get additionalPetRate => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Joined fields
  String? get serviceTypeName => throw _privateConstructorUsedError;
  String? get serviceTypeDisplayName => throw _privateConstructorUsedError;
  String? get serviceTypeIcon => throw _privateConstructorUsedError;

  /// Serializes this CaregiverService to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CaregiverService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaregiverServiceCopyWith<CaregiverService> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaregiverServiceCopyWith<$Res> {
  factory $CaregiverServiceCopyWith(
    CaregiverService value,
    $Res Function(CaregiverService) then,
  ) = _$CaregiverServiceCopyWithImpl<$Res, CaregiverService>;
  @useResult
  $Res call({
    String id,
    String caregiverId,
    String serviceTypeId,
    String rateType,
    double rateAmount,
    String currency,
    String? description,
    int? durationMinutes,
    List<String> includes,
    double additionalPetRate,
    bool isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serviceTypeName,
    String? serviceTypeDisplayName,
    String? serviceTypeIcon,
  });
}

/// @nodoc
class _$CaregiverServiceCopyWithImpl<$Res, $Val extends CaregiverService>
    implements $CaregiverServiceCopyWith<$Res> {
  _$CaregiverServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaregiverService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? caregiverId = null,
    Object? serviceTypeId = null,
    Object? rateType = null,
    Object? rateAmount = null,
    Object? currency = null,
    Object? description = freezed,
    Object? durationMinutes = freezed,
    Object? includes = null,
    Object? additionalPetRate = null,
    Object? isAvailable = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? serviceTypeName = freezed,
    Object? serviceTypeDisplayName = freezed,
    Object? serviceTypeIcon = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            caregiverId:
                null == caregiverId
                    ? _value.caregiverId
                    : caregiverId // ignore: cast_nullable_to_non_nullable
                        as String,
            serviceTypeId:
                null == serviceTypeId
                    ? _value.serviceTypeId
                    : serviceTypeId // ignore: cast_nullable_to_non_nullable
                        as String,
            rateType:
                null == rateType
                    ? _value.rateType
                    : rateType // ignore: cast_nullable_to_non_nullable
                        as String,
            rateAmount:
                null == rateAmount
                    ? _value.rateAmount
                    : rateAmount // ignore: cast_nullable_to_non_nullable
                        as double,
            currency:
                null == currency
                    ? _value.currency
                    : currency // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            durationMinutes:
                freezed == durationMinutes
                    ? _value.durationMinutes
                    : durationMinutes // ignore: cast_nullable_to_non_nullable
                        as int?,
            includes:
                null == includes
                    ? _value.includes
                    : includes // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            additionalPetRate:
                null == additionalPetRate
                    ? _value.additionalPetRate
                    : additionalPetRate // ignore: cast_nullable_to_non_nullable
                        as double,
            isAvailable:
                null == isAvailable
                    ? _value.isAvailable
                    : isAvailable // ignore: cast_nullable_to_non_nullable
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
            serviceTypeName:
                freezed == serviceTypeName
                    ? _value.serviceTypeName
                    : serviceTypeName // ignore: cast_nullable_to_non_nullable
                        as String?,
            serviceTypeDisplayName:
                freezed == serviceTypeDisplayName
                    ? _value.serviceTypeDisplayName
                    : serviceTypeDisplayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            serviceTypeIcon:
                freezed == serviceTypeIcon
                    ? _value.serviceTypeIcon
                    : serviceTypeIcon // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaregiverServiceImplCopyWith<$Res>
    implements $CaregiverServiceCopyWith<$Res> {
  factory _$$CaregiverServiceImplCopyWith(
    _$CaregiverServiceImpl value,
    $Res Function(_$CaregiverServiceImpl) then,
  ) = __$$CaregiverServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String caregiverId,
    String serviceTypeId,
    String rateType,
    double rateAmount,
    String currency,
    String? description,
    int? durationMinutes,
    List<String> includes,
    double additionalPetRate,
    bool isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serviceTypeName,
    String? serviceTypeDisplayName,
    String? serviceTypeIcon,
  });
}

/// @nodoc
class __$$CaregiverServiceImplCopyWithImpl<$Res>
    extends _$CaregiverServiceCopyWithImpl<$Res, _$CaregiverServiceImpl>
    implements _$$CaregiverServiceImplCopyWith<$Res> {
  __$$CaregiverServiceImplCopyWithImpl(
    _$CaregiverServiceImpl _value,
    $Res Function(_$CaregiverServiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaregiverService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? caregiverId = null,
    Object? serviceTypeId = null,
    Object? rateType = null,
    Object? rateAmount = null,
    Object? currency = null,
    Object? description = freezed,
    Object? durationMinutes = freezed,
    Object? includes = null,
    Object? additionalPetRate = null,
    Object? isAvailable = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? serviceTypeName = freezed,
    Object? serviceTypeDisplayName = freezed,
    Object? serviceTypeIcon = freezed,
  }) {
    return _then(
      _$CaregiverServiceImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        caregiverId:
            null == caregiverId
                ? _value.caregiverId
                : caregiverId // ignore: cast_nullable_to_non_nullable
                    as String,
        serviceTypeId:
            null == serviceTypeId
                ? _value.serviceTypeId
                : serviceTypeId // ignore: cast_nullable_to_non_nullable
                    as String,
        rateType:
            null == rateType
                ? _value.rateType
                : rateType // ignore: cast_nullable_to_non_nullable
                    as String,
        rateAmount:
            null == rateAmount
                ? _value.rateAmount
                : rateAmount // ignore: cast_nullable_to_non_nullable
                    as double,
        currency:
            null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        durationMinutes:
            freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                    as int?,
        includes:
            null == includes
                ? _value._includes
                : includes // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        additionalPetRate:
            null == additionalPetRate
                ? _value.additionalPetRate
                : additionalPetRate // ignore: cast_nullable_to_non_nullable
                    as double,
        isAvailable:
            null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
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
        serviceTypeName:
            freezed == serviceTypeName
                ? _value.serviceTypeName
                : serviceTypeName // ignore: cast_nullable_to_non_nullable
                    as String?,
        serviceTypeDisplayName:
            freezed == serviceTypeDisplayName
                ? _value.serviceTypeDisplayName
                : serviceTypeDisplayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        serviceTypeIcon:
            freezed == serviceTypeIcon
                ? _value.serviceTypeIcon
                : serviceTypeIcon // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CaregiverServiceImpl implements _CaregiverService {
  const _$CaregiverServiceImpl({
    required this.id,
    required this.caregiverId,
    required this.serviceTypeId,
    this.rateType = 'hourly',
    required this.rateAmount,
    this.currency = 'PKR',
    this.description,
    this.durationMinutes,
    final List<String> includes = const [],
    this.additionalPetRate = 0,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
    this.serviceTypeName,
    this.serviceTypeDisplayName,
    this.serviceTypeIcon,
  }) : _includes = includes;

  factory _$CaregiverServiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaregiverServiceImplFromJson(json);

  @override
  final String id;
  @override
  final String caregiverId;
  @override
  final String serviceTypeId;
  @override
  @JsonKey()
  final String rateType;
  @override
  final double rateAmount;
  @override
  @JsonKey()
  final String currency;
  @override
  final String? description;
  @override
  final int? durationMinutes;
  final List<String> _includes;
  @override
  @JsonKey()
  List<String> get includes {
    if (_includes is EqualUnmodifiableListView) return _includes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_includes);
  }

  @override
  @JsonKey()
  final double additionalPetRate;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // Joined fields
  @override
  final String? serviceTypeName;
  @override
  final String? serviceTypeDisplayName;
  @override
  final String? serviceTypeIcon;

  @override
  String toString() {
    return 'CaregiverService(id: $id, caregiverId: $caregiverId, serviceTypeId: $serviceTypeId, rateType: $rateType, rateAmount: $rateAmount, currency: $currency, description: $description, durationMinutes: $durationMinutes, includes: $includes, additionalPetRate: $additionalPetRate, isAvailable: $isAvailable, createdAt: $createdAt, updatedAt: $updatedAt, serviceTypeName: $serviceTypeName, serviceTypeDisplayName: $serviceTypeDisplayName, serviceTypeIcon: $serviceTypeIcon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaregiverServiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.caregiverId, caregiverId) ||
                other.caregiverId == caregiverId) &&
            (identical(other.serviceTypeId, serviceTypeId) ||
                other.serviceTypeId == serviceTypeId) &&
            (identical(other.rateType, rateType) ||
                other.rateType == rateType) &&
            (identical(other.rateAmount, rateAmount) ||
                other.rateAmount == rateAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            const DeepCollectionEquality().equals(other._includes, _includes) &&
            (identical(other.additionalPetRate, additionalPetRate) ||
                other.additionalPetRate == additionalPetRate) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.serviceTypeName, serviceTypeName) ||
                other.serviceTypeName == serviceTypeName) &&
            (identical(other.serviceTypeDisplayName, serviceTypeDisplayName) ||
                other.serviceTypeDisplayName == serviceTypeDisplayName) &&
            (identical(other.serviceTypeIcon, serviceTypeIcon) ||
                other.serviceTypeIcon == serviceTypeIcon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    caregiverId,
    serviceTypeId,
    rateType,
    rateAmount,
    currency,
    description,
    durationMinutes,
    const DeepCollectionEquality().hash(_includes),
    additionalPetRate,
    isAvailable,
    createdAt,
    updatedAt,
    serviceTypeName,
    serviceTypeDisplayName,
    serviceTypeIcon,
  );

  /// Create a copy of CaregiverService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaregiverServiceImplCopyWith<_$CaregiverServiceImpl> get copyWith =>
      __$$CaregiverServiceImplCopyWithImpl<_$CaregiverServiceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CaregiverServiceImplToJson(this);
  }
}

abstract class _CaregiverService implements CaregiverService {
  const factory _CaregiverService({
    required final String id,
    required final String caregiverId,
    required final String serviceTypeId,
    final String rateType,
    required final double rateAmount,
    final String currency,
    final String? description,
    final int? durationMinutes,
    final List<String> includes,
    final double additionalPetRate,
    final bool isAvailable,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? serviceTypeName,
    final String? serviceTypeDisplayName,
    final String? serviceTypeIcon,
  }) = _$CaregiverServiceImpl;

  factory _CaregiverService.fromJson(Map<String, dynamic> json) =
      _$CaregiverServiceImpl.fromJson;

  @override
  String get id;
  @override
  String get caregiverId;
  @override
  String get serviceTypeId;
  @override
  String get rateType;
  @override
  double get rateAmount;
  @override
  String get currency;
  @override
  String? get description;
  @override
  int? get durationMinutes;
  @override
  List<String> get includes;
  @override
  double get additionalPetRate;
  @override
  bool get isAvailable;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Joined fields
  @override
  String? get serviceTypeName;
  @override
  String? get serviceTypeDisplayName;
  @override
  String? get serviceTypeIcon;

  /// Create a copy of CaregiverService
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaregiverServiceImplCopyWith<_$CaregiverServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AddCaregiverServiceRequest _$AddCaregiverServiceRequestFromJson(
  Map<String, dynamic> json,
) {
  return _AddCaregiverServiceRequest.fromJson(json);
}

/// @nodoc
mixin _$AddCaregiverServiceRequest {
  String get serviceTypeId => throw _privateConstructorUsedError;
  String get rateType => throw _privateConstructorUsedError;
  double get rateAmount => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  List<String>? get includes => throw _privateConstructorUsedError;
  double? get additionalPetRate => throw _privateConstructorUsedError;

  /// Serializes this AddCaregiverServiceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddCaregiverServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddCaregiverServiceRequestCopyWith<AddCaregiverServiceRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddCaregiverServiceRequestCopyWith<$Res> {
  factory $AddCaregiverServiceRequestCopyWith(
    AddCaregiverServiceRequest value,
    $Res Function(AddCaregiverServiceRequest) then,
  ) =
      _$AddCaregiverServiceRequestCopyWithImpl<
        $Res,
        AddCaregiverServiceRequest
      >;
  @useResult
  $Res call({
    String serviceTypeId,
    String rateType,
    double rateAmount,
    String? description,
    int? durationMinutes,
    List<String>? includes,
    double? additionalPetRate,
  });
}

/// @nodoc
class _$AddCaregiverServiceRequestCopyWithImpl<
  $Res,
  $Val extends AddCaregiverServiceRequest
>
    implements $AddCaregiverServiceRequestCopyWith<$Res> {
  _$AddCaregiverServiceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddCaregiverServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceTypeId = null,
    Object? rateType = null,
    Object? rateAmount = null,
    Object? description = freezed,
    Object? durationMinutes = freezed,
    Object? includes = freezed,
    Object? additionalPetRate = freezed,
  }) {
    return _then(
      _value.copyWith(
            serviceTypeId:
                null == serviceTypeId
                    ? _value.serviceTypeId
                    : serviceTypeId // ignore: cast_nullable_to_non_nullable
                        as String,
            rateType:
                null == rateType
                    ? _value.rateType
                    : rateType // ignore: cast_nullable_to_non_nullable
                        as String,
            rateAmount:
                null == rateAmount
                    ? _value.rateAmount
                    : rateAmount // ignore: cast_nullable_to_non_nullable
                        as double,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            durationMinutes:
                freezed == durationMinutes
                    ? _value.durationMinutes
                    : durationMinutes // ignore: cast_nullable_to_non_nullable
                        as int?,
            includes:
                freezed == includes
                    ? _value.includes
                    : includes // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            additionalPetRate:
                freezed == additionalPetRate
                    ? _value.additionalPetRate
                    : additionalPetRate // ignore: cast_nullable_to_non_nullable
                        as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddCaregiverServiceRequestImplCopyWith<$Res>
    implements $AddCaregiverServiceRequestCopyWith<$Res> {
  factory _$$AddCaregiverServiceRequestImplCopyWith(
    _$AddCaregiverServiceRequestImpl value,
    $Res Function(_$AddCaregiverServiceRequestImpl) then,
  ) = __$$AddCaregiverServiceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String serviceTypeId,
    String rateType,
    double rateAmount,
    String? description,
    int? durationMinutes,
    List<String>? includes,
    double? additionalPetRate,
  });
}

/// @nodoc
class __$$AddCaregiverServiceRequestImplCopyWithImpl<$Res>
    extends
        _$AddCaregiverServiceRequestCopyWithImpl<
          $Res,
          _$AddCaregiverServiceRequestImpl
        >
    implements _$$AddCaregiverServiceRequestImplCopyWith<$Res> {
  __$$AddCaregiverServiceRequestImplCopyWithImpl(
    _$AddCaregiverServiceRequestImpl _value,
    $Res Function(_$AddCaregiverServiceRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddCaregiverServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceTypeId = null,
    Object? rateType = null,
    Object? rateAmount = null,
    Object? description = freezed,
    Object? durationMinutes = freezed,
    Object? includes = freezed,
    Object? additionalPetRate = freezed,
  }) {
    return _then(
      _$AddCaregiverServiceRequestImpl(
        serviceTypeId:
            null == serviceTypeId
                ? _value.serviceTypeId
                : serviceTypeId // ignore: cast_nullable_to_non_nullable
                    as String,
        rateType:
            null == rateType
                ? _value.rateType
                : rateType // ignore: cast_nullable_to_non_nullable
                    as String,
        rateAmount:
            null == rateAmount
                ? _value.rateAmount
                : rateAmount // ignore: cast_nullable_to_non_nullable
                    as double,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        durationMinutes:
            freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                    as int?,
        includes:
            freezed == includes
                ? _value._includes
                : includes // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        additionalPetRate:
            freezed == additionalPetRate
                ? _value.additionalPetRate
                : additionalPetRate // ignore: cast_nullable_to_non_nullable
                    as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AddCaregiverServiceRequestImpl implements _AddCaregiverServiceRequest {
  const _$AddCaregiverServiceRequestImpl({
    required this.serviceTypeId,
    this.rateType = 'hourly',
    required this.rateAmount,
    this.description,
    this.durationMinutes,
    final List<String>? includes,
    this.additionalPetRate,
  }) : _includes = includes;

  factory _$AddCaregiverServiceRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$AddCaregiverServiceRequestImplFromJson(json);

  @override
  final String serviceTypeId;
  @override
  @JsonKey()
  final String rateType;
  @override
  final double rateAmount;
  @override
  final String? description;
  @override
  final int? durationMinutes;
  final List<String>? _includes;
  @override
  List<String>? get includes {
    final value = _includes;
    if (value == null) return null;
    if (_includes is EqualUnmodifiableListView) return _includes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? additionalPetRate;

  @override
  String toString() {
    return 'AddCaregiverServiceRequest(serviceTypeId: $serviceTypeId, rateType: $rateType, rateAmount: $rateAmount, description: $description, durationMinutes: $durationMinutes, includes: $includes, additionalPetRate: $additionalPetRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddCaregiverServiceRequestImpl &&
            (identical(other.serviceTypeId, serviceTypeId) ||
                other.serviceTypeId == serviceTypeId) &&
            (identical(other.rateType, rateType) ||
                other.rateType == rateType) &&
            (identical(other.rateAmount, rateAmount) ||
                other.rateAmount == rateAmount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            const DeepCollectionEquality().equals(other._includes, _includes) &&
            (identical(other.additionalPetRate, additionalPetRate) ||
                other.additionalPetRate == additionalPetRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    serviceTypeId,
    rateType,
    rateAmount,
    description,
    durationMinutes,
    const DeepCollectionEquality().hash(_includes),
    additionalPetRate,
  );

  /// Create a copy of AddCaregiverServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddCaregiverServiceRequestImplCopyWith<_$AddCaregiverServiceRequestImpl>
  get copyWith => __$$AddCaregiverServiceRequestImplCopyWithImpl<
    _$AddCaregiverServiceRequestImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddCaregiverServiceRequestImplToJson(this);
  }
}

abstract class _AddCaregiverServiceRequest
    implements AddCaregiverServiceRequest {
  const factory _AddCaregiverServiceRequest({
    required final String serviceTypeId,
    final String rateType,
    required final double rateAmount,
    final String? description,
    final int? durationMinutes,
    final List<String>? includes,
    final double? additionalPetRate,
  }) = _$AddCaregiverServiceRequestImpl;

  factory _AddCaregiverServiceRequest.fromJson(Map<String, dynamic> json) =
      _$AddCaregiverServiceRequestImpl.fromJson;

  @override
  String get serviceTypeId;
  @override
  String get rateType;
  @override
  double get rateAmount;
  @override
  String? get description;
  @override
  int? get durationMinutes;
  @override
  List<String>? get includes;
  @override
  double? get additionalPetRate;

  /// Create a copy of AddCaregiverServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddCaregiverServiceRequestImplCopyWith<_$AddCaregiverServiceRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CaregiverAvailability _$CaregiverAvailabilityFromJson(
  Map<String, dynamic> json,
) {
  return _CaregiverAvailability.fromJson(json);
}

/// @nodoc
mixin _$CaregiverAvailability {
  String get id => throw _privateConstructorUsedError;
  String get caregiverId => throw _privateConstructorUsedError;
  int get dayOfWeek =>
      throw _privateConstructorUsedError; // 0=Sunday, 6=Saturday
  String get startTime => throw _privateConstructorUsedError; // "HH:mm"
  String get endTime => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CaregiverAvailability to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CaregiverAvailability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaregiverAvailabilityCopyWith<CaregiverAvailability> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaregiverAvailabilityCopyWith<$Res> {
  factory $CaregiverAvailabilityCopyWith(
    CaregiverAvailability value,
    $Res Function(CaregiverAvailability) then,
  ) = _$CaregiverAvailabilityCopyWithImpl<$Res, CaregiverAvailability>;
  @useResult
  $Res call({
    String id,
    String caregiverId,
    int dayOfWeek,
    String startTime,
    String endTime,
    bool isAvailable,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CaregiverAvailabilityCopyWithImpl<
  $Res,
  $Val extends CaregiverAvailability
>
    implements $CaregiverAvailabilityCopyWith<$Res> {
  _$CaregiverAvailabilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaregiverAvailability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? caregiverId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            caregiverId:
                null == caregiverId
                    ? _value.caregiverId
                    : caregiverId // ignore: cast_nullable_to_non_nullable
                        as String,
            dayOfWeek:
                null == dayOfWeek
                    ? _value.dayOfWeek
                    : dayOfWeek // ignore: cast_nullable_to_non_nullable
                        as int,
            startTime:
                null == startTime
                    ? _value.startTime
                    : startTime // ignore: cast_nullable_to_non_nullable
                        as String,
            endTime:
                null == endTime
                    ? _value.endTime
                    : endTime // ignore: cast_nullable_to_non_nullable
                        as String,
            isAvailable:
                null == isAvailable
                    ? _value.isAvailable
                    : isAvailable // ignore: cast_nullable_to_non_nullable
                        as bool,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaregiverAvailabilityImplCopyWith<$Res>
    implements $CaregiverAvailabilityCopyWith<$Res> {
  factory _$$CaregiverAvailabilityImplCopyWith(
    _$CaregiverAvailabilityImpl value,
    $Res Function(_$CaregiverAvailabilityImpl) then,
  ) = __$$CaregiverAvailabilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String caregiverId,
    int dayOfWeek,
    String startTime,
    String endTime,
    bool isAvailable,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CaregiverAvailabilityImplCopyWithImpl<$Res>
    extends
        _$CaregiverAvailabilityCopyWithImpl<$Res, _$CaregiverAvailabilityImpl>
    implements _$$CaregiverAvailabilityImplCopyWith<$Res> {
  __$$CaregiverAvailabilityImplCopyWithImpl(
    _$CaregiverAvailabilityImpl _value,
    $Res Function(_$CaregiverAvailabilityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaregiverAvailability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? caregiverId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CaregiverAvailabilityImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        caregiverId:
            null == caregiverId
                ? _value.caregiverId
                : caregiverId // ignore: cast_nullable_to_non_nullable
                    as String,
        dayOfWeek:
            null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                    as int,
        startTime:
            null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                    as String,
        endTime:
            null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                    as String,
        isAvailable:
            null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                    as bool,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CaregiverAvailabilityImpl implements _CaregiverAvailability {
  const _$CaregiverAvailabilityImpl({
    required this.id,
    required this.caregiverId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.createdAt,
  });

  factory _$CaregiverAvailabilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaregiverAvailabilityImplFromJson(json);

  @override
  final String id;
  @override
  final String caregiverId;
  @override
  final int dayOfWeek;
  // 0=Sunday, 6=Saturday
  @override
  final String startTime;
  // "HH:mm"
  @override
  final String endTime;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CaregiverAvailability(id: $id, caregiverId: $caregiverId, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, isAvailable: $isAvailable, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaregiverAvailabilityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.caregiverId, caregiverId) ||
                other.caregiverId == caregiverId) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    caregiverId,
    dayOfWeek,
    startTime,
    endTime,
    isAvailable,
    createdAt,
  );

  /// Create a copy of CaregiverAvailability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaregiverAvailabilityImplCopyWith<_$CaregiverAvailabilityImpl>
  get copyWith =>
      __$$CaregiverAvailabilityImplCopyWithImpl<_$CaregiverAvailabilityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CaregiverAvailabilityImplToJson(this);
  }
}

abstract class _CaregiverAvailability implements CaregiverAvailability {
  const factory _CaregiverAvailability({
    required final String id,
    required final String caregiverId,
    required final int dayOfWeek,
    required final String startTime,
    required final String endTime,
    final bool isAvailable,
    final DateTime? createdAt,
  }) = _$CaregiverAvailabilityImpl;

  factory _CaregiverAvailability.fromJson(Map<String, dynamic> json) =
      _$CaregiverAvailabilityImpl.fromJson;

  @override
  String get id;
  @override
  String get caregiverId;
  @override
  int get dayOfWeek; // 0=Sunday, 6=Saturday
  @override
  String get startTime; // "HH:mm"
  @override
  String get endTime;
  @override
  bool get isAvailable;
  @override
  DateTime? get createdAt;

  /// Create a copy of CaregiverAvailability
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaregiverAvailabilityImplCopyWith<_$CaregiverAvailabilityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AvailabilitySlot _$AvailabilitySlotFromJson(Map<String, dynamic> json) {
  return _AvailabilitySlot.fromJson(json);
}

/// @nodoc
mixin _$AvailabilitySlot {
  int get dayOfWeek => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;

  /// Serializes this AvailabilitySlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AvailabilitySlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailabilitySlotCopyWith<AvailabilitySlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvailabilitySlotCopyWith<$Res> {
  factory $AvailabilitySlotCopyWith(
    AvailabilitySlot value,
    $Res Function(AvailabilitySlot) then,
  ) = _$AvailabilitySlotCopyWithImpl<$Res, AvailabilitySlot>;
  @useResult
  $Res call({
    int dayOfWeek,
    String startTime,
    String endTime,
    bool isAvailable,
  });
}

/// @nodoc
class _$AvailabilitySlotCopyWithImpl<$Res, $Val extends AvailabilitySlot>
    implements $AvailabilitySlotCopyWith<$Res> {
  _$AvailabilitySlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvailabilitySlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
  }) {
    return _then(
      _value.copyWith(
            dayOfWeek:
                null == dayOfWeek
                    ? _value.dayOfWeek
                    : dayOfWeek // ignore: cast_nullable_to_non_nullable
                        as int,
            startTime:
                null == startTime
                    ? _value.startTime
                    : startTime // ignore: cast_nullable_to_non_nullable
                        as String,
            endTime:
                null == endTime
                    ? _value.endTime
                    : endTime // ignore: cast_nullable_to_non_nullable
                        as String,
            isAvailable:
                null == isAvailable
                    ? _value.isAvailable
                    : isAvailable // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AvailabilitySlotImplCopyWith<$Res>
    implements $AvailabilitySlotCopyWith<$Res> {
  factory _$$AvailabilitySlotImplCopyWith(
    _$AvailabilitySlotImpl value,
    $Res Function(_$AvailabilitySlotImpl) then,
  ) = __$$AvailabilitySlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int dayOfWeek,
    String startTime,
    String endTime,
    bool isAvailable,
  });
}

/// @nodoc
class __$$AvailabilitySlotImplCopyWithImpl<$Res>
    extends _$AvailabilitySlotCopyWithImpl<$Res, _$AvailabilitySlotImpl>
    implements _$$AvailabilitySlotImplCopyWith<$Res> {
  __$$AvailabilitySlotImplCopyWithImpl(
    _$AvailabilitySlotImpl _value,
    $Res Function(_$AvailabilitySlotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AvailabilitySlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
  }) {
    return _then(
      _$AvailabilitySlotImpl(
        dayOfWeek:
            null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                    as int,
        startTime:
            null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                    as String,
        endTime:
            null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                    as String,
        isAvailable:
            null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AvailabilitySlotImpl implements _AvailabilitySlot {
  const _$AvailabilitySlotImpl({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  factory _$AvailabilitySlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvailabilitySlotImplFromJson(json);

  @override
  final int dayOfWeek;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  @JsonKey()
  final bool isAvailable;

  @override
  String toString() {
    return 'AvailabilitySlot(dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailabilitySlotImpl &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, dayOfWeek, startTime, endTime, isAvailable);

  /// Create a copy of AvailabilitySlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailabilitySlotImplCopyWith<_$AvailabilitySlotImpl> get copyWith =>
      __$$AvailabilitySlotImplCopyWithImpl<_$AvailabilitySlotImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailabilitySlotImplToJson(this);
  }
}

abstract class _AvailabilitySlot implements AvailabilitySlot {
  const factory _AvailabilitySlot({
    required final int dayOfWeek,
    required final String startTime,
    required final String endTime,
    final bool isAvailable,
  }) = _$AvailabilitySlotImpl;

  factory _AvailabilitySlot.fromJson(Map<String, dynamic> json) =
      _$AvailabilitySlotImpl.fromJson;

  @override
  int get dayOfWeek;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  bool get isAvailable;

  /// Create a copy of AvailabilitySlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailabilitySlotImplCopyWith<_$AvailabilitySlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SetAvailabilityRequest _$SetAvailabilityRequestFromJson(
  Map<String, dynamic> json,
) {
  return _SetAvailabilityRequest.fromJson(json);
}

/// @nodoc
mixin _$SetAvailabilityRequest {
  List<AvailabilitySlot> get slots => throw _privateConstructorUsedError;

  /// Serializes this SetAvailabilityRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetAvailabilityRequestCopyWith<SetAvailabilityRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetAvailabilityRequestCopyWith<$Res> {
  factory $SetAvailabilityRequestCopyWith(
    SetAvailabilityRequest value,
    $Res Function(SetAvailabilityRequest) then,
  ) = _$SetAvailabilityRequestCopyWithImpl<$Res, SetAvailabilityRequest>;
  @useResult
  $Res call({List<AvailabilitySlot> slots});
}

/// @nodoc
class _$SetAvailabilityRequestCopyWithImpl<
  $Res,
  $Val extends SetAvailabilityRequest
>
    implements $SetAvailabilityRequestCopyWith<$Res> {
  _$SetAvailabilityRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slots = null}) {
    return _then(
      _value.copyWith(
            slots:
                null == slots
                    ? _value.slots
                    : slots // ignore: cast_nullable_to_non_nullable
                        as List<AvailabilitySlot>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SetAvailabilityRequestImplCopyWith<$Res>
    implements $SetAvailabilityRequestCopyWith<$Res> {
  factory _$$SetAvailabilityRequestImplCopyWith(
    _$SetAvailabilityRequestImpl value,
    $Res Function(_$SetAvailabilityRequestImpl) then,
  ) = __$$SetAvailabilityRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AvailabilitySlot> slots});
}

/// @nodoc
class __$$SetAvailabilityRequestImplCopyWithImpl<$Res>
    extends
        _$SetAvailabilityRequestCopyWithImpl<$Res, _$SetAvailabilityRequestImpl>
    implements _$$SetAvailabilityRequestImplCopyWith<$Res> {
  __$$SetAvailabilityRequestImplCopyWithImpl(
    _$SetAvailabilityRequestImpl _value,
    $Res Function(_$SetAvailabilityRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? slots = null}) {
    return _then(
      _$SetAvailabilityRequestImpl(
        slots:
            null == slots
                ? _value._slots
                : slots // ignore: cast_nullable_to_non_nullable
                    as List<AvailabilitySlot>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SetAvailabilityRequestImpl implements _SetAvailabilityRequest {
  const _$SetAvailabilityRequestImpl({
    required final List<AvailabilitySlot> slots,
  }) : _slots = slots;

  factory _$SetAvailabilityRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetAvailabilityRequestImplFromJson(json);

  final List<AvailabilitySlot> _slots;
  @override
  List<AvailabilitySlot> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  @override
  String toString() {
    return 'SetAvailabilityRequest(slots: $slots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetAvailabilityRequestImpl &&
            const DeepCollectionEquality().equals(other._slots, _slots));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_slots));

  /// Create a copy of SetAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetAvailabilityRequestImplCopyWith<_$SetAvailabilityRequestImpl>
  get copyWith =>
      __$$SetAvailabilityRequestImplCopyWithImpl<_$SetAvailabilityRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SetAvailabilityRequestImplToJson(this);
  }
}

abstract class _SetAvailabilityRequest implements SetAvailabilityRequest {
  const factory _SetAvailabilityRequest({
    required final List<AvailabilitySlot> slots,
  }) = _$SetAvailabilityRequestImpl;

  factory _SetAvailabilityRequest.fromJson(Map<String, dynamic> json) =
      _$SetAvailabilityRequestImpl.fromJson;

  @override
  List<AvailabilitySlot> get slots;

  /// Create a copy of SetAvailabilityRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetAvailabilityRequestImplCopyWith<_$SetAvailabilityRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CaregiverBlockedDate _$CaregiverBlockedDateFromJson(Map<String, dynamic> json) {
  return _CaregiverBlockedDate.fromJson(json);
}

/// @nodoc
mixin _$CaregiverBlockedDate {
  String get id => throw _privateConstructorUsedError;
  String get caregiverId => throw _privateConstructorUsedError;
  String get blockedDate => throw _privateConstructorUsedError; // "YYYY-MM-DD"
  String? get reason => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CaregiverBlockedDate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CaregiverBlockedDate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaregiverBlockedDateCopyWith<CaregiverBlockedDate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaregiverBlockedDateCopyWith<$Res> {
  factory $CaregiverBlockedDateCopyWith(
    CaregiverBlockedDate value,
    $Res Function(CaregiverBlockedDate) then,
  ) = _$CaregiverBlockedDateCopyWithImpl<$Res, CaregiverBlockedDate>;
  @useResult
  $Res call({
    String id,
    String caregiverId,
    String blockedDate,
    String? reason,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CaregiverBlockedDateCopyWithImpl<
  $Res,
  $Val extends CaregiverBlockedDate
>
    implements $CaregiverBlockedDateCopyWith<$Res> {
  _$CaregiverBlockedDateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaregiverBlockedDate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? caregiverId = null,
    Object? blockedDate = null,
    Object? reason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            caregiverId:
                null == caregiverId
                    ? _value.caregiverId
                    : caregiverId // ignore: cast_nullable_to_non_nullable
                        as String,
            blockedDate:
                null == blockedDate
                    ? _value.blockedDate
                    : blockedDate // ignore: cast_nullable_to_non_nullable
                        as String,
            reason:
                freezed == reason
                    ? _value.reason
                    : reason // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaregiverBlockedDateImplCopyWith<$Res>
    implements $CaregiverBlockedDateCopyWith<$Res> {
  factory _$$CaregiverBlockedDateImplCopyWith(
    _$CaregiverBlockedDateImpl value,
    $Res Function(_$CaregiverBlockedDateImpl) then,
  ) = __$$CaregiverBlockedDateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String caregiverId,
    String blockedDate,
    String? reason,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CaregiverBlockedDateImplCopyWithImpl<$Res>
    extends _$CaregiverBlockedDateCopyWithImpl<$Res, _$CaregiverBlockedDateImpl>
    implements _$$CaregiverBlockedDateImplCopyWith<$Res> {
  __$$CaregiverBlockedDateImplCopyWithImpl(
    _$CaregiverBlockedDateImpl _value,
    $Res Function(_$CaregiverBlockedDateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaregiverBlockedDate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? caregiverId = null,
    Object? blockedDate = null,
    Object? reason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CaregiverBlockedDateImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        caregiverId:
            null == caregiverId
                ? _value.caregiverId
                : caregiverId // ignore: cast_nullable_to_non_nullable
                    as String,
        blockedDate:
            null == blockedDate
                ? _value.blockedDate
                : blockedDate // ignore: cast_nullable_to_non_nullable
                    as String,
        reason:
            freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CaregiverBlockedDateImpl implements _CaregiverBlockedDate {
  const _$CaregiverBlockedDateImpl({
    required this.id,
    required this.caregiverId,
    required this.blockedDate,
    this.reason,
    this.createdAt,
  });

  factory _$CaregiverBlockedDateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaregiverBlockedDateImplFromJson(json);

  @override
  final String id;
  @override
  final String caregiverId;
  @override
  final String blockedDate;
  // "YYYY-MM-DD"
  @override
  final String? reason;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CaregiverBlockedDate(id: $id, caregiverId: $caregiverId, blockedDate: $blockedDate, reason: $reason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaregiverBlockedDateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.caregiverId, caregiverId) ||
                other.caregiverId == caregiverId) &&
            (identical(other.blockedDate, blockedDate) ||
                other.blockedDate == blockedDate) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, caregiverId, blockedDate, reason, createdAt);

  /// Create a copy of CaregiverBlockedDate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaregiverBlockedDateImplCopyWith<_$CaregiverBlockedDateImpl>
  get copyWith =>
      __$$CaregiverBlockedDateImplCopyWithImpl<_$CaregiverBlockedDateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CaregiverBlockedDateImplToJson(this);
  }
}

abstract class _CaregiverBlockedDate implements CaregiverBlockedDate {
  const factory _CaregiverBlockedDate({
    required final String id,
    required final String caregiverId,
    required final String blockedDate,
    final String? reason,
    final DateTime? createdAt,
  }) = _$CaregiverBlockedDateImpl;

  factory _CaregiverBlockedDate.fromJson(Map<String, dynamic> json) =
      _$CaregiverBlockedDateImpl.fromJson;

  @override
  String get id;
  @override
  String get caregiverId;
  @override
  String get blockedDate; // "YYYY-MM-DD"
  @override
  String? get reason;
  @override
  DateTime? get createdAt;

  /// Create a copy of CaregiverBlockedDate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaregiverBlockedDateImplCopyWith<_$CaregiverBlockedDateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CaregiverGalleryItem _$CaregiverGalleryItemFromJson(Map<String, dynamic> json) {
  return _CaregiverGalleryItem.fromJson(json);
}

/// @nodoc
mixin _$CaregiverGalleryItem {
  String get id => throw _privateConstructorUsedError;
  String get caregiverId => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  String get imageType => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CaregiverGalleryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CaregiverGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaregiverGalleryItemCopyWith<CaregiverGalleryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaregiverGalleryItemCopyWith<$Res> {
  factory $CaregiverGalleryItemCopyWith(
    CaregiverGalleryItem value,
    $Res Function(CaregiverGalleryItem) then,
  ) = _$CaregiverGalleryItemCopyWithImpl<$Res, CaregiverGalleryItem>;
  @useResult
  $Res call({
    String id,
    String caregiverId,
    String imageUrl,
    String? caption,
    String imageType,
    int displayOrder,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CaregiverGalleryItemCopyWithImpl<
  $Res,
  $Val extends CaregiverGalleryItem
>
    implements $CaregiverGalleryItemCopyWith<$Res> {
  _$CaregiverGalleryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaregiverGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? caregiverId = null,
    Object? imageUrl = null,
    Object? caption = freezed,
    Object? imageType = null,
    Object? displayOrder = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            caregiverId:
                null == caregiverId
                    ? _value.caregiverId
                    : caregiverId // ignore: cast_nullable_to_non_nullable
                        as String,
            imageUrl:
                null == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            caption:
                freezed == caption
                    ? _value.caption
                    : caption // ignore: cast_nullable_to_non_nullable
                        as String?,
            imageType:
                null == imageType
                    ? _value.imageType
                    : imageType // ignore: cast_nullable_to_non_nullable
                        as String,
            displayOrder:
                null == displayOrder
                    ? _value.displayOrder
                    : displayOrder // ignore: cast_nullable_to_non_nullable
                        as int,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaregiverGalleryItemImplCopyWith<$Res>
    implements $CaregiverGalleryItemCopyWith<$Res> {
  factory _$$CaregiverGalleryItemImplCopyWith(
    _$CaregiverGalleryItemImpl value,
    $Res Function(_$CaregiverGalleryItemImpl) then,
  ) = __$$CaregiverGalleryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String caregiverId,
    String imageUrl,
    String? caption,
    String imageType,
    int displayOrder,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CaregiverGalleryItemImplCopyWithImpl<$Res>
    extends _$CaregiverGalleryItemCopyWithImpl<$Res, _$CaregiverGalleryItemImpl>
    implements _$$CaregiverGalleryItemImplCopyWith<$Res> {
  __$$CaregiverGalleryItemImplCopyWithImpl(
    _$CaregiverGalleryItemImpl _value,
    $Res Function(_$CaregiverGalleryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaregiverGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? caregiverId = null,
    Object? imageUrl = null,
    Object? caption = freezed,
    Object? imageType = null,
    Object? displayOrder = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CaregiverGalleryItemImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        caregiverId:
            null == caregiverId
                ? _value.caregiverId
                : caregiverId // ignore: cast_nullable_to_non_nullable
                    as String,
        imageUrl:
            null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        caption:
            freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                    as String?,
        imageType:
            null == imageType
                ? _value.imageType
                : imageType // ignore: cast_nullable_to_non_nullable
                    as String,
        displayOrder:
            null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                    as int,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CaregiverGalleryItemImpl implements _CaregiverGalleryItem {
  const _$CaregiverGalleryItemImpl({
    required this.id,
    required this.caregiverId,
    required this.imageUrl,
    this.caption,
    this.imageType = 'gallery',
    this.displayOrder = 0,
    this.createdAt,
  });

  factory _$CaregiverGalleryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CaregiverGalleryItemImplFromJson(json);

  @override
  final String id;
  @override
  final String caregiverId;
  @override
  final String imageUrl;
  @override
  final String? caption;
  @override
  @JsonKey()
  final String imageType;
  @override
  @JsonKey()
  final int displayOrder;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CaregiverGalleryItem(id: $id, caregiverId: $caregiverId, imageUrl: $imageUrl, caption: $caption, imageType: $imageType, displayOrder: $displayOrder, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaregiverGalleryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.caregiverId, caregiverId) ||
                other.caregiverId == caregiverId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.imageType, imageType) ||
                other.imageType == imageType) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    caregiverId,
    imageUrl,
    caption,
    imageType,
    displayOrder,
    createdAt,
  );

  /// Create a copy of CaregiverGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaregiverGalleryItemImplCopyWith<_$CaregiverGalleryItemImpl>
  get copyWith =>
      __$$CaregiverGalleryItemImplCopyWithImpl<_$CaregiverGalleryItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CaregiverGalleryItemImplToJson(this);
  }
}

abstract class _CaregiverGalleryItem implements CaregiverGalleryItem {
  const factory _CaregiverGalleryItem({
    required final String id,
    required final String caregiverId,
    required final String imageUrl,
    final String? caption,
    final String imageType,
    final int displayOrder,
    final DateTime? createdAt,
  }) = _$CaregiverGalleryItemImpl;

  factory _CaregiverGalleryItem.fromJson(Map<String, dynamic> json) =
      _$CaregiverGalleryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get caregiverId;
  @override
  String get imageUrl;
  @override
  String? get caption;
  @override
  String get imageType;
  @override
  int get displayOrder;
  @override
  DateTime? get createdAt;

  /// Create a copy of CaregiverGalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaregiverGalleryItemImplCopyWith<_$CaregiverGalleryItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}
