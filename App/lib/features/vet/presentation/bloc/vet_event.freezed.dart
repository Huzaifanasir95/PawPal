// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vet_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VetEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadVetProfile,
    required TResult Function() loadMyProfile,
    required TResult Function(VetProfileRequest request) createOrUpdateProfile,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )
    listVets,
    required TResult Function(String query) searchVets,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
    )
    filterVets,
    required TResult Function() clearFilters,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadVetProfile,
    TResult? Function()? loadMyProfile,
    TResult? Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult? Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult? Function(String query)? searchVets,
    TResult? Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult? Function()? clearFilters,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadVetProfile,
    TResult Function()? loadMyProfile,
    TResult Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult Function(String query)? searchVets,
    TResult Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult Function()? clearFilters,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadVetProfile value) loadVetProfile,
    required TResult Function(_LoadMyProfile value) loadMyProfile,
    required TResult Function(_CreateOrUpdateProfile value)
    createOrUpdateProfile,
    required TResult Function(_ListVets value) listVets,
    required TResult Function(_SearchVets value) searchVets,
    required TResult Function(_FilterVets value) filterVets,
    required TResult Function(_ClearFilters value) clearFilters,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadVetProfile value)? loadVetProfile,
    TResult? Function(_LoadMyProfile value)? loadMyProfile,
    TResult? Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult? Function(_ListVets value)? listVets,
    TResult? Function(_SearchVets value)? searchVets,
    TResult? Function(_FilterVets value)? filterVets,
    TResult? Function(_ClearFilters value)? clearFilters,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadVetProfile value)? loadVetProfile,
    TResult Function(_LoadMyProfile value)? loadMyProfile,
    TResult Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult Function(_ListVets value)? listVets,
    TResult Function(_SearchVets value)? searchVets,
    TResult Function(_FilterVets value)? filterVets,
    TResult Function(_ClearFilters value)? clearFilters,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VetEventCopyWith<$Res> {
  factory $VetEventCopyWith(VetEvent value, $Res Function(VetEvent) then) =
      _$VetEventCopyWithImpl<$Res, VetEvent>;
}

/// @nodoc
class _$VetEventCopyWithImpl<$Res, $Val extends VetEvent>
    implements $VetEventCopyWith<$Res> {
  _$VetEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadVetProfileImplCopyWith<$Res> {
  factory _$$LoadVetProfileImplCopyWith(
    _$LoadVetProfileImpl value,
    $Res Function(_$LoadVetProfileImpl) then,
  ) = __$$LoadVetProfileImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$LoadVetProfileImplCopyWithImpl<$Res>
    extends _$VetEventCopyWithImpl<$Res, _$LoadVetProfileImpl>
    implements _$$LoadVetProfileImplCopyWith<$Res> {
  __$$LoadVetProfileImplCopyWithImpl(
    _$LoadVetProfileImpl _value,
    $Res Function(_$LoadVetProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$LoadVetProfileImpl(
        null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$LoadVetProfileImpl implements _LoadVetProfile {
  const _$LoadVetProfileImpl(this.userId);

  @override
  final String userId;

  @override
  String toString() {
    return 'VetEvent.loadVetProfile(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadVetProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadVetProfileImplCopyWith<_$LoadVetProfileImpl> get copyWith =>
      __$$LoadVetProfileImplCopyWithImpl<_$LoadVetProfileImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadVetProfile,
    required TResult Function() loadMyProfile,
    required TResult Function(VetProfileRequest request) createOrUpdateProfile,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )
    listVets,
    required TResult Function(String query) searchVets,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
    )
    filterVets,
    required TResult Function() clearFilters,
  }) {
    return loadVetProfile(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadVetProfile,
    TResult? Function()? loadMyProfile,
    TResult? Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult? Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult? Function(String query)? searchVets,
    TResult? Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult? Function()? clearFilters,
  }) {
    return loadVetProfile?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadVetProfile,
    TResult Function()? loadMyProfile,
    TResult Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult Function(String query)? searchVets,
    TResult Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult Function()? clearFilters,
    required TResult orElse(),
  }) {
    if (loadVetProfile != null) {
      return loadVetProfile(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadVetProfile value) loadVetProfile,
    required TResult Function(_LoadMyProfile value) loadMyProfile,
    required TResult Function(_CreateOrUpdateProfile value)
    createOrUpdateProfile,
    required TResult Function(_ListVets value) listVets,
    required TResult Function(_SearchVets value) searchVets,
    required TResult Function(_FilterVets value) filterVets,
    required TResult Function(_ClearFilters value) clearFilters,
  }) {
    return loadVetProfile(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadVetProfile value)? loadVetProfile,
    TResult? Function(_LoadMyProfile value)? loadMyProfile,
    TResult? Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult? Function(_ListVets value)? listVets,
    TResult? Function(_SearchVets value)? searchVets,
    TResult? Function(_FilterVets value)? filterVets,
    TResult? Function(_ClearFilters value)? clearFilters,
  }) {
    return loadVetProfile?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadVetProfile value)? loadVetProfile,
    TResult Function(_LoadMyProfile value)? loadMyProfile,
    TResult Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult Function(_ListVets value)? listVets,
    TResult Function(_SearchVets value)? searchVets,
    TResult Function(_FilterVets value)? filterVets,
    TResult Function(_ClearFilters value)? clearFilters,
    required TResult orElse(),
  }) {
    if (loadVetProfile != null) {
      return loadVetProfile(this);
    }
    return orElse();
  }
}

