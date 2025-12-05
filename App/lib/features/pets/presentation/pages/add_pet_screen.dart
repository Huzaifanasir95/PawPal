import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/breed_prediction_model.dart';
import '../../data/services/breed_verification_service.dart';
import '../../data/repositories/pet_repository_api.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _breedVerificationService = BreedVerificationService();
  final _petRepository = PetRepositoryApi();
  final _imagePicker = ImagePicker();

  // Form controllers
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _bioController = TextEditingController();

  // Form values
  String _petType = 'dog'; // 'dog' or 'cat'
  String _ageUnit = 'months'; // 'months' or 'years'
  String _gender = 'male'; // 'male' or 'female'
  String _weightUnit = 'kg'; // 'kg' or 'lbs'

  // Image
  File? _selectedImage;
  List<File> _selectedImages = []; // Multiple images
  bool _isVerifying = false;
  bool _isVerified = false;
  double? _verificationConfidence;

  // Health Record
  bool _hasHealthRecord = false;
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

  // Health record values
  bool _isVaccinated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _bioController.dispose();
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Copy the picked file to a temporary directory to ensure it's accessible
        final tempDir = await getTemporaryDirectory();
        final fileName = path.basename(pickedFile.path);
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(await pickedFile.readAsBytes());

        setState(() {
          _selectedImages.add(tempFile);
          if (_selectedImage == null) {
            _selectedImage = tempFile; // Keep the first image as primary for verification
          }
          _isVerified = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isEmpty) {
        _selectedImage = null;
        _isVerified = false;
      } else if (_selectedImage == null || !_selectedImages.contains(_selectedImage)) {
        _selectedImage = _selectedImages.first;
      }
    });
  }

  Future<void> _verifyBreed() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select a pet image first');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final result = await _breedVerificationService.predictBreed(
        imageFile: _selectedImage!,
        petType: _petType,
        useTTA: true,
        topK: 5,
      );

      setState(() {
        _isVerified = result.success;
        _verificationConfidence = result.confidence;
        _isVerifying = false;
      });

      if (result.success && result.predicted != null) {
        _breedController.text = result.predicted!;
        _showBreedVerificationDialog(result);
      } else {
        _showErrorSnackBar(result.error ?? 'Verification failed');
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });
      _showErrorSnackBar('Error verifying breed: $e');
    }
  }

  void _showBreedVerificationDialog(PredictionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.verified,
              color: AppColors.success,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Breed Verified!',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Predictions:',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            ...result.predictions.map((prediction) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${prediction.rank}. ${prediction.breed}',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(prediction.confidence)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${(prediction.confidence * 100).toStringAsFixed(1)}%',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 12.sp,
                            color: _getConfidenceColor(prediction.confidence),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _submitPet() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        _showErrorSnackBar('Please select at least one pet photo');
        return;
      }

      // Show loading indicator
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
        // API will handle validation and creation

        // Create pet with API
        final petId = await _petRepository.createPet(
          name: _nameController.text.trim(),
          type: _petType,
          breed: _breedController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          ageUnit: _ageUnit,
          gender: _gender,
          color: _colorController.text.trim(),
          weight: double.parse(_weightController.text.trim()),
          weightUnit: _weightUnit,
          imageFile: _selectedImage,
          imageLocalPath: _selectedImage?.path,
          imageUrls: _selectedImages.map((file) => file.path).toList(),
          isVerified: _isVerified,
          verificationConfidence: _isVerified ? _verificationConfidence : null,
          verifiedBreed: _isVerified ? _breedController.text.trim() : null,
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
        );

        // Add health record separately if needed
        if (_hasHealthRecord && petId != null) {
          try {
            await _petRepository.addHealthRecord(
              petId: petId,
              isVaccinated: _isVaccinated,
              vaccinationDate: _vaccinationDateController.text.trim().isEmpty
                  ? null
                  : _vaccinationDateController.text.trim(),
              vetName: _vetNameController.text.trim().isEmpty
                  ? null
                  : _vetNameController.text.trim(),
            );
          } catch (e) {
            // Health record creation failed, but pet was created
          }
        }

        // Close loading dialog
        Navigator.pop(context);

        if (petId != null) {
          _showSuccessSnackBar('Pet registered successfully!');
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          _showErrorSnackBar('Failed to register pet. Please try again.');
        }
      } catch (e) {
        // Close loading dialog
        Navigator.pop(context);
        _showErrorSnackBar('Error: $e');
      }
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
          'Add Pet',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Images Section
              Text(
                'Pet Photos',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                height: 200.h,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 12.w,
                    childAspectRatio: 1,
                  ),
                  itemCount: _selectedImages.length + 1, // +1 for add button
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      // Add photo button
                      return GestureDetector(
                        onTap: () => _showImageSourceDialog(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.add_a_photo,
                            color: AppColors.primary,
                            size: 48.sp,
                          ),
                        ),
                      );
                    } else {
                      // Photo
                      final image = _selectedImages[index];
                      final isPrimary = image == _selectedImage;
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isPrimary ? AppColors.success : AppColors.border,
                                width: isPrimary ? 3 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: Image.file(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          if (isPrimary && _isVerified)
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          Positioned(
                            top: 8.h,
                            left: 8.w,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                          if (isPrimary)
                            Positioned(
                              bottom: 8.h,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'Primary',
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }
                  },
                ),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: ElevatedButton.icon(
                    onPressed: _isVerifying ? null : _verifyBreed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: _isVerifying
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accent,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.verified_user,
                            color: AppColors.accent,
                            size: 18.sp,
                          ),
                    label: Text(
                      _isVerifying ? 'Verifying...' : 'Verify Breed',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 30.h),

              // Pet Type Selection
              Text(
                'Pet Type',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeCard('Dog', Icons.pets, 'dog'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTypeCard('Cat', Icons.pets, 'cat'),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Pet Name
              _buildTextField(
                label: 'Pet Name',
                controller: _nameController,
                hint: 'e.g., Buddy',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pet name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Breed
              _buildTextField(
                label: 'Breed',
                controller: _breedController,
                hint: 'e.g., Golden Retriever',
                suffix: _isVerified
                    ? Icon(
                        Icons.verified,
                        color: AppColors.success,
                        size: 20.sp,
                      )
                    : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter breed';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Age
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'Age',
                      controller: _ageController,
                      hint: '2',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Unit',
                      value: _ageUnit,
                      items: ['months', 'years'],
                      onChanged: (value) {
                        setState(() {
                          _ageUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Gender
              Text(
                'Gender',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderCard('Male', Icons.male, 'male'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildGenderCard('Female', Icons.female, 'female'),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Color
              _buildTextField(
                label: 'Color',
                controller: _colorController,
                hint: 'e.g., Golden',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter color';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Weight
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'Weight',
                      controller: _weightController,
                      hint: '25',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Unit',
                      value: _weightUnit,
                      items: ['kg', 'lbs'],
                      onChanged: (value) {
                        setState(() {
                          _weightUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Bio
              _buildTextField(
                label: 'Bio (Optional)',
                controller: _bioController,
                hint: 'Tell us about your pet...',
                maxLines: 4,
              ),

              SizedBox(height: 30.h),

              // Health Records Section
              Text(
                'Health Records (Optional)',
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SwitchListTile(
                title: Text(
                  'Add Health Records',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Include vaccination status, medical conditions, and vet information',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _hasHealthRecord,
                onChanged: (value) {
                  setState(() {
                    _hasHealthRecord = value;
                  });
                },
                activeColor: AppColors.primary,
              ),

              if (_hasHealthRecord) ...[
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
              ],

              SizedBox(height: 30.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _submitPet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Register Pet',
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? suffix,
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
          validator: validator,
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
            suffixIcon: suffix,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error),
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard(String title, IconData icon, String type) {
    final isSelected = _petType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _petType = type;
        });
      },
      child: Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(String title, IconData icon, String gender) {
    final isSelected = _gender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = gender;
        });
      },
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Choose Image Source',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 18.sp,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(
                'Camera',
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(
                'Gallery',
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
