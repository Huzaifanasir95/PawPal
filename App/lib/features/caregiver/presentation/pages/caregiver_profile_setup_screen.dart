import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/caregiver_models.dart';
import '../../data/repositories/caregiver_repository.dart';
import 'caregiver_home_screen.dart';

class CaregiverProfileSetupScreen extends StatefulWidget {
  const CaregiverProfileSetupScreen({super.key});

  @override
  State<CaregiverProfileSetupScreen> createState() =>
      _CaregiverProfileSetupScreenState();
}

class _CaregiverProfileSetupScreenState
    extends State<CaregiverProfileSetupScreen> {
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

  final List<IconData> _stepIcons = [
    Icons.person_outline_rounded,
    Icons.location_on_outlined,
    Icons.pets_outlined,
    Icons.home_outlined,
    Icons.verified_outlined,
  ];

  final List<String> _availablePetTypes = [
    'dog',
    'cat',
    'bird',
    'fish',
    'rabbit',
    'hamster',
    'reptile',
    'other',
  ];
  final List<String> _availableSizes = ['small', 'medium', 'large', 'giant'];

  bool _isLoading = false;
  late CaregiverRepository _repository;

  bool get _isLastStep => _currentStep == _stepTitles.length - 1;

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
    if (_currentStep < _stepTitles.length - 1) {
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
        headline:
            _headlineController.text.isNotEmpty
                ? _headlineController.text
                : null,
        bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        yearsOfExperience: int.tryParse(_experienceController.text) ?? 0,
        address:
            _addressController.text.isNotEmpty ? _addressController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        state: _stateController.text.isNotEmpty ? _stateController.text : null,
        postalCode:
            _postalCodeController.text.isNotEmpty
                ? _postalCodeController.text
                : null,
        serviceRadiusKm: int.tryParse(_radiusController.text) ?? 10,
        acceptedPetTypes: _acceptedPetTypes,
        acceptedPetSizes: _acceptedPetSizes,
        maxPetsAtOnce: _maxPetsAtOnce,
        hasFencedYard: _hasFencedYard,
        hasOwnTransport: _hasOwnTransport,
        smokeFreeHome: _smokeFreeHome,
        hasChildren: _hasChildren,
        hasOtherPets: _hasOtherPets,
        otherPetsDescription:
            _hasOtherPets && _otherPetsController.text.isNotEmpty
                ? _otherPetsController.text
                : null,
        petFirstAidCertified: _petFirstAidCertified,
        certifications: _certifications.isNotEmpty ? _certifications : null,
      );

      await _repository.createProfile(request);

      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Profile created successfully!');
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stepProgress = (_currentStep + 1) / _stepTitles.length;
    final canPopRoute = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Caregiver Profile Setup',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading:
            (_currentStep > 0 || canPopRoute)
                ? IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                  onPressed: () {
                    if (_currentStep > 0) {
                      _previousStep();
                      return;
                    }
                    Navigator.of(context).maybePop();
                  },
                )
                : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
              child: _buildProgressHeader(colorScheme, stepProgress),
            ),
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
            _buildBottomActionBar(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(ColorScheme colorScheme, double progress) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _stepIcons[_currentStep],
                  size: 20.w,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of ${_stepTitles.length}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      _stepTitles[_currentStep],
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.18)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                    minimumSize: Size.fromHeight(50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : (_isLastStep ? _submitProfile : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: Size.fromHeight(50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                        : Text(
                          _isLastStep ? 'Complete Setup' : 'Next',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutYouPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: _buildStepCard(
        title: 'Introduce Yourself',
        subtitle: 'Share your experience and what makes your care special.',
        icon: Icons.badge_outlined,
        children: [
          _buildTextField(
            controller: _headlineController,
            label: 'Headline',
            hint: 'e.g., Experienced Dog Walker in Lahore',
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _bioController,
            label: 'About Me',
            hint:
                'Tell pet owners about your experience and why you enjoy caring for pets.',
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
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: _buildStepCard(
        title: 'Service Area',
        subtitle: 'Set where you can provide care and travel distance.',
        icon: Icons.map_outlined,
        children: [
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
              SizedBox(width: 12.w),
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
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: _buildStepCard(
        title: 'Pet Preferences',
        subtitle: 'Choose the pets and sizes you are comfortable handling.',
        icon: Icons.pets_outlined,
        children: [
          Text(
            'Pet Types I Accept',
            style: AppTextStyles.titleSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                _availablePetTypes.map((type) {
                  final isSelected = _acceptedPetTypes.contains(type);
                  return _buildSelectableChip(
                    label: _titleCase(type),
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
                  );
                }).toList(),
          ),
          SizedBox(height: 22.h),
          Text(
            'Pet Sizes I Accept',
            style: AppTextStyles.titleSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                _availableSizes.map((size) {
                  final isSelected = _acceptedPetSizes.contains(size);
                  return _buildSelectableChip(
                    label: _titleCase(size),
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
                  );
                }).toList(),
          ),
          SizedBox(height: 24.h),
          Text(
            'Maximum Pets at Once: $_maxPetsAtOnce',
            style: AppTextStyles.titleSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.16),
              valueIndicatorColor: colorScheme.primary,
            ),
            child: Slider(
              value: _maxPetsAtOnce.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _maxPetsAtOnce.toString(),
              onChanged: (value) {
                setState(() => _maxPetsAtOnce = value.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeEnvironmentPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: _buildStepCard(
        title: 'Home Environment',
        subtitle: 'Describe your home setup so owners know what to expect.',
        icon: Icons.home_work_outlined,
        children: [
          _buildSwitchTile(
            title: 'Fenced Yard',
            subtitle: 'I have a secure fenced yard',
            icon: Icons.fence_rounded,
            value: _hasFencedYard,
            onChanged: (value) => setState(() => _hasFencedYard = value),
          ),
          _buildSwitchTile(
            title: 'Own Transport',
            subtitle: 'I can pick up and drop off pets',
            icon: Icons.directions_car_outlined,
            value: _hasOwnTransport,
            onChanged: (value) => setState(() => _hasOwnTransport = value),
          ),
          _buildSwitchTile(
            title: 'Smoke-Free Home',
            subtitle: 'My home is smoke-free',
            icon: Icons.air_outlined,
            value: _smokeFreeHome,
            onChanged: (value) => setState(() => _smokeFreeHome = value),
          ),
          _buildSwitchTile(
            title: 'Children in Home',
            subtitle: 'I have children at home',
            icon: Icons.family_restroom_outlined,
            value: _hasChildren,
            onChanged: (value) => setState(() => _hasChildren = value),
          ),
          _buildSwitchTile(
            title: 'Other Pets',
            subtitle: 'I have other pets at home',
            icon: Icons.pets_outlined,
            value: _hasOtherPets,
            onChanged: (value) => setState(() => _hasOtherPets = value),
          ),
          if (_hasOtherPets) ...[
            SizedBox(height: 14.h),
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
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: _buildStepCard(
        title: 'Certifications',
        subtitle: 'Highlight training and credentials for more trust.',
        icon: Icons.workspace_premium_outlined,
        children: [
          _buildSwitchTile(
            title: 'Pet First Aid Certified',
            subtitle: 'I am trained in pet first aid',
            icon: Icons.health_and_safety_outlined,
            value: _petFirstAidCertified,
            onChanged: (value) => setState(() => _petFirstAidCertified = value),
          ),
          SizedBox(height: 18.h),
          Text(
            'Other Certifications',
            style: AppTextStyles.titleSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _certificationController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 15.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add certification...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.35),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.35),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              FilledButton(
                onPressed: () {
                  if (_certificationController.text.trim().isEmpty) return;
                  setState(() {
                    _certifications.add(_certificationController.text.trim());
                    _certificationController.clear();
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: Size(48.w, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                _certifications.map((cert) {
                  return Chip(
                    label: Text(
                      cert,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 13.sp,
                      ),
                    ),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.28),
                    ),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 18.w,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onDeleted: () {
                      setState(() => _certifications.remove(cert));
                    },
                  );
                }).toList(),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: 20.w,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'You can add services and set detailed availability after profile setup.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 20.w, color: colorScheme.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontSize: 15.sp,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.7),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color:
            value
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              value
                  ? colorScheme.primary.withValues(alpha: 0.35)
                  : colorScheme.outline.withValues(alpha: 0.24),
        ),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: colorScheme.primary,
        activeTrackColor: colorScheme.primary.withValues(alpha: 0.4),
        secondary: Icon(
          icon,
          color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      checkmarkColor: colorScheme.primary,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        fontSize: 13.sp,
      ),
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.45,
      ),
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      side: BorderSide(
        color:
            selected
                ? colorScheme.primary.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
    );
  }

  String _titleCase(String raw) {
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }
}
