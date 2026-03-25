// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) {
  return _AuthUser.fromJson(json);
}

/// @nodoc
mixin _$AuthUser {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get accountType => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AuthUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthUserCopyWith<AuthUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthUserCopyWith<$Res> {
  factory $AuthUserCopyWith(AuthUser value, $Res Function(AuthUser) then) =
      _$AuthUserCopyWithImpl<$Res, AuthUser>;
  @useResult
  $Res call({
    String id,
    String email,
    String? displayName,
    String? accountType,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$AuthUserCopyWithImpl<$Res, $Val extends AuthUser>
    implements $AuthUserCopyWith<$Res> {
  _$AuthUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? accountType = freezed,
    Object? photoUrl = freezed,
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
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            accountType:
                freezed == accountType
                    ? _value.accountType
                    : accountType // ignore: cast_nullable_to_non_nullable
                        as String?,
            photoUrl:
                freezed == photoUrl
                    ? _value.photoUrl
                    : photoUrl // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AuthUserImplCopyWith<$Res>
    implements $AuthUserCopyWith<$Res> {
  factory _$$AuthUserImplCopyWith(
    _$AuthUserImpl value,
    $Res Function(_$AuthUserImpl) then,
  ) = __$$AuthUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String? displayName,
    String? accountType,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$AuthUserImplCopyWithImpl<$Res>
    extends _$AuthUserCopyWithImpl<$Res, _$AuthUserImpl>
    implements _$$AuthUserImplCopyWith<$Res> {
  __$$AuthUserImplCopyWithImpl(
    _$AuthUserImpl _value,
    $Res Function(_$AuthUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? accountType = freezed,
    Object? photoUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AuthUserImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        accountType:
            freezed == accountType
                ? _value.accountType
                : accountType // ignore: cast_nullable_to_non_nullable
                    as String?,
        photoUrl:
            freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
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
class _$AuthUserImpl extends _AuthUser {
  const _$AuthUserImpl({
    required this.id,
    required this.email,
    this.displayName,
    this.accountType,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$AuthUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthUserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? accountType;
  @override
  final String? photoUrl;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email, displayName: $displayName, accountType: $accountType, photoUrl: $photoUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.accountType, accountType) ||
                other.accountType == accountType) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
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
    email,
    displayName,
    accountType,
    photoUrl,
    createdAt,
    updatedAt,
  );

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthUserImplCopyWith<_$AuthUserImpl> get copyWith =>
      __$$AuthUserImplCopyWithImpl<_$AuthUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthUserImplToJson(this);
  }
}

abstract class _AuthUser extends AuthUser {
  const factory _AuthUser({
    required final String id,
    required final String email,
    final String? displayName,
    final String? accountType,
    final String? photoUrl,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$AuthUserImpl;
  const _AuthUser._() : super._();

  factory _AuthUser.fromJson(Map<String, dynamic> json) =
      _$AuthUserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get accountType;
  @override
  String? get photoUrl;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of AuthUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthUserImplCopyWith<_$AuthUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  AuthUser get user => throw _privateConstructorUsedError;
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  bool get isNewUser => throw _privateConstructorUsedError;

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
    AuthResponse value,
    $Res Function(AuthResponse) then,
  ) = _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call({
    AuthUser user,
    String accessToken,
    String refreshToken,
    bool isNewUser,
  });

  $AuthUserCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? isNewUser = null,
  }) {
    return _then(
      _value.copyWith(
            user:
                null == user
                    ? _value.user
                    : user // ignore: cast_nullable_to_non_nullable
                        as AuthUser,
            accessToken:
                null == accessToken
                    ? _value.accessToken
                    : accessToken // ignore: cast_nullable_to_non_nullable
                        as String,
            refreshToken:
                null == refreshToken
                    ? _value.refreshToken
                    : refreshToken // ignore: cast_nullable_to_non_nullable
                        as String,
            isNewUser:
                null == isNewUser
                    ? _value.isNewUser
                    : isNewUser // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserCopyWith<$Res> get user {
    return $AuthUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
    _$AuthResponseImpl value,
    $Res Function(_$AuthResponseImpl) then,
  ) = __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AuthUser user,
    String accessToken,
    String refreshToken,
    bool isNewUser,
  });

  @override
  $AuthUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
    _$AuthResponseImpl _value,
    $Res Function(_$AuthResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? isNewUser = null,
  }) {
    return _then(
      _$AuthResponseImpl(
        user:
            null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                    as AuthUser,
        accessToken:
            null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                    as String,
        refreshToken:
            null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                    as String,
        isNewUser:
            null == isNewUser
                ? _value.isNewUser
                : isNewUser // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.isNewUser = false,
  });

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  final AuthUser user;
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  @JsonKey()
  final bool isNewUser;

  @override
  String toString() {
    return 'AuthResponse(user: $user, accessToken: $accessToken, refreshToken: $refreshToken, isNewUser: $isNewUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, user, accessToken, refreshToken, isNewUser);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(this);
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse({
    required final AuthUser user,
    required final String accessToken,
    required final String refreshToken,
    final bool isNewUser,
  }) = _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  AuthUser get user;
  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  bool get isNewUser;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SignUpRequest _$SignUpRequestFromJson(Map<String, dynamic> json) {
  return _SignUpRequest.fromJson(json);
}

/// @nodoc
mixin _$SignUpRequest {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;

  /// Serializes this SignUpRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignUpRequestCopyWith<SignUpRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignUpRequestCopyWith<$Res> {
  factory $SignUpRequestCopyWith(
    SignUpRequest value,
    $Res Function(SignUpRequest) then,
  ) = _$SignUpRequestCopyWithImpl<$Res, SignUpRequest>;
  @useResult
  $Res call({String email, String password, String? displayName});
}

/// @nodoc
class _$SignUpRequestCopyWithImpl<$Res, $Val extends SignUpRequest>
    implements $SignUpRequestCopyWith<$Res> {
  _$SignUpRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? displayName = freezed,
  }) {
    return _then(
      _value.copyWith(
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            password:
                null == password
                    ? _value.password
                    : password // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SignUpRequestImplCopyWith<$Res>
    implements $SignUpRequestCopyWith<$Res> {
  factory _$$SignUpRequestImplCopyWith(
    _$SignUpRequestImpl value,
    $Res Function(_$SignUpRequestImpl) then,
  ) = __$$SignUpRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password, String? displayName});
}

/// @nodoc
class __$$SignUpRequestImplCopyWithImpl<$Res>
    extends _$SignUpRequestCopyWithImpl<$Res, _$SignUpRequestImpl>
    implements _$$SignUpRequestImplCopyWith<$Res> {
  __$$SignUpRequestImplCopyWithImpl(
    _$SignUpRequestImpl _value,
    $Res Function(_$SignUpRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? displayName = freezed,
  }) {
    return _then(
      _$SignUpRequestImpl(
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        password:
            null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SignUpRequestImpl implements _SignUpRequest {
  const _$SignUpRequestImpl({
    required this.email,
    required this.password,
    this.displayName,
  });

  factory _$SignUpRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignUpRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String password;
  @override
  final String? displayName;

  @override
  String toString() {
    return 'SignUpRequest(email: $email, password: $password, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignUpRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password, displayName);

  /// Create a copy of SignUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignUpRequestImplCopyWith<_$SignUpRequestImpl> get copyWith =>
      __$$SignUpRequestImplCopyWithImpl<_$SignUpRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SignUpRequestImplToJson(this);
  }
}

abstract class _SignUpRequest implements SignUpRequest {
  const factory _SignUpRequest({
    required final String email,
    required final String password,
    final String? displayName,
  }) = _$SignUpRequestImpl;

  factory _SignUpRequest.fromJson(Map<String, dynamic> json) =
      _$SignUpRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get password;
  @override
  String? get displayName;

  /// Create a copy of SignUpRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignUpRequestImplCopyWith<_$SignUpRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SignInRequest _$SignInRequestFromJson(Map<String, dynamic> json) {
  return _SignInRequest.fromJson(json);
}

/// @nodoc
mixin _$SignInRequest {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this SignInRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignInRequestCopyWith<SignInRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignInRequestCopyWith<$Res> {
  factory $SignInRequestCopyWith(
    SignInRequest value,
    $Res Function(SignInRequest) then,
  ) = _$SignInRequestCopyWithImpl<$Res, SignInRequest>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$SignInRequestCopyWithImpl<$Res, $Val extends SignInRequest>
    implements $SignInRequestCopyWith<$Res> {
  _$SignInRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            password:
                null == password
                    ? _value.password
                    : password // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SignInRequestImplCopyWith<$Res>
    implements $SignInRequestCopyWith<$Res> {
  factory _$$SignInRequestImplCopyWith(
    _$SignInRequestImpl value,
    $Res Function(_$SignInRequestImpl) then,
  ) = __$$SignInRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$SignInRequestImplCopyWithImpl<$Res>
    extends _$SignInRequestCopyWithImpl<$Res, _$SignInRequestImpl>
    implements _$$SignInRequestImplCopyWith<$Res> {
  __$$SignInRequestImplCopyWithImpl(
    _$SignInRequestImpl _value,
    $Res Function(_$SignInRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _$SignInRequestImpl(
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        password:
            null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SignInRequestImpl implements _SignInRequest {
  const _$SignInRequestImpl({required this.email, required this.password});

  factory _$SignInRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignInRequestImplFromJson(json);

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'SignInRequest(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignInRequestImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of SignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignInRequestImplCopyWith<_$SignInRequestImpl> get copyWith =>
      __$$SignInRequestImplCopyWithImpl<_$SignInRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SignInRequestImplToJson(this);
  }
}

abstract class _SignInRequest implements SignInRequest {
  const factory _SignInRequest({
    required final String email,
    required final String password,
  }) = _$SignInRequestImpl;

  factory _SignInRequest.fromJson(Map<String, dynamic> json) =
      _$SignInRequestImpl.fromJson;

  @override
  String get email;
  @override
  String get password;

  /// Create a copy of SignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignInRequestImplCopyWith<_$SignInRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoogleSignInRequest _$GoogleSignInRequestFromJson(Map<String, dynamic> json) {
  return _GoogleSignInRequest.fromJson(json);
}

/// @nodoc
mixin _$GoogleSignInRequest {
  String get idToken => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get accountType => throw _privateConstructorUsedError;

  /// Serializes this GoogleSignInRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoogleSignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoogleSignInRequestCopyWith<GoogleSignInRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoogleSignInRequestCopyWith<$Res> {
  factory $GoogleSignInRequestCopyWith(
    GoogleSignInRequest value,
    $Res Function(GoogleSignInRequest) then,
  ) = _$GoogleSignInRequestCopyWithImpl<$Res, GoogleSignInRequest>;
  @useResult
  $Res call({
    String idToken,
    String? displayName,
    String? photoUrl,
    String? accountType,
  });
}

/// @nodoc
class _$GoogleSignInRequestCopyWithImpl<$Res, $Val extends GoogleSignInRequest>
    implements $GoogleSignInRequestCopyWith<$Res> {
  _$GoogleSignInRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoogleSignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idToken = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? accountType = freezed,
  }) {
    return _then(
      _value.copyWith(
            idToken:
                null == idToken
                    ? _value.idToken
                    : idToken // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            photoUrl:
                freezed == photoUrl
                    ? _value.photoUrl
                    : photoUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            accountType:
                freezed == accountType
                    ? _value.accountType
                    : accountType // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GoogleSignInRequestImplCopyWith<$Res>
    implements $GoogleSignInRequestCopyWith<$Res> {
  factory _$$GoogleSignInRequestImplCopyWith(
    _$GoogleSignInRequestImpl value,
    $Res Function(_$GoogleSignInRequestImpl) then,
  ) = __$$GoogleSignInRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String idToken,
    String? displayName,
    String? photoUrl,
    String? accountType,
  });
}

/// @nodoc
class __$$GoogleSignInRequestImplCopyWithImpl<$Res>
    extends _$GoogleSignInRequestCopyWithImpl<$Res, _$GoogleSignInRequestImpl>
    implements _$$GoogleSignInRequestImplCopyWith<$Res> {
  __$$GoogleSignInRequestImplCopyWithImpl(
    _$GoogleSignInRequestImpl _value,
    $Res Function(_$GoogleSignInRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GoogleSignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idToken = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? accountType = freezed,
  }) {
    return _then(
      _$GoogleSignInRequestImpl(
        idToken:
            null == idToken
                ? _value.idToken
                : idToken // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        photoUrl:
            freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        accountType:
            freezed == accountType
                ? _value.accountType
                : accountType // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GoogleSignInRequestImpl implements _GoogleSignInRequest {
  const _$GoogleSignInRequestImpl({
    required this.idToken,
    this.displayName,
    this.photoUrl,
    this.accountType,
  });

  factory _$GoogleSignInRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoogleSignInRequestImplFromJson(json);

  @override
  final String idToken;
  @override
  final String? displayName;
  @override
  final String? photoUrl;
  @override
  final String? accountType;

  @override
  String toString() {
    return 'GoogleSignInRequest(idToken: $idToken, displayName: $displayName, photoUrl: $photoUrl, accountType: $accountType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoogleSignInRequestImpl &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.accountType, accountType) ||
                other.accountType == accountType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, idToken, displayName, photoUrl, accountType);

  /// Create a copy of GoogleSignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoogleSignInRequestImplCopyWith<_$GoogleSignInRequestImpl> get copyWith =>
      __$$GoogleSignInRequestImplCopyWithImpl<_$GoogleSignInRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GoogleSignInRequestImplToJson(this);
  }
}

abstract class _GoogleSignInRequest implements GoogleSignInRequest {
  const factory _GoogleSignInRequest({
    required final String idToken,
    final String? displayName,
    final String? photoUrl,
    final String? accountType,
  }) = _$GoogleSignInRequestImpl;

  factory _GoogleSignInRequest.fromJson(Map<String, dynamic> json) =
      _$GoogleSignInRequestImpl.fromJson;

  @override
  String get idToken;
  @override
  String? get displayName;
  @override
  String? get photoUrl;
  @override
  String? get accountType;

  /// Create a copy of GoogleSignInRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoogleSignInRequestImplCopyWith<_$GoogleSignInRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateProfileRequest _$UpdateProfileRequestFromJson(Map<String, dynamic> json) {
  return _UpdateProfileRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateProfileRequest {
  String? get displayName => throw _privateConstructorUsedError;
  String? get accountType => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Serializes this UpdateProfileRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateProfileRequestCopyWith<UpdateProfileRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateProfileRequestCopyWith<$Res> {
  factory $UpdateProfileRequestCopyWith(
    UpdateProfileRequest value,
    $Res Function(UpdateProfileRequest) then,
  ) = _$UpdateProfileRequestCopyWithImpl<$Res, UpdateProfileRequest>;
  @useResult
  $Res call({String? displayName, String? accountType, String? photoUrl});
}

/// @nodoc
class _$UpdateProfileRequestCopyWithImpl<
  $Res,
  $Val extends UpdateProfileRequest
>
    implements $UpdateProfileRequestCopyWith<$Res> {
  _$UpdateProfileRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = freezed,
    Object? accountType = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            accountType:
                freezed == accountType
                    ? _value.accountType
                    : accountType // ignore: cast_nullable_to_non_nullable
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
abstract class _$$UpdateProfileRequestImplCopyWith<$Res>
    implements $UpdateProfileRequestCopyWith<$Res> {
  factory _$$UpdateProfileRequestImplCopyWith(
    _$UpdateProfileRequestImpl value,
    $Res Function(_$UpdateProfileRequestImpl) then,
  ) = __$$UpdateProfileRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? displayName, String? accountType, String? photoUrl});
}

/// @nodoc
class __$$UpdateProfileRequestImplCopyWithImpl<$Res>
    extends _$UpdateProfileRequestCopyWithImpl<$Res, _$UpdateProfileRequestImpl>
    implements _$$UpdateProfileRequestImplCopyWith<$Res> {
  __$$UpdateProfileRequestImplCopyWithImpl(
    _$UpdateProfileRequestImpl _value,
    $Res Function(_$UpdateProfileRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = freezed,
    Object? accountType = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _$UpdateProfileRequestImpl(
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        accountType:
            freezed == accountType
                ? _value.accountType
                : accountType // ignore: cast_nullable_to_non_nullable
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
class _$UpdateProfileRequestImpl implements _UpdateProfileRequest {
  const _$UpdateProfileRequestImpl({
    this.displayName,
    this.accountType,
    this.photoUrl,
  });

  factory _$UpdateProfileRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateProfileRequestImplFromJson(json);

  @override
  final String? displayName;
  @override
  final String? accountType;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'UpdateProfileRequest(displayName: $displayName, accountType: $accountType, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateProfileRequestImpl &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.accountType, accountType) ||
                other.accountType == accountType) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, displayName, accountType, photoUrl);

  /// Create a copy of UpdateProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateProfileRequestImplCopyWith<_$UpdateProfileRequestImpl>
  get copyWith =>
      __$$UpdateProfileRequestImplCopyWithImpl<_$UpdateProfileRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateProfileRequestImplToJson(this);
  }
}

abstract class _UpdateProfileRequest implements UpdateProfileRequest {
  const factory _UpdateProfileRequest({
    final String? displayName,
    final String? accountType,
    final String? photoUrl,
  }) = _$UpdateProfileRequestImpl;

  factory _UpdateProfileRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateProfileRequestImpl.fromJson;

  @override
  String? get displayName;
  @override
  String? get accountType;
  @override
  String? get photoUrl;

  /// Create a copy of UpdateProfileRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateProfileRequestImplCopyWith<_$UpdateProfileRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
