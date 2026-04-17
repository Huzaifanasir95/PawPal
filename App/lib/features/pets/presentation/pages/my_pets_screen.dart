import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
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
    final iconColor = Theme.of(context).colorScheme.primary;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.pets, color: iconColor, size: 40.sp);
        },
      );
    }

    final localPath = path.startsWith('file://')
        ? (Uri.tryParse(path)?.toFilePath() ?? path)
        : path;

    return FutureBuilder<Uint8List>(
      future: XFile(localPath).readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.pets, color: iconColor, size: 40.sp);
            },
          );
        }

        return Icon(Icons.pets, color: iconColor, size: 40.sp);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? colorScheme.surfaceContainerHighest : colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Pets',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
              size: 24.sp,
            ),
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
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
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
                    color: colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading pets',
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 20.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    snapshot.error.toString(),
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: colorScheme.onSurfaceVariant,
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
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.add, color: colorScheme.onPrimary),
        label: Text(
          'Add Pet',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 100.sp,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 20.h),
          Text(
            'No Pets Yet',
            style: AppTextStyles.onboardingTitle.copyWith(
              fontSize: 24.sp,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Add your first pet to get started!',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: _navigateToAddPet,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(
              Icons.add,
              color: colorScheme.onPrimary,
              size: 20.sp,
            ),
            label: Text(
              'Add Your First Pet',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(PetModel pet) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.14),
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
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child:
                  pet.imageLocalPath != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: _buildImageFromPath(pet.imageLocalPath!),
                      )
                      : Icon(Icons.pets, color: colorScheme.primary, size: 40.sp),
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
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (pet.isVerified == true) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.verified,
                          color: colorScheme.tertiary,
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
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${pet.age} ${pet.ageUnit} • ${pet.gender}',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
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
                color: colorScheme.primary,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
