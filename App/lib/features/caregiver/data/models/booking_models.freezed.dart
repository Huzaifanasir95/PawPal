// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ServiceBooking _$ServiceBookingFromJson(Map<String, dynamic> json) {
  return _ServiceBooking.fromJson(json);
}

/// @nodoc
mixin _$ServiceBooking {
  String get id => throw _privateConstructorUsedError;
  String get bookingNumber => throw _privateConstructorUsedError;
  String get petOwnerId => throw _privateConstructorUsedError;
  String get caregiverId => throw _privateConstructorUsedError;
  String get serviceId => throw _privateConstructorUsedError;
  List<String> get petIds => throw _privateConstructorUsedError;
  DateTime get startDatetime => throw _privateConstructorUsedError;
  DateTime get endDatetime => throw _privateConstructorUsedError;
  String get serviceLocationType => throw _privateConstructorUsedError;
  String? get serviceAddress => throw _privateConstructorUsedError;
  double? get serviceLatitude => throw _privateConstructorUsedError;
  double? get serviceLongitude => throw _privateConstructorUsedError;
  String? get specialInstructions => throw _privateConstructorUsedError;
  String? get emergencyContactName => throw _privateConstructorUsedError;
  String? get emergencyContactPhone => throw _privateConstructorUsedError;
  double get baseAmount => throw _privateConstructorUsedError;
  double get additionalPetsFee => throw _privateConstructorUsedError;
  double get serviceFee => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get requestedAt => throw _privateConstructorUsedError;
  DateTime? get respondedAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Joined fields
  String? get ownerName => throw _privateConstructorUsedError;
  String? get ownerAvatar => throw _privateConstructorUsedError;
  String? get caregiverName => throw _privateConstructorUsedError;
  String? get caregiverAvatar => throw _privateConstructorUsedError;
  String? get serviceName => throw _privateConstructorUsedError;

  /// Serializes this ServiceBooking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceBooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceBookingCopyWith<ServiceBooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceBookingCopyWith<$Res> {
  factory $ServiceBookingCopyWith(
    ServiceBooking value,
    $Res Function(ServiceBooking) then,
  ) = _$ServiceBookingCopyWithImpl<$Res, ServiceBooking>;
  @useResult
  $Res call({
    String id,
    String bookingNumber,
    String petOwnerId,
    String caregiverId,
    String serviceId,
    List<String> petIds,
    DateTime startDatetime,
    DateTime endDatetime,
    String serviceLocationType,
    String? serviceAddress,
    double? serviceLatitude,
    double? serviceLongitude,
    String? specialInstructions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    double baseAmount,
    double additionalPetsFee,
    double serviceFee,
    double discountAmount,
    double totalAmount,
    String currency,
    String status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerName,
    String? ownerAvatar,
    String? caregiverName,
    String? caregiverAvatar,
    String? serviceName,
  });
}

/// @nodoc
class _$ServiceBookingCopyWithImpl<$Res, $Val extends ServiceBooking>
    implements $ServiceBookingCopyWith<$Res> {
  _$ServiceBookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceBooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingNumber = null,
    Object? petOwnerId = null,
    Object? caregiverId = null,
    Object? serviceId = null,
    Object? petIds = null,
    Object? startDatetime = null,
    Object? endDatetime = null,
    Object? serviceLocationType = null,
    Object? serviceAddress = freezed,
    Object? serviceLatitude = freezed,
    Object? serviceLongitude = freezed,
    Object? specialInstructions = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? baseAmount = null,
    Object? additionalPetsFee = null,
    Object? serviceFee = null,
    Object? discountAmount = null,
    Object? totalAmount = null,
    Object? currency = null,
    Object? status = null,
    Object? requestedAt = freezed,
    Object? respondedAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancellationReason = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? ownerName = freezed,
    Object? ownerAvatar = freezed,
    Object? caregiverName = freezed,
    Object? caregiverAvatar = freezed,
    Object? serviceName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            bookingNumber:
                null == bookingNumber
                    ? _value.bookingNumber
                    : bookingNumber // ignore: cast_nullable_to_non_nullable
                        as String,
            petOwnerId:
                null == petOwnerId
                    ? _value.petOwnerId
                    : petOwnerId // ignore: cast_nullable_to_non_nullable
                        as String,
            caregiverId:
                null == caregiverId
                    ? _value.caregiverId
                    : caregiverId // ignore: cast_nullable_to_non_nullable
                        as String,
            serviceId:
                null == serviceId
                    ? _value.serviceId
                    : serviceId // ignore: cast_nullable_to_non_nullable
                        as String,
            petIds:
                null == petIds
                    ? _value.petIds
                    : petIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            startDatetime:
                null == startDatetime
                    ? _value.startDatetime
                    : startDatetime // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            endDatetime:
                null == endDatetime
                    ? _value.endDatetime
                    : endDatetime // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            serviceLocationType:
                null == serviceLocationType
                    ? _value.serviceLocationType
                    : serviceLocationType // ignore: cast_nullable_to_non_nullable
                        as String,
            serviceAddress:
                freezed == serviceAddress
                    ? _value.serviceAddress
                    : serviceAddress // ignore: cast_nullable_to_non_nullable
                        as String?,
            serviceLatitude:
                freezed == serviceLatitude
                    ? _value.serviceLatitude
                    : serviceLatitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            serviceLongitude:
                freezed == serviceLongitude
                    ? _value.serviceLongitude
                    : serviceLongitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            specialInstructions:
                freezed == specialInstructions
                    ? _value.specialInstructions
                    : specialInstructions // ignore: cast_nullable_to_non_nullable
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
            baseAmount:
                null == baseAmount
                    ? _value.baseAmount
                    : baseAmount // ignore: cast_nullable_to_non_nullable
                        as double,
            additionalPetsFee:
                null == additionalPetsFee
                    ? _value.additionalPetsFee
                    : additionalPetsFee // ignore: cast_nullable_to_non_nullable
                        as double,
            serviceFee:
                null == serviceFee
                    ? _value.serviceFee
                    : serviceFee // ignore: cast_nullable_to_non_nullable
                        as double,
            discountAmount:
                null == discountAmount
                    ? _value.discountAmount
                    : discountAmount // ignore: cast_nullable_to_non_nullable
                        as double,
            totalAmount:
                null == totalAmount
                    ? _value.totalAmount
                    : totalAmount // ignore: cast_nullable_to_non_nullable
                        as double,
            currency:
                null == currency
                    ? _value.currency
                    : currency // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            requestedAt:
                freezed == requestedAt
                    ? _value.requestedAt
                    : requestedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            respondedAt:
                freezed == respondedAt
                    ? _value.respondedAt
                    : respondedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            startedAt:
                freezed == startedAt
                    ? _value.startedAt
                    : startedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            completedAt:
                freezed == completedAt
                    ? _value.completedAt
                    : completedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            cancelledAt:
                freezed == cancelledAt
                    ? _value.cancelledAt
                    : cancelledAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            cancellationReason:
                freezed == cancellationReason
                    ? _value.cancellationReason
                    : cancellationReason // ignore: cast_nullable_to_non_nullable
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
            ownerName:
                freezed == ownerName
                    ? _value.ownerName
                    : ownerName // ignore: cast_nullable_to_non_nullable
                        as String?,
            ownerAvatar:
                freezed == ownerAvatar
                    ? _value.ownerAvatar
                    : ownerAvatar // ignore: cast_nullable_to_non_nullable
                        as String?,
            caregiverName:
                freezed == caregiverName
                    ? _value.caregiverName
                    : caregiverName // ignore: cast_nullable_to_non_nullable
                        as String?,
            caregiverAvatar:
                freezed == caregiverAvatar
                    ? _value.caregiverAvatar
                    : caregiverAvatar // ignore: cast_nullable_to_non_nullable
                        as String?,
            serviceName:
                freezed == serviceName
                    ? _value.serviceName
                    : serviceName // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceBookingImplCopyWith<$Res>
    implements $ServiceBookingCopyWith<$Res> {
  factory _$$ServiceBookingImplCopyWith(
    _$ServiceBookingImpl value,
    $Res Function(_$ServiceBookingImpl) then,
  ) = __$$ServiceBookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookingNumber,
    String petOwnerId,
    String caregiverId,
    String serviceId,
    List<String> petIds,
    DateTime startDatetime,
    DateTime endDatetime,
    String serviceLocationType,
    String? serviceAddress,
    double? serviceLatitude,
    double? serviceLongitude,
    String? specialInstructions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    double baseAmount,
    double additionalPetsFee,
    double serviceFee,
    double discountAmount,
    double totalAmount,
    String currency,
    String status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerName,
    String? ownerAvatar,
    String? caregiverName,
    String? caregiverAvatar,
    String? serviceName,
  });
}

/// @nodoc
class __$$ServiceBookingImplCopyWithImpl<$Res>
    extends _$ServiceBookingCopyWithImpl<$Res, _$ServiceBookingImpl>
    implements _$$ServiceBookingImplCopyWith<$Res> {
  __$$ServiceBookingImplCopyWithImpl(
    _$ServiceBookingImpl _value,
    $Res Function(_$ServiceBookingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceBooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingNumber = null,
    Object? petOwnerId = null,
    Object? caregiverId = null,
    Object? serviceId = null,
    Object? petIds = null,
    Object? startDatetime = null,
    Object? endDatetime = null,
    Object? serviceLocationType = null,
    Object? serviceAddress = freezed,
    Object? serviceLatitude = freezed,
    Object? serviceLongitude = freezed,
    Object? specialInstructions = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? baseAmount = null,
    Object? additionalPetsFee = null,
    Object? serviceFee = null,
    Object? discountAmount = null,
    Object? totalAmount = null,
    Object? currency = null,
    Object? status = null,
    Object? requestedAt = freezed,
    Object? respondedAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancellationReason = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? ownerName = freezed,
    Object? ownerAvatar = freezed,
    Object? caregiverName = freezed,
    Object? caregiverAvatar = freezed,
    Object? serviceName = freezed,
  }) {
    return _then(
      _$ServiceBookingImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        bookingNumber:
            null == bookingNumber
                ? _value.bookingNumber
                : bookingNumber // ignore: cast_nullable_to_non_nullable
                    as String,
        petOwnerId:
            null == petOwnerId
                ? _value.petOwnerId
                : petOwnerId // ignore: cast_nullable_to_non_nullable
                    as String,
        caregiverId:
            null == caregiverId
                ? _value.caregiverId
                : caregiverId // ignore: cast_nullable_to_non_nullable
                    as String,
        serviceId:
            null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                    as String,
        petIds:
            null == petIds
                ? _value._petIds
                : petIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        startDatetime:
            null == startDatetime
                ? _value.startDatetime
                : startDatetime // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        endDatetime:
            null == endDatetime
                ? _value.endDatetime
                : endDatetime // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        serviceLocationType:
            null == serviceLocationType
                ? _value.serviceLocationType
                : serviceLocationType // ignore: cast_nullable_to_non_nullable
                    as String,
        serviceAddress:
            freezed == serviceAddress
                ? _value.serviceAddress
                : serviceAddress // ignore: cast_nullable_to_non_nullable
                    as String?,
        serviceLatitude:
            freezed == serviceLatitude
                ? _value.serviceLatitude
                : serviceLatitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        serviceLongitude:
            freezed == serviceLongitude
                ? _value.serviceLongitude
                : serviceLongitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        specialInstructions:
            freezed == specialInstructions
                ? _value.specialInstructions
                : specialInstructions // ignore: cast_nullable_to_non_nullable
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
        baseAmount:
            null == baseAmount
                ? _value.baseAmount
                : baseAmount // ignore: cast_nullable_to_non_nullable
                    as double,
        additionalPetsFee:
            null == additionalPetsFee
                ? _value.additionalPetsFee
                : additionalPetsFee // ignore: cast_nullable_to_non_nullable
                    as double,
        serviceFee:
            null == serviceFee
                ? _value.serviceFee
                : serviceFee // ignore: cast_nullable_to_non_nullable
                    as double,
        discountAmount:
            null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                    as double,
        totalAmount:
            null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                    as double,
        currency:
            null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        requestedAt:
            freezed == requestedAt
                ? _value.requestedAt
                : requestedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        respondedAt:
            freezed == respondedAt
                ? _value.respondedAt
                : respondedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        startedAt:
            freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        completedAt:
            freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        cancelledAt:
            freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        cancellationReason:
            freezed == cancellationReason
                ? _value.cancellationReason
                : cancellationReason // ignore: cast_nullable_to_non_nullable
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
        ownerName:
            freezed == ownerName
                ? _value.ownerName
                : ownerName // ignore: cast_nullable_to_non_nullable
                    as String?,
        ownerAvatar:
            freezed == ownerAvatar
                ? _value.ownerAvatar
                : ownerAvatar // ignore: cast_nullable_to_non_nullable
                    as String?,
        caregiverName:
            freezed == caregiverName
                ? _value.caregiverName
                : caregiverName // ignore: cast_nullable_to_non_nullable
                    as String?,
        caregiverAvatar:
            freezed == caregiverAvatar
                ? _value.caregiverAvatar
                : caregiverAvatar // ignore: cast_nullable_to_non_nullable
                    as String?,
        serviceName:
            freezed == serviceName
                ? _value.serviceName
                : serviceName // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceBookingImpl implements _ServiceBooking {
  const _$ServiceBookingImpl({
    required this.id,
    required this.bookingNumber,
    required this.petOwnerId,
    required this.caregiverId,
    required this.serviceId,
    required final List<String> petIds,
    required this.startDatetime,
    required this.endDatetime,
    this.serviceLocationType = 'owner_home',
    this.serviceAddress,
    this.serviceLatitude,
    this.serviceLongitude,
    this.specialInstructions,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.baseAmount = 0,
    this.additionalPetsFee = 0,
    this.serviceFee = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.currency = 'PKR',
    this.status = 'pending',
    this.requestedAt,
    this.respondedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.ownerAvatar,
    this.caregiverName,
    this.caregiverAvatar,
    this.serviceName,
  }) : _petIds = petIds;

  factory _$ServiceBookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceBookingImplFromJson(json);

  @override
  final String id;
  @override
  final String bookingNumber;
  @override
  final String petOwnerId;
  @override
  final String caregiverId;
  @override
  final String serviceId;
  final List<String> _petIds;
  @override
  List<String> get petIds {
    if (_petIds is EqualUnmodifiableListView) return _petIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_petIds);
  }

  @override
  final DateTime startDatetime;
  @override
  final DateTime endDatetime;
  @override
  @JsonKey()
  final String serviceLocationType;
  @override
  final String? serviceAddress;
  @override
  final double? serviceLatitude;
  @override
  final double? serviceLongitude;
  @override
  final String? specialInstructions;
  @override
  final String? emergencyContactName;
  @override
  final String? emergencyContactPhone;
  @override
  @JsonKey()
  final double baseAmount;
  @override
  @JsonKey()
  final double additionalPetsFee;
  @override
  @JsonKey()
  final double serviceFee;
  @override
  @JsonKey()
  final double discountAmount;
  @override
  @JsonKey()
  final double totalAmount;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? requestedAt;
  @override
  final DateTime? respondedAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? cancelledAt;
  @override
  final String? cancellationReason;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // Joined fields
  @override
  final String? ownerName;
  @override
  final String? ownerAvatar;
  @override
  final String? caregiverName;
  @override
  final String? caregiverAvatar;
  @override
  final String? serviceName;

  @override
  String toString() {
    return 'ServiceBooking(id: $id, bookingNumber: $bookingNumber, petOwnerId: $petOwnerId, caregiverId: $caregiverId, serviceId: $serviceId, petIds: $petIds, startDatetime: $startDatetime, endDatetime: $endDatetime, serviceLocationType: $serviceLocationType, serviceAddress: $serviceAddress, serviceLatitude: $serviceLatitude, serviceLongitude: $serviceLongitude, specialInstructions: $specialInstructions, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, baseAmount: $baseAmount, additionalPetsFee: $additionalPetsFee, serviceFee: $serviceFee, discountAmount: $discountAmount, totalAmount: $totalAmount, currency: $currency, status: $status, requestedAt: $requestedAt, respondedAt: $respondedAt, startedAt: $startedAt, completedAt: $completedAt, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt, ownerName: $ownerName, ownerAvatar: $ownerAvatar, caregiverName: $caregiverName, caregiverAvatar: $caregiverAvatar, serviceName: $serviceName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceBookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingNumber, bookingNumber) ||
                other.bookingNumber == bookingNumber) &&
            (identical(other.petOwnerId, petOwnerId) ||
                other.petOwnerId == petOwnerId) &&
            (identical(other.caregiverId, caregiverId) ||
                other.caregiverId == caregiverId) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            const DeepCollectionEquality().equals(other._petIds, _petIds) &&
            (identical(other.startDatetime, startDatetime) ||
                other.startDatetime == startDatetime) &&
            (identical(other.endDatetime, endDatetime) ||
                other.endDatetime == endDatetime) &&
            (identical(other.serviceLocationType, serviceLocationType) ||
                other.serviceLocationType == serviceLocationType) &&
            (identical(other.serviceAddress, serviceAddress) ||
                other.serviceAddress == serviceAddress) &&
            (identical(other.serviceLatitude, serviceLatitude) ||
                other.serviceLatitude == serviceLatitude) &&
            (identical(other.serviceLongitude, serviceLongitude) ||
                other.serviceLongitude == serviceLongitude) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(other.emergencyContactPhone, emergencyContactPhone) ||
                other.emergencyContactPhone == emergencyContactPhone) &&
            (identical(other.baseAmount, baseAmount) ||
                other.baseAmount == baseAmount) &&
            (identical(other.additionalPetsFee, additionalPetsFee) ||
                other.additionalPetsFee == additionalPetsFee) &&
            (identical(other.serviceFee, serviceFee) ||
                other.serviceFee == serviceFee) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.ownerAvatar, ownerAvatar) ||
                other.ownerAvatar == ownerAvatar) &&
            (identical(other.caregiverName, caregiverName) ||
                other.caregiverName == caregiverName) &&
            (identical(other.caregiverAvatar, caregiverAvatar) ||
                other.caregiverAvatar == caregiverAvatar) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    bookingNumber,
    petOwnerId,
    caregiverId,
    serviceId,
    const DeepCollectionEquality().hash(_petIds),
    startDatetime,
    endDatetime,
    serviceLocationType,
    serviceAddress,
    serviceLatitude,
    serviceLongitude,
    specialInstructions,
    emergencyContactName,
    emergencyContactPhone,
    baseAmount,
    additionalPetsFee,
    serviceFee,
    discountAmount,
    totalAmount,
    currency,
    status,
    requestedAt,
    respondedAt,
    startedAt,
    completedAt,
    cancelledAt,
    cancellationReason,
    createdAt,
    updatedAt,
    ownerName,
    ownerAvatar,
    caregiverName,
    caregiverAvatar,
    serviceName,
  ]);

  /// Create a copy of ServiceBooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceBookingImplCopyWith<_$ServiceBookingImpl> get copyWith =>
      __$$ServiceBookingImplCopyWithImpl<_$ServiceBookingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceBookingImplToJson(this);
  }
}