abstract class _LoadVetProfile implements VetEvent {
  const factory _LoadVetProfile(final String userId) = _$LoadVetProfileImpl;

  String get userId;

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadVetProfileImplCopyWith<_$LoadVetProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadMyProfileImplCopyWith<$Res> {
  factory _$$LoadMyProfileImplCopyWith(
    _$LoadMyProfileImpl value,
    $Res Function(_$LoadMyProfileImpl) then,
  ) = __$$LoadMyProfileImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadMyProfileImplCopyWithImpl<$Res>
    extends _$VetEventCopyWithImpl<$Res, _$LoadMyProfileImpl>
    implements _$$LoadMyProfileImplCopyWith<$Res> {
  __$$LoadMyProfileImplCopyWithImpl(
    _$LoadMyProfileImpl _value,
    $Res Function(_$LoadMyProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadMyProfileImpl implements _LoadMyProfile {
  const _$LoadMyProfileImpl();

  @override
  String toString() {
    return 'VetEvent.loadMyProfile()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadMyProfileImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadVetProfile,
    required TResult Function() loadMyProfile,
    required TResult Function(VetProfileRequest request) createOrUpdateProfile,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )
    listVets,
    required TResult Function(String query) searchVets,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
    )
    filterVets,
    required TResult Function() clearFilters,
  }) {
    return loadMyProfile();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadVetProfile,
    TResult? Function()? loadMyProfile,
    TResult? Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult? Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult? Function(String query)? searchVets,
    TResult? Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult? Function()? clearFilters,
  }) {
    return loadMyProfile?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadVetProfile,
    TResult Function()? loadMyProfile,
    TResult Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult Function(String query)? searchVets,
    TResult Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult Function()? clearFilters,
    required TResult orElse(),
  }) {
    if (loadMyProfile != null) {
      return loadMyProfile();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadVetProfile value) loadVetProfile,
    required TResult Function(_LoadMyProfile value) loadMyProfile,
    required TResult Function(_CreateOrUpdateProfile value)
    createOrUpdateProfile,
    required TResult Function(_ListVets value) listVets,
    required TResult Function(_SearchVets value) searchVets,
    required TResult Function(_FilterVets value) filterVets,
    required TResult Function(_ClearFilters value) clearFilters,
  }) {
    return loadMyProfile(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadVetProfile value)? loadVetProfile,
    TResult? Function(_LoadMyProfile value)? loadMyProfile,
    TResult? Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult? Function(_ListVets value)? listVets,
    TResult? Function(_SearchVets value)? searchVets,
    TResult? Function(_FilterVets value)? filterVets,
    TResult? Function(_ClearFilters value)? clearFilters,
  }) {
    return loadMyProfile?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadVetProfile value)? loadVetProfile,
    TResult Function(_LoadMyProfile value)? loadMyProfile,
    TResult Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult Function(_ListVets value)? listVets,
    TResult Function(_SearchVets value)? searchVets,
    TResult Function(_FilterVets value)? filterVets,
    TResult Function(_ClearFilters value)? clearFilters,
    required TResult orElse(),
  }) {
    if (loadMyProfile != null) {
      return loadMyProfile(this);
    }
    return orElse();
  }
}

