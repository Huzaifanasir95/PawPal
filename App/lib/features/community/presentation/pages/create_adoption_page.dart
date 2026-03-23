import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../cubit/adoption_cubit.dart';
import '../cubit/adoption_state.dart';

class CreateAdoptionPage extends StatefulWidget {
  const CreateAdoptionPage({super.key});

  @override
  State<CreateAdoptionPage> createState() => _CreateAdoptionPageState();
}

class _CreateAdoptionPageState extends State<CreateAdoptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _colorController = TextEditingController();
  final _medicalInfoController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _feeController = TextEditingController();

  String _petType = 'dog';
  String? _gender;
  String? _size;
  bool _isVaccinated = false;
  bool _isNeutered = false;
  bool _isTrained = false;

  @override
  void dispose() {
    _petNameController.dispose();
    _descriptionController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _colorController.dispose();
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet type
                _sectionLabel('Pet Type *'),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: ['Dog', 'Cat', 'Bird', 'Other'].map((t) {
                    final val = t.toLowerCase();
                    final isActive = _petType == val;
                    return GestureDetector(
                      onTap: () => setState(() => _petType = val),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          t,
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 13.sp,
                            color: isActive
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),

                _buildField('Pet Name *', _petNameController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null),
                _buildField('Breed', _breedController),
                _buildField('Age', _ageController, hint: 'e.g. 2 years'),
                _buildField('Color', _colorController),

                // Gender
                _sectionLabel('Gender'),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: ['Male', 'Female'].map((g) {
                    final isActive = _gender == g.toLowerCase();
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _gender = g.toLowerCase()),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          g,
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 13.sp,
                            color: isActive
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),

                // Size
                _sectionLabel('Size'),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: ['Small', 'Medium', 'Large'].map((s) {
                    final isActive = _size == s.toLowerCase();
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _size = s.toLowerCase()),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          s,
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 13.sp,
                            color: isActive
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),

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
                    hint: '0 for free',
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
    if (!_formKey.currentState!.validate()) return;
    final feeText = _feeController.text.trim();
    final fee = feeText.isNotEmpty ? double.tryParse(feeText) : null;

    final success = await context.read<AdoptionCubit>().createListing(
          petName: _petNameController.text.trim(),
          petType: _petType,
          description: _descriptionController.text.trim(),
          breed: _optional(_breedController),
          age: _optional(_ageController),
          gender: _gender,
          size: _size,
          color: _optional(_colorController),
          medicalInfo: _optional(_medicalInfoController),
          isVaccinated: _isVaccinated,
          isNeutered: _isNeutered,
          isTrained: _isTrained,
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
