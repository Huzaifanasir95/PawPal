import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';

class PetImageConfig {
  final String imagePath;
  final double width;
  final double height;
  final double left;
  final double top;
  final bool showImage;

  const PetImageConfig({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.left,
    required this.top,
    this.showImage = true,
  });
}

class OnboardingPageConfig {
  final PetImageConfig petImageConfig;
  final String logoImage;
  final String title;
  final String body;

  const OnboardingPageConfig({
    required this.petImageConfig,
    required this.logoImage,
    required this.title,
    required this.body,
  });

  // Static configurations for all onboarding pages
  static const List<OnboardingPageConfig> pages = [
    // Page 1 - Cat (original positioning)
    OnboardingPageConfig(
      petImageConfig: PetImageConfig(
        imagePath: AppImages.onboardingPage1Pet,
        width: 431,
        height: 419,
        left: -6,
        top: 100, // Adjusted for safe area
        showImage: true,
      ),
      logoImage: AppImages.onboardingPage1LogoCenter,
      title: AppStrings.onboardingTitle1,
      body: AppStrings.onboardingBody1,
    ),
    // Page 2 - Dog (positioned on right side as per Figma)
    OnboardingPageConfig(
      petImageConfig: PetImageConfig(
        imagePath: AppImages.onboardingPage2Pet,
        width: 700, // Adjusted from Figma specs
        height: 550, // Adjusted from Figma specs
        left: -135, // Position on right side of screen
        top: 100, // Centered vertically in available space
        showImage: true,
      ),
      logoImage: AppImages.onboardingPage2Logo,
      title: AppStrings.onboardingTitle2,
      body: AppStrings.onboardingBody2,
    ),
    // Page 3 - Another pet
    OnboardingPageConfig(
      petImageConfig: PetImageConfig(
        imagePath: AppImages.onboardingPage3Pet,
        width: 500,
        height: 500,
        left: -30,
        top: 100,
        showImage: true,
      ),
      logoImage: AppImages.onboardingPage3Center,
      title: AppStrings.onboardingTitle3,
      body: AppStrings.onboardingBody3,
    ),
  ];
}