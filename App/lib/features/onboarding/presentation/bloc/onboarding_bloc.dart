import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';
part 'onboarding_bloc.freezed.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState.initial()) {
    on<OnboardingEvent>((event, emit) async {
      await event.when(
        pageChanged: (pageIndex) => _onPageChanged(pageIndex, emit),
        nextPressed: () => _onNextPressed(emit),
        skipPressed: () => _onSkipPressed(emit),
        getStartedPressed: () => _onGetStartedPressed(emit),
      );
    });
  }

  Future<void> _onPageChanged(int pageIndex, Emitter<OnboardingState> emit) async {
    emit(OnboardingState.loaded(
      currentPage: pageIndex,
      isLastPage: pageIndex == 2, // Assuming 3 onboarding pages (0, 1, 2)
    ));
  }

  Future<void> _onNextPressed(Emitter<OnboardingState> emit) async {
    state.maybeWhen(
      loaded: (currentPage, isLastPage) {
        if (!isLastPage) {
          final nextPage = currentPage + 1;
          emit(OnboardingState.loaded(
            currentPage: nextPage,
            isLastPage: nextPage == 2,
          ));
        } else {
          emit(const OnboardingState.completed());
        }
      },
      orElse: () {},
    );
  }

  Future<void> _onSkipPressed(Emitter<OnboardingState> emit) async {
    emit(const OnboardingState.completed());
  }

  Future<void> _onGetStartedPressed(Emitter<OnboardingState> emit) async {
    emit(const OnboardingState.completed());
  }
}