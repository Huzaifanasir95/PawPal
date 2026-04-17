import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/services/api_client.dart';
import '../../data/repositories/vet_repository.dart';
import '../../data/models/vet_profile_model.dart';
import 'vet_home_screen.dart';

class VetProfileSetupScreen extends StatefulWidget {
  final bool isEditing;
  final int initialStep;

  const VetProfileSetupScreen({
    super.key,
    this.isEditing = false,
    this.initialStep = 0,
  });

  @override
  State<VetProfileSetupScreen> createState() => _VetProfileSetupScreenState();
}

class _VetProfileSetupScreenState extends State<VetProfileSetupScreen> {
  late final PageController _pageController;
  int _currentStep = 0;

  final _fullNameController = TextEditingController();
  final _degreeController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _bioController = TextEditingController();
  final _availabilityController = TextEditingController();

  final List<String> _selectedSpecializations = [];
  final List<String> _availableSpecializations = [
    'General Practice',
    'Emergency Care',
    'Surgery',
    'Dermatology',
    'Cardiology',
    'Oncology',
    'Dentistry',
    'Orthopedics',
    'Internal Medicine',
    'Radiology',
  ];

  final List<String> _stepTitles = [
    'Personal Info',
    'Specializations',
    'Clinic Details',
    'Contact & Fees',
    'About You',
  ];

  bool _isAvailable = true;
  bool _isInitializing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final requestedStep = widget.initialStep;
    if (requestedStep < 0) {
      _currentStep = 0;
    } else if (requestedStep > 4) {
      _currentStep = 4;
    } else {
      _currentStep = requestedStep;
    }
    _pageController = PageController(initialPage: _currentStep);

    if (widget.isEditing) {
      _isInitializing = true;
      _loadExistingProfile();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _degreeController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    _consultationFeeController.dispose();
    _bioController.dispose();
    _availabilityController.dispose();
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

  Future<void> _loadExistingProfile() async {
    try {
      final profile = await VetRepository(ApiClient.instance).getMyProfile();
      if (!mounted) return;

      _populateFieldsFromProfile(profile);
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
      });

      CustomSnackbar.showError(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
      Navigator.of(context).maybePop();
    }
  }