abstract class _ServiceBooking implements ServiceBooking {
  const factory _ServiceBooking({
    required final String id,
    required final String bookingNumber,
    required final String petOwnerId,
    required final String caregiverId,
    required final String serviceId,
    required final List<String> petIds,
    required final DateTime startDatetime,
    required final DateTime endDatetime,
    final String serviceLocationType,
    final String? serviceAddress,
    final double? serviceLatitude,
    final double? serviceLongitude,
    final String? specialInstructions,
    final String? emergencyContactName,
    final String? emergencyContactPhone,
    final double baseAmount,
    final double additionalPetsFee,
    final double serviceFee,
    final double discountAmount,
    final double totalAmount,
    final String currency,
    final String status,
    final DateTime? requestedAt,
    final DateTime? respondedAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final DateTime? cancelledAt,
    final String? cancellationReason,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? ownerName,
    final String? ownerAvatar,
    final String? caregiverName,
    final String? caregiverAvatar,
    final String? serviceName,
  }) = _$ServiceBookingImpl;

  factory _ServiceBooking.fromJson(Map<String, dynamic> json) =
      _$ServiceBookingImpl.fromJson;

  @override
  String get id;
  @override
  String get bookingNumber;
  @override
  String get petOwnerId;
  @override
  String get caregiverId;
  @override
  String get serviceId;
  @override
  List<String> get petIds;
  @override
  DateTime get startDatetime;
  @override
  DateTime get endDatetime;
  @override
  String get serviceLocationType;
  @override
  String? get serviceAddress;
  @override
  double? get serviceLatitude;
  @override
  double? get serviceLongitude;
  @override
  String? get specialInstructions;
  @override
  String? get emergencyContactName;
  @override
  String? get emergencyContactPhone;
  @override
  double get baseAmount;
  @override
  double get additionalPetsFee;
  @override
  double get serviceFee;
  @override
  double get discountAmount;
  @override
  double get totalAmount;
  @override
  String get currency;
  @override
  String get status;
  @override
  DateTime? get requestedAt;
  @override
  DateTime? get respondedAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get cancelledAt;
  @override
  String? get cancellationReason;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Joined fields
  @override
  String? get ownerName;
  @override
  String? get ownerAvatar;
  @override
  String? get caregiverName;
  @override
  String? get caregiverAvatar;
  @override
  String? get serviceName;

