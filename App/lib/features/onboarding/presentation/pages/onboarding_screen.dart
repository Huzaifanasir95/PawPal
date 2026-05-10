import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pawpawl/core/constants/app_images.dart';
import '../bloc/onboarding_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../widgets/onboarding_page_widget.dart';
import '../models/onboarding_page_config.dart';
import '../widgets/custom_button.dart';
import '../widgets/skip_button.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback? onComplete;
  
  const OnboardingScreen({super.key, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: OnboardingView(onComplete: onComplete),
    );
  }
}

class OnboardingView extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const OnboardingView({super.key, this.onComplete});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        top: false, // Allow content to extend to the top for background color
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          state.maybeWhen(
            completed: () {
              // Call the completion callback instead of navigating
              widget.onComplete?.call();
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: Stack(
              children: [
                // PageView for different onboarding pages
                PageView.builder(
                  key: const ValueKey('onboarding_pageview'),
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(() {
                        _currentPage = index;
                      });
                      context.read<OnboardingBloc>().add(
                        OnboardingEvent.pageChanged(index),
                      );
                    }
                  },
                  itemCount: OnboardingPageConfig.pages.length,
                  itemBuilder: (context, index) {
                    final config = OnboardingPageConfig.pages[index];
                    return OnboardingPageWidget(
                      key: ValueKey('onboarding_page_$index'),
                      config: config,
                    );
                  },
                ),
              Positioned(child: Image.asset(AppImages.primaryLogo),
              top: 60.h,
              left: 20.w,
              ),
              // Skip Button positioned according to Figma
              Positioned(
                top: 60.h,
                right: 20.w,
                child: const SkipButton(),
              ),
              
              // Next Button positioned according to Figma
              Positioned(
                left: (390 / 2 - 335 / 2 + 0.5).w,
                top: 730.h,
                child: CustomButton(
                  icon: Image.asset(AppImages.nextButtonLogo),
                  text: _currentPage == OnboardingPageConfig.pages.length - 1 
                      ? AppStrings.getStarted 
                      : AppStrings.next,
                  width: AppDimensions.onboardingButtonWidth.w,
                  height: AppDimensions.buttonHeight.h,
                  onPressed: () {
                    if (!mounted || !_pageController.hasClients) return;
                    
                    if (_currentPage == OnboardingPageConfig.pages.length - 1) {
                      // Last page - trigger completion
                      context.read<OnboardingBloc>().add(
                        const OnboardingEvent.getStartedPressed(),
                      );
                    } else {
                      // Navigate to next page
                      final nextPage = _currentPage + 1;
                      if (nextPage < OnboardingPageConfig.pages.length) {
                        _pageController.animateToPage(
                          nextPage,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  },
                ),
              ),
            ],
            ),
          );
        },
        ),
        ),
      ),
    );
  }
}
