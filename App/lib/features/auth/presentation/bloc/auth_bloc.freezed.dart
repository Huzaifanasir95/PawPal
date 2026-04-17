// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthEventCopyWith<$Res> {
  factory $AuthEventCopyWith(AuthEvent value, $Res Function(AuthEvent) then) =
      _$AuthEventCopyWithImpl<$Res, AuthEvent>;
}

/// @nodoc
class _$AuthEventCopyWithImpl<$Res, $Val extends AuthEvent>
    implements $AuthEventCopyWith<$Res> {
  _$AuthEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CheckAuthImplCopyWith<$Res> {
  factory _$$CheckAuthImplCopyWith(
    _$CheckAuthImpl value,
    $Res Function(_$CheckAuthImpl) then,
  ) = __$$CheckAuthImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CheckAuthImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$CheckAuthImpl>
    implements _$$CheckAuthImplCopyWith<$Res> {
  __$$CheckAuthImplCopyWithImpl(
    _$CheckAuthImpl _value,
    $Res Function(_$CheckAuthImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CheckAuthImpl implements _CheckAuth {
  const _$CheckAuthImpl();

  @override
  String toString() {
    return 'AuthEvent.checkAuth()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CheckAuthImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return checkAuth();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return checkAuth?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (checkAuth != null) {
      return checkAuth();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return checkAuth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return checkAuth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (checkAuth != null) {
      return checkAuth(this);
    }
    return orElse();
  }
}

abstract class _CheckAuth implements AuthEvent {
  const factory _CheckAuth() = _$CheckAuthImpl;
}

/// @nodoc
abstract class _$$SignInWithEmailImplCopyWith<$Res> {
  factory _$$SignInWithEmailImplCopyWith(
    _$SignInWithEmailImpl value,
    $Res Function(_$SignInWithEmailImpl) then,
  ) = __$$SignInWithEmailImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$SignInWithEmailImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SignInWithEmailImpl>
    implements _$$SignInWithEmailImplCopyWith<$Res> {
  __$$SignInWithEmailImplCopyWithImpl(
    _$SignInWithEmailImpl _value,
    $Res Function(_$SignInWithEmailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null, Object? password = null}) {
    return _then(
      _$SignInWithEmailImpl(
        null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                as String,
        null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$SignInWithEmailImpl implements _SignInWithEmail {
  const _$SignInWithEmailImpl(this.email, this.password);

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'AuthEvent.signInWithEmail(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignInWithEmailImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignInWithEmailImplCopyWith<_$SignInWithEmailImpl> get copyWith =>
      __$$SignInWithEmailImplCopyWithImpl<_$SignInWithEmailImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return signInWithEmail(email, password);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return signInWithEmail?.call(email, password);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (signInWithEmail != null) {
      return signInWithEmail(email, password);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return signInWithEmail(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return signInWithEmail?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (signInWithEmail != null) {
      return signInWithEmail(this);
    }
    return orElse();
  }
}

abstract class _SignInWithEmail implements AuthEvent {
  const factory _SignInWithEmail(final String email, final String password) =
      _$SignInWithEmailImpl;

  String get email;
  String get password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignInWithEmailImplCopyWith<_$SignInWithEmailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SignUpWithEmailImplCopyWith<$Res> {
  factory _$$SignUpWithEmailImplCopyWith(
    _$SignUpWithEmailImpl value,
    $Res Function(_$SignUpWithEmailImpl) then,
  ) = __$$SignUpWithEmailImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, String password, String? name, String? accountType});
}

/// @nodoc
class __$$SignUpWithEmailImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SignUpWithEmailImpl>
    implements _$$SignUpWithEmailImplCopyWith<$Res> {
  __$$SignUpWithEmailImplCopyWithImpl(
    _$SignUpWithEmailImpl _value,
    $Res Function(_$SignUpWithEmailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? name = freezed,
    Object? accountType = freezed,
  }) {
    return _then(
      _$SignUpWithEmailImpl(
        null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                as String,
        null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                as String,
        freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                as String?,
        freezed == accountType
            ? _value.accountType
            : accountType // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$SignUpWithEmailImpl implements _SignUpWithEmail {
  const _$SignUpWithEmailImpl(
    this.email,
    this.password,
    this.name,
    this.accountType,
  );

  @override
  final String email;
  @override
  final String password;
  @override
  final String? name;
  @override
  final String? accountType;

  @override
  String toString() {
    return 'AuthEvent.signUpWithEmail(email: $email, password: $password, name: $name, accountType: $accountType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignUpWithEmailImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.accountType, accountType) ||
                other.accountType == accountType));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, email, password, name, accountType);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignUpWithEmailImplCopyWith<_$SignUpWithEmailImpl> get copyWith =>
      __$$SignUpWithEmailImplCopyWithImpl<_$SignUpWithEmailImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return signUpWithEmail(email, password, name, accountType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return signUpWithEmail?.call(email, password, name, accountType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (signUpWithEmail != null) {
      return signUpWithEmail(email, password, name, accountType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return signUpWithEmail(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return signUpWithEmail?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (signUpWithEmail != null) {
      return signUpWithEmail(this);
    }
    return orElse();
  }
}

abstract class _SignUpWithEmail implements AuthEvent {
  const factory _SignUpWithEmail(
    final String email,
    final String password,
    final String? name,
    final String? accountType,
  ) = _$SignUpWithEmailImpl;

  String get email;
  String get password;
  String? get name;
  String? get accountType;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignUpWithEmailImplCopyWith<_$SignUpWithEmailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SignInWithGoogleImplCopyWith<$Res> {
  factory _$$SignInWithGoogleImplCopyWith(
    _$SignInWithGoogleImpl value,
    $Res Function(_$SignInWithGoogleImpl) then,
  ) = __$$SignInWithGoogleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SignInWithGoogleImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SignInWithGoogleImpl>
    implements _$$SignInWithGoogleImplCopyWith<$Res> {
  __$$SignInWithGoogleImplCopyWithImpl(
    _$SignInWithGoogleImpl _value,
    $Res Function(_$SignInWithGoogleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SignInWithGoogleImpl implements _SignInWithGoogle {
  const _$SignInWithGoogleImpl();

  @override
  String toString() {
    return 'AuthEvent.signInWithGoogle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SignInWithGoogleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return signInWithGoogle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return signInWithGoogle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (signInWithGoogle != null) {
      return signInWithGoogle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return signInWithGoogle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return signInWithGoogle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (signInWithGoogle != null) {
      return signInWithGoogle(this);
    }
    return orElse();
  }
}

abstract class _SignInWithGoogle implements AuthEvent {
  const factory _SignInWithGoogle() = _$SignInWithGoogleImpl;
}

/// @nodoc
abstract class _$$CompleteGoogleSignInImplCopyWith<$Res> {
  factory _$$CompleteGoogleSignInImplCopyWith(
    _$CompleteGoogleSignInImpl value,
    $Res Function(_$CompleteGoogleSignInImpl) then,
  ) = __$$CompleteGoogleSignInImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String idToken,
    String accountType,
    String? displayName,
    String? photoUrl,
  });
}

/// @nodoc
class __$$CompleteGoogleSignInImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$CompleteGoogleSignInImpl>
    implements _$$CompleteGoogleSignInImplCopyWith<$Res> {
  __$$CompleteGoogleSignInImplCopyWithImpl(
    _$CompleteGoogleSignInImpl _value,
    $Res Function(_$CompleteGoogleSignInImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idToken = null,
    Object? accountType = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _$CompleteGoogleSignInImpl(
        null == idToken
            ? _value.idToken
            : idToken // ignore: cast_nullable_to_non_nullable
                as String,
        null == accountType
            ? _value.accountType
            : accountType // ignore: cast_nullable_to_non_nullable
                as String,
        freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                as String?,
        freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$CompleteGoogleSignInImpl implements _CompleteGoogleSignIn {
  const _$CompleteGoogleSignInImpl(
    this.idToken,
    this.accountType,
    this.displayName,
    this.photoUrl,
  );

  @override
  final String idToken;
  @override
  final String accountType;
  @override
  final String? displayName;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'AuthEvent.completeGoogleSignIn(idToken: $idToken, accountType: $accountType, displayName: $displayName, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompleteGoogleSignInImpl &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.accountType, accountType) ||
                other.accountType == accountType) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, idToken, accountType, displayName, photoUrl);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompleteGoogleSignInImplCopyWith<_$CompleteGoogleSignInImpl>
  get copyWith =>
      __$$CompleteGoogleSignInImplCopyWithImpl<_$CompleteGoogleSignInImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return completeGoogleSignIn(idToken, accountType, displayName, photoUrl);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return completeGoogleSignIn?.call(
      idToken,
      accountType,
      displayName,
      photoUrl,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (completeGoogleSignIn != null) {
      return completeGoogleSignIn(idToken, accountType, displayName, photoUrl);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return completeGoogleSignIn(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return completeGoogleSignIn?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (completeGoogleSignIn != null) {
      return completeGoogleSignIn(this);
    }
    return orElse();
  }
}

abstract class _CompleteGoogleSignIn implements AuthEvent {
  const factory _CompleteGoogleSignIn(
    final String idToken,
    final String accountType,
    final String? displayName,
    final String? photoUrl,
  ) = _$CompleteGoogleSignInImpl;

  String get idToken;
  String get accountType;
  String? get displayName;
  String? get photoUrl;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompleteGoogleSignInImplCopyWith<_$CompleteGoogleSignInImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SignOutImplCopyWith<$Res> {
  factory _$$SignOutImplCopyWith(
    _$SignOutImpl value,
    $Res Function(_$SignOutImpl) then,
  ) = __$$SignOutImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SignOutImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SignOutImpl>
    implements _$$SignOutImplCopyWith<$Res> {
  __$$SignOutImplCopyWithImpl(
    _$SignOutImpl _value,
    $Res Function(_$SignOutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SignOutImpl implements _SignOut {
  const _$SignOutImpl();

  @override
  String toString() {
    return 'AuthEvent.signOut()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SignOutImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return signOut();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return signOut?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (signOut != null) {
      return signOut();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return signOut(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return signOut?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (signOut != null) {
      return signOut(this);
    }
    return orElse();
  }
}

abstract class _SignOut implements AuthEvent {
  const factory _SignOut() = _$SignOutImpl;
}

/// @nodoc
abstract class _$$ResetPasswordImplCopyWith<$Res> {
  factory _$$ResetPasswordImplCopyWith(
    _$ResetPasswordImpl value,
    $Res Function(_$ResetPasswordImpl) then,
  ) = __$$ResetPasswordImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$ResetPasswordImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$ResetPasswordImpl>
    implements _$$ResetPasswordImplCopyWith<$Res> {
  __$$ResetPasswordImplCopyWithImpl(
    _$ResetPasswordImpl _value,
    $Res Function(_$ResetPasswordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null}) {
    return _then(
      _$ResetPasswordImpl(
        null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ResetPasswordImpl implements _ResetPassword {
  const _$ResetPasswordImpl(this.email);

  @override
  final String email;

  @override
  String toString() {
    return 'AuthEvent.resetPassword(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResetPasswordImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResetPasswordImplCopyWith<_$ResetPasswordImpl> get copyWith =>
      __$$ResetPasswordImplCopyWithImpl<_$ResetPasswordImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return resetPassword(email);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return resetPassword?.call(email);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (resetPassword != null) {
      return resetPassword(email);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return resetPassword(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return resetPassword?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (resetPassword != null) {
      return resetPassword(this);
    }
    return orElse();
  }
}

abstract class _ResetPassword implements AuthEvent {
  const factory _ResetPassword(final String email) = _$ResetPasswordImpl;

  String get email;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResetPasswordImplCopyWith<_$ResetPasswordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateAccountTypeImplCopyWith<$Res> {
  factory _$$UpdateAccountTypeImplCopyWith(
    _$UpdateAccountTypeImpl value,
    $Res Function(_$UpdateAccountTypeImpl) then,
  ) = __$$UpdateAccountTypeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String accountType});
}

/// @nodoc
class __$$UpdateAccountTypeImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$UpdateAccountTypeImpl>
    implements _$$UpdateAccountTypeImplCopyWith<$Res> {
  __$$UpdateAccountTypeImplCopyWithImpl(
    _$UpdateAccountTypeImpl _value,
    $Res Function(_$UpdateAccountTypeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? accountType = null}) {
    return _then(
      _$UpdateAccountTypeImpl(
        null == accountType
            ? _value.accountType
            : accountType // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$UpdateAccountTypeImpl implements _UpdateAccountType {
  const _$UpdateAccountTypeImpl(this.accountType);

  @override
  final String accountType;

  @override
  String toString() {
    return 'AuthEvent.updateAccountType(accountType: $accountType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateAccountTypeImpl &&
            (identical(other.accountType, accountType) ||
                other.accountType == accountType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accountType);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateAccountTypeImplCopyWith<_$UpdateAccountTypeImpl> get copyWith =>
      __$$UpdateAccountTypeImplCopyWithImpl<_$UpdateAccountTypeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return updateAccountType(accountType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return updateAccountType?.call(accountType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (updateAccountType != null) {
      return updateAccountType(accountType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return updateAccountType(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return updateAccountType?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (updateAccountType != null) {
      return updateAccountType(this);
    }
    return orElse();
  }
}

abstract class _UpdateAccountType implements AuthEvent {
  const factory _UpdateAccountType(final String accountType) =
      _$UpdateAccountTypeImpl;

  String get accountType;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateAccountTypeImplCopyWith<_$UpdateAccountTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UserChangedImplCopyWith<$Res> {
  factory _$$UserChangedImplCopyWith(
    _$UserChangedImpl value,
    $Res Function(_$UserChangedImpl) then,
  ) = __$$UserChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AuthUser user});

  $AuthUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$UserChangedImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$UserChangedImpl>
    implements _$$UserChangedImplCopyWith<$Res> {
  __$$UserChangedImplCopyWithImpl(
    _$UserChangedImpl _value,
    $Res Function(_$UserChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null}) {
    return _then(
      _$UserChangedImpl(
        null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                as AuthUser,
      ),
    );
  }

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserCopyWith<$Res> get user {
    return $AuthUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value));
    });
  }
}

/// @nodoc

class _$UserChangedImpl implements _UserChanged {
  const _$UserChangedImpl(this.user);

  @override
  final AuthUser user;

  @override
  String toString() {
    return 'AuthEvent.userChanged(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserChangedImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserChangedImplCopyWith<_$UserChangedImpl> get copyWith =>
      __$$UserChangedImplCopyWithImpl<_$UserChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return userChanged(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return userChanged?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (userChanged != null) {
      return userChanged(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return userChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return userChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (userChanged != null) {
      return userChanged(this);
    }
    return orElse();
  }
}

abstract class _UserChanged implements AuthEvent {
  const factory _UserChanged(final AuthUser user) = _$UserChangedImpl;

  AuthUser get user;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserChangedImplCopyWith<_$UserChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SignedOutImplCopyWith<$Res> {
  factory _$$SignedOutImplCopyWith(
    _$SignedOutImpl value,
    $Res Function(_$SignedOutImpl) then,
  ) = __$$SignedOutImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SignedOutImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SignedOutImpl>
    implements _$$SignedOutImplCopyWith<$Res> {
  __$$SignedOutImplCopyWithImpl(
    _$SignedOutImpl _value,
    $Res Function(_$SignedOutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SignedOutImpl implements _SignedOut {
  const _$SignedOutImpl();

  @override
  String toString() {
    return 'AuthEvent.signedOut()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SignedOutImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkAuth,
    required TResult Function(String email, String password) signInWithEmail,
    required TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )
    signUpWithEmail,
    required TResult Function() signInWithGoogle,
    required TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )
    completeGoogleSignIn,
    required TResult Function() signOut,
    required TResult Function(String email) resetPassword,
    required TResult Function(String accountType) updateAccountType,
    required TResult Function(AuthUser user) userChanged,
    required TResult Function() signedOut,
  }) {
    return signedOut();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkAuth,
    TResult? Function(String email, String password)? signInWithEmail,
    TResult? Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult? Function()? signInWithGoogle,
    TResult? Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult? Function()? signOut,
    TResult? Function(String email)? resetPassword,
    TResult? Function(String accountType)? updateAccountType,
    TResult? Function(AuthUser user)? userChanged,
    TResult? Function()? signedOut,
  }) {
    return signedOut?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkAuth,
    TResult Function(String email, String password)? signInWithEmail,
    TResult Function(
      String email,
      String password,
      String? name,
      String? accountType,
    )?
    signUpWithEmail,
    TResult Function()? signInWithGoogle,
    TResult Function(
      String idToken,
      String accountType,
      String? displayName,
      String? photoUrl,
    )?
    completeGoogleSignIn,
    TResult Function()? signOut,
    TResult Function(String email)? resetPassword,
    TResult Function(String accountType)? updateAccountType,
    TResult Function(AuthUser user)? userChanged,
    TResult Function()? signedOut,
    required TResult orElse(),
  }) {
    if (signedOut != null) {
      return signedOut();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CheckAuth value) checkAuth,
    required TResult Function(_SignInWithEmail value) signInWithEmail,
    required TResult Function(_SignUpWithEmail value) signUpWithEmail,
    required TResult Function(_SignInWithGoogle value) signInWithGoogle,
    required TResult Function(_CompleteGoogleSignIn value) completeGoogleSignIn,
    required TResult Function(_SignOut value) signOut,
    required TResult Function(_ResetPassword value) resetPassword,
    required TResult Function(_UpdateAccountType value) updateAccountType,
    required TResult Function(_UserChanged value) userChanged,
    required TResult Function(_SignedOut value) signedOut,
  }) {
    return signedOut(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CheckAuth value)? checkAuth,
    TResult? Function(_SignInWithEmail value)? signInWithEmail,
    TResult? Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult? Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult? Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult? Function(_SignOut value)? signOut,
    TResult? Function(_ResetPassword value)? resetPassword,
    TResult? Function(_UpdateAccountType value)? updateAccountType,
    TResult? Function(_UserChanged value)? userChanged,
    TResult? Function(_SignedOut value)? signedOut,
  }) {
    return signedOut?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CheckAuth value)? checkAuth,
    TResult Function(_SignInWithEmail value)? signInWithEmail,
    TResult Function(_SignUpWithEmail value)? signUpWithEmail,
    TResult Function(_SignInWithGoogle value)? signInWithGoogle,
    TResult Function(_CompleteGoogleSignIn value)? completeGoogleSignIn,
    TResult Function(_SignOut value)? signOut,
    TResult Function(_ResetPassword value)? resetPassword,
    TResult Function(_UpdateAccountType value)? updateAccountType,
    TResult Function(_UserChanged value)? userChanged,
    TResult Function(_SignedOut value)? signedOut,
    required TResult orElse(),
  }) {
    if (signedOut != null) {
      return signedOut(this);
    }
    return orElse();
  }
}

abstract class _SignedOut implements AuthEvent {
  const factory _SignedOut() = _$SignedOutImpl;
}

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthUser user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function(String message) error,
    required TResult Function() passwordResetSent,
    required TResult Function(
      String idToken,
      String? displayName,
      String? photoUrl,
    )
    accountTypeRequired,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthUser user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function()? passwordResetSent,
    TResult? Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthUser user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function(String message)? error,
    TResult Function()? passwordResetSent,
    TResult Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_Error value) error,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_AccountTypeRequired value) accountTypeRequired,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_Error value)? error,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_AccountTypeRequired value)? accountTypeRequired,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_Error value)? error,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_AccountTypeRequired value)? accountTypeRequired,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'AuthState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthUser user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function(String message) error,
    required TResult Function() passwordResetSent,
    required TResult Function(
      String idToken,
      String? displayName,
      String? photoUrl,
    )
    accountTypeRequired,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthUser user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function()? passwordResetSent,
    TResult? Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthUser user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function(String message)? error,
    TResult Function()? passwordResetSent,
    TResult Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_Error value) error,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_AccountTypeRequired value) accountTypeRequired,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_Error value)? error,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_AccountTypeRequired value)? accountTypeRequired,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_Error value)? error,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_AccountTypeRequired value)? accountTypeRequired,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements AuthState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'AuthState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthUser user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function(String message) error,
    required TResult Function() passwordResetSent,
    required TResult Function(
      String idToken,
      String? displayName,
      String? photoUrl,
    )
    accountTypeRequired,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthUser user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function()? passwordResetSent,
    TResult? Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthUser user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function(String message)? error,
    TResult Function()? passwordResetSent,
    TResult Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_Error value) error,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_AccountTypeRequired value) accountTypeRequired,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_Error value)? error,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_AccountTypeRequired value)? accountTypeRequired,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_Error value)? error,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_AccountTypeRequired value)? accountTypeRequired,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements AuthState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$AuthenticatedImplCopyWith<$Res> {
  factory _$$AuthenticatedImplCopyWith(
    _$AuthenticatedImpl value,
    $Res Function(_$AuthenticatedImpl) then,
  ) = __$$AuthenticatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AuthUser user});

  $AuthUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthenticatedImpl>
    implements _$$AuthenticatedImplCopyWith<$Res> {
  __$$AuthenticatedImplCopyWithImpl(
    _$AuthenticatedImpl _value,
    $Res Function(_$AuthenticatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null}) {
    return _then(
      _$AuthenticatedImpl(
        null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                as AuthUser,
      ),
    );
  }

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthUserCopyWith<$Res> get user {
    return $AuthUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value));
    });
  }
}

/// @nodoc

class _$AuthenticatedImpl implements _Authenticated {
  const _$AuthenticatedImpl(this.user);

  @override
  final AuthUser user;

  @override
  String toString() {
    return 'AuthState.authenticated(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticatedImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      __$$AuthenticatedImplCopyWithImpl<_$AuthenticatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthUser user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function(String message) error,
    required TResult Function() passwordResetSent,
    required TResult Function(
      String idToken,
      String? displayName,
      String? photoUrl,
    )
    accountTypeRequired,
  }) {
    return authenticated(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthUser user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function()? passwordResetSent,
    TResult? Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
  }) {
    return authenticated?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthUser user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function(String message)? error,
    TResult Function()? passwordResetSent,
    TResult Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_Error value) error,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_AccountTypeRequired value) accountTypeRequired,
  }) {
    return authenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_Error value)? error,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_AccountTypeRequired value)? accountTypeRequired,
  }) {
    return authenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_Error value)? error,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_AccountTypeRequired value)? accountTypeRequired,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(this);
    }
    return orElse();
  }
}

abstract class _Authenticated implements AuthState {
  const factory _Authenticated(final AuthUser user) = _$AuthenticatedImpl;

  AuthUser get user;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthenticatedImplCopyWith<$Res> {
  factory _$$UnauthenticatedImplCopyWith(
    _$UnauthenticatedImpl value,
    $Res Function(_$UnauthenticatedImpl) then,
  ) = __$$UnauthenticatedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UnauthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$UnauthenticatedImpl>
    implements _$$UnauthenticatedImplCopyWith<$Res> {
  __$$UnauthenticatedImplCopyWithImpl(
    _$UnauthenticatedImpl _value,
    $Res Function(_$UnauthenticatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UnauthenticatedImpl implements _Unauthenticated {
  const _$UnauthenticatedImpl();

  @override
  String toString() {
    return 'AuthState.unauthenticated()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UnauthenticatedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthUser user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function(String message) error,
    required TResult Function() passwordResetSent,
    required TResult Function(
      String idToken,
      String? displayName,
      String? photoUrl,
    )
    accountTypeRequired,
  }) {
    return unauthenticated();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthUser user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function()? passwordResetSent,
    TResult? Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
  }) {
    return unauthenticated?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthUser user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function(String message)? error,
    TResult Function()? passwordResetSent,
    TResult Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_Error value) error,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_AccountTypeRequired value) accountTypeRequired,
  }) {
    return unauthenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_Error value)? error,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_AccountTypeRequired value)? accountTypeRequired,
  }) {
    return unauthenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_Error value)? error,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_AccountTypeRequired value)? accountTypeRequired,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(this);
    }
    return orElse();
  }
}

