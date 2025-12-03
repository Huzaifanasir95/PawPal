part of 'onboarding_bloc.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState.initial() = _Initial;
  const factory OnboardingState.loaded({
    required int currentPage,
    required bool isLastPage,
  }) = _Loaded;
  const factory OnboardingState.completed() = _Completed;
}