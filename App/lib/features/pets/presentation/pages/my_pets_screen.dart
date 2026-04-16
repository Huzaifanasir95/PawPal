import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pet_model.dart';
import '../../data/repositories/pet_repository_api.dart';
import 'add_pet_screen.dart';
import 'pet_details_screen.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final _petRepository = PetRepositoryApi();

  Widget _buildImageFromPath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.pets, color: AppColors.primary, size: 40.sp);
        },
      );
    }

    return FutureBuilder<Uint8List>(
      future: XFile(path).readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.pets, color: AppColors.primary, size: 40.sp);
            },
          );
        }

        return Icon(Icons.pets, color: AppColors.primary, size: 40.sp);
      },
    );
  }

  void _navigateToAddPet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPetScreen()),
    );

    // Refresh is handled by StreamBuilder
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accent, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Pets',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.accent, size: 24.sp),
            onPressed: _navigateToAddPet,
          ),
        ],
      ),
      body: StreamBuilder<List<PetModel>>(
        stream: _petRepository.getUserPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading pets',
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 20.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    snapshot.error.toString(),
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final pets = snapshot.data ?? [];

          if (pets.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              return _buildPetCard(pets[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPet,
        backgroundColor: AppColors.accent,
        icon: Icon(Icons.add, color: AppColors.textOnSecondary),
        label: Text(
          'Add Pet',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: AppColors.textOnSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 100.sp,
            color: AppColors.primary.withOpacity(0.5),
          ),
          SizedBox(height: 20.h),
          Text(
            'No Pets Yet',
            style: AppTextStyles.onboardingTitle.copyWith(
              fontSize: 24.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Add your first pet to get started!',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: _navigateToAddPet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(
              Icons.add,
              color: AppColors.textOnSecondary,
              size: 20.sp,
            ),
            label: Text(
              'Add Your First Pet',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: AppColors.textOnSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(PetModel pet) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            // Pet Image
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child:
                  pet.imageLocalPath != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: _buildImageFromPath(pet.imageLocalPath!),
                      )
                      : Icon(Icons.pets, color: AppColors.primary, size: 40.sp),
            ),
            SizedBox(width: 12.w),
            // Pet Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pet.name,
                        style: AppTextStyles.onboardingTitle.copyWith(
                          fontSize: 18.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (pet.isVerified == true) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.verified,
                          color: AppColors.success,
                          size: 18.sp,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    pet.breed,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${pet.age} ${pet.ageUnit} • ${pet.gender}',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetDetailsScreen(pet: pet),
                  ),
                );
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
