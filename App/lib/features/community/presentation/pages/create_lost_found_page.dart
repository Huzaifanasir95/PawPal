import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../cubit/lost_found_cubit.dart';
import '../cubit/lost_found_state.dart';

class CreateLostFoundPage extends StatefulWidget {
  const CreateLostFoundPage({super.key});

  @override
  State<CreateLostFoundPage> createState() => _CreateLostFoundPageState();
}

class _CreateLostFoundPageState extends State<CreateLostFoundPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'lost';
  String _urgency = 'medium';
  final _descriptionController = TextEditingController();
  final _petNameController = TextEditingController();
  final _petTypeController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _petNameController.dispose();
    _petTypeController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LostFoundCubit, LostFoundState>(
      listener: (context, state) {
        if (state.error != null) {
          CustomSnackbar.showError(context, state.error!);
          context.read<LostFoundCubit>().clearError();
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
            'Report Lost / Found Pet',
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
                // Type selection
                _sectionLabel('Type *'),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _typeChip('Lost', 'lost'),
                    SizedBox(width: 12.w),
                    _typeChip('Found', 'found'),
                  ],
                ),
                SizedBox(height: 20.h),

                // Urgency
                _sectionLabel('Urgency'),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _urgencyChip('Low', 'low'),
                    SizedBox(width: 8.w),
                    _urgencyChip('Medium', 'medium'),
                    SizedBox(width: 8.w),
                    _urgencyChip('High', 'high'),
                  ],
                ),
                SizedBox(height: 20.h),

                _buildField('Pet Name', _petNameController, hint: 'e.g. Buddy'),
                _buildField('Pet Type', _petTypeController, hint: 'e.g. Dog, Cat'),
                _buildField('Breed', _breedController, hint: 'e.g. Golden Retriever'),
                _buildField('Color', _colorController, hint: 'e.g. Golden, Black & White'),
                _buildField('Description *', _descriptionController,
                    hint: 'Describe the pet and circumstances...', maxLines: 4,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Description is required' : null),
                _buildField('Last Seen Location', _locationController,
                    hint: 'e.g. Central Park, near the lake'),
                _buildField('Contact Phone', _phoneController,
                    hint: '+1 234 567 8901',
                    keyboardType: TextInputType.phone),
                _buildField('Contact Email', _emailController,
                    hint: 'email@example.com',
                    keyboardType: TextInputType.emailAddress),

                SizedBox(height: 30.h),
                _buildSubmitButton(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String value) {
    final isActive = _type == value;
    final isLost = value == 'lost';
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive
              ? (isLost ? AppColors.error : AppColors.success)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isActive
                ? (isLost ? AppColors.error : AppColors.success)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLost ? Icons.pets : Icons.check_circle_outline,
              size: 18.sp,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _urgencyChip(String label, String value) {
    final isActive = _urgency == value;
    return GestureDetector(
      onTap: () => setState(() => _urgency = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? _urgencyColor(value).withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive ? _urgencyColor(value) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 13.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? _urgencyColor(value) : AppColors.textSecondary,
          ),
        ),
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
    return BlocBuilder<LostFoundCubit, LostFoundState>(
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
                    'Submit Report',
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

    final success = await context.read<LostFoundCubit>().createPost(
          type: _type,
          description: _descriptionController.text.trim(),
          petName: _optional(_petNameController),
          petType: _optional(_petTypeController),
          breed: _optional(_breedController),
          color: _optional(_colorController),
          lastSeenLocation: _optional(_locationController),
          urgency: _urgency,
          contactPhone: _optional(_phoneController),
          contactEmail: _optional(_emailController),
        );

    if (success && mounted) {
      CustomSnackbar.showSuccess(context, 'Report submitted successfully!');
      Navigator.pop(context, true);
    }
  }

  String? _optional(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }
}
