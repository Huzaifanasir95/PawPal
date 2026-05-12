import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import 'vet_profile_setup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Title
              Text(
                'Choose Your Role',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 12.h),

              Text(
                'Select how you\'d like to use PawPawl',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              SizedBox(height: 40.h),

              // Pet Owner Option
              _buildRoleOption(
                title: 'Pet Owner',
                description: 'Find vets, manage your pets, and connect with professionals',
                icon: Icons.pets,
                role: 'petowner',
                isSelected: _selectedRole == 'petowner',
                onTap: () => setState(() => _selectedRole = 'petowner'),
              ),

              SizedBox(height: 20.h),

              // Veterinarian Option
              _buildRoleOption(
                title: 'Veterinarian',
                description: 'Provide professional care and connect with pet owners',
                icon: Icons.local_hospital,
                role: 'vet',
                isSelected: _selectedRole == 'vet',
                onTap: () => setState(() => _selectedRole = 'vet'),
              ),

              SizedBox(height: 60.h),

              // Continue Button
              _buildContinueButton(context),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String title,
    required String description,
    required IconData icon,
    required String role,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15) 
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primary,
                size: 28.w,
              ),
            ),

            SizedBox(width: 16.w),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Check icon
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _selectedRole == null || _isLoading
            ? null
            : () => _handleContinue(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          disabledBackgroundColor: Theme.of(context).colorScheme.outline,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: _selectedRole == null ? 0 : 2,
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.surface),
                ),
              )
            : Text(
                'Continue',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: _selectedRole == null 
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) 
                      : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  Future<void> _handleContinue(BuildContext context) async {
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = context.read<AuthRepository>();
      await authRepo.setUserRole(_selectedRole!);

      if (!mounted) return;

      // Show success message
      CustomSnackbar.showSuccess(context, 'Role set successfully!');

      // Navigate based on role
      if (_selectedRole == 'vet') {
        // Navigate to vet profile setup
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const VetProfileSetupScreen(),
          ),
        );
      } else {
        // Navigate to main app (pet owner)
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
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