  /// Create a copy of ServiceBooking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceBookingImplCopyWith<_$ServiceBookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateBookingRequest _$CreateBookingRequestFromJson(Map<String, dynamic> json) {
  return _CreateBookingRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateBookingRequest {
  String get caregiverId => throw _privateConstructorUsedError;
  String get serviceId => throw _privateConstructorUsedError;
  List<String> get petIds => throw _privateConstructorUsedError;
  String get startDatetime => throw _privateConstructorUsedError; // ISO 8601
  String get endDatetime => throw _privateConstructorUsedError;
  String get serviceLocationType => throw _privateConstructorUsedError;
  String? get serviceAddress => throw _privateConstructorUsedError;
  double? get serviceLatitude => throw _privateConstructorUsedError;
  double? get serviceLongitude => throw _privateConstructorUsedError;
  String? get specialInstructions => throw _privateConstructorUsedError;
  String? get emergencyContactName => throw _privateConstructorUsedError;
  String? get emergencyContactPhone => throw _privateConstructorUsedError;

  /// Serializes this CreateBookingRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateBookingRequestCopyWith<CreateBookingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateBookingRequestCopyWith<$Res> {
  factory $CreateBookingRequestCopyWith(
    CreateBookingRequest value,
    $Res Function(CreateBookingRequest) then,
  ) = _$CreateBookingRequestCopyWithImpl<$Res, CreateBookingRequest>;
  @useResult
  $Res call({
    String caregiverId,
    String serviceId,
    List<String> petIds,
    String startDatetime,
    String endDatetime,
    String serviceLocationType,
    String? serviceAddress,
    double? serviceLatitude,
    double? serviceLongitude,
    String? specialInstructions,
    String? emergencyContactName,
    String? emergencyContactPhone,
  });
}

/// @nodoc
class _$CreateBookingRequestCopyWithImpl<
  $Res,
  $Val extends CreateBookingRequest
>
    implements $CreateBookingRequestCopyWith<$Res> {
  _$CreateBookingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? caregiverId = null,
    Object? serviceId = null,
    Object? petIds = null,
    Object? startDatetime = null,
    Object? endDatetime = null,
    Object? serviceLocationType = null,
    Object? serviceAddress = freezed,
    Object? serviceLatitude = freezed,
    Object? serviceLongitude = freezed,
    Object? specialInstructions = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
  }) {
    return _then(
      _value.copyWith(
            caregiverId:
                null == caregiverId
                    ? _value.caregiverId
                    : caregiverId // ignore: cast_nullable_to_non_nullable
                        as String,
            serviceId:
                null == serviceId
                    ? _value.serviceId
                    : serviceId // ignore: cast_nullable_to_non_nullable
                        as String,
            petIds:
                null == petIds
                    ? _value.petIds
                    : petIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            startDatetime:
                null == startDatetime
                    ? _value.startDatetime
                    : startDatetime // ignore: cast_nullable_to_non_nullable
                        as String,
            endDatetime:
                null == endDatetime
                    ? _value.endDatetime
                    : endDatetime // ignore: cast_nullable_to_non_nullable
                        as String,
            serviceLocationType:
                null == serviceLocationType
                    ? _value.serviceLocationType
                    : serviceLocationType // ignore: cast_nullable_to_non_nullable
                        as String,
            serviceAddress:
                freezed == serviceAddress
                    ? _value.serviceAddress
                    : serviceAddress // ignore: cast_nullable_to_non_nullable
                        as String?,
            serviceLatitude:
                freezed == serviceLatitude
                    ? _value.serviceLatitude
                    : serviceLatitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            serviceLongitude:
                freezed == serviceLongitude
                    ? _value.serviceLongitude
                    : serviceLongitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            specialInstructions:
                freezed == specialInstructions
                    ? _value.specialInstructions
                    : specialInstructions // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateBookingRequestImplCopyWith<$Res>
    implements $CreateBookingRequestCopyWith<$Res> {
  factory _$$CreateBookingRequestImplCopyWith(
    _$CreateBookingRequestImpl value,
    $Res Function(_$CreateBookingRequestImpl) then,
  ) = __$$CreateBookingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String caregiverId,
    String serviceId,
    List<String> petIds,
    String startDatetime,
    String endDatetime,
    String serviceLocationType,
    String? serviceAddress,
    double? serviceLatitude,
    double? serviceLongitude,
    String? specialInstructions,
    String? emergencyContactName,
    String? emergencyContactPhone,
  });
}

/// @nodoc
class __$$CreateBookingRequestImplCopyWithImpl<$Res>
    extends _$CreateBookingRequestCopyWithImpl<$Res, _$CreateBookingRequestImpl>
    implements _$$CreateBookingRequestImplCopyWith<$Res> {
  __$$CreateBookingRequestImplCopyWithImpl(
    _$CreateBookingRequestImpl _value,
    $Res Function(_$CreateBookingRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? caregiverId = null,
    Object? serviceId = null,
    Object? petIds = null,
    Object? startDatetime = null,
    Object? endDatetime = null,
    Object? serviceLocationType = null,
    Object? serviceAddress = freezed,
    Object? serviceLatitude = freezed,
    Object? serviceLongitude = freezed,
    Object? specialInstructions = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
  }) {
    return _then(
      _$CreateBookingRequestImpl(
        caregiverId:
            null == caregiverId
                ? _value.caregiverId
                : caregiverId // ignore: cast_nullable_to_non_nullable
                    as String,
        serviceId:
            null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                    as String,
        petIds:
            null == petIds
                ? _value._petIds
                : petIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        startDatetime:
            null == startDatetime
                ? _value.startDatetime
                : startDatetime // ignore: cast_nullable_to_non_nullable
                    as String,
        endDatetime:
            null == endDatetime
                ? _value.endDatetime
                : endDatetime // ignore: cast_nullable_to_non_nullable
                    as String,
        serviceLocationType:
            null == serviceLocationType
                ? _value.serviceLocationType
                : serviceLocationType // ignore: cast_nullable_to_non_nullable
                    as String,
        serviceAddress:
            freezed == serviceAddress
                ? _value.serviceAddress
                : serviceAddress // ignore: cast_nullable_to_non_nullable
                    as String?,
        serviceLatitude:
            freezed == serviceLatitude
                ? _value.serviceLatitude
                : serviceLatitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        serviceLongitude:
            freezed == serviceLongitude
                ? _value.serviceLongitude
                : serviceLongitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        specialInstructions:
            freezed == specialInstructions
                ? _value.specialInstructions
                : specialInstructions // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateBookingRequestImpl implements _CreateBookingRequest {
  const _$CreateBookingRequestImpl({
    required this.caregiverId,
    required this.serviceId,
    required final List<String> petIds,
    required this.startDatetime,
    required this.endDatetime,
    this.serviceLocationType = 'owner_home',
    this.serviceAddress,
    this.serviceLatitude,
    this.serviceLongitude,
    this.specialInstructions,
    this.emergencyContactName,
    this.emergencyContactPhone,
  }) : _petIds = petIds;

  factory _$CreateBookingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateBookingRequestImplFromJson(json);

  @override
  final String caregiverId;
  @override
  final String serviceId;
  final List<String> _petIds;
  @override
  List<String> get petIds {
    if (_petIds is EqualUnmodifiableListView) return _petIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_petIds);
  }

  @override
  final String startDatetime;
  // ISO 8601
  @override
  final String endDatetime;
  @override
  @JsonKey()
  final String serviceLocationType;
  @override
  final String? serviceAddress;
  @override
  final double? serviceLatitude;
  @override
  final double? serviceLongitude;
  @override
  final String? specialInstructions;
  @override
  final String? emergencyContactName;
  @override
  final String? emergencyContactPhone;

  @override
  String toString() {
    return 'CreateBookingRequest(caregiverId: $caregiverId, serviceId: $serviceId, petIds: $petIds, startDatetime: $startDatetime, endDatetime: $endDatetime, serviceLocationType: $serviceLocationType, serviceAddress: $serviceAddress, serviceLatitude: $serviceLatitude, serviceLongitude: $serviceLongitude, specialInstructions: $specialInstructions, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateBookingRequestImpl &&
            (identical(other.caregiverId, caregiverId) ||
                other.caregiverId == caregiverId) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            const DeepCollectionEquality().equals(other._petIds, _petIds) &&
            (identical(other.startDatetime, startDatetime) ||
                other.startDatetime == startDatetime) &&
            (identical(other.endDatetime, endDatetime) ||
                other.endDatetime == endDatetime) &&
            (identical(other.serviceLocationType, serviceLocationType) ||
                other.serviceLocationType == serviceLocationType) &&
            (identical(other.serviceAddress, serviceAddress) ||
                other.serviceAddress == serviceAddress) &&
            (identical(other.serviceLatitude, serviceLatitude) ||
                other.serviceLatitude == serviceLatitude) &&
            (identical(other.serviceLongitude, serviceLongitude) ||
                other.serviceLongitude == serviceLongitude) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(other.emergencyContactPhone, emergencyContactPhone) ||
                other.emergencyContactPhone == emergencyContactPhone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    caregiverId,
    serviceId,
    const DeepCollectionEquality().hash(_petIds),
    startDatetime,
    endDatetime,
    serviceLocationType,
    serviceAddress,
    serviceLatitude,
    serviceLongitude,
    specialInstructions,
    emergencyContactName,
    emergencyContactPhone,
  );

  /// Create a copy of CreateBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateBookingRequestImplCopyWith<_$CreateBookingRequestImpl>
  get copyWith =>
      __$$CreateBookingRequestImplCopyWithImpl<_$CreateBookingRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateBookingRequestImplToJson(this);
  }
}

abstract class _CreateBookingRequest implements CreateBookingRequest {
  const factory _CreateBookingRequest({
    required final String caregiverId,
    required final String serviceId,
    required final List<String> petIds,
    required final String startDatetime,
    required final String endDatetime,
    final String serviceLocationType,
    final String? serviceAddress,
    final double? serviceLatitude,
    final double? serviceLongitude,
    final String? specialInstructions,
    final String? emergencyContactName,
    final String? emergencyContactPhone,
  }) = _$CreateBookingRequestImpl;

  factory _CreateBookingRequest.fromJson(Map<String, dynamic> json) =
      _$CreateBookingRequestImpl.fromJson;

  @override
  String get caregiverId;
  @override
  String get serviceId;
  @override
  List<String> get petIds;
  @override
  String get startDatetime; // ISO 8601
  @override
  String get endDatetime;
  @override
  String get serviceLocationType;
  @override
  String? get serviceAddress;
  @override
  double? get serviceLatitude;
  @override
  double? get serviceLongitude;
  @override
  String? get specialInstructions;
  @override
  String? get emergencyContactName;
  @override
  String? get emergencyContactPhone;

  /// Create a copy of CreateBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateBookingRequestImplCopyWith<_$CreateBookingRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RespondToBookingRequest _$RespondToBookingRequestFromJson(
  Map<String, dynamic> json,
) {
  return _RespondToBookingRequest.fromJson(json);
}

/// @nodoc
mixin _$RespondToBookingRequest {
  bool get accept => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this RespondToBookingRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RespondToBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RespondToBookingRequestCopyWith<RespondToBookingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RespondToBookingRequestCopyWith<$Res> {
  factory $RespondToBookingRequestCopyWith(
    RespondToBookingRequest value,
    $Res Function(RespondToBookingRequest) then,
  ) = _$RespondToBookingRequestCopyWithImpl<$Res, RespondToBookingRequest>;
  @useResult
  $Res call({bool accept, String? reason});
}

/// @nodoc
class _$RespondToBookingRequestCopyWithImpl<
  $Res,
  $Val extends RespondToBookingRequest
>
    implements $RespondToBookingRequestCopyWith<$Res> {
  _$RespondToBookingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RespondToBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? accept = null, Object? reason = freezed}) {
    return _then(
      _value.copyWith(
            accept:
                null == accept
                    ? _value.accept
                    : accept // ignore: cast_nullable_to_non_nullable
                        as bool,
            reason:
                freezed == reason
                    ? _value.reason
                    : reason // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RespondToBookingRequestImplCopyWith<$Res>
    implements $RespondToBookingRequestCopyWith<$Res> {
  factory _$$RespondToBookingRequestImplCopyWith(
    _$RespondToBookingRequestImpl value,
    $Res Function(_$RespondToBookingRequestImpl) then,
  ) = __$$RespondToBookingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool accept, String? reason});
}

/// @nodoc
class __$$RespondToBookingRequestImplCopyWithImpl<$Res>
    extends
        _$RespondToBookingRequestCopyWithImpl<
          $Res,
          _$RespondToBookingRequestImpl
        >
    implements _$$RespondToBookingRequestImplCopyWith<$Res> {
  __$$RespondToBookingRequestImplCopyWithImpl(
    _$RespondToBookingRequestImpl _value,
    $Res Function(_$RespondToBookingRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RespondToBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? accept = null, Object? reason = freezed}) {
    return _then(
      _$RespondToBookingRequestImpl(
        accept:
            null == accept
                ? _value.accept
                : accept // ignore: cast_nullable_to_non_nullable
                    as bool,
        reason:
            freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RespondToBookingRequestImpl implements _RespondToBookingRequest {
  const _$RespondToBookingRequestImpl({required this.accept, this.reason});

  factory _$RespondToBookingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RespondToBookingRequestImplFromJson(json);

  @override
  final bool accept;
  @override
  final String? reason;

  @override
  String toString() {
    return 'RespondToBookingRequest(accept: $accept, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RespondToBookingRequestImpl &&
            (identical(other.accept, accept) || other.accept == accept) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accept, reason);

  /// Create a copy of RespondToBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RespondToBookingRequestImplCopyWith<_$RespondToBookingRequestImpl>
  get copyWith => __$$RespondToBookingRequestImplCopyWithImpl<
    _$RespondToBookingRequestImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RespondToBookingRequestImplToJson(this);
  }
}

abstract class _RespondToBookingRequest implements RespondToBookingRequest {
  const factory _RespondToBookingRequest({
    required final bool accept,
    final String? reason,
  }) = _$RespondToBookingRequestImpl;

  factory _RespondToBookingRequest.fromJson(Map<String, dynamic> json) =
      _$RespondToBookingRequestImpl.fromJson;

  @override
  bool get accept;
  @override
  String? get reason;

  /// Create a copy of RespondToBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RespondToBookingRequestImplCopyWith<_$RespondToBookingRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CancelBookingRequest _$CancelBookingRequestFromJson(Map<String, dynamic> json) {
  return _CancelBookingRequest.fromJson(json);
}

/// @nodoc
mixin _$CancelBookingRequest {
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this CancelBookingRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CancelBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CancelBookingRequestCopyWith<CancelBookingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CancelBookingRequestCopyWith<$Res> {
  factory $CancelBookingRequestCopyWith(
    CancelBookingRequest value,
    $Res Function(CancelBookingRequest) then,
  ) = _$CancelBookingRequestCopyWithImpl<$Res, CancelBookingRequest>;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class _$CancelBookingRequestCopyWithImpl<
  $Res,
  $Val extends CancelBookingRequest
>
    implements $CancelBookingRequestCopyWith<$Res> {
  _$CancelBookingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CancelBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _value.copyWith(
            reason:
                null == reason
                    ? _value.reason
                    : reason // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CancelBookingRequestImplCopyWith<$Res>
    implements $CancelBookingRequestCopyWith<$Res> {
  factory _$$CancelBookingRequestImplCopyWith(
    _$CancelBookingRequestImpl value,
    $Res Function(_$CancelBookingRequestImpl) then,
  ) = __$$CancelBookingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$$CancelBookingRequestImplCopyWithImpl<$Res>
    extends _$CancelBookingRequestCopyWithImpl<$Res, _$CancelBookingRequestImpl>
    implements _$$CancelBookingRequestImplCopyWith<$Res> {
  __$$CancelBookingRequestImplCopyWithImpl(
    _$CancelBookingRequestImpl _value,
    $Res Function(_$CancelBookingRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CancelBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _$CancelBookingRequestImpl(
        reason:
            null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CancelBookingRequestImpl implements _CancelBookingRequest {
  const _$CancelBookingRequestImpl({required this.reason});

  factory _$CancelBookingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CancelBookingRequestImplFromJson(json);

  @override
  final String reason;

  @override
  String toString() {
    return 'CancelBookingRequest(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CancelBookingRequestImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reason);

  /// Create a copy of CancelBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CancelBookingRequestImplCopyWith<_$CancelBookingRequestImpl>
  get copyWith =>
      __$$CancelBookingRequestImplCopyWithImpl<_$CancelBookingRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CancelBookingRequestImplToJson(this);
  }
}

abstract class _CancelBookingRequest implements CancelBookingRequest {
  const factory _CancelBookingRequest({required final String reason}) =
      _$CancelBookingRequestImpl;

  factory _CancelBookingRequest.fromJson(Map<String, dynamic> json) =
      _$CancelBookingRequestImpl.fromJson;

  @override
  String get reason;

  /// Create a copy of CancelBookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CancelBookingRequestImplCopyWith<_$CancelBookingRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

StartServiceRequest _$StartServiceRequestFromJson(Map<String, dynamic> json) {
  return _StartServiceRequest.fromJson(json);
}

/// @nodoc
mixin _$StartServiceRequest {
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this StartServiceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StartServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StartServiceRequestCopyWith<StartServiceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StartServiceRequestCopyWith<$Res> {
  factory $StartServiceRequestCopyWith(
    StartServiceRequest value,
    $Res Function(StartServiceRequest) then,
  ) = _$StartServiceRequestCopyWithImpl<$Res, StartServiceRequest>;
  @useResult
  $Res call({double? latitude, double? longitude});
}

/// @nodoc
class _$StartServiceRequestCopyWithImpl<$Res, $Val extends StartServiceRequest>
    implements $StartServiceRequestCopyWith<$Res> {
  _$StartServiceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StartServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = freezed, Object? longitude = freezed}) {
    return _then(
      _value.copyWith(
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StartServiceRequestImplCopyWith<$Res>
    implements $StartServiceRequestCopyWith<$Res> {
  factory _$$StartServiceRequestImplCopyWith(
    _$StartServiceRequestImpl value,
    $Res Function(_$StartServiceRequestImpl) then,
  ) = __$$StartServiceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? latitude, double? longitude});
}

/// @nodoc
class __$$StartServiceRequestImplCopyWithImpl<$Res>
    extends _$StartServiceRequestCopyWithImpl<$Res, _$StartServiceRequestImpl>
    implements _$$StartServiceRequestImplCopyWith<$Res> {
  __$$StartServiceRequestImplCopyWithImpl(
    _$StartServiceRequestImpl _value,
    $Res Function(_$StartServiceRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StartServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = freezed, Object? longitude = freezed}) {
    return _then(
      _$StartServiceRequestImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StartServiceRequestImpl implements _StartServiceRequest {
  const _$StartServiceRequestImpl({this.latitude, this.longitude});

  factory _$StartServiceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$StartServiceRequestImplFromJson(json);

  @override
  final double? latitude;
  @override
  final double? longitude;

  @override
  String toString() {
    return 'StartServiceRequest(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StartServiceRequestImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of StartServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StartServiceRequestImplCopyWith<_$StartServiceRequestImpl> get copyWith =>
      __$$StartServiceRequestImplCopyWithImpl<_$StartServiceRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StartServiceRequestImplToJson(this);
  }
}

abstract class _StartServiceRequest implements StartServiceRequest {
  const factory _StartServiceRequest({
    final double? latitude,
    final double? longitude,
  }) = _$StartServiceRequestImpl;

  factory _StartServiceRequest.fromJson(Map<String, dynamic> json) =
      _$StartServiceRequestImpl.fromJson;

  @override
  double? get latitude;
  @override
  double? get longitude;

  /// Create a copy of StartServiceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StartServiceRequestImplCopyWith<_$StartServiceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingTracking _$BookingTrackingFromJson(Map<String, dynamic> json) {
  return _BookingTracking.fromJson(json);
}

/// @nodoc
mixin _$BookingTracking {
  String get id => throw _privateConstructorUsedError;
  String get bookingId => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get activityType => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  DateTime? get recordedAt => throw _privateConstructorUsedError;

  /// Serializes this BookingTracking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingTracking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingTrackingCopyWith<BookingTracking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingTrackingCopyWith<$Res> {
  factory $BookingTrackingCopyWith(
    BookingTracking value,
    $Res Function(BookingTracking) then,
  ) = _$BookingTrackingCopyWithImpl<$Res, BookingTracking>;
  @useResult
  $Res call({
    String id,
    String bookingId,
    double latitude,
    double longitude,
    String? activityType,
    String? note,
    String? photoUrl,
    DateTime? recordedAt,
  });
}

/// @nodoc
class _$BookingTrackingCopyWithImpl<$Res, $Val extends BookingTracking>
    implements $BookingTrackingCopyWith<$Res> {
  _$BookingTrackingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingTracking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? activityType = freezed,
    Object? note = freezed,
    Object? photoUrl = freezed,
    Object? recordedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            bookingId:
                null == bookingId
                    ? _value.bookingId
                    : bookingId // ignore: cast_nullable_to_non_nullable
                        as String,
            latitude:
                null == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double,
            longitude:
                null == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double,
            activityType:
                freezed == activityType
                    ? _value.activityType
                    : activityType // ignore: cast_nullable_to_non_nullable
                        as String?,
            note:
                freezed == note
                    ? _value.note
                    : note // ignore: cast_nullable_to_non_nullable
                        as String?,
            photoUrl:
                freezed == photoUrl
                    ? _value.photoUrl
                    : photoUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            recordedAt:
                freezed == recordedAt
                    ? _value.recordedAt
                    : recordedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookingTrackingImplCopyWith<$Res>
    implements $BookingTrackingCopyWith<$Res> {
  factory _$$BookingTrackingImplCopyWith(
    _$BookingTrackingImpl value,
    $Res Function(_$BookingTrackingImpl) then,
  ) = __$$BookingTrackingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookingId,
    double latitude,
    double longitude,
    String? activityType,
    String? note,
    String? photoUrl,
    DateTime? recordedAt,
  });
}

/// @nodoc
class __$$BookingTrackingImplCopyWithImpl<$Res>
    extends _$BookingTrackingCopyWithImpl<$Res, _$BookingTrackingImpl>
    implements _$$BookingTrackingImplCopyWith<$Res> {
  __$$BookingTrackingImplCopyWithImpl(
    _$BookingTrackingImpl _value,
    $Res Function(_$BookingTrackingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingTracking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? activityType = freezed,
    Object? note = freezed,
    Object? photoUrl = freezed,
    Object? recordedAt = freezed,
  }) {
    return _then(
      _$BookingTrackingImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        bookingId:
            null == bookingId
                ? _value.bookingId
                : bookingId // ignore: cast_nullable_to_non_nullable
                    as String,
        latitude:
            null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double,
        longitude:
            null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double,
        activityType:
            freezed == activityType
                ? _value.activityType
                : activityType // ignore: cast_nullable_to_non_nullable
                    as String?,
        note:
            freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                    as String?,
        photoUrl:
            freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        recordedAt:
            freezed == recordedAt
                ? _value.recordedAt
                : recordedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingTrackingImpl implements _BookingTracking {
  const _$BookingTrackingImpl({
    required this.id,
    required this.bookingId,
    required this.latitude,
    required this.longitude,
    this.activityType,
    this.note,
    this.photoUrl,
    this.recordedAt,
  });

  factory _$BookingTrackingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingTrackingImplFromJson(json);

  @override
  final String id;
  @override
  final String bookingId;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? activityType;
  @override
  final String? note;
  @override
  final String? photoUrl;
  @override
  final DateTime? recordedAt;

  @override
  String toString() {
    return 'BookingTracking(id: $id, bookingId: $bookingId, latitude: $latitude, longitude: $longitude, activityType: $activityType, note: $note, photoUrl: $photoUrl, recordedAt: $recordedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingTrackingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bookingId,
    latitude,
    longitude,
    activityType,
    note,
    photoUrl,
    recordedAt,
  );

  /// Create a copy of BookingTracking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingTrackingImplCopyWith<_$BookingTrackingImpl> get copyWith =>
      __$$BookingTrackingImplCopyWithImpl<_$BookingTrackingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingTrackingImplToJson(this);
  }
}

abstract class _BookingTracking implements BookingTracking {
  const factory _BookingTracking({
    required final String id,
    required final String bookingId,
    required final double latitude,
    required final double longitude,
    final String? activityType,
    final String? note,
    final String? photoUrl,
    final DateTime? recordedAt,
  }) = _$BookingTrackingImpl;

  factory _BookingTracking.fromJson(Map<String, dynamic> json) =
      _$BookingTrackingImpl.fromJson;

  @override
  String get id;
  @override
  String get bookingId;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get activityType;
  @override
  String? get note;
  @override
  String? get photoUrl;
  @override
  DateTime? get recordedAt;

  /// Create a copy of BookingTracking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingTrackingImplCopyWith<_$BookingTrackingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AddTrackingRequest _$AddTrackingRequestFromJson(Map<String, dynamic> json) {
  return _AddTrackingRequest.fromJson(json);
}

/// @nodoc
mixin _$AddTrackingRequest {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get activityType => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Serializes this AddTrackingRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddTrackingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddTrackingRequestCopyWith<AddTrackingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddTrackingRequestCopyWith<$Res> {
  factory $AddTrackingRequestCopyWith(
    AddTrackingRequest value,
    $Res Function(AddTrackingRequest) then,
  ) = _$AddTrackingRequestCopyWithImpl<$Res, AddTrackingRequest>;
  @useResult
  $Res call({
    double latitude,
    double longitude,
    String? activityType,
    String? note,
    String? photoUrl,
  });
}

/// @nodoc
class _$AddTrackingRequestCopyWithImpl<$Res, $Val extends AddTrackingRequest>
    implements $AddTrackingRequestCopyWith<$Res> {
  _$AddTrackingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddTrackingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? activityType = freezed,
    Object? note = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            latitude:
                null == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double,
            longitude:
                null == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double,
            activityType:
                freezed == activityType
                    ? _value.activityType
                    : activityType // ignore: cast_nullable_to_non_nullable
                        as String?,
            note:
                freezed == note
                    ? _value.note
                    : note // ignore: cast_nullable_to_non_nullable
                        as String?,
            photoUrl:
                freezed == photoUrl
                    ? _value.photoUrl
                    : photoUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddTrackingRequestImplCopyWith<$Res>
    implements $AddTrackingRequestCopyWith<$Res> {
  factory _$$AddTrackingRequestImplCopyWith(
    _$AddTrackingRequestImpl value,
    $Res Function(_$AddTrackingRequestImpl) then,
  ) = __$$AddTrackingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double latitude,
    double longitude,
    String? activityType,
    String? note,
    String? photoUrl,
  });
}

/// @nodoc
class __$$AddTrackingRequestImplCopyWithImpl<$Res>
    extends _$AddTrackingRequestCopyWithImpl<$Res, _$AddTrackingRequestImpl>
    implements _$$AddTrackingRequestImplCopyWith<$Res> {
  __$$AddTrackingRequestImplCopyWithImpl(
    _$AddTrackingRequestImpl _value,
    $Res Function(_$AddTrackingRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddTrackingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? activityType = freezed,
    Object? note = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _$AddTrackingRequestImpl(
        latitude:
            null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double,
        longitude:
            null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double,
        activityType:
            freezed == activityType
                ? _value.activityType
                : activityType // ignore: cast_nullable_to_non_nullable
                    as String?,
        note:
            freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                    as String?,
        photoUrl:
            freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AddTrackingRequestImpl implements _AddTrackingRequest {
  const _$AddTrackingRequestImpl({
    required this.latitude,
    required this.longitude,
    this.activityType,
    this.note,
    this.photoUrl,
  });

  factory _$AddTrackingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddTrackingRequestImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? activityType;
  @override
  final String? note;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'AddTrackingRequest(latitude: $latitude, longitude: $longitude, activityType: $activityType, note: $note, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddTrackingRequestImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    latitude,
    longitude,
    activityType,
    note,
    photoUrl,
  );

  /// Create a copy of AddTrackingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddTrackingRequestImplCopyWith<_$AddTrackingRequestImpl> get copyWith =>
      __$$AddTrackingRequestImplCopyWithImpl<_$AddTrackingRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AddTrackingRequestImplToJson(this);
  }
}

abstract class _AddTrackingRequest implements AddTrackingRequest {
  const factory _AddTrackingRequest({
    required final double latitude,
    required final double longitude,
    final String? activityType,
    final String? note,
    final String? photoUrl,
  }) = _$AddTrackingRequestImpl;

  factory _AddTrackingRequest.fromJson(Map<String, dynamic> json) =
      _$AddTrackingRequestImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get activityType;
  @override
  String? get note;
  @override
  String? get photoUrl;

  /// Create a copy of AddTrackingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddTrackingRequestImplCopyWith<_$AddTrackingRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompletionReport _$CompletionReportFromJson(Map<String, dynamic> json) {
  return _CompletionReport.fromJson(json);
}

/// @nodoc
mixin _$CompletionReport {
  String get id => throw _privateConstructorUsedError;
  String get bookingId => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  List<String> get activitiesPerformed => throw _privateConstructorUsedError;
  String? get behaviorNotes => throw _privateConstructorUsedError;
  String? get feedingNotes => throw _privateConstructorUsedError;
  String? get medicationGiven => throw _privateConstructorUsedError;
  int? get actualDurationMinutes => throw _privateConstructorUsedError;
  double? get distanceWalkedKm => throw _privateConstructorUsedError;
  List<String> get photos => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this CompletionReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompletionReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompletionReportCopyWith<CompletionReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompletionReportCopyWith<$Res> {
  factory $CompletionReportCopyWith(
    CompletionReport value,
    $Res Function(CompletionReport) then,
  ) = _$CompletionReportCopyWithImpl<$Res, CompletionReport>;
  @useResult
  $Res call({
    String id,
    String bookingId,
    String summary,
    List<String> activitiesPerformed,
    String? behaviorNotes,
    String? feedingNotes,
    String? medicationGiven,
    int? actualDurationMinutes,
    double? distanceWalkedKm,
    List<String> photos,
    DateTime? submittedAt,
  });
}

/// @nodoc
class _$CompletionReportCopyWithImpl<$Res, $Val extends CompletionReport>
    implements $CompletionReportCopyWith<$Res> {
  _$CompletionReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompletionReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? summary = null,
    Object? activitiesPerformed = null,
    Object? behaviorNotes = freezed,
    Object? feedingNotes = freezed,
    Object? medicationGiven = freezed,
    Object? actualDurationMinutes = freezed,
    Object? distanceWalkedKm = freezed,
    Object? photos = null,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            bookingId:
                null == bookingId
                    ? _value.bookingId
                    : bookingId // ignore: cast_nullable_to_non_nullable
                        as String,
            summary:
                null == summary
                    ? _value.summary
                    : summary // ignore: cast_nullable_to_non_nullable
                        as String,
            activitiesPerformed:
                null == activitiesPerformed
                    ? _value.activitiesPerformed
                    : activitiesPerformed // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            behaviorNotes:
                freezed == behaviorNotes
                    ? _value.behaviorNotes
                    : behaviorNotes // ignore: cast_nullable_to_non_nullable
                        as String?,
            feedingNotes:
                freezed == feedingNotes
                    ? _value.feedingNotes
                    : feedingNotes // ignore: cast_nullable_to_non_nullable
                        as String?,
            medicationGiven:
                freezed == medicationGiven
                    ? _value.medicationGiven
                    : medicationGiven // ignore: cast_nullable_to_non_nullable
                        as String?,
            actualDurationMinutes:
                freezed == actualDurationMinutes
                    ? _value.actualDurationMinutes
                    : actualDurationMinutes // ignore: cast_nullable_to_non_nullable
                        as int?,
            distanceWalkedKm:
                freezed == distanceWalkedKm
                    ? _value.distanceWalkedKm
                    : distanceWalkedKm // ignore: cast_nullable_to_non_nullable
                        as double?,
            photos:
                null == photos
                    ? _value.photos
                    : photos // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            submittedAt:
                freezed == submittedAt
                    ? _value.submittedAt
                    : submittedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompletionReportImplCopyWith<$Res>
    implements $CompletionReportCopyWith<$Res> {
  factory _$$CompletionReportImplCopyWith(
    _$CompletionReportImpl value,
    $Res Function(_$CompletionReportImpl) then,
  ) = __$$CompletionReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookingId,
    String summary,
    List<String> activitiesPerformed,
    String? behaviorNotes,
    String? feedingNotes,
    String? medicationGiven,
    int? actualDurationMinutes,
    double? distanceWalkedKm,
    List<String> photos,
    DateTime? submittedAt,
  });
}

/// @nodoc
class __$$CompletionReportImplCopyWithImpl<$Res>
    extends _$CompletionReportCopyWithImpl<$Res, _$CompletionReportImpl>
    implements _$$CompletionReportImplCopyWith<$Res> {
  __$$CompletionReportImplCopyWithImpl(
    _$CompletionReportImpl _value,
    $Res Function(_$CompletionReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompletionReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? summary = null,
    Object? activitiesPerformed = null,
    Object? behaviorNotes = freezed,
    Object? feedingNotes = freezed,
    Object? medicationGiven = freezed,
    Object? actualDurationMinutes = freezed,
    Object? distanceWalkedKm = freezed,
    Object? photos = null,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _$CompletionReportImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        bookingId:
            null == bookingId
                ? _value.bookingId
                : bookingId // ignore: cast_nullable_to_non_nullable
                    as String,
        summary:
            null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                    as String,
        activitiesPerformed:
            null == activitiesPerformed
                ? _value._activitiesPerformed
                : activitiesPerformed // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        behaviorNotes:
            freezed == behaviorNotes
                ? _value.behaviorNotes
                : behaviorNotes // ignore: cast_nullable_to_non_nullable
                    as String?,
        feedingNotes:
            freezed == feedingNotes
                ? _value.feedingNotes
                : feedingNotes // ignore: cast_nullable_to_non_nullable
                    as String?,
        medicationGiven:
            freezed == medicationGiven
                ? _value.medicationGiven
                : medicationGiven // ignore: cast_nullable_to_non_nullable
                    as String?,
        actualDurationMinutes:
            freezed == actualDurationMinutes
                ? _value.actualDurationMinutes
                : actualDurationMinutes // ignore: cast_nullable_to_non_nullable
                    as int?,
        distanceWalkedKm:
            freezed == distanceWalkedKm
                ? _value.distanceWalkedKm
                : distanceWalkedKm // ignore: cast_nullable_to_non_nullable
                    as double?,
        photos:
            null == photos
                ? _value._photos
                : photos // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        submittedAt:
            freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompletionReportImpl implements _CompletionReport {
  const _$CompletionReportImpl({
    required this.id,
    required this.bookingId,
    required this.summary,
    final List<String> activitiesPerformed = const [],
    this.behaviorNotes,
    this.feedingNotes,
    this.medicationGiven,
    this.actualDurationMinutes,
    this.distanceWalkedKm,
    final List<String> photos = const [],
    this.submittedAt,
  }) : _activitiesPerformed = activitiesPerformed,
       _photos = photos;

  factory _$CompletionReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompletionReportImplFromJson(json);

  @override
  final String id;
  @override
  final String bookingId;
  @override
  final String summary;
  final List<String> _activitiesPerformed;
  @override
  @JsonKey()
  List<String> get activitiesPerformed {
    if (_activitiesPerformed is EqualUnmodifiableListView)
      return _activitiesPerformed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activitiesPerformed);
  }

  @override
  final String? behaviorNotes;
  @override
  final String? feedingNotes;
  @override
  final String? medicationGiven;
  @override
  final int? actualDurationMinutes;
  @override
  final double? distanceWalkedKm;
  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  final DateTime? submittedAt;

  @override
  String toString() {
    return 'CompletionReport(id: $id, bookingId: $bookingId, summary: $summary, activitiesPerformed: $activitiesPerformed, behaviorNotes: $behaviorNotes, feedingNotes: $feedingNotes, medicationGiven: $medicationGiven, actualDurationMinutes: $actualDurationMinutes, distanceWalkedKm: $distanceWalkedKm, photos: $photos, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletionReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._activitiesPerformed,
              _activitiesPerformed,
            ) &&
            (identical(other.behaviorNotes, behaviorNotes) ||
                other.behaviorNotes == behaviorNotes) &&
            (identical(other.feedingNotes, feedingNotes) ||
                other.feedingNotes == feedingNotes) &&
            (identical(other.medicationGiven, medicationGiven) ||
                other.medicationGiven == medicationGiven) &&
            (identical(other.actualDurationMinutes, actualDurationMinutes) ||
                other.actualDurationMinutes == actualDurationMinutes) &&
            (identical(other.distanceWalkedKm, distanceWalkedKm) ||
                other.distanceWalkedKm == distanceWalkedKm) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bookingId,
    summary,
    const DeepCollectionEquality().hash(_activitiesPerformed),
    behaviorNotes,
    feedingNotes,
    medicationGiven,
    actualDurationMinutes,
    distanceWalkedKm,
    const DeepCollectionEquality().hash(_photos),
    submittedAt,
  );

  /// Create a copy of CompletionReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletionReportImplCopyWith<_$CompletionReportImpl> get copyWith =>
      __$$CompletionReportImplCopyWithImpl<_$CompletionReportImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CompletionReportImplToJson(this);
  }
}

abstract class _CompletionReport implements CompletionReport {
  const factory _CompletionReport({
    required final String id,
    required final String bookingId,
    required final String summary,
    final List<String> activitiesPerformed,
    final String? behaviorNotes,
    final String? feedingNotes,
    final String? medicationGiven,
    final int? actualDurationMinutes,
    final double? distanceWalkedKm,
    final List<String> photos,
    final DateTime? submittedAt,
  }) = _$CompletionReportImpl;

  factory _CompletionReport.fromJson(Map<String, dynamic> json) =
      _$CompletionReportImpl.fromJson;

  @override
  String get id;
  @override
  String get bookingId;
  @override
  String get summary;
  @override
  List<String> get activitiesPerformed;
  @override
  String? get behaviorNotes;
  @override
  String? get feedingNotes;
  @override
  String? get medicationGiven;
  @override
  int? get actualDurationMinutes;
  @override
  double? get distanceWalkedKm;
  @override
  List<String> get photos;
  @override
  DateTime? get submittedAt;

  /// Create a copy of CompletionReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompletionReportImplCopyWith<_$CompletionReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubmitCompletionReportRequest _$SubmitCompletionReportRequestFromJson(
  Map<String, dynamic> json,
) {
  return _SubmitCompletionReportRequest.fromJson(json);
}

/// @nodoc
mixin _$SubmitCompletionReportRequest {
  String get summary => throw _privateConstructorUsedError;
  List<String>? get activitiesPerformed => throw _privateConstructorUsedError;
  String? get behaviorNotes => throw _privateConstructorUsedError;
  String? get feedingNotes => throw _privateConstructorUsedError;
  String? get medicationGiven => throw _privateConstructorUsedError;
  int? get actualDurationMinutes => throw _privateConstructorUsedError;
  double? get distanceWalkedKm => throw _privateConstructorUsedError;
  List<String>? get photos => throw _privateConstructorUsedError;

  /// Serializes this SubmitCompletionReportRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmitCompletionReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmitCompletionReportRequestCopyWith<SubmitCompletionReportRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitCompletionReportRequestCopyWith<$Res> {
  factory $SubmitCompletionReportRequestCopyWith(
    SubmitCompletionReportRequest value,
    $Res Function(SubmitCompletionReportRequest) then,
  ) =
      _$SubmitCompletionReportRequestCopyWithImpl<
        $Res,
        SubmitCompletionReportRequest
      >;
  @useResult
  $Res call({
    String summary,
    List<String>? activitiesPerformed,
    String? behaviorNotes,
    String? feedingNotes,
    String? medicationGiven,
    int? actualDurationMinutes,
    double? distanceWalkedKm,
    List<String>? photos,
  });
}

/// @nodoc
class _$SubmitCompletionReportRequestCopyWithImpl<
  $Res,
  $Val extends SubmitCompletionReportRequest
>
    implements $SubmitCompletionReportRequestCopyWith<$Res> {
  _$SubmitCompletionReportRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmitCompletionReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? activitiesPerformed = freezed,
    Object? behaviorNotes = freezed,
    Object? feedingNotes = freezed,
    Object? medicationGiven = freezed,
    Object? actualDurationMinutes = freezed,
    Object? distanceWalkedKm = freezed,
    Object? photos = freezed,
  }) {
    return _then(
      _value.copyWith(
            summary:
                null == summary
                    ? _value.summary
                    : summary // ignore: cast_nullable_to_non_nullable
                        as String,
            activitiesPerformed:
                freezed == activitiesPerformed
                    ? _value.activitiesPerformed
                    : activitiesPerformed // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            behaviorNotes:
                freezed == behaviorNotes
                    ? _value.behaviorNotes
                    : behaviorNotes // ignore: cast_nullable_to_non_nullable
                        as String?,
            feedingNotes:
                freezed == feedingNotes
                    ? _value.feedingNotes
                    : feedingNotes // ignore: cast_nullable_to_non_nullable
                        as String?,
            medicationGiven:
                freezed == medicationGiven
                    ? _value.medicationGiven
                    : medicationGiven // ignore: cast_nullable_to_non_nullable
                        as String?,
            actualDurationMinutes:
                freezed == actualDurationMinutes
                    ? _value.actualDurationMinutes
                    : actualDurationMinutes // ignore: cast_nullable_to_non_nullable
                        as int?,
            distanceWalkedKm:
                freezed == distanceWalkedKm
                    ? _value.distanceWalkedKm
                    : distanceWalkedKm // ignore: cast_nullable_to_non_nullable
                        as double?,
            photos:
                freezed == photos
                    ? _value.photos
                    : photos // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmitCompletionReportRequestImplCopyWith<$Res>
    implements $SubmitCompletionReportRequestCopyWith<$Res> {
  factory _$$SubmitCompletionReportRequestImplCopyWith(
    _$SubmitCompletionReportRequestImpl value,
    $Res Function(_$SubmitCompletionReportRequestImpl) then,
  ) = __$$SubmitCompletionReportRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String summary,
    List<String>? activitiesPerformed,
    String? behaviorNotes,
    String? feedingNotes,
    String? medicationGiven,
    int? actualDurationMinutes,
    double? distanceWalkedKm,
    List<String>? photos,
  });
}

/// @nodoc
class __$$SubmitCompletionReportRequestImplCopyWithImpl<$Res>
    extends
        _$SubmitCompletionReportRequestCopyWithImpl<
          $Res,
          _$SubmitCompletionReportRequestImpl
        >
    implements _$$SubmitCompletionReportRequestImplCopyWith<$Res> {
  __$$SubmitCompletionReportRequestImplCopyWithImpl(
    _$SubmitCompletionReportRequestImpl _value,
    $Res Function(_$SubmitCompletionReportRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubmitCompletionReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? activitiesPerformed = freezed,
    Object? behaviorNotes = freezed,
    Object? feedingNotes = freezed,
    Object? medicationGiven = freezed,
    Object? actualDurationMinutes = freezed,
    Object? distanceWalkedKm = freezed,
    Object? photos = freezed,
  }) {
    return _then(
      _$SubmitCompletionReportRequestImpl(
        summary:
            null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                    as String,
        activitiesPerformed:
            freezed == activitiesPerformed
                ? _value._activitiesPerformed
                : activitiesPerformed // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        behaviorNotes:
            freezed == behaviorNotes
                ? _value.behaviorNotes
                : behaviorNotes // ignore: cast_nullable_to_non_nullable
                    as String?,
        feedingNotes:
            freezed == feedingNotes
                ? _value.feedingNotes
                : feedingNotes // ignore: cast_nullable_to_non_nullable
                    as String?,
        medicationGiven:
            freezed == medicationGiven
                ? _value.medicationGiven
                : medicationGiven // ignore: cast_nullable_to_non_nullable
                    as String?,
        actualDurationMinutes:
            freezed == actualDurationMinutes
                ? _value.actualDurationMinutes
                : actualDurationMinutes // ignore: cast_nullable_to_non_nullable
                    as int?,
        distanceWalkedKm:
            freezed == distanceWalkedKm
                ? _value.distanceWalkedKm
                : distanceWalkedKm // ignore: cast_nullable_to_non_nullable
                    as double?,
        photos:
            freezed == photos
                ? _value._photos
                : photos // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmitCompletionReportRequestImpl
    implements _SubmitCompletionReportRequest {
  const _$SubmitCompletionReportRequestImpl({
    required this.summary,
    final List<String>? activitiesPerformed,
    this.behaviorNotes,
    this.feedingNotes,
    this.medicationGiven,
    this.actualDurationMinutes,
    this.distanceWalkedKm,
    final List<String>? photos,
  }) : _activitiesPerformed = activitiesPerformed,
       _photos = photos;

  factory _$SubmitCompletionReportRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SubmitCompletionReportRequestImplFromJson(json);

  @override
  final String summary;
  final List<String>? _activitiesPerformed;
  @override
  List<String>? get activitiesPerformed {
    final value = _activitiesPerformed;
    if (value == null) return null;
    if (_activitiesPerformed is EqualUnmodifiableListView)
      return _activitiesPerformed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? behaviorNotes;
  @override
  final String? feedingNotes;
  @override
  final String? medicationGiven;
  @override
  final int? actualDurationMinutes;
  @override
  final double? distanceWalkedKm;
  final List<String>? _photos;
  @override
  List<String>? get photos {
    final value = _photos;
    if (value == null) return null;
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SubmitCompletionReportRequest(summary: $summary, activitiesPerformed: $activitiesPerformed, behaviorNotes: $behaviorNotes, feedingNotes: $feedingNotes, medicationGiven: $medicationGiven, actualDurationMinutes: $actualDurationMinutes, distanceWalkedKm: $distanceWalkedKm, photos: $photos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitCompletionReportRequestImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._activitiesPerformed,
              _activitiesPerformed,
            ) &&
            (identical(other.behaviorNotes, behaviorNotes) ||
                other.behaviorNotes == behaviorNotes) &&
            (identical(other.feedingNotes, feedingNotes) ||
                other.feedingNotes == feedingNotes) &&
            (identical(other.medicationGiven, medicationGiven) ||
                other.medicationGiven == medicationGiven) &&
            (identical(other.actualDurationMinutes, actualDurationMinutes) ||
                other.actualDurationMinutes == actualDurationMinutes) &&
            (identical(other.distanceWalkedKm, distanceWalkedKm) ||
                other.distanceWalkedKm == distanceWalkedKm) &&
            const DeepCollectionEquality().equals(other._photos, _photos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    summary,
    const DeepCollectionEquality().hash(_activitiesPerformed),
    behaviorNotes,
    feedingNotes,
    medicationGiven,
    actualDurationMinutes,
    distanceWalkedKm,
    const DeepCollectionEquality().hash(_photos),
  );

  /// Create a copy of SubmitCompletionReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitCompletionReportRequestImplCopyWith<
    _$SubmitCompletionReportRequestImpl
  >
  get copyWith => __$$SubmitCompletionReportRequestImplCopyWithImpl<
    _$SubmitCompletionReportRequestImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmitCompletionReportRequestImplToJson(this);
  }
}

abstract class _SubmitCompletionReportRequest
    implements SubmitCompletionReportRequest {
  const factory _SubmitCompletionReportRequest({
    required final String summary,
    final List<String>? activitiesPerformed,
    final String? behaviorNotes,
    final String? feedingNotes,
    final String? medicationGiven,
    final int? actualDurationMinutes,
    final double? distanceWalkedKm,
    final List<String>? photos,
  }) = _$SubmitCompletionReportRequestImpl;

  factory _SubmitCompletionReportRequest.fromJson(Map<String, dynamic> json) =
      _$SubmitCompletionReportRequestImpl.fromJson;

  @override
  String get summary;
  @override
  List<String>? get activitiesPerformed;
  @override
  String? get behaviorNotes;
  @override
  String? get feedingNotes;
  @override
  String? get medicationGiven;
  @override
  int? get actualDurationMinutes;
  @override
  double? get distanceWalkedKm;
  @override
  List<String>? get photos;

  /// Create a copy of SubmitCompletionReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitCompletionReportRequestImplCopyWith<
    _$SubmitCompletionReportRequestImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

ServiceReview _$ServiceReviewFromJson(Map<String, dynamic> json) {
  return _ServiceReview.fromJson(json);
}

/// @nodoc
mixin _$ServiceReview {
  String get id => throw _privateConstructorUsedError;
  String get bookingId => throw _privateConstructorUsedError;
  int? get ownerRating => throw _privateConstructorUsedError;
  String? get ownerReview => throw _privateConstructorUsedError;
  DateTime? get ownerReviewAt => throw _privateConstructorUsedError;
  int? get communicationRating => throw _privateConstructorUsedError;
  int? get reliabilityRating => throw _privateConstructorUsedError;
  int? get careQualityRating => throw _privateConstructorUsedError;
  int? get caregiverRating => throw _privateConstructorUsedError;
  String? get caregiverReview => throw _privateConstructorUsedError;
  DateTime? get caregiverReviewAt => throw _privateConstructorUsedError;
  int? get petBehaviorRating => throw _privateConstructorUsedError;
  String? get petBehaviorNotes => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceReviewCopyWith<ServiceReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceReviewCopyWith<$Res> {
  factory $ServiceReviewCopyWith(
    ServiceReview value,
    $Res Function(ServiceReview) then,
  ) = _$ServiceReviewCopyWithImpl<$Res, ServiceReview>;
  @useResult
  $Res call({
    String id,
    String bookingId,
    int? ownerRating,
    String? ownerReview,
    DateTime? ownerReviewAt,
    int? communicationRating,
    int? reliabilityRating,
    int? careQualityRating,
    int? caregiverRating,
    String? caregiverReview,
    DateTime? caregiverReviewAt,
    int? petBehaviorRating,
    String? petBehaviorNotes,
    bool isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$ServiceReviewCopyWithImpl<$Res, $Val extends ServiceReview>
    implements $ServiceReviewCopyWith<$Res> {
  _$ServiceReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? ownerRating = freezed,
    Object? ownerReview = freezed,
    Object? ownerReviewAt = freezed,
    Object? communicationRating = freezed,
    Object? reliabilityRating = freezed,
    Object? careQualityRating = freezed,
    Object? caregiverRating = freezed,
    Object? caregiverReview = freezed,
    Object? caregiverReviewAt = freezed,
    Object? petBehaviorRating = freezed,
    Object? petBehaviorNotes = freezed,
    Object? isPublic = null,
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
            bookingId:
                null == bookingId
                    ? _value.bookingId
                    : bookingId // ignore: cast_nullable_to_non_nullable
                        as String,
            ownerRating:
                freezed == ownerRating
                    ? _value.ownerRating
                    : ownerRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            ownerReview:
                freezed == ownerReview
                    ? _value.ownerReview
                    : ownerReview // ignore: cast_nullable_to_non_nullable
                        as String?,
            ownerReviewAt:
                freezed == ownerReviewAt
                    ? _value.ownerReviewAt
                    : ownerReviewAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            communicationRating:
                freezed == communicationRating
                    ? _value.communicationRating
                    : communicationRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            reliabilityRating:
                freezed == reliabilityRating
                    ? _value.reliabilityRating
                    : reliabilityRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            careQualityRating:
                freezed == careQualityRating
                    ? _value.careQualityRating
                    : careQualityRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            caregiverRating:
                freezed == caregiverRating
                    ? _value.caregiverRating
                    : caregiverRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            caregiverReview:
                freezed == caregiverReview
                    ? _value.caregiverReview
                    : caregiverReview // ignore: cast_nullable_to_non_nullable
                        as String?,
            caregiverReviewAt:
                freezed == caregiverReviewAt
                    ? _value.caregiverReviewAt
                    : caregiverReviewAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            petBehaviorRating:
                freezed == petBehaviorRating
                    ? _value.petBehaviorRating
                    : petBehaviorRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            petBehaviorNotes:
                freezed == petBehaviorNotes
                    ? _value.petBehaviorNotes
                    : petBehaviorNotes // ignore: cast_nullable_to_non_nullable
                        as String?,
            isPublic:
                null == isPublic
                    ? _value.isPublic
                    : isPublic // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ServiceReviewImplCopyWith<$Res>
    implements $ServiceReviewCopyWith<$Res> {
  factory _$$ServiceReviewImplCopyWith(
    _$ServiceReviewImpl value,
    $Res Function(_$ServiceReviewImpl) then,
  ) = __$$ServiceReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookingId,
    int? ownerRating,
    String? ownerReview,
    DateTime? ownerReviewAt,
    int? communicationRating,
    int? reliabilityRating,
    int? careQualityRating,
    int? caregiverRating,
    String? caregiverReview,
    DateTime? caregiverReviewAt,
    int? petBehaviorRating,
    String? petBehaviorNotes,
    bool isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ServiceReviewImplCopyWithImpl<$Res>
    extends _$ServiceReviewCopyWithImpl<$Res, _$ServiceReviewImpl>
    implements _$$ServiceReviewImplCopyWith<$Res> {
  __$$ServiceReviewImplCopyWithImpl(
    _$ServiceReviewImpl _value,
    $Res Function(_$ServiceReviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? ownerRating = freezed,
    Object? ownerReview = freezed,
    Object? ownerReviewAt = freezed,
    Object? communicationRating = freezed,
    Object? reliabilityRating = freezed,
    Object? careQualityRating = freezed,
    Object? caregiverRating = freezed,
    Object? caregiverReview = freezed,
    Object? caregiverReviewAt = freezed,
    Object? petBehaviorRating = freezed,
    Object? petBehaviorNotes = freezed,
    Object? isPublic = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ServiceReviewImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        bookingId:
            null == bookingId
                ? _value.bookingId
                : bookingId // ignore: cast_nullable_to_non_nullable
                    as String,
        ownerRating:
            freezed == ownerRating
                ? _value.ownerRating
                : ownerRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        ownerReview:
            freezed == ownerReview
                ? _value.ownerReview
                : ownerReview // ignore: cast_nullable_to_non_nullable
                    as String?,
        ownerReviewAt:
            freezed == ownerReviewAt
                ? _value.ownerReviewAt
                : ownerReviewAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        communicationRating:
            freezed == communicationRating
                ? _value.communicationRating
                : communicationRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        reliabilityRating:
            freezed == reliabilityRating
                ? _value.reliabilityRating
                : reliabilityRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        careQualityRating:
            freezed == careQualityRating
                ? _value.careQualityRating
                : careQualityRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        caregiverRating:
            freezed == caregiverRating
                ? _value.caregiverRating
                : caregiverRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        caregiverReview:
            freezed == caregiverReview
                ? _value.caregiverReview
                : caregiverReview // ignore: cast_nullable_to_non_nullable
                    as String?,
        caregiverReviewAt:
            freezed == caregiverReviewAt
                ? _value.caregiverReviewAt
                : caregiverReviewAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        petBehaviorRating:
            freezed == petBehaviorRating
                ? _value.petBehaviorRating
                : petBehaviorRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        petBehaviorNotes:
            freezed == petBehaviorNotes
                ? _value.petBehaviorNotes
                : petBehaviorNotes // ignore: cast_nullable_to_non_nullable
                    as String?,
        isPublic:
            null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
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
class _$ServiceReviewImpl implements _ServiceReview {
  const _$ServiceReviewImpl({
    required this.id,
    required this.bookingId,
    this.ownerRating,
    this.ownerReview,
    this.ownerReviewAt,
    this.communicationRating,
    this.reliabilityRating,
    this.careQualityRating,
    this.caregiverRating,
    this.caregiverReview,
    this.caregiverReviewAt,
    this.petBehaviorRating,
    this.petBehaviorNotes,
    this.isPublic = true,
    this.createdAt,
    this.updatedAt,
  });

  factory _$ServiceReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceReviewImplFromJson(json);

  @override
  final String id;
  @override
  final String bookingId;
  @override
  final int? ownerRating;
  @override
  final String? ownerReview;
  @override
  final DateTime? ownerReviewAt;
  @override
  final int? communicationRating;
  @override
  final int? reliabilityRating;
  @override
  final int? careQualityRating;
  @override
  final int? caregiverRating;
  @override
  final String? caregiverReview;
  @override
  final DateTime? caregiverReviewAt;
  @override
  final int? petBehaviorRating;
  @override
  final String? petBehaviorNotes;
  @override
  @JsonKey()
  final bool isPublic;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ServiceReview(id: $id, bookingId: $bookingId, ownerRating: $ownerRating, ownerReview: $ownerReview, ownerReviewAt: $ownerReviewAt, communicationRating: $communicationRating, reliabilityRating: $reliabilityRating, careQualityRating: $careQualityRating, caregiverRating: $caregiverRating, caregiverReview: $caregiverReview, caregiverReviewAt: $caregiverReviewAt, petBehaviorRating: $petBehaviorRating, petBehaviorNotes: $petBehaviorNotes, isPublic: $isPublic, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.ownerRating, ownerRating) ||
                other.ownerRating == ownerRating) &&
            (identical(other.ownerReview, ownerReview) ||
                other.ownerReview == ownerReview) &&
            (identical(other.ownerReviewAt, ownerReviewAt) ||
                other.ownerReviewAt == ownerReviewAt) &&
            (identical(other.communicationRating, communicationRating) ||
                other.communicationRating == communicationRating) &&
            (identical(other.reliabilityRating, reliabilityRating) ||
                other.reliabilityRating == reliabilityRating) &&
            (identical(other.careQualityRating, careQualityRating) ||
                other.careQualityRating == careQualityRating) &&
            (identical(other.caregiverRating, caregiverRating) ||
                other.caregiverRating == caregiverRating) &&
            (identical(other.caregiverReview, caregiverReview) ||
                other.caregiverReview == caregiverReview) &&
            (identical(other.caregiverReviewAt, caregiverReviewAt) ||
                other.caregiverReviewAt == caregiverReviewAt) &&
            (identical(other.petBehaviorRating, petBehaviorRating) ||
                other.petBehaviorRating == petBehaviorRating) &&
            (identical(other.petBehaviorNotes, petBehaviorNotes) ||
                other.petBehaviorNotes == petBehaviorNotes) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
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
    bookingId,
    ownerRating,
    ownerReview,
    ownerReviewAt,
    communicationRating,
    reliabilityRating,
    careQualityRating,
    caregiverRating,
    caregiverReview,
    caregiverReviewAt,
    petBehaviorRating,
    petBehaviorNotes,
    isPublic,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ServiceReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceReviewImplCopyWith<_$ServiceReviewImpl> get copyWith =>
      __$$ServiceReviewImplCopyWithImpl<_$ServiceReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceReviewImplToJson(this);
  }
}

abstract class _ServiceReview implements ServiceReview {
  const factory _ServiceReview({
    required final String id,
    required final String bookingId,
    final int? ownerRating,
    final String? ownerReview,
    final DateTime? ownerReviewAt,
    final int? communicationRating,
    final int? reliabilityRating,
    final int? careQualityRating,
    final int? caregiverRating,
    final String? caregiverReview,
    final DateTime? caregiverReviewAt,
    final int? petBehaviorRating,
    final String? petBehaviorNotes,
    final bool isPublic,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ServiceReviewImpl;

  factory _ServiceReview.fromJson(Map<String, dynamic> json) =
      _$ServiceReviewImpl.fromJson;

  @override
  String get id;
  @override
  String get bookingId;
  @override
  int? get ownerRating;
  @override
  String? get ownerReview;
  @override
  DateTime? get ownerReviewAt;
  @override
  int? get communicationRating;
  @override
  int? get reliabilityRating;
  @override
  int? get careQualityRating;
  @override
  int? get caregiverRating;
  @override
  String? get caregiverReview;
  @override
  DateTime? get caregiverReviewAt;
  @override
  int? get petBehaviorRating;
  @override
  String? get petBehaviorNotes;
  @override
  bool get isPublic;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ServiceReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceReviewImplCopyWith<_$ServiceReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubmitOwnerReviewRequest _$SubmitOwnerReviewRequestFromJson(
  Map<String, dynamic> json,
) {
  return _SubmitOwnerReviewRequest.fromJson(json);
}

/// @nodoc
mixin _$SubmitOwnerReviewRequest {
  int get rating => throw _privateConstructorUsedError;
  String? get review => throw _privateConstructorUsedError;
  int? get communicationRating => throw _privateConstructorUsedError;
  int? get reliabilityRating => throw _privateConstructorUsedError;
  int? get careQualityRating => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;

  /// Serializes this SubmitOwnerReviewRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmitOwnerReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmitOwnerReviewRequestCopyWith<SubmitOwnerReviewRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitOwnerReviewRequestCopyWith<$Res> {
  factory $SubmitOwnerReviewRequestCopyWith(
    SubmitOwnerReviewRequest value,
    $Res Function(SubmitOwnerReviewRequest) then,
  ) = _$SubmitOwnerReviewRequestCopyWithImpl<$Res, SubmitOwnerReviewRequest>;
  @useResult
  $Res call({
    int rating,
    String? review,
    int? communicationRating,
    int? reliabilityRating,
    int? careQualityRating,
    bool isPublic,
  });
}

/// @nodoc
class _$SubmitOwnerReviewRequestCopyWithImpl<
  $Res,
  $Val extends SubmitOwnerReviewRequest
>
    implements $SubmitOwnerReviewRequestCopyWith<$Res> {
  _$SubmitOwnerReviewRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmitOwnerReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? review = freezed,
    Object? communicationRating = freezed,
    Object? reliabilityRating = freezed,
    Object? careQualityRating = freezed,
    Object? isPublic = null,
  }) {
    return _then(
      _value.copyWith(
            rating:
                null == rating
                    ? _value.rating
                    : rating // ignore: cast_nullable_to_non_nullable
                        as int,
            review:
                freezed == review
                    ? _value.review
                    : review // ignore: cast_nullable_to_non_nullable
                        as String?,
            communicationRating:
                freezed == communicationRating
                    ? _value.communicationRating
                    : communicationRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            reliabilityRating:
                freezed == reliabilityRating
                    ? _value.reliabilityRating
                    : reliabilityRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            careQualityRating:
                freezed == careQualityRating
                    ? _value.careQualityRating
                    : careQualityRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            isPublic:
                null == isPublic
                    ? _value.isPublic
                    : isPublic // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmitOwnerReviewRequestImplCopyWith<$Res>
    implements $SubmitOwnerReviewRequestCopyWith<$Res> {
  factory _$$SubmitOwnerReviewRequestImplCopyWith(
    _$SubmitOwnerReviewRequestImpl value,
    $Res Function(_$SubmitOwnerReviewRequestImpl) then,
  ) = __$$SubmitOwnerReviewRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int rating,
    String? review,
    int? communicationRating,
    int? reliabilityRating,
    int? careQualityRating,
    bool isPublic,
  });
}

/// @nodoc
class __$$SubmitOwnerReviewRequestImplCopyWithImpl<$Res>
    extends
        _$SubmitOwnerReviewRequestCopyWithImpl<
          $Res,
          _$SubmitOwnerReviewRequestImpl
        >
    implements _$$SubmitOwnerReviewRequestImplCopyWith<$Res> {
  __$$SubmitOwnerReviewRequestImplCopyWithImpl(
    _$SubmitOwnerReviewRequestImpl _value,
    $Res Function(_$SubmitOwnerReviewRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubmitOwnerReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? review = freezed,
    Object? communicationRating = freezed,
    Object? reliabilityRating = freezed,
    Object? careQualityRating = freezed,
    Object? isPublic = null,
  }) {
    return _then(
      _$SubmitOwnerReviewRequestImpl(
        rating:
            null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                    as int,
        review:
            freezed == review
                ? _value.review
                : review // ignore: cast_nullable_to_non_nullable
                    as String?,
        communicationRating:
            freezed == communicationRating
                ? _value.communicationRating
                : communicationRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        reliabilityRating:
            freezed == reliabilityRating
                ? _value.reliabilityRating
                : reliabilityRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        careQualityRating:
            freezed == careQualityRating
                ? _value.careQualityRating
                : careQualityRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        isPublic:
            null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmitOwnerReviewRequestImpl implements _SubmitOwnerReviewRequest {
  const _$SubmitOwnerReviewRequestImpl({
    required this.rating,
    this.review,
    this.communicationRating,
    this.reliabilityRating,
    this.careQualityRating,
    this.isPublic = true,
  });

  factory _$SubmitOwnerReviewRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmitOwnerReviewRequestImplFromJson(json);

  @override
  final int rating;
  @override
  final String? review;
  @override
  final int? communicationRating;
  @override
  final int? reliabilityRating;
  @override
  final int? careQualityRating;
  @override
  @JsonKey()
  final bool isPublic;

  @override
  String toString() {
    return 'SubmitOwnerReviewRequest(rating: $rating, review: $review, communicationRating: $communicationRating, reliabilityRating: $reliabilityRating, careQualityRating: $careQualityRating, isPublic: $isPublic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitOwnerReviewRequestImpl &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.review, review) || other.review == review) &&
            (identical(other.communicationRating, communicationRating) ||
                other.communicationRating == communicationRating) &&
            (identical(other.reliabilityRating, reliabilityRating) ||
                other.reliabilityRating == reliabilityRating) &&
            (identical(other.careQualityRating, careQualityRating) ||
                other.careQualityRating == careQualityRating) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rating,
    review,
    communicationRating,
    reliabilityRating,
    careQualityRating,
    isPublic,
  );

  /// Create a copy of SubmitOwnerReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitOwnerReviewRequestImplCopyWith<_$SubmitOwnerReviewRequestImpl>
  get copyWith => __$$SubmitOwnerReviewRequestImplCopyWithImpl<
    _$SubmitOwnerReviewRequestImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmitOwnerReviewRequestImplToJson(this);
  }
}

abstract class _SubmitOwnerReviewRequest implements SubmitOwnerReviewRequest {
  const factory _SubmitOwnerReviewRequest({
    required final int rating,
    final String? review,
    final int? communicationRating,
    final int? reliabilityRating,
    final int? careQualityRating,
    final bool isPublic,
  }) = _$SubmitOwnerReviewRequestImpl;

  factory _SubmitOwnerReviewRequest.fromJson(Map<String, dynamic> json) =
      _$SubmitOwnerReviewRequestImpl.fromJson;

  @override
  int get rating;
  @override
  String? get review;
  @override
  int? get communicationRating;
  @override
  int? get reliabilityRating;
  @override
  int? get careQualityRating;
  @override
  bool get isPublic;

  /// Create a copy of SubmitOwnerReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitOwnerReviewRequestImplCopyWith<_$SubmitOwnerReviewRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SubmitCaregiverReviewRequest _$SubmitCaregiverReviewRequestFromJson(
  Map<String, dynamic> json,
) {
  return _SubmitCaregiverReviewRequest.fromJson(json);
}

/// @nodoc
mixin _$SubmitCaregiverReviewRequest {
  int get rating => throw _privateConstructorUsedError;
  String? get review => throw _privateConstructorUsedError;
  int? get petBehaviorRating => throw _privateConstructorUsedError;
  String? get petBehaviorNotes => throw _privateConstructorUsedError;

  /// Serializes this SubmitCaregiverReviewRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmitCaregiverReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmitCaregiverReviewRequestCopyWith<SubmitCaregiverReviewRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitCaregiverReviewRequestCopyWith<$Res> {
  factory $SubmitCaregiverReviewRequestCopyWith(
    SubmitCaregiverReviewRequest value,
    $Res Function(SubmitCaregiverReviewRequest) then,
  ) =
      _$SubmitCaregiverReviewRequestCopyWithImpl<
        $Res,
        SubmitCaregiverReviewRequest
      >;
  @useResult
  $Res call({
    int rating,
    String? review,
    int? petBehaviorRating,
    String? petBehaviorNotes,
  });
}

/// @nodoc
class _$SubmitCaregiverReviewRequestCopyWithImpl<
  $Res,
  $Val extends SubmitCaregiverReviewRequest
>
    implements $SubmitCaregiverReviewRequestCopyWith<$Res> {
  _$SubmitCaregiverReviewRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmitCaregiverReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? review = freezed,
    Object? petBehaviorRating = freezed,
    Object? petBehaviorNotes = freezed,
  }) {
    return _then(
      _value.copyWith(
            rating:
                null == rating
                    ? _value.rating
                    : rating // ignore: cast_nullable_to_non_nullable
                        as int,
            review:
                freezed == review
                    ? _value.review
                    : review // ignore: cast_nullable_to_non_nullable
                        as String?,
            petBehaviorRating:
                freezed == petBehaviorRating
                    ? _value.petBehaviorRating
                    : petBehaviorRating // ignore: cast_nullable_to_non_nullable
                        as int?,
            petBehaviorNotes:
                freezed == petBehaviorNotes
                    ? _value.petBehaviorNotes
                    : petBehaviorNotes // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmitCaregiverReviewRequestImplCopyWith<$Res>
    implements $SubmitCaregiverReviewRequestCopyWith<$Res> {
  factory _$$SubmitCaregiverReviewRequestImplCopyWith(
    _$SubmitCaregiverReviewRequestImpl value,
    $Res Function(_$SubmitCaregiverReviewRequestImpl) then,
  ) = __$$SubmitCaregiverReviewRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int rating,
    String? review,
    int? petBehaviorRating,
    String? petBehaviorNotes,
  });
}

/// @nodoc
class __$$SubmitCaregiverReviewRequestImplCopyWithImpl<$Res>
    extends
        _$SubmitCaregiverReviewRequestCopyWithImpl<
          $Res,
          _$SubmitCaregiverReviewRequestImpl
        >
    implements _$$SubmitCaregiverReviewRequestImplCopyWith<$Res> {
  __$$SubmitCaregiverReviewRequestImplCopyWithImpl(
    _$SubmitCaregiverReviewRequestImpl _value,
    $Res Function(_$SubmitCaregiverReviewRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubmitCaregiverReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? review = freezed,
    Object? petBehaviorRating = freezed,
    Object? petBehaviorNotes = freezed,
  }) {
    return _then(
      _$SubmitCaregiverReviewRequestImpl(
        rating:
            null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                    as int,
        review:
            freezed == review
                ? _value.review
                : review // ignore: cast_nullable_to_non_nullable
                    as String?,
        petBehaviorRating:
            freezed == petBehaviorRating
                ? _value.petBehaviorRating
                : petBehaviorRating // ignore: cast_nullable_to_non_nullable
                    as int?,
        petBehaviorNotes:
            freezed == petBehaviorNotes
                ? _value.petBehaviorNotes
                : petBehaviorNotes // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmitCaregiverReviewRequestImpl
    implements _SubmitCaregiverReviewRequest {
  const _$SubmitCaregiverReviewRequestImpl({
    required this.rating,
    this.review,
    this.petBehaviorRating,
    this.petBehaviorNotes,
  });

  factory _$SubmitCaregiverReviewRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SubmitCaregiverReviewRequestImplFromJson(json);

  @override
  final int rating;
  @override
  final String? review;
  @override
  final int? petBehaviorRating;
  @override
  final String? petBehaviorNotes;

  @override
  String toString() {
    return 'SubmitCaregiverReviewRequest(rating: $rating, review: $review, petBehaviorRating: $petBehaviorRating, petBehaviorNotes: $petBehaviorNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitCaregiverReviewRequestImpl &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.review, review) || other.review == review) &&
            (identical(other.petBehaviorRating, petBehaviorRating) ||
                other.petBehaviorRating == petBehaviorRating) &&
            (identical(other.petBehaviorNotes, petBehaviorNotes) ||
                other.petBehaviorNotes == petBehaviorNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rating,
    review,
    petBehaviorRating,
    petBehaviorNotes,
  );

  /// Create a copy of SubmitCaregiverReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitCaregiverReviewRequestImplCopyWith<
    _$SubmitCaregiverReviewRequestImpl
  >
  get copyWith => __$$SubmitCaregiverReviewRequestImplCopyWithImpl<
    _$SubmitCaregiverReviewRequestImpl
  >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmitCaregiverReviewRequestImplToJson(this);
  }
}

abstract class _SubmitCaregiverReviewRequest
    implements SubmitCaregiverReviewRequest {
  const factory _SubmitCaregiverReviewRequest({
    required final int rating,
    final String? review,
    final int? petBehaviorRating,
    final String? petBehaviorNotes,
  }) = _$SubmitCaregiverReviewRequestImpl;

  factory _SubmitCaregiverReviewRequest.fromJson(Map<String, dynamic> json) =
      _$SubmitCaregiverReviewRequestImpl.fromJson;

  @override
  int get rating;
  @override
  String? get review;
  @override
  int? get petBehaviorRating;
  @override
  String? get petBehaviorNotes;

  /// Create a copy of SubmitCaregiverReviewRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitCaregiverReviewRequestImplCopyWith<
    _$SubmitCaregiverReviewRequestImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

BookingPayment _$BookingPaymentFromJson(Map<String, dynamic> json) {
  return _BookingPayment.fromJson(json);
}

/// @nodoc
mixin _$BookingPayment {
  String get id => throw _privateConstructorUsedError;
  String get bookingId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get paymentType =>
      throw _privateConstructorUsedError; // deposit, final, refund, tip
  String? get paymentMethod => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get escrowHeldAt => throw _privateConstructorUsedError;
  DateTime? get escrowReleasedAt => throw _privateConstructorUsedError;
  String get payoutStatus => throw _privateConstructorUsedError;
  double? get payoutAmount => throw _privateConstructorUsedError;
  double? get platformFee => throw _privateConstructorUsedError;
  String? get payoutTransactionId => throw _privateConstructorUsedError;
  DateTime? get payoutAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BookingPayment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingPaymentCopyWith<BookingPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingPaymentCopyWith<$Res> {
  factory $BookingPaymentCopyWith(
    BookingPayment value,
    $Res Function(BookingPayment) then,
  ) = _$BookingPaymentCopyWithImpl<$Res, BookingPayment>;
  @useResult
  $Res call({
    String id,
    String bookingId,
    double amount,
    String currency,
    String paymentType,
    String? paymentMethod,
    String? transactionId,
    String status,
    DateTime? escrowHeldAt,
    DateTime? escrowReleasedAt,
    String payoutStatus,
    double? payoutAmount,
    double? platformFee,
    String? payoutTransactionId,
    DateTime? payoutAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$BookingPaymentCopyWithImpl<$Res, $Val extends BookingPayment>
    implements $BookingPaymentCopyWith<$Res> {
  _$BookingPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? amount = null,
    Object? currency = null,
    Object? paymentType = null,
    Object? paymentMethod = freezed,
    Object? transactionId = freezed,
    Object? status = null,
    Object? escrowHeldAt = freezed,
    Object? escrowReleasedAt = freezed,
    Object? payoutStatus = null,
    Object? payoutAmount = freezed,
    Object? platformFee = freezed,
    Object? payoutTransactionId = freezed,
    Object? payoutAt = freezed,
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
            bookingId:
                null == bookingId
                    ? _value.bookingId
                    : bookingId // ignore: cast_nullable_to_non_nullable
                        as String,
            amount:
                null == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as double,
            currency:
                null == currency
                    ? _value.currency
                    : currency // ignore: cast_nullable_to_non_nullable
                        as String,
            paymentType:
                null == paymentType
                    ? _value.paymentType
                    : paymentType // ignore: cast_nullable_to_non_nullable
                        as String,
            paymentMethod:
                freezed == paymentMethod
                    ? _value.paymentMethod
                    : paymentMethod // ignore: cast_nullable_to_non_nullable
                        as String?,
            transactionId:
                freezed == transactionId
                    ? _value.transactionId
                    : transactionId // ignore: cast_nullable_to_non_nullable
                        as String?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            escrowHeldAt:
                freezed == escrowHeldAt
                    ? _value.escrowHeldAt
                    : escrowHeldAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            escrowReleasedAt:
                freezed == escrowReleasedAt
                    ? _value.escrowReleasedAt
                    : escrowReleasedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            payoutStatus:
                null == payoutStatus
                    ? _value.payoutStatus
                    : payoutStatus // ignore: cast_nullable_to_non_nullable
                        as String,
            payoutAmount:
                freezed == payoutAmount
                    ? _value.payoutAmount
                    : payoutAmount // ignore: cast_nullable_to_non_nullable
                        as double?,
            platformFee:
                freezed == platformFee
                    ? _value.platformFee
                    : platformFee // ignore: cast_nullable_to_non_nullable
                        as double?,
            payoutTransactionId:
                freezed == payoutTransactionId
                    ? _value.payoutTransactionId
                    : payoutTransactionId // ignore: cast_nullable_to_non_nullable
                        as String?,
            payoutAt:
                freezed == payoutAt
                    ? _value.payoutAt
                    : payoutAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
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
abstract class _$$BookingPaymentImplCopyWith<$Res>
    implements $BookingPaymentCopyWith<$Res> {
  factory _$$BookingPaymentImplCopyWith(
    _$BookingPaymentImpl value,
    $Res Function(_$BookingPaymentImpl) then,
  ) = __$$BookingPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookingId,
    double amount,
    String currency,
    String paymentType,
    String? paymentMethod,
    String? transactionId,
    String status,
    DateTime? escrowHeldAt,
    DateTime? escrowReleasedAt,
    String payoutStatus,
    double? payoutAmount,
    double? platformFee,
    String? payoutTransactionId,
    DateTime? payoutAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$BookingPaymentImplCopyWithImpl<$Res>
    extends _$BookingPaymentCopyWithImpl<$Res, _$BookingPaymentImpl>
    implements _$$BookingPaymentImplCopyWith<$Res> {
  __$$BookingPaymentImplCopyWithImpl(
    _$BookingPaymentImpl _value,
    $Res Function(_$BookingPaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? amount = null,
    Object? currency = null,
    Object? paymentType = null,
    Object? paymentMethod = freezed,
    Object? transactionId = freezed,
    Object? status = null,
    Object? escrowHeldAt = freezed,
    Object? escrowReleasedAt = freezed,
    Object? payoutStatus = null,
    Object? payoutAmount = freezed,
    Object? platformFee = freezed,
    Object? payoutTransactionId = freezed,
    Object? payoutAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$BookingPaymentImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        bookingId:
            null == bookingId
                ? _value.bookingId
                : bookingId // ignore: cast_nullable_to_non_nullable
                    as String,
        amount:
            null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as double,
        currency:
            null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                    as String,
        paymentType:
            null == paymentType
                ? _value.paymentType
                : paymentType // ignore: cast_nullable_to_non_nullable
                    as String,
        paymentMethod:
            freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                    as String?,
        transactionId:
            freezed == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                    as String?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        escrowHeldAt:
            freezed == escrowHeldAt
                ? _value.escrowHeldAt
                : escrowHeldAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        escrowReleasedAt:
            freezed == escrowReleasedAt
                ? _value.escrowReleasedAt
                : escrowReleasedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        payoutStatus:
            null == payoutStatus
                ? _value.payoutStatus
                : payoutStatus // ignore: cast_nullable_to_non_nullable
                    as String,
        payoutAmount:
            freezed == payoutAmount
                ? _value.payoutAmount
                : payoutAmount // ignore: cast_nullable_to_non_nullable
                    as double?,
        platformFee:
            freezed == platformFee
                ? _value.platformFee
                : platformFee // ignore: cast_nullable_to_non_nullable
                    as double?,
        payoutTransactionId:
            freezed == payoutTransactionId
                ? _value.payoutTransactionId
                : payoutTransactionId // ignore: cast_nullable_to_non_nullable
                    as String?,
        payoutAt:
            freezed == payoutAt
                ? _value.payoutAt
                : payoutAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
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
class _$BookingPaymentImpl implements _BookingPayment {
  const _$BookingPaymentImpl({
    required this.id,
    required this.bookingId,
    required this.amount,
    this.currency = 'PKR',
    required this.paymentType,
    this.paymentMethod,
    this.transactionId,
    this.status = 'pending',
    this.escrowHeldAt,
    this.escrowReleasedAt,
    this.payoutStatus = 'pending',
    this.payoutAmount,
    this.platformFee,
    this.payoutTransactionId,
    this.payoutAt,
    this.createdAt,
    this.updatedAt,
  });

  factory _$BookingPaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingPaymentImplFromJson(json);

  @override
  final String id;
  @override
  final String bookingId;
  @override
  final double amount;
  @override
  @JsonKey()
  final String currency;
  @override
  final String paymentType;
  // deposit, final, refund, tip
  @override
  final String? paymentMethod;
  @override
  final String? transactionId;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? escrowHeldAt;
  @override
  final DateTime? escrowReleasedAt;
  @override
  @JsonKey()
  final String payoutStatus;
  @override
  final double? payoutAmount;
  @override
  final double? platformFee;
  @override
  final String? payoutTransactionId;
  @override
  final DateTime? payoutAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BookingPayment(id: $id, bookingId: $bookingId, amount: $amount, currency: $currency, paymentType: $paymentType, paymentMethod: $paymentMethod, transactionId: $transactionId, status: $status, escrowHeldAt: $escrowHeldAt, escrowReleasedAt: $escrowReleasedAt, payoutStatus: $payoutStatus, payoutAmount: $payoutAmount, platformFee: $platformFee, payoutTransactionId: $payoutTransactionId, payoutAt: $payoutAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingPaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.paymentType, paymentType) ||
                other.paymentType == paymentType) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.escrowHeldAt, escrowHeldAt) ||
                other.escrowHeldAt == escrowHeldAt) &&
            (identical(other.escrowReleasedAt, escrowReleasedAt) ||
                other.escrowReleasedAt == escrowReleasedAt) &&
            (identical(other.payoutStatus, payoutStatus) ||
                other.payoutStatus == payoutStatus) &&
            (identical(other.payoutAmount, payoutAmount) ||
                other.payoutAmount == payoutAmount) &&
            (identical(other.platformFee, platformFee) ||
                other.platformFee == platformFee) &&
            (identical(other.payoutTransactionId, payoutTransactionId) ||
                other.payoutTransactionId == payoutTransactionId) &&
            (identical(other.payoutAt, payoutAt) ||
                other.payoutAt == payoutAt) &&
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
    bookingId,
    amount,
    currency,
    paymentType,
    paymentMethod,
    transactionId,
    status,
    escrowHeldAt,
    escrowReleasedAt,
    payoutStatus,
    payoutAmount,
    platformFee,
    payoutTransactionId,
    payoutAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of BookingPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingPaymentImplCopyWith<_$BookingPaymentImpl> get copyWith =>
      __$$BookingPaymentImplCopyWithImpl<_$BookingPaymentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingPaymentImplToJson(this);
  }
}

abstract class _BookingPayment implements BookingPayment {
  const factory _BookingPayment({
    required final String id,
    required final String bookingId,
    required final double amount,
    final String currency,
    required final String paymentType,
    final String? paymentMethod,
    final String? transactionId,
    final String status,
    final DateTime? escrowHeldAt,
    final DateTime? escrowReleasedAt,
    final String payoutStatus,
    final double? payoutAmount,
    final double? platformFee,
    final String? payoutTransactionId,
    final DateTime? payoutAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$BookingPaymentImpl;

  factory _BookingPayment.fromJson(Map<String, dynamic> json) =
      _$BookingPaymentImpl.fromJson;

  @override
  String get id;
  @override
  String get bookingId;
  @override
  double get amount;
  @override
  String get currency;
  @override
  String get paymentType; // deposit, final, refund, tip
  @override
  String? get paymentMethod;
  @override
  String? get transactionId;
  @override
  String get status;
  @override
  DateTime? get escrowHeldAt;
  @override
  DateTime? get escrowReleasedAt;
  @override
  String get payoutStatus;
  @override
  double? get payoutAmount;
  @override
  double? get platformFee;
  @override
  String? get payoutTransactionId;
  @override
  DateTime? get payoutAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of BookingPayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingPaymentImplCopyWith<_$BookingPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProcessPaymentRequest _$ProcessPaymentRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ProcessPaymentRequest.fromJson(json);
}

/// @nodoc
mixin _$ProcessPaymentRequest {
  double get amount => throw _privateConstructorUsedError;
  String get paymentType => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;

  /// Serializes this ProcessPaymentRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProcessPaymentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProcessPaymentRequestCopyWith<ProcessPaymentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProcessPaymentRequestCopyWith<$Res> {
  factory $ProcessPaymentRequestCopyWith(
    ProcessPaymentRequest value,
    $Res Function(ProcessPaymentRequest) then,
  ) = _$ProcessPaymentRequestCopyWithImpl<$Res, ProcessPaymentRequest>;
  @useResult
  $Res call({
    double amount,
    String paymentType,
    String paymentMethod,
    String? transactionId,
  });
}

/// @nodoc
class _$ProcessPaymentRequestCopyWithImpl<
  $Res,
  $Val extends ProcessPaymentRequest
>
    implements $ProcessPaymentRequestCopyWith<$Res> {
  _$ProcessPaymentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProcessPaymentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? paymentType = null,
    Object? paymentMethod = null,
    Object? transactionId = freezed,
  }) {
    return _then(
      _value.copyWith(
            amount:
                null == amount
                    ? _value.amount
                    : amount // ignore: cast_nullable_to_non_nullable
                        as double,
            paymentType:
                null == paymentType
                    ? _value.paymentType
                    : paymentType // ignore: cast_nullable_to_non_nullable
                        as String,
            paymentMethod:
                null == paymentMethod
                    ? _value.paymentMethod
                    : paymentMethod // ignore: cast_nullable_to_non_nullable
                        as String,
            transactionId:
                freezed == transactionId
                    ? _value.transactionId
                    : transactionId // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProcessPaymentRequestImplCopyWith<$Res>
    implements $ProcessPaymentRequestCopyWith<$Res> {
  factory _$$ProcessPaymentRequestImplCopyWith(
    _$ProcessPaymentRequestImpl value,
    $Res Function(_$ProcessPaymentRequestImpl) then,
  ) = __$$ProcessPaymentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double amount,
    String paymentType,
    String paymentMethod,
    String? transactionId,
  });
}

/// @nodoc
class __$$ProcessPaymentRequestImplCopyWithImpl<$Res>
    extends
        _$ProcessPaymentRequestCopyWithImpl<$Res, _$ProcessPaymentRequestImpl>
    implements _$$ProcessPaymentRequestImplCopyWith<$Res> {
  __$$ProcessPaymentRequestImplCopyWithImpl(
    _$ProcessPaymentRequestImpl _value,
    $Res Function(_$ProcessPaymentRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProcessPaymentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? paymentType = null,
    Object? paymentMethod = null,
    Object? transactionId = freezed,
  }) {
    return _then(
      _$ProcessPaymentRequestImpl(
        amount:
            null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                    as double,
        paymentType:
            null == paymentType
                ? _value.paymentType
                : paymentType // ignore: cast_nullable_to_non_nullable
                    as String,
        paymentMethod:
            null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                    as String,
        transactionId:
            freezed == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProcessPaymentRequestImpl implements _ProcessPaymentRequest {
  const _$ProcessPaymentRequestImpl({
    required this.amount,
    this.paymentType = 'final',
    required this.paymentMethod,
    this.transactionId,
  });

  factory _$ProcessPaymentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProcessPaymentRequestImplFromJson(json);

  @override
  final double amount;
  @override
  @JsonKey()
  final String paymentType;
  @override
  final String paymentMethod;
  @override
  final String? transactionId;

  @override
  String toString() {
    return 'ProcessPaymentRequest(amount: $amount, paymentType: $paymentType, paymentMethod: $paymentMethod, transactionId: $transactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessPaymentRequestImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentType, paymentType) ||
                other.paymentType == paymentType) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    amount,
    paymentType,
    paymentMethod,
    transactionId,
  );

  /// Create a copy of ProcessPaymentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessPaymentRequestImplCopyWith<_$ProcessPaymentRequestImpl>
  get copyWith =>
      __$$ProcessPaymentRequestImplCopyWithImpl<_$ProcessPaymentRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProcessPaymentRequestImplToJson(this);
  }
}

abstract class _ProcessPaymentRequest implements ProcessPaymentRequest {
  const factory _ProcessPaymentRequest({
    required final double amount,
    final String paymentType,
    required final String paymentMethod,
    final String? transactionId,
  }) = _$ProcessPaymentRequestImpl;

  factory _ProcessPaymentRequest.fromJson(Map<String, dynamic> json) =
      _$ProcessPaymentRequestImpl.fromJson;

  @override
  double get amount;
  @override
  String get paymentType;
  @override
  String get paymentMethod;
  @override
  String? get transactionId;

  /// Create a copy of ProcessPaymentRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessPaymentRequestImplCopyWith<_$ProcessPaymentRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ServiceIncident _$ServiceIncidentFromJson(Map<String, dynamic> json) {
  return _ServiceIncident.fromJson(json);
}

/// @nodoc
mixin _$ServiceIncident {
  String get id => throw _privateConstructorUsedError;
  String get bookingId => throw _privateConstructorUsedError;
  String get reportedBy => throw _privateConstructorUsedError;
  String get incidentType => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get photos => throw _privateConstructorUsedError;
  String? get vetVisitRequired => throw _privateConstructorUsedError;
  String? get vetDetails => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  DateTime? get reportedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceIncident to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceIncident
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceIncidentCopyWith<ServiceIncident> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceIncidentCopyWith<$Res> {
  factory $ServiceIncidentCopyWith(
    ServiceIncident value,
    $Res Function(ServiceIncident) then,
  ) = _$ServiceIncidentCopyWithImpl<$Res, ServiceIncident>;
  @useResult
  $Res call({
    String id,
    String bookingId,
    String reportedBy,
    String incidentType,
    String severity,
    String description,
    List<String> photos,
    String? vetVisitRequired,
    String? vetDetails,
    String status,
    String? resolution,
    DateTime? resolvedAt,
    DateTime? reportedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$ServiceIncidentCopyWithImpl<$Res, $Val extends ServiceIncident>
    implements $ServiceIncidentCopyWith<$Res> {
  _$ServiceIncidentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceIncident
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? reportedBy = null,
    Object? incidentType = null,
    Object? severity = null,
    Object? description = null,
    Object? photos = null,
    Object? vetVisitRequired = freezed,
    Object? vetDetails = freezed,
    Object? status = null,
    Object? resolution = freezed,
    Object? resolvedAt = freezed,
    Object? reportedAt = freezed,
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
            bookingId:
                null == bookingId
                    ? _value.bookingId
                    : bookingId // ignore: cast_nullable_to_non_nullable
                        as String,
            reportedBy:
                null == reportedBy
                    ? _value.reportedBy
                    : reportedBy // ignore: cast_nullable_to_non_nullable
                        as String,
            incidentType:
                null == incidentType
                    ? _value.incidentType
                    : incidentType // ignore: cast_nullable_to_non_nullable
                        as String,
            severity:
                null == severity
                    ? _value.severity
                    : severity // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            photos:
                null == photos
                    ? _value.photos
                    : photos // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            vetVisitRequired:
                freezed == vetVisitRequired
                    ? _value.vetVisitRequired
                    : vetVisitRequired // ignore: cast_nullable_to_non_nullable
                        as String?,
            vetDetails:
                freezed == vetDetails
                    ? _value.vetDetails
                    : vetDetails // ignore: cast_nullable_to_non_nullable
                        as String?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            resolution:
                freezed == resolution
                    ? _value.resolution
                    : resolution // ignore: cast_nullable_to_non_nullable
                        as String?,
            resolvedAt:
                freezed == resolvedAt
                    ? _value.resolvedAt
                    : resolvedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            reportedAt:
                freezed == reportedAt
                    ? _value.reportedAt
                    : reportedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
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
abstract class _$$ServiceIncidentImplCopyWith<$Res>
    implements $ServiceIncidentCopyWith<$Res> {
  factory _$$ServiceIncidentImplCopyWith(
    _$ServiceIncidentImpl value,
    $Res Function(_$ServiceIncidentImpl) then,
  ) = __$$ServiceIncidentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookingId,
    String reportedBy,
    String incidentType,
    String severity,
    String description,
    List<String> photos,
    String? vetVisitRequired,
    String? vetDetails,
    String status,
    String? resolution,
    DateTime? resolvedAt,
    DateTime? reportedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ServiceIncidentImplCopyWithImpl<$Res>
    extends _$ServiceIncidentCopyWithImpl<$Res, _$ServiceIncidentImpl>
    implements _$$ServiceIncidentImplCopyWith<$Res> {
  __$$ServiceIncidentImplCopyWithImpl(
    _$ServiceIncidentImpl _value,
    $Res Function(_$ServiceIncidentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceIncident
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? reportedBy = null,
    Object? incidentType = null,
    Object? severity = null,
    Object? description = null,
    Object? photos = null,
    Object? vetVisitRequired = freezed,
    Object? vetDetails = freezed,
    Object? status = null,
    Object? resolution = freezed,
    Object? resolvedAt = freezed,
    Object? reportedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ServiceIncidentImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        bookingId:
            null == bookingId
                ? _value.bookingId
                : bookingId // ignore: cast_nullable_to_non_nullable
                    as String,
        reportedBy:
            null == reportedBy
                ? _value.reportedBy
                : reportedBy // ignore: cast_nullable_to_non_nullable
                    as String,
        incidentType:
            null == incidentType
                ? _value.incidentType
                : incidentType // ignore: cast_nullable_to_non_nullable
                    as String,
        severity:
            null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        photos:
            null == photos
                ? _value._photos
                : photos // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        vetVisitRequired:
            freezed == vetVisitRequired
                ? _value.vetVisitRequired
                : vetVisitRequired // ignore: cast_nullable_to_non_nullable
                    as String?,
        vetDetails:
            freezed == vetDetails
                ? _value.vetDetails
                : vetDetails // ignore: cast_nullable_to_non_nullable
                    as String?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        resolution:
            freezed == resolution
                ? _value.resolution
                : resolution // ignore: cast_nullable_to_non_nullable
                    as String?,
        resolvedAt:
            freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        reportedAt:
            freezed == reportedAt
                ? _value.reportedAt
                : reportedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
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
class _$ServiceIncidentImpl implements _ServiceIncident {
  const _$ServiceIncidentImpl({
    required this.id,
    required this.bookingId,
    required this.reportedBy,
    required this.incidentType,
    required this.severity,
    required this.description,
    final List<String> photos = const [],
    this.vetVisitRequired,
    this.vetDetails,
    this.status = 'open',
    this.resolution,
    this.resolvedAt,
    this.reportedAt,
    this.createdAt,
    this.updatedAt,
  }) : _photos = photos;

  factory _$ServiceIncidentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceIncidentImplFromJson(json);

  @override
  final String id;
  @override
  final String bookingId;
  @override
  final String reportedBy;
  @override
  final String incidentType;
  @override
  final String severity;
  @override
  final String description;
  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  final String? vetVisitRequired;
  @override
  final String? vetDetails;
  @override
  @JsonKey()
  final String status;
  @override
  final String? resolution;
  @override
  final DateTime? resolvedAt;
  @override
  final DateTime? reportedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ServiceIncident(id: $id, bookingId: $bookingId, reportedBy: $reportedBy, incidentType: $incidentType, severity: $severity, description: $description, photos: $photos, vetVisitRequired: $vetVisitRequired, vetDetails: $vetDetails, status: $status, resolution: $resolution, resolvedAt: $resolvedAt, reportedAt: $reportedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceIncidentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.reportedBy, reportedBy) ||
                other.reportedBy == reportedBy) &&
            (identical(other.incidentType, incidentType) ||
                other.incidentType == incidentType) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.vetVisitRequired, vetVisitRequired) ||
                other.vetVisitRequired == vetVisitRequired) &&
            (identical(other.vetDetails, vetDetails) ||
                other.vetDetails == vetDetails) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.reportedAt, reportedAt) ||
                other.reportedAt == reportedAt) &&
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
    bookingId,
    reportedBy,
    incidentType,
    severity,
    description,
    const DeepCollectionEquality().hash(_photos),
    vetVisitRequired,
    vetDetails,
    status,
    resolution,
    resolvedAt,
    reportedAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ServiceIncident
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceIncidentImplCopyWith<_$ServiceIncidentImpl> get copyWith =>
      __$$ServiceIncidentImplCopyWithImpl<_$ServiceIncidentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceIncidentImplToJson(this);
  }
}

abstract class _ServiceIncident implements ServiceIncident {
  const factory _ServiceIncident({
    required final String id,
    required final String bookingId,
    required final String reportedBy,
    required final String incidentType,
    required final String severity,
    required final String description,
    final List<String> photos,
    final String? vetVisitRequired,
    final String? vetDetails,
    final String status,
    final String? resolution,
    final DateTime? resolvedAt,
    final DateTime? reportedAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ServiceIncidentImpl;

  factory _ServiceIncident.fromJson(Map<String, dynamic> json) =
      _$ServiceIncidentImpl.fromJson;

  @override
  String get id;
  @override
  String get bookingId;
  @override
  String get reportedBy;
  @override
  String get incidentType;
  @override
  String get severity;
  @override
  String get description;
  @override
  List<String> get photos;
  @override
  String? get vetVisitRequired;
  @override
  String? get vetDetails;
  @override
  String get status;
  @override
  String? get resolution;
  @override
  DateTime? get resolvedAt;
  @override
  DateTime? get reportedAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ServiceIncident
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceIncidentImplCopyWith<_$ServiceIncidentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportIncidentRequest _$ReportIncidentRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ReportIncidentRequest.fromJson(json);
}

/// @nodoc
mixin _$ReportIncidentRequest {
  String get incidentType => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String>? get photos => throw _privateConstructorUsedError;
  bool? get vetVisitRequired => throw _privateConstructorUsedError;
  String? get vetDetails => throw _privateConstructorUsedError;

  /// Serializes this ReportIncidentRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportIncidentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportIncidentRequestCopyWith<ReportIncidentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportIncidentRequestCopyWith<$Res> {
  factory $ReportIncidentRequestCopyWith(
    ReportIncidentRequest value,
    $Res Function(ReportIncidentRequest) then,
  ) = _$ReportIncidentRequestCopyWithImpl<$Res, ReportIncidentRequest>;
  @useResult
  $Res call({
    String incidentType,
    String severity,
    String description,
    List<String>? photos,
    bool? vetVisitRequired,
    String? vetDetails,
  });
}

/// @nodoc
class _$ReportIncidentRequestCopyWithImpl<
  $Res,
  $Val extends ReportIncidentRequest
>
    implements $ReportIncidentRequestCopyWith<$Res> {
  _$ReportIncidentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportIncidentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? incidentType = null,
    Object? severity = null,
    Object? description = null,
    Object? photos = freezed,
    Object? vetVisitRequired = freezed,
    Object? vetDetails = freezed,
  }) {
    return _then(
      _value.copyWith(
            incidentType:
                null == incidentType
                    ? _value.incidentType
                    : incidentType // ignore: cast_nullable_to_non_nullable
                        as String,
            severity:
                null == severity
                    ? _value.severity
                    : severity // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            photos:
                freezed == photos
                    ? _value.photos
                    : photos // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            vetVisitRequired:
                freezed == vetVisitRequired
                    ? _value.vetVisitRequired
                    : vetVisitRequired // ignore: cast_nullable_to_non_nullable
                        as bool?,
            vetDetails:
                freezed == vetDetails
                    ? _value.vetDetails
                    : vetDetails // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReportIncidentRequestImplCopyWith<$Res>
    implements $ReportIncidentRequestCopyWith<$Res> {
  factory _$$ReportIncidentRequestImplCopyWith(
    _$ReportIncidentRequestImpl value,
    $Res Function(_$ReportIncidentRequestImpl) then,
  ) = __$$ReportIncidentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String incidentType,
    String severity,
    String description,
    List<String>? photos,
    bool? vetVisitRequired,
    String? vetDetails,
  });
}

/// @nodoc
class __$$ReportIncidentRequestImplCopyWithImpl<$Res>
    extends
        _$ReportIncidentRequestCopyWithImpl<$Res, _$ReportIncidentRequestImpl>
    implements _$$ReportIncidentRequestImplCopyWith<$Res> {
  __$$ReportIncidentRequestImplCopyWithImpl(
    _$ReportIncidentRequestImpl _value,
    $Res Function(_$ReportIncidentRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportIncidentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? incidentType = null,
    Object? severity = null,
    Object? description = null,
    Object? photos = freezed,
    Object? vetVisitRequired = freezed,
    Object? vetDetails = freezed,
  }) {
    return _then(
      _$ReportIncidentRequestImpl(
        incidentType:
            null == incidentType
                ? _value.incidentType
                : incidentType // ignore: cast_nullable_to_non_nullable
                    as String,
        severity:
            null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        photos:
            freezed == photos
                ? _value._photos
                : photos // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        vetVisitRequired:
            freezed == vetVisitRequired
                ? _value.vetVisitRequired
                : vetVisitRequired // ignore: cast_nullable_to_non_nullable
                    as bool?,
        vetDetails:
            freezed == vetDetails
                ? _value.vetDetails
                : vetDetails // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportIncidentRequestImpl implements _ReportIncidentRequest {
  const _$ReportIncidentRequestImpl({
    required this.incidentType,
    required this.severity,
    required this.description,
    final List<String>? photos,
    this.vetVisitRequired,
    this.vetDetails,
  }) : _photos = photos;

  factory _$ReportIncidentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportIncidentRequestImplFromJson(json);

  @override
  final String incidentType;
  @override
  final String severity;
  @override
  final String description;
  final List<String>? _photos;
  @override
  List<String>? get photos {
    final value = _photos;
    if (value == null) return null;
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? vetVisitRequired;
  @override
  final String? vetDetails;

  @override
  String toString() {
    return 'ReportIncidentRequest(incidentType: $incidentType, severity: $severity, description: $description, photos: $photos, vetVisitRequired: $vetVisitRequired, vetDetails: $vetDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportIncidentRequestImpl &&
            (identical(other.incidentType, incidentType) ||
                other.incidentType == incidentType) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.vetVisitRequired, vetVisitRequired) ||
                other.vetVisitRequired == vetVisitRequired) &&
            (identical(other.vetDetails, vetDetails) ||
                other.vetDetails == vetDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    incidentType,
    severity,
    description,
    const DeepCollectionEquality().hash(_photos),
    vetVisitRequired,
    vetDetails,
  );

  /// Create a copy of ReportIncidentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportIncidentRequestImplCopyWith<_$ReportIncidentRequestImpl>
  get copyWith =>
      __$$ReportIncidentRequestImplCopyWithImpl<_$ReportIncidentRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportIncidentRequestImplToJson(this);
  }
}

abstract class _ReportIncidentRequest implements ReportIncidentRequest {
  const factory _ReportIncidentRequest({
    required final String incidentType,
    required final String severity,
    required final String description,
    final List<String>? photos,
    final bool? vetVisitRequired,
    final String? vetDetails,
  }) = _$ReportIncidentRequestImpl;

  factory _ReportIncidentRequest.fromJson(Map<String, dynamic> json) =
      _$ReportIncidentRequestImpl.fromJson;

  @override
  String get incidentType;
  @override
  String get severity;
  @override
  String get description;
  @override
  List<String>? get photos;
  @override
  bool? get vetVisitRequired;
  @override
  String? get vetDetails;

  /// Create a copy of ReportIncidentRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportIncidentRequestImplCopyWith<_$ReportIncidentRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