abstract class _Unauthenticated implements AuthState {
  const factory _Unauthenticated() = _$UnauthenticatedImpl;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'AuthState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthUser user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function(String message) error,
    required TResult Function() passwordResetSent,
    required TResult Function(
      String idToken,
      String? displayName,
      String? photoUrl,
    )
    accountTypeRequired,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthUser user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function()? passwordResetSent,
    TResult? Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthUser user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function(String message)? error,
    TResult Function()? passwordResetSent,
    TResult Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_Error value) error,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_AccountTypeRequired value) accountTypeRequired,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_Error value)? error,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_AccountTypeRequired value)? accountTypeRequired,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_Error value)? error,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_AccountTypeRequired value)? accountTypeRequired,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements AuthState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PasswordResetSentImplCopyWith<$Res> {
  factory _$$PasswordResetSentImplCopyWith(
    _$PasswordResetSentImpl value,
    $Res Function(_$PasswordResetSentImpl) then,
  ) = __$$PasswordResetSentImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PasswordResetSentImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$PasswordResetSentImpl>
    implements _$$PasswordResetSentImplCopyWith<$Res> {
  __$$PasswordResetSentImplCopyWithImpl(
    _$PasswordResetSentImpl _value,
    $Res Function(_$PasswordResetSentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PasswordResetSentImpl implements _PasswordResetSent {
  const _$PasswordResetSentImpl();

  @override
  String toString() {
    return 'AuthState.passwordResetSent()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PasswordResetSentImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthUser user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function(String message) error,
    required TResult Function() passwordResetSent,
    required TResult Function(
      String idToken,
      String? displayName,
      String? photoUrl,
    )
    accountTypeRequired,
  }) {
    return passwordResetSent();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthUser user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function()? passwordResetSent,
    TResult? Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
  }) {
    return passwordResetSent?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthUser user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function(String message)? error,
    TResult Function()? passwordResetSent,
    TResult Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
    required TResult orElse(),
  }) {
    if (passwordResetSent != null) {
      return passwordResetSent();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_Error value) error,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_AccountTypeRequired value) accountTypeRequired,
  }) {
    return passwordResetSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_Error value)? error,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_AccountTypeRequired value)? accountTypeRequired,
  }) {
    return passwordResetSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_Error value)? error,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_AccountTypeRequired value)? accountTypeRequired,
    required TResult orElse(),
  }) {
    if (passwordResetSent != null) {
      return passwordResetSent(this);
    }
    return orElse();
  }
}

