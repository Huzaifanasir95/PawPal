import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../../data/models/caregiver_models.dart';
import 'caregiver_home_screen.dart';

class CaregiverProfileSetupScreen extends StatefulWidget {
  const CaregiverProfileSetupScreen({super.key});

  @override
  State<CaregiverProfileSetupScreen> createState() => _CaregiverProfileSetupScreenState();
}

class _CaregiverProfileSetupScreenState extends State<CaregiverProfileSetupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Personal info
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  
  // Location
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _radiusController = TextEditingController(text: '10');
  
  // Preferences
  final List<String> _acceptedPetTypes = ['dog', 'cat'];
  final List<String> _acceptedPetSizes = ['small', 'medium', 'large'];
  int _maxPetsAtOnce = 3;
  bool _hasFencedYard = false;
  bool _hasOwnTransport = false;
  bool _smokeFreeHome = true;
  bool _hasChildren = false;
  bool _hasOtherPets = false;
  final _otherPetsController = TextEditingController();
  
  // Certifications
  bool _petFirstAidCertified = false;
  final List<String> _certifications = [];
  final _certificationController = TextEditingController();

  final List<String> _stepTitles = [
    'About You',
    'Location',
    'Pet Preferences',
    'Home Environment',
    'Certifications',
  ];

  final List<String> _availablePetTypes = ['dog', 'cat', 'bird', 'fish', 'rabbit', 'hamster', 'reptile', 'other'];
  final List<String> _availableSizes = ['small', 'medium', 'large', 'giant'];

  bool _isLoading = false;
  late CaregiverRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = getIt<CaregiverRepository>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _radiusController.dispose();
    _otherPetsController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitProfile() async {
    setState(() => _isLoading = true);

    try {
      final request = CreateCaregiverProfileRequest(
        headline: _headlineController.text.isNotEmpty ? _headlineController.text : null,
        bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        yearsOfExperience: int.tryParse(_experienceController.text) ?? 0,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        state: _stateController.text.isNotEmpty ? _stateController.text : null,
        postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
        serviceRadiusKm: int.tryParse(_radiusController.text) ?? 10,
        acceptedPetTypes: _acceptedPetTypes,
        acceptedPetSizes: _acceptedPetSizes,
        maxPetsAtOnce: _maxPetsAtOnce,
        hasFencedYard: _hasFencedYard,
        hasOwnTransport: _hasOwnTransport,
        smokeFreeHome: _smokeFreeHome,
        hasChildren: _hasChildren,
        hasOtherPets: _hasOtherPets,
        otherPetsDescription: _hasOtherPets && _otherPetsController.text.isNotEmpty
            ? _otherPetsController.text
            : null,
        petFirstAidCertified: _petFirstAidCertified,
        certifications: _certifications.isNotEmpty ? _certifications : null,
      );

      await _repository.createProfile(request);

      if (mounted) {
        CustomSnackbar.showSuccess(
          context,
          'Profile created successfully!',
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CaregiverHomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Caregiver Profile Setup',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of 5: ${_stepTitles[_currentStep]}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 5,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 4.h,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAboutYouPage(),
                  _buildLocationPage(),
                  _buildPetPreferencesPage(),
                  _buildHomeEnvironmentPage(),
                  _buildCertificationsPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: AppTextStyles.buttonMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_currentStep == 4 ? _submitProfile : _nextStep),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _currentStep == 4 ? 'Complete Setup' : 'Next',
                              style: AppTextStyles.buttonMedium,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutYouPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _headlineController,
            label: 'Headline',
            hint: 'e.g., Experienced Dog Walker in Lahore',
            maxLines: 1,
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _bioController,
            label: 'About Me',
            hint: 'Tell pet owners about yourself, your experience, and why you love caring for pets...',
            maxLines: 5,
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _experienceController,
            label: 'Years of Experience',
            hint: 'e.g., 5',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _addressController,
            label: 'Address',
            hint: 'Street address',
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'e.g., Lahore',
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  hint: 'e.g., Punjab',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _postalCodeController,
            label: 'Postal Code',
            hint: 'e.g., 54000',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _radiusController,
            label: 'Service Radius (km)',
            hint: 'How far will you travel?',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildPetPreferencesPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Text(
            'Pet Types I Accept',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _availablePetTypes.map((type) {
              final isSelected = _acceptedPetTypes.contains(type);
              return FilterChip(
                label: Text(type.substring(0, 1).toUpperCase() + type.substring(1)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _acceptedPetTypes.add(type);
                    } else {
                      _acceptedPetTypes.remove(type);
                    }
                  });
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
          Text(
            'Pet Sizes I Accept',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _availableSizes.map((size) {
              final isSelected = _acceptedPetSizes.contains(size);
              return FilterChip(
                label: Text(size.substring(0, 1).toUpperCase() + size.substring(1)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _acceptedPetSizes.add(size);
                    } else {
                      _acceptedPetSizes.remove(size);
                    }
                  });
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
          Text(
            'Maximum Pets at Once: $_maxPetsAtOnce',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _maxPetsAtOnce.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: _maxPetsAtOnce.toString(),
            onChanged: (value) {
              setState(() => _maxPetsAtOnce = value.round());
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeEnvironmentPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildSwitchTile(
            title: 'Fenced Yard',
            subtitle: 'I have a secure fenced yard',
            value: _hasFencedYard,
            onChanged: (value) => setState(() => _hasFencedYard = value),
          ),
          _buildSwitchTile(
            title: 'Own Transport',
            subtitle: 'I can pick up and drop off pets',
            value: _hasOwnTransport,
            onChanged: (value) => setState(() => _hasOwnTransport = value),
          ),
          _buildSwitchTile(
            title: 'Smoke-Free Home',
            subtitle: 'My home is smoke-free',
            value: _smokeFreeHome,
            onChanged: (value) => setState(() => _smokeFreeHome = value),
          ),
          _buildSwitchTile(
            title: 'Children in Home',
            subtitle: 'I have children at home',
            value: _hasChildren,
            onChanged: (value) => setState(() => _hasChildren = value),
          ),
          _buildSwitchTile(
            title: 'Other Pets',
            subtitle: 'I have other pets at home',
            value: _hasOtherPets,
            onChanged: (value) => setState(() => _hasOtherPets = value),
          ),
          if (_hasOtherPets) ...[
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _otherPetsController,
              label: 'Describe Your Pets',
              hint: 'e.g., 2 friendly cats, 1 senior dog',
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCertificationsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildSwitchTile(
            title: 'Pet First Aid Certified',
            subtitle: 'I am trained in pet first aid',
            value: _petFirstAidCertified,
            onChanged: (value) => setState(() => _petFirstAidCertified = value),
          ),
          SizedBox(height: 24.h),
          Text(
            'Other Certifications',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _certificationController,
                  decoration: InputDecoration(
                    hintText: 'Add certification...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: () {
                  if (_certificationController.text.isNotEmpty) {
                    setState(() {
                      _certifications.add(_certificationController.text);
                      _certificationController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                iconSize: 36.w,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _certifications.map((cert) {
              return Chip(
                label: Text(cert),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() => _certifications.remove(cert));
                },
              );
            }).toList(),
          ),
          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 24.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'You can add your services and set availability after completing your profile.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
