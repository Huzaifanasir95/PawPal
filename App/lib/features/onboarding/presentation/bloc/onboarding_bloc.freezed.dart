// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnboardingEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int pageIndex) pageChanged,
    required TResult Function() nextPressed,
    required TResult Function() skipPressed,
    required TResult Function() getStartedPressed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int pageIndex)? pageChanged,
    TResult? Function()? nextPressed,
    TResult? Function()? skipPressed,
    TResult? Function()? getStartedPressed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int pageIndex)? pageChanged,
    TResult Function()? nextPressed,
    TResult Function()? skipPressed,
    TResult Function()? getStartedPressed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PageChanged value) pageChanged,
    required TResult Function(_NextPressed value) nextPressed,
    required TResult Function(_SkipPressed value) skipPressed,
    required TResult Function(_GetStartedPressed value) getStartedPressed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PageChanged value)? pageChanged,
    TResult? Function(_NextPressed value)? nextPressed,
    TResult? Function(_SkipPressed value)? skipPressed,
    TResult? Function(_GetStartedPressed value)? getStartedPressed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PageChanged value)? pageChanged,
    TResult Function(_NextPressed value)? nextPressed,
    TResult Function(_SkipPressed value)? skipPressed,
    TResult Function(_GetStartedPressed value)? getStartedPressed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingEventCopyWith<$Res> {
  factory $OnboardingEventCopyWith(
    OnboardingEvent value,
    $Res Function(OnboardingEvent) then,
  ) = _$OnboardingEventCopyWithImpl<$Res, OnboardingEvent>;
}

/// @nodoc
class _$OnboardingEventCopyWithImpl<$Res, $Val extends OnboardingEvent>
    implements $OnboardingEventCopyWith<$Res> {
  _$OnboardingEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$PageChangedImplCopyWith<$Res> {
  factory _$$PageChangedImplCopyWith(
    _$PageChangedImpl value,
    $Res Function(_$PageChangedImpl) then,
  ) = __$$PageChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int pageIndex});
}

/// @nodoc
class __$$PageChangedImplCopyWithImpl<$Res>
    extends _$OnboardingEventCopyWithImpl<$Res, _$PageChangedImpl>
    implements _$$PageChangedImplCopyWith<$Res> {
  __$$PageChangedImplCopyWithImpl(
    _$PageChangedImpl _value,
    $Res Function(_$PageChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pageIndex = null}) {
    return _then(
      _$PageChangedImpl(
        null == pageIndex
            ? _value.pageIndex
            : pageIndex // ignore: cast_nullable_to_non_nullable
                as int,
      ),
    );
  }
}

/// @nodoc

class _$PageChangedImpl implements _PageChanged {
  const _$PageChangedImpl(this.pageIndex);

  @override
  final int pageIndex;

  @override
  String toString() {
    return 'OnboardingEvent.pageChanged(pageIndex: $pageIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageChangedImpl &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pageIndex);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageChangedImplCopyWith<_$PageChangedImpl> get copyWith =>
      __$$PageChangedImplCopyWithImpl<_$PageChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int pageIndex) pageChanged,
    required TResult Function() nextPressed,
    required TResult Function() skipPressed,
    required TResult Function() getStartedPressed,
  }) {
    return pageChanged(pageIndex);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int pageIndex)? pageChanged,
    TResult? Function()? nextPressed,
    TResult? Function()? skipPressed,
    TResult? Function()? getStartedPressed,
  }) {
    return pageChanged?.call(pageIndex);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int pageIndex)? pageChanged,
    TResult Function()? nextPressed,
    TResult Function()? skipPressed,
    TResult Function()? getStartedPressed,
    required TResult orElse(),
  }) {
    if (pageChanged != null) {
      return pageChanged(pageIndex);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PageChanged value) pageChanged,
    required TResult Function(_NextPressed value) nextPressed,
    required TResult Function(_SkipPressed value) skipPressed,
    required TResult Function(_GetStartedPressed value) getStartedPressed,
  }) {
    return pageChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PageChanged value)? pageChanged,
    TResult? Function(_NextPressed value)? nextPressed,
    TResult? Function(_SkipPressed value)? skipPressed,
    TResult? Function(_GetStartedPressed value)? getStartedPressed,
  }) {
    return pageChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PageChanged value)? pageChanged,
    TResult Function(_NextPressed value)? nextPressed,
    TResult Function(_SkipPressed value)? skipPressed,
    TResult Function(_GetStartedPressed value)? getStartedPressed,
    required TResult orElse(),
  }) {
    if (pageChanged != null) {
      return pageChanged(this);
    }
    return orElse();
  }
}