abstract class _PasswordResetSent implements AuthState {
  const factory _PasswordResetSent() = _$PasswordResetSentImpl;
}

/// @nodoc
abstract class _$$AccountTypeRequiredImplCopyWith<$Res> {
  factory _$$AccountTypeRequiredImplCopyWith(
    _$AccountTypeRequiredImpl value,
    $Res Function(_$AccountTypeRequiredImpl) then,
  ) = __$$AccountTypeRequiredImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String idToken, String? displayName, String? photoUrl});
}

/// @nodoc
class __$$AccountTypeRequiredImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AccountTypeRequiredImpl>
    implements _$$AccountTypeRequiredImplCopyWith<$Res> {
  __$$AccountTypeRequiredImplCopyWithImpl(
    _$AccountTypeRequiredImpl _value,
    $Res Function(_$AccountTypeRequiredImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idToken = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _$AccountTypeRequiredImpl(
        null == idToken
            ? _value.idToken
            : idToken // ignore: cast_nullable_to_non_nullable
                as String,
        freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                as String?,
        freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$AccountTypeRequiredImpl implements _AccountTypeRequired {
  const _$AccountTypeRequiredImpl(
    this.idToken,
    this.displayName,
    this.photoUrl,
  );

  @override
  final String idToken;
  @override
  final String? displayName;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'AuthState.accountTypeRequired(idToken: $idToken, displayName: $displayName, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountTypeRequiredImpl &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, idToken, displayName, photoUrl);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountTypeRequiredImplCopyWith<_$AccountTypeRequiredImpl> get copyWith =>
      __$$AccountTypeRequiredImplCopyWithImpl<_$AccountTypeRequiredImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AuthUser user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function(String message) error,
    required TResult Function() passwordResetSent,
    required TResult Function(
      String idToken,
      String? displayName,
      String? photoUrl,
    )
    accountTypeRequired,
  }) {
    return accountTypeRequired(idToken, displayName, photoUrl);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AuthUser user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function()? passwordResetSent,
    TResult? Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
  }) {
    return accountTypeRequired?.call(idToken, displayName, photoUrl);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AuthUser user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function(String message)? error,
    TResult Function()? passwordResetSent,
    TResult Function(String idToken, String? displayName, String? photoUrl)?
    accountTypeRequired,
    required TResult orElse(),
  }) {
    if (accountTypeRequired != null) {
      return accountTypeRequired(idToken, displayName, photoUrl);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Authenticated value) authenticated,
    required TResult Function(_Unauthenticated value) unauthenticated,
    required TResult Function(_Error value) error,
    required TResult Function(_PasswordResetSent value) passwordResetSent,
    required TResult Function(_AccountTypeRequired value) accountTypeRequired,
  }) {
    return accountTypeRequired(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Authenticated value)? authenticated,
    TResult? Function(_Unauthenticated value)? unauthenticated,
    TResult? Function(_Error value)? error,
    TResult? Function(_PasswordResetSent value)? passwordResetSent,
    TResult? Function(_AccountTypeRequired value)? accountTypeRequired,
  }) {
    return accountTypeRequired?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Authenticated value)? authenticated,
    TResult Function(_Unauthenticated value)? unauthenticated,
    TResult Function(_Error value)? error,
    TResult Function(_PasswordResetSent value)? passwordResetSent,
    TResult Function(_AccountTypeRequired value)? accountTypeRequired,
    required TResult orElse(),
  }) {
    if (accountTypeRequired != null) {
      return accountTypeRequired(this);
    }
    return orElse();
  }
}

abstract class _AccountTypeRequired implements AuthState {
  const factory _AccountTypeRequired(
    final String idToken,
    final String? displayName,
    final String? photoUrl,
  ) = _$AccountTypeRequiredImpl;

  String get idToken;
  String? get displayName;
  String? get photoUrl;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountTypeRequiredImplCopyWith<_$AccountTypeRequiredImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
