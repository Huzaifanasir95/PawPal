import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/repositories/community_hub_repository.dart';
import '../../../pets/data/models/pet_model.dart';
import '../../../pets/data/repositories/pet_repository_api.dart';
import '../../../pets/presentation/pages/add_pet_screen.dart';
import '../cubit/adoption_cubit.dart';
import '../cubit/adoption_state.dart';

class CreateAdoptionPage extends StatefulWidget {
  const CreateAdoptionPage({super.key});

  @override
  State<CreateAdoptionPage> createState() => _CreateAdoptionPageState();
}

class _CreateAdoptionPageState extends State<CreateAdoptionPage> {
  final _petRepository = PetRepositoryApi();
  final _communityRepo = CommunityHubRepository.instance;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _medicalInfoController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _feeController = TextEditingController();

  List<PetModel> _pets = [];
  bool _isLoadingPets = true;
  String? _petsError;
  String? _selectedPetId;
  bool _hasAnyPets = false;

  bool _isVaccinated = false;
  bool _isNeutered = false;
  bool _isTrained = false;

  @override
  void initState() {
    super.initState();
    _loadUserPets();
  }

  String _normalizeKey(String value) => value.trim().toLowerCase();

  String _petNameTypeKey(String name, String type) {
    return '${_normalizeKey(name)}::${_normalizeKey(type)}';
  }

  Future<void> _loadUserPets() async {
    setState(() {
      _isLoadingPets = true;
      _petsError = null;
    });

    try {
      final pets = await _petRepository.getPets();
      final availablePets = pets.where((pet) => !pet.isAdopted).toList();
      final myListings = await _communityRepo.getMyAdoptionListings();

      final activeListings = myListings.where((listing) {
        final status = listing.status.trim().toLowerCase();
        return status == 'available' || status == 'pending';
      }).toList();

      final listedPetNameTypeKeys = activeListings
          .where((listing) => listing.petId == null || listing.petId!.isEmpty)
          .map((listing) => _petNameTypeKey(listing.petName, listing.petType))
          .toSet();

      final listedPetIds = myListings
          .where((listing) {
            final status = listing.status.trim().toLowerCase();
            return status == 'available' || status == 'pending';
          })
          .map((listing) => listing.petId)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();

      final eligiblePets = availablePets
          .where((pet) {
            if (listedPetIds.contains(pet.id)) {
              return false;
            }
            final key = _petNameTypeKey(pet.name, pet.type);
            return !listedPetNameTypeKeys.contains(key);
          })
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _hasAnyPets = pets.isNotEmpty;
        _pets = eligiblePets;
        _selectedPetId = eligiblePets.isNotEmpty ? eligiblePets.first.id : null;
        _isLoadingPets = false;
      });

      _applySelectedPetDefaults();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingPets = false;
        _petsError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  PetModel? get _selectedPet {
    for (final pet in _pets) {
      if (pet.id == _selectedPetId) {
        return pet;
      }
    }
    return null;
  }

  void _applySelectedPetDefaults() {
    final pet = _selectedPet;
    if (pet == null) {
      return;
    }

    final health = pet.healthRecord;
    setState(() {
      _isVaccinated = health?.isVaccinated ?? false;
      if (_descriptionController.text.trim().isEmpty && pet.bio != null) {
        _descriptionController.text = pet.bio!;
      }
    });
  }

