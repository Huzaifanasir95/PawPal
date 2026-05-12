import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';

class SkipButton extends StatelessWidget {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<OnboardingBloc>().add(
          const OnboardingEvent.skipPressed(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 2,
        ),
        child: Text(
          AppStrings.skip,
          style: AppTextStyles.skipButton.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}