abstract class _LoadMyProfile implements VetEvent {
  const factory _LoadMyProfile() = _$LoadMyProfileImpl;
}

/// @nodoc
abstract class _$$CreateOrUpdateProfileImplCopyWith<$Res> {
  factory _$$CreateOrUpdateProfileImplCopyWith(
    _$CreateOrUpdateProfileImpl value,
    $Res Function(_$CreateOrUpdateProfileImpl) then,
  ) = __$$CreateOrUpdateProfileImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VetProfileRequest request});

  $VetProfileRequestCopyWith<$Res> get request;
}

/// @nodoc
class __$$CreateOrUpdateProfileImplCopyWithImpl<$Res>
    extends _$VetEventCopyWithImpl<$Res, _$CreateOrUpdateProfileImpl>
    implements _$$CreateOrUpdateProfileImplCopyWith<$Res> {
  __$$CreateOrUpdateProfileImplCopyWithImpl(
    _$CreateOrUpdateProfileImpl _value,
    $Res Function(_$CreateOrUpdateProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? request = null}) {
    return _then(
      _$CreateOrUpdateProfileImpl(
        null == request
            ? _value.request
            : request // ignore: cast_nullable_to_non_nullable
                as VetProfileRequest,
      ),
    );
  }

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VetProfileRequestCopyWith<$Res> get request {
    return $VetProfileRequestCopyWith<$Res>(_value.request, (value) {
      return _then(_value.copyWith(request: value));
    });
  }
}

/// @nodoc

class _$CreateOrUpdateProfileImpl implements _CreateOrUpdateProfile {
  const _$CreateOrUpdateProfileImpl(this.request);

  @override
  final VetProfileRequest request;

  @override
  String toString() {
    return 'VetEvent.createOrUpdateProfile(request: $request)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateOrUpdateProfileImpl &&
            (identical(other.request, request) || other.request == request));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateOrUpdateProfileImplCopyWith<_$CreateOrUpdateProfileImpl>
  get copyWith =>
      __$$CreateOrUpdateProfileImplCopyWithImpl<_$CreateOrUpdateProfileImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadVetProfile,
    required TResult Function() loadMyProfile,
    required TResult Function(VetProfileRequest request) createOrUpdateProfile,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )
    listVets,
    required TResult Function(String query) searchVets,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
    )
    filterVets,
    required TResult Function() clearFilters,
  }) {
    return createOrUpdateProfile(request);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadVetProfile,
    TResult? Function()? loadMyProfile,
    TResult? Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult? Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult? Function(String query)? searchVets,
    TResult? Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult? Function()? clearFilters,
  }) {
    return createOrUpdateProfile?.call(request);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadVetProfile,
    TResult Function()? loadMyProfile,
    TResult Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult Function(String query)? searchVets,
    TResult Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult Function()? clearFilters,
    required TResult orElse(),
  }) {
    if (createOrUpdateProfile != null) {
      return createOrUpdateProfile(request);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadVetProfile value) loadVetProfile,
    required TResult Function(_LoadMyProfile value) loadMyProfile,
    required TResult Function(_CreateOrUpdateProfile value)
    createOrUpdateProfile,
    required TResult Function(_ListVets value) listVets,
    required TResult Function(_SearchVets value) searchVets,
    required TResult Function(_FilterVets value) filterVets,
    required TResult Function(_ClearFilters value) clearFilters,
  }) {
    return createOrUpdateProfile(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadVetProfile value)? loadVetProfile,
    TResult? Function(_LoadMyProfile value)? loadMyProfile,
    TResult? Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult? Function(_ListVets value)? listVets,
    TResult? Function(_SearchVets value)? searchVets,
    TResult? Function(_FilterVets value)? filterVets,
    TResult? Function(_ClearFilters value)? clearFilters,
  }) {
    return createOrUpdateProfile?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadVetProfile value)? loadVetProfile,
    TResult Function(_LoadMyProfile value)? loadMyProfile,
    TResult Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult Function(_ListVets value)? listVets,
    TResult Function(_SearchVets value)? searchVets,
    TResult Function(_FilterVets value)? filterVets,
    TResult Function(_ClearFilters value)? clearFilters,
    required TResult orElse(),
  }) {
    if (createOrUpdateProfile != null) {
      return createOrUpdateProfile(this);
    }
    return orElse();
  }
}

