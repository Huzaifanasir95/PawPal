import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/health_record_model.dart';
import '../../data/repositories/health_repository_api.dart';

class EditHealthRecordsScreen extends StatefulWidget {
  final String petId;
  final String petName;
  final HealthRecordModel? existingRecord;

  const EditHealthRecordsScreen({
    super.key,
    required this.petId,
    required this.petName,
    this.existingRecord,
  });

  @override
  State<EditHealthRecordsScreen> createState() => _EditHealthRecordsScreenState();
}

class _EditHealthRecordsScreenState extends State<EditHealthRecordsScreen> {
  final _healthRepository = HealthRepositoryApi();

  // Form controllers
  final _vaccinationDateController = TextEditingController();
  final _vaccinationDetailsController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _vetNameController = TextEditingController();
  final _vetClinicController = TextEditingController();
  final _vetPhoneController = TextEditingController();
  final _vetAddressController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insurancePolicyController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  // Form values
  bool _isVaccinated = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final record = widget.existingRecord!;
    _isVaccinated = record.isVaccinated;
    _vaccinationDateController.text = record.vaccinationDate ?? '';
    _vaccinationDetailsController.text = record.vaccinationDetails ?? '';
    _medicalConditionsController.text = record.medicalConditions?.join(', ') ?? '';
    _allergiesController.text = record.allergies?.join(', ') ?? '';
    _medicationsController.text = record.medications?.join(', ') ?? '';
    _vetNameController.text = record.vetName ?? '';
    _vetClinicController.text = record.vetClinic ?? '';
    _vetPhoneController.text = record.vetPhone ?? '';
    _vetAddressController.text = record.vetAddress ?? '';
    _emergencyContactNameController.text = record.emergencyContactName ?? '';
    _emergencyContactPhoneController.text = record.emergencyContactPhone ?? '';
    _insuranceProviderController.text = record.insuranceProvider ?? '';
    _insurancePolicyController.text = record.insurancePolicyNumber ?? '';
    _additionalNotesController.text = record.additionalNotes ?? '';
  }

  @override
  void dispose() {
    _vaccinationDateController.dispose();
    _vaccinationDetailsController.dispose();
    _medicalConditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _vetNameController.dispose();
    _vetClinicController.dispose();
    _vetPhoneController.dispose();
    _vetAddressController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveHealthRecord() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );

    try {
      final recordId = await _healthRepository.createHealthRecord(
        petId: widget.petId,
        isVaccinated: _isVaccinated,
        vaccinationDate: _vaccinationDateController.text.trim().isEmpty
            ? null
            : _vaccinationDateController.text.trim(),
        vaccinationDetails: _vaccinationDetailsController.text.trim().isEmpty
            ? null
            : _vaccinationDetailsController.text.trim(),
        medicalConditions: _medicalConditionsController.text.trim().isEmpty
            ? null
            : _medicalConditionsController.text.trim().split(',').map((e) => e.trim()).toList(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim().split(',').map((e) => e.trim()).toList(),
        medications: _medicationsController.text.trim().isEmpty
            ? null
            : _medicationsController.text.trim().split(',').map((e) => e.trim()).toList(),
        vetName: _vetNameController.text.trim().isEmpty
            ? null
            : _vetNameController.text.trim(),
        vetClinic: _vetClinicController.text.trim().isEmpty
            ? null
            : _vetClinicController.text.trim(),
        vetPhone: _vetPhoneController.text.trim().isEmpty
            ? null
            : _vetPhoneController.text.trim(),
        vetAddress: _vetAddressController.text.trim().isEmpty
            ? null
            : _vetAddressController.text.trim(),
        emergencyContactName: _emergencyContactNameController.text.trim().isEmpty
            ? null
            : _emergencyContactNameController.text.trim(),
        emergencyContactPhone: _emergencyContactPhoneController.text.trim().isEmpty
            ? null
            : _emergencyContactPhoneController.text.trim(),
        insuranceProvider: _insuranceProviderController.text.trim().isEmpty
            ? null
            : _insuranceProviderController.text.trim(),
        insurancePolicyNumber: _insurancePolicyController.text.trim().isEmpty
            ? null
            : _insurancePolicyController.text.trim(),
        additionalNotes: _additionalNotesController.text.trim().isEmpty
            ? null
            : _additionalNotesController.text.trim(),
      );

      Navigator.pop(context); // Close loading

      if (recordId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health records saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save health records'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.accent,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingRecord == null ? 'Add Health Records' : 'Edit Health Records',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Health Information for ${widget.petName}',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 18.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Keep track of your pet\'s medical history and important information',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // Vaccination Status
            Text(
              'Vaccination',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            SwitchListTile(
              title: Text(
                'Is Vaccinated',
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              value: _isVaccinated,
              onChanged: (value) {
                setState(() {
                  _isVaccinated = value;
                });
              },
              activeColor: AppColors.primary,
            ),

            if (_isVaccinated) ...[
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'Vaccination Date',
                controller: _vaccinationDateController,
                hint: 'e.g., 2024-01-15',
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'Vaccination Details',
                controller: _vaccinationDetailsController,
                hint: 'e.g., Rabies, DHPP, etc.',
                maxLines: 3,
              ),
            ],

            SizedBox(height: 24.h),

            // Medical Conditions
            _buildTextField(
              label: 'Medical Conditions (Optional)',
              controller: _medicalConditionsController,
              hint: 'e.g., Arthritis, Diabetes (separate with commas)',
              maxLines: 2,
            ),

            SizedBox(height: 16.h),

            // Allergies
            _buildTextField(
              label: 'Allergies (Optional)',
              controller: _allergiesController,
              hint: 'e.g., Chicken, Pollen (separate with commas)',
              maxLines: 2,
            ),

            SizedBox(height: 16.h),

            // Current Medications
            _buildTextField(
              label: 'Current Medications (Optional)',
              controller: _medicationsController,
              hint: 'e.g., Heartworm preventive, Insulin (separate with commas)',
              maxLines: 2,
            ),

            SizedBox(height: 24.h),

            // Vet Information
            Text(
              'Veterinarian Information',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Vet Name (Optional)',
              controller: _vetNameController,
              hint: 'Dr. Smith',
            ),

            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Vet Clinic (Optional)',
              controller: _vetClinicController,
              hint: 'City Animal Hospital',
            ),

            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Vet Phone (Optional)',
              controller: _vetPhoneController,
              hint: '+1 (555) 123-4567',
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Vet Address (Optional)',
              controller: _vetAddressController,
              hint: '123 Main St, City, State',
              maxLines: 2,
            ),

            SizedBox(height: 24.h),

            // Emergency Contact
            Text(
              'Emergency Contact',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Emergency Contact Name (Optional)',
              controller: _emergencyContactNameController,
              hint: 'John Doe',
            ),

            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Emergency Contact Phone (Optional)',
              controller: _emergencyContactPhoneController,
              hint: '+1 (555) 987-6543',
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 24.h),

            // Insurance
            Text(
              'Pet Insurance (Optional)',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Insurance Provider',
              controller: _insuranceProviderController,
              hint: 'Pet Insurance Company',
            ),

            SizedBox(height: 16.h),

            _buildTextField(
              label: 'Policy Number',
              controller: _insurancePolicyController,
              hint: 'POL-123456789',
            ),

            SizedBox(height: 16.h),

            // Additional Notes
            _buildTextField(
              label: 'Additional Health Notes (Optional)',
              controller: _additionalNotesController,
              hint: 'Any other health-related information...',
              maxLines: 4,
            ),

            SizedBox(height: 30.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _saveHealthRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Save Health Records',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.textOnSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }
}