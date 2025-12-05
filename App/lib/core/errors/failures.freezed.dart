// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Failure {
  String? get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverFailure,
    required TResult Function(String? message) cacheFailure,
    required TResult Function(String? message) networkFailure,
    required TResult Function(String? message) validationFailure,
    required TResult Function(String? message) notFoundFailure,
    required TResult Function(String? message) unauthorizedFailure,
    required TResult Function(String? message) unknownFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverFailure,
    TResult? Function(String? message)? cacheFailure,
    TResult? Function(String? message)? networkFailure,
    TResult? Function(String? message)? validationFailure,
    TResult? Function(String? message)? notFoundFailure,
    TResult? Function(String? message)? unauthorizedFailure,
    TResult? Function(String? message)? unknownFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverFailure,
    TResult Function(String? message)? cacheFailure,
    TResult Function(String? message)? networkFailure,
    TResult Function(String? message)? validationFailure,
    TResult Function(String? message)? notFoundFailure,
    TResult Function(String? message)? unauthorizedFailure,
    TResult Function(String? message)? unknownFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(NotFoundFailure value) notFoundFailure,
    required TResult Function(UnauthorizedFailure value) unauthorizedFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(NotFoundFailure value)? notFoundFailure,
    TResult? Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(NotFoundFailure value)? notFoundFailure,
    TResult Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FailureCopyWith<Failure> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _value.copyWith(
            message:
                freezed == message
                    ? _value.message
                    : message // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServerFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ServerFailureImplCopyWith(
    _$ServerFailureImpl value,
    $Res Function(_$ServerFailureImpl) then,
  ) = __$$ServerFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$ServerFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ServerFailureImpl>
    implements _$$ServerFailureImplCopyWith<$Res> {
  __$$ServerFailureImplCopyWithImpl(
    _$ServerFailureImpl _value,
    $Res Function(_$ServerFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$ServerFailureImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$ServerFailureImpl implements ServerFailure {
  const _$ServerFailureImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.serverFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      __$$ServerFailureImplCopyWithImpl<_$ServerFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverFailure,
    required TResult Function(String? message) cacheFailure,
    required TResult Function(String? message) networkFailure,
    required TResult Function(String? message) validationFailure,
    required TResult Function(String? message) notFoundFailure,
    required TResult Function(String? message) unauthorizedFailure,
    required TResult Function(String? message) unknownFailure,
  }) {
    return serverFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverFailure,
    TResult? Function(String? message)? cacheFailure,
    TResult? Function(String? message)? networkFailure,
    TResult? Function(String? message)? validationFailure,
    TResult? Function(String? message)? notFoundFailure,
    TResult? Function(String? message)? unauthorizedFailure,
    TResult? Function(String? message)? unknownFailure,
  }) {
    return serverFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverFailure,
    TResult Function(String? message)? cacheFailure,
    TResult Function(String? message)? networkFailure,
    TResult Function(String? message)? validationFailure,
    TResult Function(String? message)? notFoundFailure,
    TResult Function(String? message)? unauthorizedFailure,
    TResult Function(String? message)? unknownFailure,
    required TResult orElse(),
  }) {
    if (serverFailure != null) {
      return serverFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(NotFoundFailure value) notFoundFailure,
    required TResult Function(UnauthorizedFailure value) unauthorizedFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
  }) {
    return serverFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(NotFoundFailure value)? notFoundFailure,
    TResult? Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
  }) {
    return serverFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(NotFoundFailure value)? notFoundFailure,
    TResult Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    required TResult orElse(),
  }) {
    if (serverFailure != null) {
      return serverFailure(this);
    }
    return orElse();
  }
}