abstract class _CreateOrUpdateProfile implements VetEvent {
  const factory _CreateOrUpdateProfile(final VetProfileRequest request) =
      _$CreateOrUpdateProfileImpl;

  VetProfileRequest get request;

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateOrUpdateProfileImplCopyWith<_$CreateOrUpdateProfileImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ListVetsImplCopyWith<$Res> {
  factory _$$ListVetsImplCopyWith(
    _$ListVetsImpl value,
    $Res Function(_$ListVetsImpl) then,
  ) = __$$ListVetsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String? city,
    String? specialization,
    double? minRating,
    int page,
    int limit,
  });
}

/// @nodoc
class __$$ListVetsImplCopyWithImpl<$Res>
    extends _$VetEventCopyWithImpl<$Res, _$ListVetsImpl>
    implements _$$ListVetsImplCopyWith<$Res> {
  __$$ListVetsImplCopyWithImpl(
    _$ListVetsImpl _value,
    $Res Function(_$ListVetsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = freezed,
    Object? specialization = freezed,
    Object? minRating = freezed,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(
      _$ListVetsImpl(
        city:
            freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                    as String?,
        specialization:
            freezed == specialization
                ? _value.specialization
                : specialization // ignore: cast_nullable_to_non_nullable
                    as String?,
        minRating:
            freezed == minRating
                ? _value.minRating
                : minRating // ignore: cast_nullable_to_non_nullable
                    as double?,
        page:
            null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                    as int,
        limit:
            null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc

class _$ListVetsImpl implements _ListVets {
  const _$ListVetsImpl({
    this.city,
    this.specialization,
    this.minRating,
    this.page = 1,
    this.limit = 20,
  });

  @override
  final String? city;
  @override
  final String? specialization;
  @override
  final double? minRating;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;

  @override
  String toString() {
    return 'VetEvent.listVets(city: $city, specialization: $specialization, minRating: $minRating, page: $page, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListVetsImpl &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.specialization, specialization) ||
                other.specialization == specialization) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, city, specialization, minRating, page, limit);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListVetsImplCopyWith<_$ListVetsImpl> get copyWith =>
      __$$ListVetsImplCopyWithImpl<_$ListVetsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadVetProfile,
    required TResult Function() loadMyProfile,
    required TResult Function(VetProfileRequest request) createOrUpdateProfile,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )
    listVets,
    required TResult Function(String query) searchVets,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
    )
    filterVets,
    required TResult Function() clearFilters,
  }) {
    return listVets(city, specialization, minRating, page, limit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadVetProfile,
    TResult? Function()? loadMyProfile,
    TResult? Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult? Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult? Function(String query)? searchVets,
    TResult? Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult? Function()? clearFilters,
  }) {
    return listVets?.call(city, specialization, minRating, page, limit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadVetProfile,
    TResult Function()? loadMyProfile,
    TResult Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult Function(String query)? searchVets,
    TResult Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult Function()? clearFilters,
    required TResult orElse(),
  }) {
    if (listVets != null) {
      return listVets(city, specialization, minRating, page, limit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadVetProfile value) loadVetProfile,
    required TResult Function(_LoadMyProfile value) loadMyProfile,
    required TResult Function(_CreateOrUpdateProfile value)
    createOrUpdateProfile,
    required TResult Function(_ListVets value) listVets,
    required TResult Function(_SearchVets value) searchVets,
    required TResult Function(_FilterVets value) filterVets,
    required TResult Function(_ClearFilters value) clearFilters,
  }) {
    return listVets(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadVetProfile value)? loadVetProfile,
    TResult? Function(_LoadMyProfile value)? loadMyProfile,
    TResult? Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult? Function(_ListVets value)? listVets,
    TResult? Function(_SearchVets value)? searchVets,
    TResult? Function(_FilterVets value)? filterVets,
    TResult? Function(_ClearFilters value)? clearFilters,
  }) {
    return listVets?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadVetProfile value)? loadVetProfile,
    TResult Function(_LoadMyProfile value)? loadMyProfile,
    TResult Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult Function(_ListVets value)? listVets,
    TResult Function(_SearchVets value)? searchVets,
    TResult Function(_FilterVets value)? filterVets,
    TResult Function(_ClearFilters value)? clearFilters,
    required TResult orElse(),
  }) {
    if (listVets != null) {
      return listVets(this);
    }
    return orElse();
  }
}

