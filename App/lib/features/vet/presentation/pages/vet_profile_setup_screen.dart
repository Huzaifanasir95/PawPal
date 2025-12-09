import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/services/api_client.dart';
import '../../data/repositories/vet_repository.dart';
import '../../data/models/vet_profile_model.dart';
import 'vet_home_screen.dart';

class VetProfileSetupScreen extends StatefulWidget {
  const VetProfileSetupScreen({super.key});

  @override
  State<VetProfileSetupScreen> createState() => _VetProfileSetupScreenState();
}

class _VetProfileSetupScreenState extends State<VetProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
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

  bool _isLoading = false;

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
          CustomSnackbar.showError(context, 'Please enter valid years of experience');
          return false;
        }
        return true;
      
      case 1: // Specializations
        if (_selectedSpecializations.isEmpty) {
          CustomSnackbar.showError(context, 'Please select at least one specialization');
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
          CustomSnackbar.showError(context, 'Please enter valid consultation fee');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_stepTitles[_currentStep]),
        backgroundColor: AppColors.primary,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                      gradient: isCompleted || isCurrent
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: isCompleted || isCurrent ? null : AppColors.neutral300,
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
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            icon,
            size: 48.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    side: BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 12.w),
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
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
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.neutral300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep < 4 ? 'Continue' : 'Complete Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentStep < 4) ...[
                            SizedBox(width: 8.w),
                            Icon(Icons.arrow_forward_rounded, size: 20.sp),
                          ],
                        ],
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15.sp),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primary.withOpacity(0.7))
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: icon != null ? 12.w : 20.w,
          vertical: 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSpecializationChips() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: _availableSpecializations.map((spec) {
        final isSelected = _selectedSpecializations.contains(spec);
        return Material(
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
            borderRadius: BorderRadius.circular(25.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.border.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    spec,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vetRepo = VetRepository(ApiClient.instance);
      
      final request = VetProfileRequest(
        fullName: _fullNameController.text.trim(),
        degree: _degreeController.text.trim(),
        licenseNumber: _licenseController.text.trim().isEmpty 
            ? null 
            : _licenseController.text.trim(),
        specialization: _selectedSpecializations,
        experience: int.parse(_experienceController.text.trim()),
        clinicName: _clinicNameController.text.trim().isEmpty 
            ? null 
            : _clinicNameController.text.trim(),
        clinicAddress: _clinicAddressController.text.trim().isEmpty 
            ? null 
            : _clinicAddressController.text.trim(),
        city: _cityController.text.trim().isEmpty 
            ? null 
            : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty 
            ? null 
            : _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim().isEmpty 
            ? null 
            : _zipCodeController.text.trim(),
        phone: _phoneController.text.trim(),
        consultationFee: double.parse(_consultationFeeController.text.trim()),
        currency: 'USD',
        bio: _bioController.text.trim().isEmpty 
            ? null 
            : _bioController.text.trim(),
        availabilityHours: _availabilityController.text.trim().isEmpty 
            ? null 
            : _availabilityController.text.trim(),
        isAvailable: true,
      );

      await vetRepo.createOrUpdateProfile(request);

      if (!mounted) return;

      CustomSnackbar.showSuccess(
        context,
        'Profile created successfully!',
      );

      // Navigate back to VetHomeScreen (which will now load the profile)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const VetHomeScreen(),
        ),
        (route) => false,
      );
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