abstract class ServerFailure implements Failure {
  const factory ServerFailure([final String? message]) = _$ServerFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$CacheFailureImplCopyWith(
    _$CacheFailureImpl value,
    $Res Function(_$CacheFailureImpl) then,
  ) = __$$CacheFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$CacheFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$CacheFailureImpl>
    implements _$$CacheFailureImplCopyWith<$Res> {
  __$$CacheFailureImplCopyWithImpl(
    _$CacheFailureImpl _value,
    $Res Function(_$CacheFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$CacheFailureImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$CacheFailureImpl implements CacheFailure {
  const _$CacheFailureImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.cacheFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      __$$CacheFailureImplCopyWithImpl<_$CacheFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverFailure,
    required TResult Function(String? message) cacheFailure,
    required TResult Function(String? message) networkFailure,
    required TResult Function(String? message) validationFailure,
    required TResult Function(String? message) notFoundFailure,
    required TResult Function(String? message) unauthorizedFailure,
    required TResult Function(String? message) unknownFailure,
  }) {
    return cacheFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverFailure,
    TResult? Function(String? message)? cacheFailure,
    TResult? Function(String? message)? networkFailure,
    TResult? Function(String? message)? validationFailure,
    TResult? Function(String? message)? notFoundFailure,
    TResult? Function(String? message)? unauthorizedFailure,
    TResult? Function(String? message)? unknownFailure,
  }) {
    return cacheFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverFailure,
    TResult Function(String? message)? cacheFailure,
    TResult Function(String? message)? networkFailure,
    TResult Function(String? message)? validationFailure,
    TResult Function(String? message)? notFoundFailure,
    TResult Function(String? message)? unauthorizedFailure,
    TResult Function(String? message)? unknownFailure,
    required TResult orElse(),
  }) {
    if (cacheFailure != null) {
      return cacheFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(NotFoundFailure value) notFoundFailure,
    required TResult Function(UnauthorizedFailure value) unauthorizedFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
  }) {
    return cacheFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(NotFoundFailure value)? notFoundFailure,
    TResult? Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
  }) {
    return cacheFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(NotFoundFailure value)? notFoundFailure,
    TResult Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    required TResult orElse(),
  }) {
    if (cacheFailure != null) {
      return cacheFailure(this);
    }
    return orElse();
  }
}