abstract class _ListVets implements VetEvent {
  const factory _ListVets({
    final String? city,
    final String? specialization,
    final double? minRating,
    final int page,
    final int limit,
  }) = _$ListVetsImpl;

  String? get city;
  String? get specialization;
  double? get minRating;
  int get page;
  int get limit;

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListVetsImplCopyWith<_$ListVetsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SearchVetsImplCopyWith<$Res> {
  factory _$$SearchVetsImplCopyWith(
    _$SearchVetsImpl value,
    $Res Function(_$SearchVetsImpl) then,
  ) = __$$SearchVetsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String query});
}

/// @nodoc
class __$$SearchVetsImplCopyWithImpl<$Res>
    extends _$VetEventCopyWithImpl<$Res, _$SearchVetsImpl>
    implements _$$SearchVetsImplCopyWith<$Res> {
  __$$SearchVetsImplCopyWithImpl(
    _$SearchVetsImpl _value,
    $Res Function(_$SearchVetsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? query = null}) {
    return _then(
      _$SearchVetsImpl(
        null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$SearchVetsImpl implements _SearchVets {
  const _$SearchVetsImpl(this.query);

  @override
  final String query;

  @override
  String toString() {
    return 'VetEvent.searchVets(query: $query)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchVetsImpl &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchVetsImplCopyWith<_$SearchVetsImpl> get copyWith =>
      __$$SearchVetsImplCopyWithImpl<_$SearchVetsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadVetProfile,
    required TResult Function() loadMyProfile,
    required TResult Function(VetProfileRequest request) createOrUpdateProfile,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )
    listVets,
    required TResult Function(String query) searchVets,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
    )
    filterVets,
    required TResult Function() clearFilters,
  }) {
    return searchVets(query);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadVetProfile,
    TResult? Function()? loadMyProfile,
    TResult? Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult? Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult? Function(String query)? searchVets,
    TResult? Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult? Function()? clearFilters,
  }) {
    return searchVets?.call(query);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadVetProfile,
    TResult Function()? loadMyProfile,
    TResult Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult Function(String query)? searchVets,
    TResult Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult Function()? clearFilters,
    required TResult orElse(),
  }) {
    if (searchVets != null) {
      return searchVets(query);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadVetProfile value) loadVetProfile,
    required TResult Function(_LoadMyProfile value) loadMyProfile,
    required TResult Function(_CreateOrUpdateProfile value)
    createOrUpdateProfile,
    required TResult Function(_ListVets value) listVets,
    required TResult Function(_SearchVets value) searchVets,
    required TResult Function(_FilterVets value) filterVets,
    required TResult Function(_ClearFilters value) clearFilters,
  }) {
    return searchVets(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadVetProfile value)? loadVetProfile,
    TResult? Function(_LoadMyProfile value)? loadMyProfile,
    TResult? Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult? Function(_ListVets value)? listVets,
    TResult? Function(_SearchVets value)? searchVets,
    TResult? Function(_FilterVets value)? filterVets,
    TResult? Function(_ClearFilters value)? clearFilters,
  }) {
    return searchVets?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadVetProfile value)? loadVetProfile,
    TResult Function(_LoadMyProfile value)? loadMyProfile,
    TResult Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult Function(_ListVets value)? listVets,
    TResult Function(_SearchVets value)? searchVets,
    TResult Function(_FilterVets value)? filterVets,
    TResult Function(_ClearFilters value)? clearFilters,
    required TResult orElse(),
  }) {
    if (searchVets != null) {
      return searchVets(this);
    }
    return orElse();
  }
}

