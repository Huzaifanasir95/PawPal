import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/services/api_client.dart';
import '../../data/repositories/vet_repository.dart';
import '../../data/models/vet_profile_model.dart';

class VetProfileSetupScreen extends StatefulWidget {
  const VetProfileSetupScreen({super.key});

  @override
  State<VetProfileSetupScreen> createState() => _VetProfileSetupScreenState();
}

class _VetProfileSetupScreenState extends State<VetProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
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

  bool _isLoading = false;

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Your Vet Profile'),
        backgroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSectionTitle('Personal Information'),
              SizedBox(height: 16.h),
              
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name *',
                hint: 'Dr. John Smith',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _degreeController,
                label: 'Degree *',
                hint: 'DVM, BVMS, etc.',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your degree';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _licenseController,
                label: 'License Number',
                hint: 'VET-123456',
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _experienceController,
                label: 'Years of Experience *',
                hint: '5',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your experience';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Specializations Section
              _buildSectionTitle('Specializations'),
              SizedBox(height: 12.h),
              _buildSpecializationChips(),
              SizedBox(height: 24.h),

              // Clinic Information Section
              _buildSectionTitle('Clinic Information'),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _clinicNameController,
                label: 'Clinic Name',
                hint: 'Happy Paws Veterinary Clinic',
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _clinicAddressController,
                label: 'Clinic Address',
                hint: '123 Pet Street, Suite 100',
                maxLines: 2,
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'San Francisco',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'California',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _zipCodeController,
                label: 'ZIP Code',
                hint: '94102',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24.h),

              // Contact & Fees Section
              _buildSectionTitle('Contact & Fees'),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number *',
                hint: '+1-415-555-0123',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _consultationFeeController,
                label: 'Consultation Fee (USD) *',
                hint: '150',
                keyboardType: TextInputType.number,
                prefixText: '\$ ',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter consultation fee';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // About Section
              _buildSectionTitle('About You'),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                hint: 'Tell pet owners about yourself and your practice...',
                maxLines: 4,
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _availabilityController,
                label: 'Availability Hours',
                hint: 'Mon-Fri: 9AM-6PM, Sat: 10AM-4PM',
                maxLines: 2,
              ),
              SizedBox(height: 40.h),

              // Submit Button
              _buildSubmitButton(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        filled: true,
        fillColor: AppColors.surface,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSpecializationChips() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _availableSpecializations.map((spec) {
        final isSelected = _selectedSpecializations.contains(spec);
        return FilterChip(
          label: Text(spec),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSpecializations.add(spec);
              } else {
                _selectedSpecializations.remove(spec);
              }
            });
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                ),
              )
            : Text(
                'Complete Profile',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
      ),
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

      // Navigate to main app
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
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