  void _populateFieldsFromProfile(VetProfile profile) {
    _fullNameController.text = profile.fullName;
    _degreeController.text = profile.degree;
    _licenseController.text = profile.licenseNumber ?? '';
    _experienceController.text = profile.experience.toString();
    _clinicNameController.text = profile.clinicName ?? '';
    _clinicAddressController.text = profile.clinicAddress ?? '';
    _cityController.text = profile.city ?? '';
    _stateController.text = profile.state ?? '';
    _zipCodeController.text = profile.zipCode ?? '';
    _phoneController.text = profile.phone;
    _consultationFeeController.text = profile.consultationFee.toString();
    _bioController.text = profile.bio ?? '';
    _availabilityController.text = profile.availabilityHours ?? '';

    _selectedSpecializations
      ..clear()
      ..addAll(profile.specialization);

    _isAvailable = profile.isAvailable;
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

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Personal Info
        if (_fullNameController.text.trim().isEmpty) {
          CustomSnackbar.showError(context, 'Please enter your full name');
          return false;
        }
        if (_degreeController.text.trim().isEmpty) {
          CustomSnackbar.showError(context, 'Please enter your degree');
          return false;
        }
        if (_experienceController.text.trim().isEmpty ||
            int.tryParse(_experienceController.text.trim()) == null) {
          CustomSnackbar.showError(
            context,
            'Please enter valid years of experience',
          );
          return false;
        }
        return true;

      case 1: // Specializations
        if (_selectedSpecializations.isEmpty) {
          CustomSnackbar.showError(
            context,
            'Please select at least one specialization',
          );
          return false;
        }
        return true;

      case 2: // Clinic Info - Optional
        return true;

      case 3: // Contact & Fees
        if (_phoneController.text.trim().isEmpty) {
          CustomSnackbar.showError(context, 'Please enter your phone number');
          return false;
        }
        if (_consultationFeeController.text.trim().isEmpty ||
            double.tryParse(_consultationFeeController.text.trim()) == null) {
          CustomSnackbar.showError(
            context,
            'Please enter valid consultation fee',
          );
          return false;
        }
        return true;

      case 4: // About - Optional
        return true;

      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isInitializing) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Edit Vet Profile' : _stepTitles[_currentStep],
          ),
          backgroundColor: theme.colorScheme.primary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? (widget.initialStep == 4
                  ? 'Manage Availability'
                  : 'Edit Vet Profile')
              : _stepTitles[_currentStep],
        ),
        backgroundColor: theme.colorScheme.primary,
        leading:
            widget.isEditing || _currentStep > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (widget.isEditing) {
                      Navigator.of(context).maybePop();
                      return;
                    }
                    _previousStep();
                  },
                )
                : null,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoStep(),
                _buildSpecializationsStep(),
                _buildClinicInfoStep(),
                _buildContactFeesStep(),
                _buildAboutStep(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(5, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4.h,
                    decoration: BoxDecoration(
                      gradient:
                          isCompleted || isCurrent
                              ? LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withValues(alpha: 0.8),
                                ],
                              )
                              : null,
                      color:
                          isCompleted || isCurrent
                              ? null
                              : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                if (index < 4) SizedBox(width: 4.w),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Personal Information',
            'Tell us about your professional background',
            Icons.person_outline_rounded,
          ),
          SizedBox(height: 32.h),

          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name *',
            hint: 'Dr. John Smith',
            icon: Icons.badge_outlined,
          ),
          SizedBox(height: 20.h),

          _buildTextField(
            controller: _degreeController,
            label: 'Degree *',
            hint: 'DVM, BVMS, etc.',
            icon: Icons.school_outlined,
          ),
          SizedBox(height: 20.h),

          _buildTextField(
            controller: _licenseController,
            label: 'License Number',
            hint: 'VET-123456',
            icon: Icons.verified_outlined,
          ),
          SizedBox(height: 20.h),

          _buildTextField(
            controller: _experienceController,
            label: 'Years of Experience *',
            hint: '5',
            icon: Icons.work_outline_rounded,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Your Specializations',
            'Select your areas of expertise',
            Icons.medical_services_outlined,
          ),
          SizedBox(height: 32.h),

          _buildSpecializationChips(),
        ],
      ),
    );
  }

  Widget _buildClinicInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Clinic Information',
            'Where do you practice? (Optional)',
            Icons.local_hospital_outlined,
          ),
          SizedBox(height: 32.h),

          _buildTextField(
            controller: _clinicNameController,
            label: 'Clinic Name',
            hint: 'Happy Paws Veterinary Clinic',
            icon: Icons.business_outlined,
          ),
          SizedBox(height: 20.h),

          _buildTextField(
            controller: _clinicAddressController,
            label: 'Clinic Address',
            hint: '123 Pet Street, Suite 100',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'San Francisco',
                  icon: Icons.location_city_outlined,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  hint: 'California',
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          _buildTextField(
            controller: _zipCodeController,
            label: 'ZIP Code',
            hint: '94102',
            icon: Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildContactFeesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Contact & Fees',
            'How can pet owners reach you?',
            Icons.phone_outlined,
          ),
          SizedBox(height: 32.h),

          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number *',
            hint: '+1-415-555-0123',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 20.h),

          _buildTextField(
            controller: _consultationFeeController,
            label: 'Consultation Fee (USD) *',
            hint: '150',
            icon: Icons.attach_money_rounded,
            keyboardType: TextInputType.number,
            prefixText: '\$ ',
          ),
        ],
      ),
    );
  }

  Widget _buildAboutStep() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'About You',
            'Share more about yourself (Optional)',
            Icons.info_outline_rounded,
          ),
          SizedBox(height: 32.h),

          _buildTextField(
            controller: _bioController,
            label: 'Professional Bio',
            hint: 'Tell pet owners about yourself and your practice...',
            icon: Icons.description_outlined,
            maxLines: 5,
          ),
          SizedBox(height: 20.h),

          _buildTextField(
            controller: _availabilityController,
            label: 'Availability Hours',
            hint: 'Mon-Fri: 9AM-6PM, Sat: 10AM-4PM',
            icon: Icons.access_time_outlined,
            maxLines: 3,
          ),
          SizedBox(height: 20.h),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: SwitchListTile.adaptive(
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
              title: Text(
                'Currently Available',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _isAvailable
                    ? 'Pet owners can see you as available'
                    : 'You will appear as unavailable',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              secondary: Icon(
                _isAvailable
                    ? Icons.check_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
                color:
                    _isAvailable ? Colors.green : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.12),
                colorScheme.primary.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(icon, size: 48.sp, color: colorScheme.primary),
        ),
        SizedBox(height: 20.h),
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final colorScheme = Theme.of(context).colorScheme;

    // Check if current step has all required fields filled
    bool isStepComplete = false;

    switch (_currentStep) {
      case 0: // Personal Info - Required fields
        isStepComplete =
            _fullNameController.text.trim().isNotEmpty &&
            _degreeController.text.trim().isNotEmpty &&
            _experienceController.text.trim().isNotEmpty &&
            int.tryParse(_experienceController.text.trim()) != null;
        break;

      case 1: // Specializations - At least one required
        isStepComplete = _selectedSpecializations.isNotEmpty;
        break;

      case 2: // Clinic Info - Optional, always complete
        isStepComplete = true;
        break;

      case 3: // Contact & Fees - Required fields
        isStepComplete =
            _phoneController.text.trim().isNotEmpty &&
            _consultationFeeController.text.trim().isNotEmpty &&
            double.tryParse(_consultationFeeController.text.trim()) != null;
        break;

      case 4: // About - Optional, always complete
        isStepComplete = true;
        break;
    }

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: BorderSide(color: colorScheme.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 12.w),
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow:
                      isStepComplete
                          ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : [],
                ),
                child: ElevatedButton(
                  onPressed:
                      _isLoading || _isInitializing
                          ? null
                          : () {
                            if (_validateCurrentStep()) {
                              if (_currentStep < 4) {
                                _nextStep();
                              } else {
                                _handleSubmit();
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    backgroundColor:
                        isStepComplete
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: isStepComplete ? 4 : 1,
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentStep < 4
                                    ? 'Continue'
                                    : (widget.isEditing
                                        ? 'Save Changes'
                                        : 'Complete Profile'),
                                style: TextStyle(
                                  color:
                                      isStepComplete
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_currentStep < 4) ...[
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20.sp,
                                  color:
                                      isStepComplete
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefixText,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15.sp),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        prefixIcon:
            icon != null
                ? Icon(icon, color: colorScheme.primary.withValues(alpha: 0.7))
                : null,
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: icon != null ? 12.w : 20.w,
          vertical: 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildSpecializationChips() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children:
          _availableSpecializations.map((spec) {
            final isSelected = _selectedSpecializations.contains(spec);
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSpecializations.remove(spec);
                      } else {
                        _selectedSpecializations.add(spec);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                              width: 2,
                            ),
                          ),
                          child:
                              isSelected
                                  ? Icon(
                                    Icons.check_rounded,
                                    size: 16.sp,
                                    color: colorScheme.primary,
                                  )
                                  : null,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            spec,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Future<void> _handleSubmit() async {
    // Validate all required fields before submitting
    if (_fullNameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter your full name');
      setState(() => _currentStep = 0);
      _pageController.jumpToPage(0);
      return;
    }

    if (_degreeController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter your degree');
      setState(() => _currentStep = 0);
      _pageController.jumpToPage(0);
      return;
    }

    if (_experienceController.text.trim().isEmpty ||
        int.tryParse(_experienceController.text.trim()) == null) {
      CustomSnackbar.showError(
        context,
        'Please enter valid years of experience',
      );
      setState(() => _currentStep = 0);
      _pageController.jumpToPage(0);
      return;
    }

    if (_selectedSpecializations.isEmpty) {
      CustomSnackbar.showError(
        context,
        'Please select at least one specialization',
      );
      setState(() => _currentStep = 1);
      _pageController.jumpToPage(1);
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter your phone number');
      setState(() => _currentStep = 3);
      _pageController.jumpToPage(3);
      return;
    }

    if (_consultationFeeController.text.trim().isEmpty ||
        double.tryParse(_consultationFeeController.text.trim()) == null) {
      CustomSnackbar.showError(context, 'Please enter valid consultation fee');
      setState(() => _currentStep = 3);
      _pageController.jumpToPage(3);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vetRepo = VetRepository(ApiClient.instance);

      final request = VetProfileRequest(
        fullName: _fullNameController.text.trim(),
        degree: _degreeController.text.trim(),
        licenseNumber:
            _licenseController.text.trim().isEmpty
                ? null
                : _licenseController.text.trim(),
        specialization: _selectedSpecializations,
        experience: int.parse(_experienceController.text.trim()),
        clinicName:
            _clinicNameController.text.trim().isEmpty
                ? null
                : _clinicNameController.text.trim(),
        clinicAddress:
            _clinicAddressController.text.trim().isEmpty
                ? null
                : _clinicAddressController.text.trim(),
        city:
            _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
        state:
            _stateController.text.trim().isEmpty
                ? null
                : _stateController.text.trim(),
        zipCode:
            _zipCodeController.text.trim().isEmpty
                ? null
                : _zipCodeController.text.trim(),
        phone: _phoneController.text.trim(),
        consultationFee: double.parse(_consultationFeeController.text.trim()),
        currency: 'USD',
        bio:
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        availabilityHours:
            _availabilityController.text.trim().isEmpty
                ? null
                : _availabilityController.text.trim(),
        isAvailable: _isAvailable,
      );

      await vetRepo.createOrUpdateProfile(request);

      if (!mounted) return;

      CustomSnackbar.showSuccess(
        context,
        widget.isEditing
            ? 'Profile updated successfully!'
            : 'Profile created successfully!',
      );

      if (widget.isEditing) {
        Navigator.of(context).pop(true);
      } else {
        // Navigate back to VetHomeScreen (which will now load the profile)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const VetHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      CustomSnackbar.showError(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