abstract class _SearchVets implements VetEvent {
  const factory _SearchVets(final String query) = _$SearchVetsImpl;

  String get query;

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchVetsImplCopyWith<_$SearchVetsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FilterVetsImplCopyWith<$Res> {
  factory _$$FilterVetsImplCopyWith(
    _$FilterVetsImpl value,
    $Res Function(_$FilterVetsImpl) then,
  ) = __$$FilterVetsImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? city, String? specialization, double? minRating});
}

/// @nodoc
class __$$FilterVetsImplCopyWithImpl<$Res>
    extends _$VetEventCopyWithImpl<$Res, _$FilterVetsImpl>
    implements _$$FilterVetsImplCopyWith<$Res> {
  __$$FilterVetsImplCopyWithImpl(
    _$FilterVetsImpl _value,
    $Res Function(_$FilterVetsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = freezed,
    Object? specialization = freezed,
    Object? minRating = freezed,
  }) {
    return _then(
      _$FilterVetsImpl(
        city:
            freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                    as String?,
        specialization:
            freezed == specialization
                ? _value.specialization
                : specialization // ignore: cast_nullable_to_non_nullable
                    as String?,
        minRating:
            freezed == minRating
                ? _value.minRating
                : minRating // ignore: cast_nullable_to_non_nullable
                    as double?,
      ),
    );
  }
}

/// @nodoc

class _$FilterVetsImpl implements _FilterVets {
  const _$FilterVetsImpl({this.city, this.specialization, this.minRating});

  @override
  final String? city;
  @override
  final String? specialization;
  @override
  final double? minRating;

  @override
  String toString() {
    return 'VetEvent.filterVets(city: $city, specialization: $specialization, minRating: $minRating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterVetsImpl &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.specialization, specialization) ||
                other.specialization == specialization) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating));
  }

  @override
  int get hashCode => Object.hash(runtimeType, city, specialization, minRating);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterVetsImplCopyWith<_$FilterVetsImpl> get copyWith =>
      __$$FilterVetsImplCopyWithImpl<_$FilterVetsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadVetProfile,
    required TResult Function() loadMyProfile,
    required TResult Function(VetProfileRequest request) createOrUpdateProfile,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )
    listVets,
    required TResult Function(String query) searchVets,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
    )
    filterVets,
    required TResult Function() clearFilters,
  }) {
    return filterVets(city, specialization, minRating);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadVetProfile,
    TResult? Function()? loadMyProfile,
    TResult? Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult? Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult? Function(String query)? searchVets,
    TResult? Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult? Function()? clearFilters,
  }) {
    return filterVets?.call(city, specialization, minRating);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadVetProfile,
    TResult Function()? loadMyProfile,
    TResult Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult Function(String query)? searchVets,
    TResult Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult Function()? clearFilters,
    required TResult orElse(),
  }) {
    if (filterVets != null) {
      return filterVets(city, specialization, minRating);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadVetProfile value) loadVetProfile,
    required TResult Function(_LoadMyProfile value) loadMyProfile,
    required TResult Function(_CreateOrUpdateProfile value)
    createOrUpdateProfile,
    required TResult Function(_ListVets value) listVets,
    required TResult Function(_SearchVets value) searchVets,
    required TResult Function(_FilterVets value) filterVets,
    required TResult Function(_ClearFilters value) clearFilters,
  }) {
    return filterVets(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadVetProfile value)? loadVetProfile,
    TResult? Function(_LoadMyProfile value)? loadMyProfile,
    TResult? Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult? Function(_ListVets value)? listVets,
    TResult? Function(_SearchVets value)? searchVets,
    TResult? Function(_FilterVets value)? filterVets,
    TResult? Function(_ClearFilters value)? clearFilters,
  }) {
    return filterVets?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadVetProfile value)? loadVetProfile,
    TResult Function(_LoadMyProfile value)? loadMyProfile,
    TResult Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult Function(_ListVets value)? listVets,
    TResult Function(_SearchVets value)? searchVets,
    TResult Function(_FilterVets value)? filterVets,
    TResult Function(_ClearFilters value)? clearFilters,
    required TResult orElse(),
  }) {
    if (filterVets != null) {
      return filterVets(this);
    }
    return orElse();
  }
}

