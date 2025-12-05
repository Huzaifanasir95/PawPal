/// App Image Assets Path Constants
class AppImages {
  AppImages._();

  // Base paths
  static const String _logoPath = 'assets/logo';
  
  // Onboarding Images
  static const String onboardingPage1Pet = '$_logoPath/onboarding_page1_pet.png';
  static const String onboardingPage1LogoCenter = '$_logoPath/onboarding_page1_logo_center.png';
  static const String onboardingPage2Pet = '$_logoPath/onboarding_page_2_pet.png';
  static const String onboardingPage2Logo = '$_logoPath/onboarding_page2_logo.png';
  static const String onboardingPage3Pet = '$_logoPath/onboarding_page3_pet.png';
  static const String onboardingPage3Center = '$_logoPath/onboarding_page3_center.png';
  
  // Button and Navigation
  static const String nextButtonLogo = '$_logoPath/NextButtonLogo.png';
  
  // Primary Logo
  static const String primaryLogo = '$_logoPath/primaryLogo.png';
  
  // Helper method to get image path safely
  static String getImagePath(String imageName) {
    return '$_logoPath/$imageName';
  }
  
  // All available images list for validation
  static const List<String> allImages = [
    onboardingPage1Pet,
    onboardingPage1LogoCenter,
    onboardingPage2Pet,
    onboardingPage2Logo,
    onboardingPage3Pet,
    onboardingPage3Center,
    nextButtonLogo,
    primaryLogo,
  ];
}