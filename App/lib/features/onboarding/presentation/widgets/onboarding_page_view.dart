import 'package:flutter/material.dart';
import 'onboarding_page_widget.dart';
import '../models/onboarding_page_config.dart';

class OnboardingPageView extends StatelessWidget {
  final PageController controller;
  final Function(int) onPageChanged;

  const OnboardingPageView({
    super.key,
    required this.controller,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      onPageChanged: onPageChanged,
      itemCount: OnboardingPageConfig.pages.length,
      itemBuilder: (context, index) {
        final config = OnboardingPageConfig.pages[index];
        return OnboardingPageWidget(
          config: config,
        );
      },
    );
  }
}