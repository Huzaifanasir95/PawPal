part of 'onboarding_bloc.dart';

@freezed
class OnboardingEvent with _$OnboardingEvent {
  const factory OnboardingEvent.pageChanged(int pageIndex) = _PageChanged;
  const factory OnboardingEvent.nextPressed() = _NextPressed;
  const factory OnboardingEvent.skipPressed() = _SkipPressed;
  const factory OnboardingEvent.getStartedPressed() = _GetStartedPressed;
}