abstract class CacheFailure implements Failure {
  const factory CacheFailure([final String? message]) = _$CacheFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(
    _$NetworkFailureImpl value,
    $Res Function(_$NetworkFailureImpl) then,
  ) = __$$NetworkFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
    _$NetworkFailureImpl _value,
    $Res Function(_$NetworkFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$NetworkFailureImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$NetworkFailureImpl implements NetworkFailure {
  const _$NetworkFailureImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.networkFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      __$$NetworkFailureImplCopyWithImpl<_$NetworkFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverFailure,
    required TResult Function(String? message) cacheFailure,
    required TResult Function(String? message) networkFailure,
    required TResult Function(String? message) validationFailure,
    required TResult Function(String? message) notFoundFailure,
    required TResult Function(String? message) unauthorizedFailure,
    required TResult Function(String? message) unknownFailure,
  }) {
    return networkFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverFailure,
    TResult? Function(String? message)? cacheFailure,
    TResult? Function(String? message)? networkFailure,
    TResult? Function(String? message)? validationFailure,
    TResult? Function(String? message)? notFoundFailure,
    TResult? Function(String? message)? unauthorizedFailure,
    TResult? Function(String? message)? unknownFailure,
  }) {
    return networkFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverFailure,
    TResult Function(String? message)? cacheFailure,
    TResult Function(String? message)? networkFailure,
    TResult Function(String? message)? validationFailure,
    TResult Function(String? message)? notFoundFailure,
    TResult Function(String? message)? unauthorizedFailure,
    TResult Function(String? message)? unknownFailure,
    required TResult orElse(),
  }) {
    if (networkFailure != null) {
      return networkFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(NotFoundFailure value) notFoundFailure,
    required TResult Function(UnauthorizedFailure value) unauthorizedFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
  }) {
    return networkFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(NotFoundFailure value)? notFoundFailure,
    TResult? Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
  }) {
    return networkFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(NotFoundFailure value)? notFoundFailure,
    TResult Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    required TResult orElse(),
  }) {
    if (networkFailure != null) {
      return networkFailure(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure implements Failure {
  const factory NetworkFailure([final String? message]) = _$NetworkFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ValidationFailureImplCopyWith(
    _$ValidationFailureImpl value,
    $Res Function(_$ValidationFailureImpl) then,
  ) = __$$ValidationFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$ValidationFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ValidationFailureImpl>
    implements _$$ValidationFailureImplCopyWith<$Res> {
  __$$ValidationFailureImplCopyWithImpl(
    _$ValidationFailureImpl _value,
    $Res Function(_$ValidationFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$ValidationFailureImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$ValidationFailureImpl implements ValidationFailure {
  const _$ValidationFailureImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.validationFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      __$$ValidationFailureImplCopyWithImpl<_$ValidationFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverFailure,
    required TResult Function(String? message) cacheFailure,
    required TResult Function(String? message) networkFailure,
    required TResult Function(String? message) validationFailure,
    required TResult Function(String? message) notFoundFailure,
    required TResult Function(String? message) unauthorizedFailure,
    required TResult Function(String? message) unknownFailure,
  }) {
    return validationFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverFailure,
    TResult? Function(String? message)? cacheFailure,
    TResult? Function(String? message)? networkFailure,
    TResult? Function(String? message)? validationFailure,
    TResult? Function(String? message)? notFoundFailure,
    TResult? Function(String? message)? unauthorizedFailure,
    TResult? Function(String? message)? unknownFailure,
  }) {
    return validationFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverFailure,
    TResult Function(String? message)? cacheFailure,
    TResult Function(String? message)? networkFailure,
    TResult Function(String? message)? validationFailure,
    TResult Function(String? message)? notFoundFailure,
    TResult Function(String? message)? unauthorizedFailure,
    TResult Function(String? message)? unknownFailure,
    required TResult orElse(),
  }) {
    if (validationFailure != null) {
      return validationFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(NotFoundFailure value) notFoundFailure,
    required TResult Function(UnauthorizedFailure value) unauthorizedFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
  }) {
    return validationFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(NotFoundFailure value)? notFoundFailure,
    TResult? Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
  }) {
    return validationFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(NotFoundFailure value)? notFoundFailure,
    TResult Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    required TResult orElse(),
  }) {
    if (validationFailure != null) {
      return validationFailure(this);
    }
    return orElse();
  }
}

abstract class ValidationFailure implements Failure {
  const factory ValidationFailure([final String? message]) =
      _$ValidationFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NotFoundFailureImplCopyWith(
    _$NotFoundFailureImpl value,
    $Res Function(_$NotFoundFailureImpl) then,
  ) = __$$NotFoundFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$NotFoundFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NotFoundFailureImpl>
    implements _$$NotFoundFailureImplCopyWith<$Res> {
  __$$NotFoundFailureImplCopyWithImpl(
    _$NotFoundFailureImpl _value,
    $Res Function(_$NotFoundFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$NotFoundFailureImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$NotFoundFailureImpl implements NotFoundFailure {
  const _$NotFoundFailureImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.notFoundFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      __$$NotFoundFailureImplCopyWithImpl<_$NotFoundFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverFailure,
    required TResult Function(String? message) cacheFailure,
    required TResult Function(String? message) networkFailure,
    required TResult Function(String? message) validationFailure,
    required TResult Function(String? message) notFoundFailure,
    required TResult Function(String? message) unauthorizedFailure,
    required TResult Function(String? message) unknownFailure,
  }) {
    return notFoundFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverFailure,
    TResult? Function(String? message)? cacheFailure,
    TResult? Function(String? message)? networkFailure,
    TResult? Function(String? message)? validationFailure,
    TResult? Function(String? message)? notFoundFailure,
    TResult? Function(String? message)? unauthorizedFailure,
    TResult? Function(String? message)? unknownFailure,
  }) {
    return notFoundFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverFailure,
    TResult Function(String? message)? cacheFailure,
    TResult Function(String? message)? networkFailure,
    TResult Function(String? message)? validationFailure,
    TResult Function(String? message)? notFoundFailure,
    TResult Function(String? message)? unauthorizedFailure,
    TResult Function(String? message)? unknownFailure,
    required TResult orElse(),
  }) {
    if (notFoundFailure != null) {
      return notFoundFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(NotFoundFailure value) notFoundFailure,
    required TResult Function(UnauthorizedFailure value) unauthorizedFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
  }) {
    return notFoundFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(NotFoundFailure value)? notFoundFailure,
    TResult? Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
  }) {
    return notFoundFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(NotFoundFailure value)? notFoundFailure,
    TResult Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    required TResult orElse(),
  }) {
    if (notFoundFailure != null) {
      return notFoundFailure(this);
    }
    return orElse();
  }
}