abstract class _PageChanged implements OnboardingEvent {
  const factory _PageChanged(final int pageIndex) = _$PageChangedImpl;

  int get pageIndex;

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageChangedImplCopyWith<_$PageChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NextPressedImplCopyWith<$Res> {
  factory _$$NextPressedImplCopyWith(
    _$NextPressedImpl value,
    $Res Function(_$NextPressedImpl) then,
  ) = __$$NextPressedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NextPressedImplCopyWithImpl<$Res>
    extends _$OnboardingEventCopyWithImpl<$Res, _$NextPressedImpl>
    implements _$$NextPressedImplCopyWith<$Res> {
  __$$NextPressedImplCopyWithImpl(
    _$NextPressedImpl _value,
    $Res Function(_$NextPressedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NextPressedImpl implements _NextPressed {
  const _$NextPressedImpl();

  @override
  String toString() {
    return 'OnboardingEvent.nextPressed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NextPressedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int pageIndex) pageChanged,
    required TResult Function() nextPressed,
    required TResult Function() skipPressed,
    required TResult Function() getStartedPressed,
  }) {
    return nextPressed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int pageIndex)? pageChanged,
    TResult? Function()? nextPressed,
    TResult? Function()? skipPressed,
    TResult? Function()? getStartedPressed,
  }) {
    return nextPressed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int pageIndex)? pageChanged,
    TResult Function()? nextPressed,
    TResult Function()? skipPressed,
    TResult Function()? getStartedPressed,
    required TResult orElse(),
  }) {
    if (nextPressed != null) {
      return nextPressed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PageChanged value) pageChanged,
    required TResult Function(_NextPressed value) nextPressed,
    required TResult Function(_SkipPressed value) skipPressed,
    required TResult Function(_GetStartedPressed value) getStartedPressed,
  }) {
    return nextPressed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PageChanged value)? pageChanged,
    TResult? Function(_NextPressed value)? nextPressed,
    TResult? Function(_SkipPressed value)? skipPressed,
    TResult? Function(_GetStartedPressed value)? getStartedPressed,
  }) {
    return nextPressed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PageChanged value)? pageChanged,
    TResult Function(_NextPressed value)? nextPressed,
    TResult Function(_SkipPressed value)? skipPressed,
    TResult Function(_GetStartedPressed value)? getStartedPressed,
    required TResult orElse(),
  }) {
    if (nextPressed != null) {
      return nextPressed(this);
    }
    return orElse();
  }
}

abstract class _NextPressed implements OnboardingEvent {
  const factory _NextPressed() = _$NextPressedImpl;
}