abstract class _FilterVets implements VetEvent {
  const factory _FilterVets({
    final String? city,
    final String? specialization,
    final double? minRating,
  }) = _$FilterVetsImpl;

  String? get city;
  String? get specialization;
  double? get minRating;

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FilterVetsImplCopyWith<_$FilterVetsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ClearFiltersImplCopyWith<$Res> {
  factory _$$ClearFiltersImplCopyWith(
    _$ClearFiltersImpl value,
    $Res Function(_$ClearFiltersImpl) then,
  ) = __$$ClearFiltersImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ClearFiltersImplCopyWithImpl<$Res>
    extends _$VetEventCopyWithImpl<$Res, _$ClearFiltersImpl>
    implements _$$ClearFiltersImplCopyWith<$Res> {
  __$$ClearFiltersImplCopyWithImpl(
    _$ClearFiltersImpl _value,
    $Res Function(_$ClearFiltersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VetEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ClearFiltersImpl implements _ClearFilters {
  const _$ClearFiltersImpl();

  @override
  String toString() {
    return 'VetEvent.clearFilters()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ClearFiltersImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadVetProfile,
    required TResult Function() loadMyProfile,
    required TResult Function(VetProfileRequest request) createOrUpdateProfile,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )
    listVets,
    required TResult Function(String query) searchVets,
    required TResult Function(
      String? city,
      String? specialization,
      double? minRating,
    )
    filterVets,
    required TResult Function() clearFilters,
  }) {
    return clearFilters();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadVetProfile,
    TResult? Function()? loadMyProfile,
    TResult? Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult? Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult? Function(String query)? searchVets,
    TResult? Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult? Function()? clearFilters,
  }) {
    return clearFilters?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadVetProfile,
    TResult Function()? loadMyProfile,
    TResult Function(VetProfileRequest request)? createOrUpdateProfile,
    TResult Function(
      String? city,
      String? specialization,
      double? minRating,
      int page,
      int limit,
    )?
    listVets,
    TResult Function(String query)? searchVets,
    TResult Function(String? city, String? specialization, double? minRating)?
    filterVets,
    TResult Function()? clearFilters,
    required TResult orElse(),
  }) {
    if (clearFilters != null) {
      return clearFilters();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadVetProfile value) loadVetProfile,
    required TResult Function(_LoadMyProfile value) loadMyProfile,
    required TResult Function(_CreateOrUpdateProfile value)
    createOrUpdateProfile,
    required TResult Function(_ListVets value) listVets,
    required TResult Function(_SearchVets value) searchVets,
    required TResult Function(_FilterVets value) filterVets,
    required TResult Function(_ClearFilters value) clearFilters,
  }) {
    return clearFilters(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadVetProfile value)? loadVetProfile,
    TResult? Function(_LoadMyProfile value)? loadMyProfile,
    TResult? Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult? Function(_ListVets value)? listVets,
    TResult? Function(_SearchVets value)? searchVets,
    TResult? Function(_FilterVets value)? filterVets,
    TResult? Function(_ClearFilters value)? clearFilters,
  }) {
    return clearFilters?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadVetProfile value)? loadVetProfile,
    TResult Function(_LoadMyProfile value)? loadMyProfile,
    TResult Function(_CreateOrUpdateProfile value)? createOrUpdateProfile,
    TResult Function(_ListVets value)? listVets,
    TResult Function(_SearchVets value)? searchVets,
    TResult Function(_FilterVets value)? filterVets,
    TResult Function(_ClearFilters value)? clearFilters,
    required TResult orElse(),
  }) {
    if (clearFilters != null) {
      return clearFilters(this);
    }
    return orElse();
  }
}

abstract class _ClearFilters implements VetEvent {
  const factory _ClearFilters() = _$ClearFiltersImpl;
}