abstract class NotFoundFailure implements Failure {
  const factory NotFoundFailure([final String? message]) =
      _$NotFoundFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthorizedFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnauthorizedFailureImplCopyWith(
    _$UnauthorizedFailureImpl value,
    $Res Function(_$UnauthorizedFailureImpl) then,
  ) = __$$UnauthorizedFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$UnauthorizedFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnauthorizedFailureImpl>
    implements _$$UnauthorizedFailureImplCopyWith<$Res> {
  __$$UnauthorizedFailureImplCopyWithImpl(
    _$UnauthorizedFailureImpl _value,
    $Res Function(_$UnauthorizedFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$UnauthorizedFailureImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$UnauthorizedFailureImpl implements UnauthorizedFailure {
  const _$UnauthorizedFailureImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.unauthorizedFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthorizedFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthorizedFailureImplCopyWith<_$UnauthorizedFailureImpl> get copyWith =>
      __$$UnauthorizedFailureImplCopyWithImpl<_$UnauthorizedFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverFailure,
    required TResult Function(String? message) cacheFailure,
    required TResult Function(String? message) networkFailure,
    required TResult Function(String? message) validationFailure,
    required TResult Function(String? message) notFoundFailure,
    required TResult Function(String? message) unauthorizedFailure,
    required TResult Function(String? message) unknownFailure,
  }) {
    return unauthorizedFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverFailure,
    TResult? Function(String? message)? cacheFailure,
    TResult? Function(String? message)? networkFailure,
    TResult? Function(String? message)? validationFailure,
    TResult? Function(String? message)? notFoundFailure,
    TResult? Function(String? message)? unauthorizedFailure,
    TResult? Function(String? message)? unknownFailure,
  }) {
    return unauthorizedFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverFailure,
    TResult Function(String? message)? cacheFailure,
    TResult Function(String? message)? networkFailure,
    TResult Function(String? message)? validationFailure,
    TResult Function(String? message)? notFoundFailure,
    TResult Function(String? message)? unauthorizedFailure,
    TResult Function(String? message)? unknownFailure,
    required TResult orElse(),
  }) {
    if (unauthorizedFailure != null) {
      return unauthorizedFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(NotFoundFailure value) notFoundFailure,
    required TResult Function(UnauthorizedFailure value) unauthorizedFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
  }) {
    return unauthorizedFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(NotFoundFailure value)? notFoundFailure,
    TResult? Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
  }) {
    return unauthorizedFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(NotFoundFailure value)? notFoundFailure,
    TResult Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    required TResult orElse(),
  }) {
    if (unauthorizedFailure != null) {
      return unauthorizedFailure(this);
    }
    return orElse();
  }
}

abstract class UnauthorizedFailure implements Failure {
  const factory UnauthorizedFailure([final String? message]) =
      _$UnauthorizedFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnauthorizedFailureImplCopyWith<_$UnauthorizedFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(
    _$UnknownFailureImpl value,
    $Res Function(_$UnknownFailureImpl) then,
  ) = __$$UnknownFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
    _$UnknownFailureImpl _value,
    $Res Function(_$UnknownFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = freezed}) {
    return _then(
      _$UnknownFailureImpl(
        freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl([this.message]);

  @override
  final String? message;

  @override
  String toString() {
    return 'Failure.unknownFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverFailure,
    required TResult Function(String? message) cacheFailure,
    required TResult Function(String? message) networkFailure,
    required TResult Function(String? message) validationFailure,
    required TResult Function(String? message) notFoundFailure,
    required TResult Function(String? message) unauthorizedFailure,
    required TResult Function(String? message) unknownFailure,
  }) {
    return unknownFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverFailure,
    TResult? Function(String? message)? cacheFailure,
    TResult? Function(String? message)? networkFailure,
    TResult? Function(String? message)? validationFailure,
    TResult? Function(String? message)? notFoundFailure,
    TResult? Function(String? message)? unauthorizedFailure,
    TResult? Function(String? message)? unknownFailure,
  }) {
    return unknownFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverFailure,
    TResult Function(String? message)? cacheFailure,
    TResult Function(String? message)? networkFailure,
    TResult Function(String? message)? validationFailure,
    TResult Function(String? message)? notFoundFailure,
    TResult Function(String? message)? unauthorizedFailure,
    TResult Function(String? message)? unknownFailure,
    required TResult orElse(),
  }) {
    if (unknownFailure != null) {
      return unknownFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(NetworkFailure value) networkFailure,
    required TResult Function(ValidationFailure value) validationFailure,
    required TResult Function(NotFoundFailure value) notFoundFailure,
    required TResult Function(UnauthorizedFailure value) unauthorizedFailure,
    required TResult Function(UnknownFailure value) unknownFailure,
  }) {
    return unknownFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(NetworkFailure value)? networkFailure,
    TResult? Function(ValidationFailure value)? validationFailure,
    TResult? Function(NotFoundFailure value)? notFoundFailure,
    TResult? Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult? Function(UnknownFailure value)? unknownFailure,
  }) {
    return unknownFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(NetworkFailure value)? networkFailure,
    TResult Function(ValidationFailure value)? validationFailure,
    TResult Function(NotFoundFailure value)? notFoundFailure,
    TResult Function(UnauthorizedFailure value)? unauthorizedFailure,
    TResult Function(UnknownFailure value)? unknownFailure,
    required TResult orElse(),
  }) {
    if (unknownFailure != null) {
      return unknownFailure(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements Failure {
  const factory UnknownFailure([final String? message]) = _$UnknownFailureImpl;

  @override
  String? get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
