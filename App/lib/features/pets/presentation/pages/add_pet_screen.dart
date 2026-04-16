import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _selectedImage;
  List<XFile> _selectedImages = []; // Multiple images
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
        setState(() {
          _selectedImages.add(pickedFile);
          if (_selectedImage == null) {
            _selectedImage =
                pickedFile; // Keep the first image as primary for verification
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
      } else if (_selectedImage == null ||
          !_selectedImages.contains(_selectedImage)) {
        _selectedImage = _selectedImages.first;
      }
    });
  }

  Widget _buildSelectedImagePreview(XFile image) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Icon(Icons.pets, color: colorScheme.primary, size: 32.sp),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          );
        }

        return Center(
          child: Icon(Icons.pets, color: colorScheme.primary, size: 32.sp),
        );
      },
    );
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
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(Icons.verified, color: colorScheme.tertiary, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Breed Verified!',
                  style: AppTextStyles.onboardingTitle.copyWith(
                    fontSize: 20.sp,
                    color: colorScheme.onSurface,
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
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                ...result.predictions.map(
                  (prediction) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${prediction.rank}. ${prediction.breed}',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(
                              prediction.confidence,
                            ).withOpacity(0.2),
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
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 16.sp,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    final colorScheme = Theme.of(context).colorScheme;
    if (confidence >= 0.8) return colorScheme.tertiary;
    if (confidence >= 0.5) return colorScheme.secondary;
    return colorScheme.error;
  }

  void _showErrorSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colorScheme.error),
    );
  }

  void _showSuccessSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colorScheme.tertiary),
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
        builder:
            (context) => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
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
          bio:
              _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
        );

        // Add health record separately if needed
        if (_hasHealthRecord && petId != null) {
          try {
            await _petRepository.addHealthRecord(
              petId: petId,
              isVaccinated: _isVaccinated,
              vaccinationDate:
                  _vaccinationDateController.text.trim().isEmpty
                      ? null
                      : _vaccinationDateController.text.trim(),
              vetName:
                  _vetNameController.text.trim().isEmpty
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Pet',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest,
                  ]
                : [
                    colorScheme.surface,
                    colorScheme.surfaceContainer,
                  ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  title: 'Pet Photos',
                  subtitle:
                      'Add clear photos and verify breed for better records.',
                  icon: Icons.photo_camera_back_outlined,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 188.h,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 12.w,
                                childAspectRatio: 1,
                              ),
                          itemCount: _selectedImages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _selectedImages.length) {
                              return GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: colorScheme.outline.withValues(alpha: 0.35),
                                      width: 1.6,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: colorScheme.primary,
                                    size: 48.sp,
                                  ),
                                ),
                              );
                            }

                            final image = _selectedImages[index];
                            final isPrimary = image == _selectedImage;

                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color:
                                          isPrimary
                                              ? colorScheme.primary
                                              : colorScheme.outline.withValues(alpha: 0.35),
                                      width: isPrimary ? 2.4 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: _buildSelectedImagePreview(image),
                                  ),
                                ),
                                if (isPrimary && _isVerified)
                                  Positioned(
                                    top: 8.h,
                                    right: 8.w,
                                    child: Container(
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.verified,
                                        color: colorScheme.onTertiary,
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
                                        color: colorScheme.error.withValues(alpha: 0.85),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: colorScheme.onError,
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
                                        color: colorScheme.primary.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Primary',
                                        style: AppTextStyles.onboardingBody
                                            .copyWith(
                                              fontSize: 10.sp,
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (_selectedImage != null)
                        Padding(
                          padding: EdgeInsets.only(top: 14.h),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isVerifying ? null : _verifyBreed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              icon:
                                  _isVerifying
                                      ? SizedBox(
                                        width: 16.w,
                                        height: 16.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                colorScheme.onPrimary,
                                              ),
                                        ),
                                      )
                                      : Icon(Icons.verified_user, size: 18.sp),
                              label: Text(
                                _isVerifying ? 'Verifying...' : 'Verify Breed',
                                style: AppTextStyles.onboardingBody.copyWith(
                                  fontSize: 14.sp,
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                _buildSectionCard(
                  title: 'Basic Details',
                  subtitle: 'Tell us the essentials for your pet profile.',
                  icon: Icons.pets_outlined,
                  child: Column(
                    children: [
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
                      SizedBox(height: 18.h),
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
                      SizedBox(height: 14.h),
                      _buildTextField(
                        label: 'Breed',
                        controller: _breedController,
                        hint: 'e.g., Golden Retriever',
                        suffix:
                            _isVerified
                                ? Icon(
                                  Icons.verified,
                                  color: const Color(0xFF2E7D32),
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
                      SizedBox(height: 14.h),
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
                              items: const ['months', 'years'],
                              onChanged: (value) {
                                setState(() {
                                  _ageUnit = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gender',
                            style: AppTextStyles.onboardingTitle.copyWith(
                              fontSize: 16.sp,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGenderCard(
                                  'Male',
                                  Icons.male,
                                  'male',
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildGenderCard(
                                  'Female',
                                  Icons.female,
                                  'female',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
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
                      SizedBox(height: 14.h),
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
                              items: const ['kg', 'lbs'],
                              onChanged: (value) {
                                setState(() {
                                  _weightUnit = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        label: 'Bio (Optional)',
                        controller: _bioController,
                        hint: 'Tell us about your pet...',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                _buildSectionCard(
                  title: 'Health Records (Optional)',
                  subtitle:
                      'Add vaccination details, vet info, and emergency contacts.',
                  icon: Icons.favorite_border_rounded,
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Add Health Records',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 16.sp,
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Include vaccination status, medical conditions, and vet information',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 13.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _hasHealthRecord,
                        onChanged: (value) {
                          setState(() {
                            _hasHealthRecord = value;
                          });
                        },
                        activeColor: colorScheme.primary,
                      ),
                      if (_hasHealthRecord) ...[
                        SizedBox(height: 8.h),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Is Vaccinated',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 15.sp,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          value: _isVaccinated,
                          onChanged: (value) {
                            setState(() {
                              _isVaccinated = value;
                            });
                          },
                          activeColor: colorScheme.primary,
                        ),
                        if (_isVaccinated) ...[
                          SizedBox(height: 10.h),
                          _buildTextField(
                            label: 'Vaccination Date',
                            controller: _vaccinationDateController,
                            hint: 'e.g., 2024-01-15',
                          ),
                          SizedBox(height: 12.h),
                          _buildTextField(
                            label: 'Vaccination Details',
                            controller: _vaccinationDetailsController,
                            hint: 'e.g., Rabies, DHPP, etc.',
                            maxLines: 3,
                          ),
                        ],
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Medical Conditions (Optional)',
                          controller: _medicalConditionsController,
                          hint: 'e.g., Arthritis, Diabetes',
                          maxLines: 2,
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Allergies (Optional)',
                          controller: _allergiesController,
                          hint: 'e.g., Chicken, Pollen',
                          maxLines: 2,
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Current Medications (Optional)',
                          controller: _medicationsController,
                          hint: 'e.g., Heartworm preventive, Insulin',
                          maxLines: 2,
                        ),
                        SizedBox(height: 16.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Veterinarian Information',
                            style: AppTextStyles.onboardingTitle.copyWith(
                              fontSize: 16.sp,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Vet Name (Optional)',
                          controller: _vetNameController,
                          hint: 'Dr. Smith',
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Vet Clinic (Optional)',
                          controller: _vetClinicController,
                          hint: 'City Animal Hospital',
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Vet Phone (Optional)',
                          controller: _vetPhoneController,
                          hint: '+1 (555) 123-4567',
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Vet Address (Optional)',
                          controller: _vetAddressController,
                          hint: '123 Main St, City, State',
                          maxLines: 2,
                        ),
                        SizedBox(height: 16.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Emergency Contact',
                            style: AppTextStyles.onboardingTitle.copyWith(
                              fontSize: 16.sp,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Emergency Contact Name (Optional)',
                          controller: _emergencyContactNameController,
                          hint: 'John Doe',
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Emergency Contact Phone (Optional)',
                          controller: _emergencyContactPhoneController,
                          hint: '+1 (555) 987-6543',
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 16.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pet Insurance (Optional)',
                            style: AppTextStyles.onboardingTitle.copyWith(
                              fontSize: 16.sp,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Insurance Provider',
                          controller: _insuranceProviderController,
                          hint: 'Pet Insurance Company',
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Policy Number',
                          controller: _insurancePolicyController,
                          hint: 'POL-123456789',
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          label: 'Additional Health Notes (Optional)',
                          controller: _additionalNotesController,
                          hint: 'Any other health-related information...',
                          maxLines: 4,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _submitPet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Register Pet',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 18.sp,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.h,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.primary, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.onboardingTitle.copyWith(
                        fontSize: 17.sp,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
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
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: colorScheme.onSurfaceVariant,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: colorScheme.error),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.35),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 16.sp,
                        color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
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
              ? colorScheme.primary.withValues(alpha: 0.14)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.35),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 24.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(String title, IconData icon, String gender) {
    final colorScheme = Theme.of(context).colorScheme;
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
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.35),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'Choose Image Source',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 18.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: colorScheme.primary),
                  title: Text(
                    'Camera',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 16.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: colorScheme.primary),
                  title: Text(
                    'Gallery',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 16.sp,
                      color: colorScheme.onSurface,
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