/// @nodoc
abstract class _$$SkipPressedImplCopyWith<$Res> {
  factory _$$SkipPressedImplCopyWith(
    _$SkipPressedImpl value,
    $Res Function(_$SkipPressedImpl) then,
  ) = __$$SkipPressedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SkipPressedImplCopyWithImpl<$Res>
    extends _$OnboardingEventCopyWithImpl<$Res, _$SkipPressedImpl>
    implements _$$SkipPressedImplCopyWith<$Res> {
  __$$SkipPressedImplCopyWithImpl(
    _$SkipPressedImpl _value,
    $Res Function(_$SkipPressedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SkipPressedImpl implements _SkipPressed {
  const _$SkipPressedImpl();

  @override
  String toString() {
    return 'OnboardingEvent.skipPressed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SkipPressedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int pageIndex) pageChanged,
    required TResult Function() nextPressed,
    required TResult Function() skipPressed,
    required TResult Function() getStartedPressed,
  }) {
    return skipPressed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int pageIndex)? pageChanged,
    TResult? Function()? nextPressed,
    TResult? Function()? skipPressed,
    TResult? Function()? getStartedPressed,
  }) {
    return skipPressed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int pageIndex)? pageChanged,
    TResult Function()? nextPressed,
    TResult Function()? skipPressed,
    TResult Function()? getStartedPressed,
    required TResult orElse(),
  }) {
    if (skipPressed != null) {
      return skipPressed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PageChanged value) pageChanged,
    required TResult Function(_NextPressed value) nextPressed,
    required TResult Function(_SkipPressed value) skipPressed,
    required TResult Function(_GetStartedPressed value) getStartedPressed,
  }) {
    return skipPressed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PageChanged value)? pageChanged,
    TResult? Function(_NextPressed value)? nextPressed,
    TResult? Function(_SkipPressed value)? skipPressed,
    TResult? Function(_GetStartedPressed value)? getStartedPressed,
  }) {
    return skipPressed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PageChanged value)? pageChanged,
    TResult Function(_NextPressed value)? nextPressed,
    TResult Function(_SkipPressed value)? skipPressed,
    TResult Function(_GetStartedPressed value)? getStartedPressed,
    required TResult orElse(),
  }) {
    if (skipPressed != null) {
      return skipPressed(this);
    }
    return orElse();
  }
}

abstract class _SkipPressed implements OnboardingEvent {
  const factory _SkipPressed() = _$SkipPressedImpl;
}

/// @nodoc
abstract class _$$GetStartedPressedImplCopyWith<$Res> {
  factory _$$GetStartedPressedImplCopyWith(
    _$GetStartedPressedImpl value,
    $Res Function(_$GetStartedPressedImpl) then,
  ) = __$$GetStartedPressedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GetStartedPressedImplCopyWithImpl<$Res>
    extends _$OnboardingEventCopyWithImpl<$Res, _$GetStartedPressedImpl>
    implements _$$GetStartedPressedImplCopyWith<$Res> {
  __$$GetStartedPressedImplCopyWithImpl(
    _$GetStartedPressedImpl _value,
    $Res Function(_$GetStartedPressedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GetStartedPressedImpl implements _GetStartedPressed {
  const _$GetStartedPressedImpl();

  @override
  String toString() {
    return 'OnboardingEvent.getStartedPressed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GetStartedPressedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int pageIndex) pageChanged,
    required TResult Function() nextPressed,
    required TResult Function() skipPressed,
    required TResult Function() getStartedPressed,
  }) {
    return getStartedPressed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int pageIndex)? pageChanged,
    TResult? Function()? nextPressed,
    TResult? Function()? skipPressed,
    TResult? Function()? getStartedPressed,
  }) {
    return getStartedPressed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int pageIndex)? pageChanged,
    TResult Function()? nextPressed,
    TResult Function()? skipPressed,
    TResult Function()? getStartedPressed,
    required TResult orElse(),
  }) {
    if (getStartedPressed != null) {
      return getStartedPressed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PageChanged value) pageChanged,
    required TResult Function(_NextPressed value) nextPressed,
    required TResult Function(_SkipPressed value) skipPressed,
    required TResult Function(_GetStartedPressed value) getStartedPressed,
  }) {
    return getStartedPressed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PageChanged value)? pageChanged,
    TResult? Function(_NextPressed value)? nextPressed,
    TResult? Function(_SkipPressed value)? skipPressed,
    TResult? Function(_GetStartedPressed value)? getStartedPressed,
  }) {
    return getStartedPressed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PageChanged value)? pageChanged,
    TResult Function(_NextPressed value)? nextPressed,
    TResult Function(_SkipPressed value)? skipPressed,
    TResult Function(_GetStartedPressed value)? getStartedPressed,
    required TResult orElse(),
  }) {
    if (getStartedPressed != null) {
      return getStartedPressed(this);
    }
    return orElse();
  }
}