  Widget _buildPetAvatar(PetModel pet) {
    final imagePath = (pet.imageUrls != null && pet.imageUrls!.isNotEmpty)
        ? pet.imageUrls!.first
        : pet.imageUrl;

    if (imagePath == null || imagePath.trim().isEmpty) {
      return Icon(Icons.pets_rounded, color: AppColors.primary, size: 18.sp);
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.pets_rounded, color: AppColors.primary, size: 18.sp),
      );
    }

    if (imagePath.startsWith('data:image/')) {
      try {
        final comma = imagePath.indexOf(',');
        if (comma > 0 && comma < imagePath.length - 1) {
          final bytes = base64Decode(imagePath.substring(comma + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.pets_rounded, color: AppColors.primary, size: 18.sp),
          );
        }
      } catch (_) {
        // Fall through to local file read attempt.
      }
    }

    final localPath = imagePath.startsWith('file://')
        ? (Uri.tryParse(imagePath)?.toFilePath() ?? imagePath)
        : imagePath;

    return FutureBuilder<Uint8List>(
      future: XFile(localPath).readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.pets_rounded, color: AppColors.primary, size: 18.sp),
          );
        }

        return Icon(Icons.pets_rounded, color: AppColors.primary, size: 18.sp);
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _medicalInfoController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdoptionCubit, AdoptionState>(
      listener: (context, state) {
        if (state.error != null) {
          CustomSnackbar.showError(context, state.error!);
          context.read<AdoptionCubit>().clearError();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F2),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.accent, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'List Pet for Adoption',
            style: AppTextStyles.onboardingTitle.copyWith(
              fontSize: 20.sp,
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: _isLoadingPets
              ? const Center(child: CircularProgressIndicator())
              : _petsError != null
                  ? Center(
                      child: Column(
                        children: [
                          Text(
                            _petsError!,
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: _loadUserPets,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _pets.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.pets_outlined,
                                size: 56.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                _hasAnyPets
                                    ? 'All your pets are already listed for adoption.'
                                    : 'You have no pets to list for adoption.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.onboardingBody.copyWith(
                                  fontSize: 15.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddPetScreen(),
                                    ),
                                  );
                                  if (mounted) {
                                    _loadUserPets();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add a pet'),
                              ),
                            ],
                          ),
                        )
                      : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Select Your Pet *'),
                SizedBox(height: 8.h),
                ..._pets.map((pet) {
                  final isSelected = pet.id == _selectedPetId;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedPetId = pet.id);
                      _applySelectedPetDefaults();
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? AppColors.accent : AppColors.border,
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            child: ClipOval(
                              child: SizedBox(
                                width: 40.r,
                                height: 40.r,
                                child: _buildPetAvatar(pet),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pet.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.onboardingBody.copyWith(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (pet.isVerified == true)
                                      Icon(Icons.verified_rounded, color: const Color(0xFF0E9F6E), size: 16.sp),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '${pet.type} • ${pet.verifiedBreed ?? pet.breed}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppColors.accent : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 12.h),

                _buildField('Description *', _descriptionController,
                    maxLines: 4,
                    hint: 'Tell potential adopters about this pet...',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null),
                _buildField('Medical Information', _medicalInfoController,
                    maxLines: 2),

                // Health toggles
                _sectionLabel('Health & Training'),
                SizedBox(height: 8.h),
                _toggleRow('Vaccinated', _isVaccinated,
                    (v) => setState(() => _isVaccinated = v)),
                _toggleRow('Neutered/Spayed', _isNeutered,
                    (v) => setState(() => _isNeutered = v)),
                _toggleRow('Trained', _isTrained,
                    (v) => setState(() => _isTrained = v)),
                SizedBox(height: 16.h),

                _buildField('Location', _locationController),
                _buildField('Adoption Fee', _feeController,
                  hint: 'PKR amount (0 for free)',
                    keyboardType: TextInputType.number),
                _buildField('Contact Phone', _phoneController,
                    keyboardType: TextInputType.phone),
                _buildField('Contact Email', _emailController,
                    keyboardType: TextInputType.emailAddress),

                SizedBox(height: 24.h),
                _buildSubmitButton(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.onboardingBody.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
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
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AdoptionCubit, AdoptionState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: state.isCreating ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: state.isCreating
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'List for Adoption',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final selectedPet = _selectedPet;
    if (selectedPet == null) {
      CustomSnackbar.showError(context, 'Please select one of your pets first.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    final feeText = _feeController.text.trim();
    final fee = feeText.isNotEmpty ? double.tryParse(feeText) : null;

    final selectedImages = (selectedPet.imageUrls ?? []).isNotEmpty
        ? selectedPet.imageUrls
        : (selectedPet.imageUrl != null ? <String>[selectedPet.imageUrl!] : null);

    final ageText = '${selectedPet.age} ${selectedPet.ageUnit}';

    final success = await context.read<AdoptionCubit>().createListing(
          petId: selectedPet.id,
          petName: selectedPet.name,
          petType: selectedPet.type,
          description: _descriptionController.text.trim(),
          breed: selectedPet.verifiedBreed ?? selectedPet.breed,
          age: ageText,
          gender: selectedPet.gender,
          color: selectedPet.color,
          medicalInfo: _optional(_medicalInfoController),
          isVaccinated: _isVaccinated,
          isNeutered: _isNeutered,
          isTrained: _isTrained,
          imageUrls: selectedImages,
          location: _optional(_locationController),
          contactPhone: _optional(_phoneController),
          contactEmail: _optional(_emailController),
          adoptionFee: fee,
        );

    if (success && mounted) {
      CustomSnackbar.showSuccess(context, 'Listing created successfully!');
      Navigator.pop(context, true);
    }
  }

  String? _optional(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }
}
