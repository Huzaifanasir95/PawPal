import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../bloc/auth_bloc.dart';

class AccountTypeSelectionScreen extends StatefulWidget {
  final VoidCallback? onAccountTypeSelected;
  final String? idToken;
  final String? displayName;
  final String? photoUrl;
  
  const AccountTypeSelectionScreen({
    super.key,
    this.onAccountTypeSelected,
    this.idToken,
    this.displayName,
    this.photoUrl,
  });

  @override
  State<AccountTypeSelectionScreen> createState() => _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState extends State<AccountTypeSelectionScreen> {
  String? _selectedAccountType;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          authenticated: (user) {
            // Don't handle here - let AuthFlow handle navigation
            print('🏠 AccountTypeSelection: Authenticated - letting AuthFlow handle it');
          },
          unauthenticated: () {},
          error: (message) {
            CustomSnackbar.showError(context, message);
          },
          passwordResetSent: () {},
          accountTypeRequired: (idToken, displayName, photoUrl) {},
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.authBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 50.h),

                // Primary Logo
                Row(
                  children: [
                    Image.asset(
                      AppImages.primaryLogo,
                      width: 58.w,
                      height: 58.h,
                      errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 58.w,
                        height: 58.h,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(29.r),
                        ),
                        child: Icon(
                          Icons.pets,
                          color: AppColors.primary,
                          size: 30.w,
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 50.h),

              // Title
              Text(
                AppStrings.selectAccountType,
                style: AppTextStyles.onboardingTitle.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.authText,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),

              // Account Type Options
              _buildAccountTypeOption(
                title: AppStrings.petOwner,
                description: 'Find and adopt your perfect pet companion',
                icon: Icons.pets,
                isSelected: _selectedAccountType == 'pet_owner',
                onTap: () => _selectAccountType('pet_owner'),
              ),

              SizedBox(height: 20.h),

              _buildAccountTypeOption(
                title: AppStrings.veterinary,
                description: 'Provide professional care for pets',
                icon: Icons.local_hospital,
                isSelected: _selectedAccountType == 'vet',
                onTap: () => _selectAccountType('vet'),
              ),

              SizedBox(height: 20.h),

              _buildAccountTypeOption(
                title: AppStrings.caregiver,
                description: 'Help care for pets in need',
                icon: Icons.volunteer_activism,
                isSelected: _selectedAccountType == 'caregiver',
                onTap: () => _selectAccountType('caregiver'),
              ),

              SizedBox(height: 60.h),

              // Continue Button
              _buildContinueButton(context),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildAccountTypeOption({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.socialBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                icon,
                color: AppColors.surface,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.authInputText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.authTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Container(
          width: double.infinity,
          height: 65.h,
          decoration: BoxDecoration(
            color: _selectedAccountType != null && !isLoading
                ? AppColors.googleButton
                : AppColors.googleButton.withOpacity(0.5),
            borderRadius: BorderRadius.circular(98.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(98.r),
              onTap: (_selectedAccountType != null && !isLoading)
                  ? () => _onContinuePressed(context)
                  : null,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      )
                    : Text(
                        AppStrings.continueText,
                        style: AppTextStyles.onboardingTitle.copyWith(
                          fontSize: 24.sp,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectAccountType(String accountType) {
    setState(() {
      _selectedAccountType = accountType;
    });
  }

  void _onContinuePressed(BuildContext context) async {
    if (_selectedAccountType == null) {
      CustomSnackbar.showError(context, 'Please select an account type');
      return;
    }

    try {
      final authBloc = context.read<AuthBloc>();
      
      // If we have idToken, this is from Google Sign-In - complete the flow
      if (widget.idToken != null) {
        authBloc.add(AuthEvent.completeGoogleSignIn(
          widget.idToken!,
          _selectedAccountType!,
          widget.displayName,
          widget.photoUrl,
        ));
      } else {
        // Otherwise just update the account type (existing flow)
        authBloc.add(AuthEvent.updateAccountType(_selectedAccountType!));
        widget.onAccountTypeSelected?.call();
        CustomSnackbar.showSuccess(context, 'Account type saved successfully!');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Failed to save account type. Please try again.');
    }
  }
}