abstract class _GetStartedPressed implements OnboardingEvent {
  const factory _GetStartedPressed() = _$GetStartedPressedImpl;
}

/// @nodoc
mixin _$OnboardingState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(int currentPage, bool isLastPage) loaded,
    required TResult Function() completed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(int currentPage, bool isLastPage)? loaded,
    TResult? Function()? completed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(int currentPage, bool isLastPage)? loaded,
    TResult Function()? completed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Completed value) completed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Completed value)? completed,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Completed value)? completed,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
    OnboardingState value,
    $Res Function(OnboardingState) then,
  ) = _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingState
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
    extends _$OnboardingStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'OnboardingState.initial()';
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
    required TResult Function(int currentPage, bool isLastPage) loaded,
    required TResult Function() completed,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(int currentPage, bool isLastPage)? loaded,
    TResult? Function()? completed,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(int currentPage, bool isLastPage)? loaded,
    TResult Function()? completed,
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
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Completed value) completed,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Completed value)? completed,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Completed value)? completed,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements OnboardingState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
    _$LoadedImpl value,
    $Res Function(_$LoadedImpl) then,
  ) = __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int currentPage, bool isLastPage});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
    _$LoadedImpl _value,
    $Res Function(_$LoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? currentPage = null, Object? isLastPage = null}) {
    return _then(
      _$LoadedImpl(
        currentPage:
            null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                    as int,
        isLastPage:
            null == isLastPage
                ? _value.isLastPage
                : isLastPage // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl({required this.currentPage, required this.isLastPage});

  @override
  final int currentPage;
  @override
  final bool isLastPage;

  @override
  String toString() {
    return 'OnboardingState.loaded(currentPage: $currentPage, isLastPage: $isLastPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.isLastPage, isLastPage) ||
                other.isLastPage == isLastPage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentPage, isLastPage);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(int currentPage, bool isLastPage) loaded,
    required TResult Function() completed,
  }) {
    return loaded(currentPage, isLastPage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(int currentPage, bool isLastPage)? loaded,
    TResult? Function()? completed,
  }) {
    return loaded?.call(currentPage, isLastPage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(int currentPage, bool isLastPage)? loaded,
    TResult Function()? completed,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(currentPage, isLastPage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Completed value) completed,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Completed value)? completed,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Completed value)? completed,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements OnboardingState {
  const factory _Loaded({
    required final int currentPage,
    required final bool isLastPage,
  }) = _$LoadedImpl;

  int get currentPage;
  bool get isLastPage;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CompletedImplCopyWith<$Res> {
  factory _$$CompletedImplCopyWith(
    _$CompletedImpl value,
    $Res Function(_$CompletedImpl) then,
  ) = __$$CompletedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CompletedImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$CompletedImpl>
    implements _$$CompletedImplCopyWith<$Res> {
  __$$CompletedImplCopyWithImpl(
    _$CompletedImpl _value,
    $Res Function(_$CompletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CompletedImpl implements _Completed {
  const _$CompletedImpl();

  @override
  String toString() {
    return 'OnboardingState.completed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CompletedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(int currentPage, bool isLastPage) loaded,
    required TResult Function() completed,
  }) {
    return completed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(int currentPage, bool isLastPage)? loaded,
    TResult? Function()? completed,
  }) {
    return completed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(int currentPage, bool isLastPage)? loaded,
    TResult Function()? completed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Completed value) completed,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Completed value)? completed,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Completed value)? completed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class _Completed implements OnboardingState {
  const factory _Completed() = _$CompletedImpl;
}
