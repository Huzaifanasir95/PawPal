// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vet_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VetProfile _$VetProfileFromJson(Map<String, dynamic> json) {
  return _VetProfile.fromJson(json);
}

/// @nodoc
mixin _$VetProfile {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get degree => throw _privateConstructorUsedError;
  String? get licenseNumber => throw _privateConstructorUsedError;
  List<String> get specialization => throw _privateConstructorUsedError;
  int get experience => throw _privateConstructorUsedError;
  String? get clinicName => throw _privateConstructorUsedError;
  String? get clinicAddress => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get zipCode => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  double get consultationFee => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get profilePhotoUrl => throw _privateConstructorUsedError;
  String? get availabilityHours => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get totalReviews => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VetProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VetProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VetProfileCopyWith<VetProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VetProfileCopyWith<$Res> {
  factory $VetProfileCopyWith(
    VetProfile value,
    $Res Function(VetProfile) then,
  ) = _$VetProfileCopyWithImpl<$Res, VetProfile>;
  @useResult
  $Res call({
    String id,
    String userId,
    String fullName,
    String degree,
    String? licenseNumber,
    List<String> specialization,
    int experience,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? state,
    String? zipCode,
    String phone,
    double consultationFee,
    String currency,
    String? bio,
    String? profilePhotoUrl,
    String? availabilityHours,
    double rating,
    int totalReviews,
    bool isVerified,
    bool isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$VetProfileCopyWithImpl<$Res, $Val extends VetProfile>
    implements $VetProfileCopyWith<$Res> {
  _$VetProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VetProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fullName = null,
    Object? degree = null,
    Object? licenseNumber = freezed,
    Object? specialization = null,
    Object? experience = null,
    Object? clinicName = freezed,
    Object? clinicAddress = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? zipCode = freezed,
    Object? phone = null,
    Object? consultationFee = null,
    Object? currency = null,
    Object? bio = freezed,
    Object? profilePhotoUrl = freezed,
    Object? availabilityHours = freezed,
    Object? rating = null,
    Object? totalReviews = null,
    Object? isVerified = null,
    Object? isAvailable = null,
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
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            fullName:
                null == fullName
                    ? _value.fullName
                    : fullName // ignore: cast_nullable_to_non_nullable
                        as String,
            degree:
                null == degree
                    ? _value.degree
                    : degree // ignore: cast_nullable_to_non_nullable
                        as String,
            licenseNumber:
                freezed == licenseNumber
                    ? _value.licenseNumber
                    : licenseNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            specialization:
                null == specialization
                    ? _value.specialization
                    : specialization // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            experience:
                null == experience
                    ? _value.experience
                    : experience // ignore: cast_nullable_to_non_nullable
                        as int,
            clinicName:
                freezed == clinicName
                    ? _value.clinicName
                    : clinicName // ignore: cast_nullable_to_non_nullable
                        as String?,
            clinicAddress:
                freezed == clinicAddress
                    ? _value.clinicAddress
                    : clinicAddress // ignore: cast_nullable_to_non_nullable
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
            zipCode:
                freezed == zipCode
                    ? _value.zipCode
                    : zipCode // ignore: cast_nullable_to_non_nullable
                        as String?,
            phone:
                null == phone
                    ? _value.phone
                    : phone // ignore: cast_nullable_to_non_nullable
                        as String,
            consultationFee:
                null == consultationFee
                    ? _value.consultationFee
                    : consultationFee // ignore: cast_nullable_to_non_nullable
                        as double,
            currency:
                null == currency
                    ? _value.currency
                    : currency // ignore: cast_nullable_to_non_nullable
                        as String,
            bio:
                freezed == bio
                    ? _value.bio
                    : bio // ignore: cast_nullable_to_non_nullable
                        as String?,
            profilePhotoUrl:
                freezed == profilePhotoUrl
                    ? _value.profilePhotoUrl
                    : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            availabilityHours:
                freezed == availabilityHours
                    ? _value.availabilityHours
                    : availabilityHours // ignore: cast_nullable_to_non_nullable
                        as String?,
            rating:
                null == rating
                    ? _value.rating
                    : rating // ignore: cast_nullable_to_non_nullable
                        as double,
            totalReviews:
                null == totalReviews
                    ? _value.totalReviews
                    : totalReviews // ignore: cast_nullable_to_non_nullable
                        as int,
            isVerified:
                null == isVerified
                    ? _value.isVerified
                    : isVerified // ignore: cast_nullable_to_non_nullable
                        as bool,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VetProfileImplCopyWith<$Res>
    implements $VetProfileCopyWith<$Res> {
  factory _$$VetProfileImplCopyWith(
    _$VetProfileImpl value,
    $Res Function(_$VetProfileImpl) then,
  ) = __$$VetProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String fullName,
    String degree,
    String? licenseNumber,
    List<String> specialization,
    int experience,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? state,
    String? zipCode,
    String phone,
    double consultationFee,
    String currency,
    String? bio,
    String? profilePhotoUrl,
    String? availabilityHours,
    double rating,
    int totalReviews,
    bool isVerified,
    bool isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$VetProfileImplCopyWithImpl<$Res>
    extends _$VetProfileCopyWithImpl<$Res, _$VetProfileImpl>
    implements _$$VetProfileImplCopyWith<$Res> {
  __$$VetProfileImplCopyWithImpl(
    _$VetProfileImpl _value,
    $Res Function(_$VetProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VetProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fullName = null,
    Object? degree = null,
    Object? licenseNumber = freezed,
    Object? specialization = null,
    Object? experience = null,
    Object? clinicName = freezed,
    Object? clinicAddress = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? zipCode = freezed,
    Object? phone = null,
    Object? consultationFee = null,
    Object? currency = null,
    Object? bio = freezed,
    Object? profilePhotoUrl = freezed,
    Object? availabilityHours = freezed,
    Object? rating = null,
    Object? totalReviews = null,
    Object? isVerified = null,
    Object? isAvailable = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$VetProfileImpl(
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
        fullName:
            null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                    as String,
        degree:
            null == degree
                ? _value.degree
                : degree // ignore: cast_nullable_to_non_nullable
                    as String,
        licenseNumber:
            freezed == licenseNumber
                ? _value.licenseNumber
                : licenseNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        specialization:
            null == specialization
                ? _value._specialization
                : specialization // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        experience:
            null == experience
                ? _value.experience
                : experience // ignore: cast_nullable_to_non_nullable
                    as int,
        clinicName:
            freezed == clinicName
                ? _value.clinicName
                : clinicName // ignore: cast_nullable_to_non_nullable
                    as String?,
        clinicAddress:
            freezed == clinicAddress
                ? _value.clinicAddress
                : clinicAddress // ignore: cast_nullable_to_non_nullable
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
        zipCode:
            freezed == zipCode
                ? _value.zipCode
                : zipCode // ignore: cast_nullable_to_non_nullable
                    as String?,
        phone:
            null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                    as String,
        consultationFee:
            null == consultationFee
                ? _value.consultationFee
                : consultationFee // ignore: cast_nullable_to_non_nullable
                    as double,
        currency:
            null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                    as String,
        bio:
            freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                    as String?,
        profilePhotoUrl:
            freezed == profilePhotoUrl
                ? _value.profilePhotoUrl
                : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        availabilityHours:
            freezed == availabilityHours
                ? _value.availabilityHours
                : availabilityHours // ignore: cast_nullable_to_non_nullable
                    as String?,
        rating:
            null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                    as double,
        totalReviews:
            null == totalReviews
                ? _value.totalReviews
                : totalReviews // ignore: cast_nullable_to_non_nullable
                    as int,
        isVerified:
            null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                    as bool,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VetProfileImpl implements _VetProfile {
  const _$VetProfileImpl({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.degree,
    this.licenseNumber,
    final List<String> specialization = const [],
    required this.experience,
    this.clinicName,
    this.clinicAddress,
    this.city,
    this.state,
    this.zipCode,
    required this.phone,
    required this.consultationFee,
    this.currency = 'USD',
    this.bio,
    this.profilePhotoUrl,
    this.availabilityHours,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isVerified = false,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  }) : _specialization = specialization;

  factory _$VetProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$VetProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String fullName;
  @override
  final String degree;
  @override
  final String? licenseNumber;
  final List<String> _specialization;
  @override
  @JsonKey()
  List<String> get specialization {
    if (_specialization is EqualUnmodifiableListView) return _specialization;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specialization);
  }

  @override
  final int experience;
  @override
  final String? clinicName;
  @override
  final String? clinicAddress;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? zipCode;
  @override
  final String phone;
  @override
  final double consultationFee;
  @override
  @JsonKey()
  final String currency;
  @override
  final String? bio;
  @override
  final String? profilePhotoUrl;
  @override
  final String? availabilityHours;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int totalReviews;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'VetProfile(id: $id, userId: $userId, fullName: $fullName, degree: $degree, licenseNumber: $licenseNumber, specialization: $specialization, experience: $experience, clinicName: $clinicName, clinicAddress: $clinicAddress, city: $city, state: $state, zipCode: $zipCode, phone: $phone, consultationFee: $consultationFee, currency: $currency, bio: $bio, profilePhotoUrl: $profilePhotoUrl, availabilityHours: $availabilityHours, rating: $rating, totalReviews: $totalReviews, isVerified: $isVerified, isAvailable: $isAvailable, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VetProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.degree, degree) || other.degree == degree) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            const DeepCollectionEquality().equals(
              other._specialization,
              _specialization,
            ) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.clinicName, clinicName) ||
                other.clinicName == clinicName) &&
            (identical(other.clinicAddress, clinicAddress) ||
                other.clinicAddress == clinicAddress) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.consultationFee, consultationFee) ||
                other.consultationFee == consultationFee) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl) &&
            (identical(other.availabilityHours, availabilityHours) ||
                other.availabilityHours == availabilityHours) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
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
    userId,
    fullName,
    degree,
    licenseNumber,
    const DeepCollectionEquality().hash(_specialization),
    experience,
    clinicName,
    clinicAddress,
    city,
    state,
    zipCode,
    phone,
    consultationFee,
    currency,
    bio,
    profilePhotoUrl,
    availabilityHours,
    rating,
    totalReviews,
    isVerified,
    isAvailable,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of VetProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VetProfileImplCopyWith<_$VetProfileImpl> get copyWith =>
      __$$VetProfileImplCopyWithImpl<_$VetProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VetProfileImplToJson(this);
  }
}

abstract class _VetProfile implements VetProfile {
  const factory _VetProfile({
    required final String id,
    required final String userId,
    required final String fullName,
    required final String degree,
    final String? licenseNumber,
    final List<String> specialization,
    required final int experience,
    final String? clinicName,
    final String? clinicAddress,
    final String? city,
    final String? state,
    final String? zipCode,
    required final String phone,
    required final double consultationFee,
    final String currency,
    final String? bio,
    final String? profilePhotoUrl,
    final String? availabilityHours,
    final double rating,
    final int totalReviews,
    final bool isVerified,
    final bool isAvailable,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$VetProfileImpl;

  factory _VetProfile.fromJson(Map<String, dynamic> json) =
      _$VetProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get fullName;
  @override
  String get degree;
  @override
  String? get licenseNumber;
  @override
  List<String> get specialization;
  @override
  int get experience;
  @override
  String? get clinicName;
  @override
  String? get clinicAddress;
  @override
  String? get city;
  @override
  String? get state;
  @override
  String? get zipCode;
  @override
  String get phone;
  @override
  double get consultationFee;
  @override
  String get currency;
  @override
  String? get bio;
  @override
  String? get profilePhotoUrl;
  @override
  String? get availabilityHours;
  @override
  double get rating;
  @override
  int get totalReviews;
  @override
  bool get isVerified;
  @override
  bool get isAvailable;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of VetProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VetProfileImplCopyWith<_$VetProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VetProfileRequest _$VetProfileRequestFromJson(Map<String, dynamic> json) {
  return _VetProfileRequest.fromJson(json);
}

/// @nodoc
mixin _$VetProfileRequest {
  String get fullName => throw _privateConstructorUsedError;
  String get degree => throw _privateConstructorUsedError;
  String? get licenseNumber => throw _privateConstructorUsedError;
  List<String> get specialization => throw _privateConstructorUsedError;
  int get experience => throw _privateConstructorUsedError;
  String? get clinicName => throw _privateConstructorUsedError;
  String? get clinicAddress => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get zipCode => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  double get consultationFee => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get profilePhotoUrl => throw _privateConstructorUsedError;
  String? get availabilityHours => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;

  /// Serializes this VetProfileRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VetProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VetProfileRequestCopyWith<VetProfileRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VetProfileRequestCopyWith<$Res> {
  factory $VetProfileRequestCopyWith(
    VetProfileRequest value,
    $Res Function(VetProfileRequest) then,
  ) = _$VetProfileRequestCopyWithImpl<$Res, VetProfileRequest>;
  @useResult
  $Res call({
    String fullName,
    String degree,
    String? licenseNumber,
    List<String> specialization,
    int experience,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? state,
    String? zipCode,
    String phone,
    double consultationFee,
    String currency,
    String? bio,
    String? profilePhotoUrl,
    String? availabilityHours,
    bool isAvailable,
  });
}

/// @nodoc
class _$VetProfileRequestCopyWithImpl<$Res, $Val extends VetProfileRequest>
    implements $VetProfileRequestCopyWith<$Res> {
  _$VetProfileRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VetProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? degree = null,
    Object? licenseNumber = freezed,
    Object? specialization = null,
    Object? experience = null,
    Object? clinicName = freezed,
    Object? clinicAddress = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? zipCode = freezed,
    Object? phone = null,
    Object? consultationFee = null,
    Object? currency = null,
    Object? bio = freezed,
    Object? profilePhotoUrl = freezed,
    Object? availabilityHours = freezed,
    Object? isAvailable = null,
  }) {
    return _then(
      _value.copyWith(
            fullName:
                null == fullName
                    ? _value.fullName
                    : fullName // ignore: cast_nullable_to_non_nullable
                        as String,
            degree:
                null == degree
                    ? _value.degree
                    : degree // ignore: cast_nullable_to_non_nullable
                        as String,
            licenseNumber:
                freezed == licenseNumber
                    ? _value.licenseNumber
                    : licenseNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            specialization:
                null == specialization
                    ? _value.specialization
                    : specialization // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            experience:
                null == experience
                    ? _value.experience
                    : experience // ignore: cast_nullable_to_non_nullable
                        as int,
            clinicName:
                freezed == clinicName
                    ? _value.clinicName
                    : clinicName // ignore: cast_nullable_to_non_nullable
                        as String?,
            clinicAddress:
                freezed == clinicAddress
                    ? _value.clinicAddress
                    : clinicAddress // ignore: cast_nullable_to_non_nullable
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
            zipCode:
                freezed == zipCode
                    ? _value.zipCode
                    : zipCode // ignore: cast_nullable_to_non_nullable
                        as String?,
            phone:
                null == phone
                    ? _value.phone
                    : phone // ignore: cast_nullable_to_non_nullable
                        as String,
            consultationFee:
                null == consultationFee
                    ? _value.consultationFee
                    : consultationFee // ignore: cast_nullable_to_non_nullable
                        as double,
            currency:
                null == currency
                    ? _value.currency
                    : currency // ignore: cast_nullable_to_non_nullable
                        as String,
            bio:
                freezed == bio
                    ? _value.bio
                    : bio // ignore: cast_nullable_to_non_nullable
                        as String?,
            profilePhotoUrl:
                freezed == profilePhotoUrl
                    ? _value.profilePhotoUrl
                    : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            availabilityHours:
                freezed == availabilityHours
                    ? _value.availabilityHours
                    : availabilityHours // ignore: cast_nullable_to_non_nullable
                        as String?,
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
abstract class _$$VetProfileRequestImplCopyWith<$Res>
    implements $VetProfileRequestCopyWith<$Res> {
  factory _$$VetProfileRequestImplCopyWith(
    _$VetProfileRequestImpl value,
    $Res Function(_$VetProfileRequestImpl) then,
  ) = __$$VetProfileRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fullName,
    String degree,
    String? licenseNumber,
    List<String> specialization,
    int experience,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? state,
    String? zipCode,
    String phone,
    double consultationFee,
    String currency,
    String? bio,
    String? profilePhotoUrl,
    String? availabilityHours,
    bool isAvailable,
  });
}

/// @nodoc
class __$$VetProfileRequestImplCopyWithImpl<$Res>
    extends _$VetProfileRequestCopyWithImpl<$Res, _$VetProfileRequestImpl>
    implements _$$VetProfileRequestImplCopyWith<$Res> {
  __$$VetProfileRequestImplCopyWithImpl(
    _$VetProfileRequestImpl _value,
    $Res Function(_$VetProfileRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VetProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? degree = null,
    Object? licenseNumber = freezed,
    Object? specialization = null,
    Object? experience = null,
    Object? clinicName = freezed,
    Object? clinicAddress = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? zipCode = freezed,
    Object? phone = null,
    Object? consultationFee = null,
    Object? currency = null,
    Object? bio = freezed,
    Object? profilePhotoUrl = freezed,
    Object? availabilityHours = freezed,
    Object? isAvailable = null,
  }) {
    return _then(
      _$VetProfileRequestImpl(
        fullName:
            null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                    as String,
        degree:
            null == degree
                ? _value.degree
                : degree // ignore: cast_nullable_to_non_nullable
                    as String,
        licenseNumber:
            freezed == licenseNumber
                ? _value.licenseNumber
                : licenseNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        specialization:
            null == specialization
                ? _value._specialization
                : specialization // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        experience:
            null == experience
                ? _value.experience
                : experience // ignore: cast_nullable_to_non_nullable
                    as int,
        clinicName:
            freezed == clinicName
                ? _value.clinicName
                : clinicName // ignore: cast_nullable_to_non_nullable
                    as String?,
        clinicAddress:
            freezed == clinicAddress
                ? _value.clinicAddress
                : clinicAddress // ignore: cast_nullable_to_non_nullable
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
        zipCode:
            freezed == zipCode
                ? _value.zipCode
                : zipCode // ignore: cast_nullable_to_non_nullable
                    as String?,
        phone:
            null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                    as String,
        consultationFee:
            null == consultationFee
                ? _value.consultationFee
                : consultationFee // ignore: cast_nullable_to_non_nullable
                    as double,
        currency:
            null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                    as String,
        bio:
            freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                    as String?,
        profilePhotoUrl:
            freezed == profilePhotoUrl
                ? _value.profilePhotoUrl
                : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        availabilityHours:
            freezed == availabilityHours
                ? _value.availabilityHours
                : availabilityHours // ignore: cast_nullable_to_non_nullable
                    as String?,
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
class _$VetProfileRequestImpl implements _VetProfileRequest {
  const _$VetProfileRequestImpl({
    required this.fullName,
    required this.degree,
    this.licenseNumber,
    final List<String> specialization = const [],
    required this.experience,
    this.clinicName,
    this.clinicAddress,
    this.city,
    this.state,
    this.zipCode,
    required this.phone,
    required this.consultationFee,
    this.currency = 'USD',
    this.bio,
    this.profilePhotoUrl,
    this.availabilityHours,
    this.isAvailable = true,
  }) : _specialization = specialization;

  factory _$VetProfileRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VetProfileRequestImplFromJson(json);

  @override
  final String fullName;
  @override
  final String degree;
  @override
  final String? licenseNumber;
  final List<String> _specialization;
  @override
  @JsonKey()
  List<String> get specialization {
    if (_specialization is EqualUnmodifiableListView) return _specialization;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specialization);
  }

  @override
  final int experience;
  @override
  final String? clinicName;
  @override
  final String? clinicAddress;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? zipCode;
  @override
  final String phone;
  @override
  final double consultationFee;
  @override
  @JsonKey()
  final String currency;
  @override
  final String? bio;
  @override
  final String? profilePhotoUrl;
  @override
  final String? availabilityHours;
  @override
  @JsonKey()
  final bool isAvailable;

  @override
  String toString() {
    return 'VetProfileRequest(fullName: $fullName, degree: $degree, licenseNumber: $licenseNumber, specialization: $specialization, experience: $experience, clinicName: $clinicName, clinicAddress: $clinicAddress, city: $city, state: $state, zipCode: $zipCode, phone: $phone, consultationFee: $consultationFee, currency: $currency, bio: $bio, profilePhotoUrl: $profilePhotoUrl, availabilityHours: $availabilityHours, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VetProfileRequestImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.degree, degree) || other.degree == degree) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            const DeepCollectionEquality().equals(
              other._specialization,
              _specialization,
            ) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.clinicName, clinicName) ||
                other.clinicName == clinicName) &&
            (identical(other.clinicAddress, clinicAddress) ||
                other.clinicAddress == clinicAddress) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.consultationFee, consultationFee) ||
                other.consultationFee == consultationFee) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl) &&
            (identical(other.availabilityHours, availabilityHours) ||
                other.availabilityHours == availabilityHours) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fullName,
    degree,
    licenseNumber,
    const DeepCollectionEquality().hash(_specialization),
    experience,
    clinicName,
    clinicAddress,
    city,
    state,
    zipCode,
    phone,
    consultationFee,
    currency,
    bio,
    profilePhotoUrl,
    availabilityHours,
    isAvailable,
  );

  /// Create a copy of VetProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VetProfileRequestImplCopyWith<_$VetProfileRequestImpl> get copyWith =>
      __$$VetProfileRequestImplCopyWithImpl<_$VetProfileRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VetProfileRequestImplToJson(this);
  }
}

abstract class _VetProfileRequest implements VetProfileRequest {
  const factory _VetProfileRequest({
    required final String fullName,
    required final String degree,
    final String? licenseNumber,
    final List<String> specialization,
    required final int experience,
    final String? clinicName,
    final String? clinicAddress,
    final String? city,
    final String? state,
    final String? zipCode,
    required final String phone,
    required final double consultationFee,
    final String currency,
    final String? bio,
    final String? profilePhotoUrl,
    final String? availabilityHours,
    final bool isAvailable,
  }) = _$VetProfileRequestImpl;

  factory _VetProfileRequest.fromJson(Map<String, dynamic> json) =
      _$VetProfileRequestImpl.fromJson;

  @override
  String get fullName;
  @override
  String get degree;
  @override
  String? get licenseNumber;
  @override
  List<String> get specialization;
  @override
  int get experience;
  @override
  String? get clinicName;
  @override
  String? get clinicAddress;
  @override
  String? get city;
  @override
  String? get state;
  @override
  String? get zipCode;
  @override
  String get phone;
  @override
  double get consultationFee;
  @override
  String get currency;
  @override
  String? get bio;
  @override
  String? get profilePhotoUrl;
  @override
  String? get availabilityHours;
  @override
  bool get isAvailable;

  /// Create a copy of VetProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VetProfileRequestImplCopyWith<_$VetProfileRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
