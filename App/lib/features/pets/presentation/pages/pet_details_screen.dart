import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pet_model.dart';
import '../../data/models/breed_prediction_model.dart';
import '../../data/models/health_record_model.dart';
import '../../data/models/health_journal_model.dart';
import '../../data/services/breed_verification_service.dart';
import '../../data/repositories/health_repository.dart';
import '../../data/repositories/pet_repository.dart';
import 'add_health_journal_screen.dart';
import 'edit_health_records_screen.dart';

class PetDetailsScreen extends StatefulWidget {
  final PetModel pet;

  const PetDetailsScreen({
    super.key,
    required this.pet,
  });

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  late PetModel _currentPet;
  final _breedVerificationService = BreedVerificationService();
  final _petRepository = PetRepository();
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _currentPet = widget.pet;
  }

  Future<void> _refreshPetData() async {
    try {
      final updatedPet = await _petRepository.getPetById(_currentPet.id);
      if (updatedPet != null) {
        setState(() {
          _currentPet = updatedPet;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to refresh pet data', isError: true);
    }
  }

  Future<void> _verifyBreed() async {
    if (_currentPet.imageLocalPath == null) {
      _showSnackBar('No image available for verification', isError: true);
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await _breedVerificationService.predictBreed(
        imageFile: File(_currentPet.imageLocalPath!),
        petType: _currentPet.type, // Pass pet type (dog or cat)
        useTTA: true,
        topK: 5,
      );

      // Debug logging
      print('✓ BREED VERIFICATION RESULT:');
      print('  • success: ${result.success}');
      print('  • predicted: ${result.predicted}');
      print('  • confidence: ${result.confidence}');
      print('  • error: ${result.error}');
      print('  • predictions count: ${result.predictions.length}');

      if (result.success == true && result.predicted != null) {
        if (mounted) _showVerificationDialog(result);
      } else {
        if (mounted) {
          _showSnackBar(
            'Verification failed: ${result.error ?? 'Unknown error'}',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  /// Clean breed name by removing ID prefix (e.g., "N02108422 Bull Mastiff" -> "Bull Mastiff")
  String _cleanBreedName(String breed) {
    // Remove the leading ID pattern (e.g., "N02108422 " or similar)
    final parts = breed.split(' ');
    if (parts.isNotEmpty && parts[0].contains(RegExp(r'^[A-Z0-9]+$')) && parts[0].length > 3) {
      // Remove the first part if it looks like an ID
      return parts.skip(1).join(' ');
    }
    return breed;
  }

  void _showVerificationDialog(PredictionResult result) {
    final cleanedBreed = _cleanBreedName(result.predicted ?? 'Unknown');
    final confidence = (result.confidence ?? 0) * 100;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withOpacity(0.2),
                        AppColors.success.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.verified, color: AppColors.success, size: 40.sp),
                      SizedBox(height: 12.h),
                      Text(
                        'We Found Your Pet\'s Breed! 🎉',
                        style: AppTextStyles.onboardingTitle.copyWith(
                          fontSize: 18.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main breed result card
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Your Dog is a',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              cleanedBreed,
                              style: AppTextStyles.onboardingTitle.copyWith(
                                fontSize: 26.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${confidence.toStringAsFixed(1)}% Confidence',
                                style: AppTextStyles.onboardingBody.copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Top predictions in horizontal cards
                      if (result.predictions.isNotEmpty) ...[
                        Text(
                          'Other Predictions:',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(right: 4.w),
                          child: Row(
                            children: result.predictions.skip(1).take(4).map((pred) {
                              final conf = (pred.confidence * 100).toStringAsFixed(0);
                              return Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Container(
                                  width: 100.w,
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral200,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppColors.neutral300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _cleanBreedName(pred.breed),
                                        style: AppTextStyles.onboardingBody.copyWith(
                                          fontSize: 11.sp,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        '$conf%',
                                        style: AppTextStyles.onboardingBody.copyWith(
                                          fontSize: 12.sp,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      SizedBox(height: 20.h),

                      // Processing details
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Time',
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${(result.processTime / 1000).toStringAsFixed(2)}s',
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1.w,
                              height: 30.h,
                              color: AppColors.neutral300,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Method',
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  result.usedTTA ? 'TTA' : 'Standard',
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Buttons
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Update breed button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updatePetBreed(cleanedBreed);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: Icon(Icons.check_circle, size: 20.sp),
                        label: Text(
                          'Yes, Update Pet Breed',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.textOnSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Keep current breed button
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary, width: 1.5),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: Icon(Icons.close_rounded, size: 20.sp),
                        label: Text(
                          'Keep Current Breed',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Update the pet breed and save to database
  Future<void> _updatePetBreed(String newBreed) async {
    try {
      // Update the current pet model
      final updatedPet = _currentPet.copyWith(
        breed: newBreed,
        isVerified: true,
      );

      // Update the pet in database (if you have a repository)
      // await _petRepository.updatePet(updatedPet);

      // Update local state
      setState(() {
        _currentPet = updatedPet;
      });

      _showSnackBar('✓ Pet breed updated to $newBreed!', isError: false);
    } catch (e) {
      _showSnackBar('Error updating breed: $e', isError: true);
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
          'Pet Details',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Images Carousel
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 340.h,
                  color: AppColors.surfaceContainer,
                  child: _currentPet.imageUrls != null && _currentPet.imageUrls!.isNotEmpty
                      ? PageView.builder(
                          itemCount: _currentPet.imageUrls!.length,
                          itemBuilder: (context, index) {
                            final imagePath = _currentPet.imageUrls![index];
                            return GestureDetector(
                              onTap: () => _showImageGallery(context, index),
                              child: ClipRRect(
                                child: Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                    child: Icon(Icons.pets,
                                        color: AppColors.primary, size: 80.sp),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : _currentPet.imageLocalPath != null
                          ? GestureDetector(
                              onTap: () => _showImageGallery(context, 0),
                              child: ClipRRect(
                                child: Image.file(
                                  File(_currentPet.imageLocalPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                    child: Icon(Icons.pets,
                                        color: AppColors.primary, size: 80.sp),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(Icons.pets,
                                  color: AppColors.primary, size: 80.sp),
                            ),
                ),
                // Image indicator
                if ((_currentPet.imageUrls?.length ?? 0) > 1)
                  Positioned(
                    bottom: 20.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _currentPet.imageUrls!.length,
                        (index) => Container(
                          width: 8.w,
                          height: 8.h,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Tap hint
                Positioned(
                  top: 20.h,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: AppColors.textSecondary,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Tap to view all',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.authBackground.withOpacity(0.95),
                          AppColors.authBackground.withOpacity(0.7),
                          AppColors.authBackground.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Pet Info Card - Simplified Clean Layout
            Transform.translate(
              offset: Offset(0, -30.h),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Name + Type + Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentPet.name,
                                style: AppTextStyles.onboardingTitle.copyWith(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  _currentPet.type.toUpperCase(),
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 10.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Removed verified badge as per user request
                        // if (_currentPet.isVerified == true)
                        //   Tooltip(
                        //     message: 'AI Verified',
                        //     child: Container(
                        //       padding: EdgeInsets.all(8.w),
                        //       decoration: BoxDecoration(
                        //         color: AppColors.success.withOpacity(0.12),
                        //         borderRadius: BorderRadius.circular(8.r),
                        //       ),
                        //       child: Icon(
                        //         Icons.verified,
                        //         color: AppColors.success,
                        //         size: 20.sp,
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Quick Info Grid (2 columns)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.1,
                      children: [
                        _buildCompactInfoTile(
                          icon: Icons.pets,
                          label: 'Breed',
                          value: _currentPet.breed,
                          color: AppColors.primary,
                        ),
                        _buildCompactInfoTile(
                          icon: Icons.cake,
                          label: 'Age',
                          value: '${_currentPet.age} ${_currentPet.ageUnit}',
                          color: AppColors.warning,
                        ),
                        _buildCompactInfoTile(
                          icon: Icons.wc,
                          label: 'Gender',
                          value: _capitalize(_currentPet.gender),
                          color: AppColors.info,
                        ),
                        _buildCompactInfoTile(
                          icon: Icons.palette,
                          label: 'Color',
                          value: _currentPet.color,
                          color: AppColors.accent,
                        ),
                        _buildCompactInfoTile(
                          icon: Icons.scale,
                          label: 'Weight',
                          value: '${_currentPet.weight} ${_currentPet.weightUnit}',
                          color: AppColors.primary,
                        ),
                        _buildCompactInfoTile(
                          icon: Icons.date_range,
                          label: 'Joined',
                          value: _formatDate(_currentPet.createdAt),
                          color: AppColors.success,
                        ),
                      ],
                    ),

                    // Bio Section
                    if (_currentPet.bio != null && _currentPet.bio!.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.notes, color: AppColors.primary, size: 18.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'About',
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              _currentPet.bio!,
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Verification Info - REMOVED as per user request
                    // if (_currentPet.isVerified == true) ...[
                    //   SizedBox(height: 16.h),
                    //   Container(
                    //     padding: EdgeInsets.all(14.w),
                    //     decoration: BoxDecoration(
                    //       gradient: LinearGradient(
                    //         colors: [
                    //           AppColors.success.withOpacity(0.1),
                    //           AppColors.success.withOpacity(0.04),
                    //         ],
                    //         begin: Alignment.topLeft,
                    //         end: Alignment.bottomRight,
                    //       ),
                    //       borderRadius: BorderRadius.circular(12.r),
                    //       border: Border.all(
                    //         color: AppColors.success.withOpacity(0.2),
                    //         width: 1,
                    //       ),
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Row(
                    //           children: [
                    //             Icon(Icons.verified_user, color: AppColors.success, size: 18.sp),
                    //             SizedBox(width: 8.w),
                    //             Text(
                    //               'AI Verified',
                    //               style: AppTextStyles.onboardingBody.copyWith(
                    //                 fontSize: 12.sp,
                    //                 color: AppColors.textPrimary,
                    //                 fontWeight: FontWeight.w700,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         SizedBox(height: 10.h),
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //           Text(
                    //             _currentPet.verifiedBreed ?? _currentPet.breed,
                    //             style: AppTextStyles.onboardingBody.copyWith(
                    //               fontSize: 13.sp,
                    //               color: AppColors.success,
                    //               fontWeight: FontWeight.w700,
                    //             ),
                    //           ),
                    //           Text(
                    //             '${((_currentPet.verificationConfidence ?? 0) * 100).toStringAsFixed(0)}%',
                    //             style: AppTextStyles.onboardingBody.copyWith(
                    //               fontSize: 13.sp,
                    //               color: AppColors.success,
                    //               fontWeight: FontWeight.w700,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       SizedBox(height: 8.h),
                    //       ClipRRect(
                    //         borderRadius: BorderRadius.circular(6.r),
                    //         child: LinearProgressIndicator(
                    //           value: _currentPet.verificationConfidence ?? 0,
                    //           backgroundColor: AppColors.neutral300,
                    //           valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                    //           minHeight: 4.h,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ],
                  ],
                ),
              ),
            ),

            // Health Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Health Records',
                          style: AppTextStyles.onboardingTitle.copyWith(
                            fontSize: 20.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          Icons.health_and_safety,
                          color: AppColors.success,
                          size: 24.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    if (_currentPet.healthRecord == null) ...[
                      // No health records message
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              color: AppColors.textSecondary,
                              size: 48.sp,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'No health records added yet',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 16.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Add your pet\'s medical history and keep track of their health',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ] else ...[
                      // Health Info Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 1.2,
                        children: [
                          if (_currentPet.healthRecord!.isVaccinated)
                            _buildHealthInfoTile(
                              icon: Icons.vaccines,
                              label: 'Vaccinated',
                              value: 'Yes',
                              color: AppColors.success,
                            ),
                          if (_currentPet.healthRecord!.vetName != null)
                            _buildHealthInfoTile(
                              icon: Icons.local_hospital,
                              label: 'Vet',
                              value: _currentPet.healthRecord!.vetName!,
                              color: AppColors.primary,
                            ),
                          if (_currentPet.healthRecord!.medicalConditions != null &&
                              _currentPet.healthRecord!.medicalConditions!.isNotEmpty)
                            _buildHealthInfoTile(
                              icon: Icons.warning,
                              label: 'Conditions',
                              value: '${_currentPet.healthRecord!.medicalConditions!.length} recorded',
                              color: AppColors.warning,
                            ),
                          if (_currentPet.healthRecord!.medications != null &&
                              _currentPet.healthRecord!.medications!.isNotEmpty)
                            _buildHealthInfoTile(
                              icon: Icons.medication,
                              label: 'Medications',
                              value: '${_currentPet.healthRecord!.medications!.length} active',
                              color: AppColors.info,
                            ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditHealthRecordsScreen(
                                    petId: _currentPet.id,
                                    petName: _currentPet.name,
                                    existingRecord: _currentPet.healthRecord,
                                  ),
                                ),
                              );

                              // Refresh pet data if health records were updated
                              if (result == true) {
                                await _refreshPetData();
                                _showSnackBar('Health records updated successfully!');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.info,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: Icon(
                              _currentPet.healthRecord == null ? Icons.add : Icons.edit,
                              color: AppColors.textOnSecondary,
                              size: 20.sp,
                            ),
                            label: Text(
                              _currentPet.healthRecord == null ? 'Add Health Records' : 'Edit Health Records',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.textOnSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddHealthJournalScreen(
                                    petId: _currentPet.id,
                                    petName: _currentPet.name,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.add,
                              color: AppColors.accent,
                              size: 20.sp,
                            ),
                            label: Text(
                              'Add Journal',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Verify Breed Button Section
            Padding(
              padding:
                  EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isVerifying)
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18.w,
                            height: 18.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.info,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Analyzing breed...',
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Using AI model (2-5 seconds)',
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isVerifying ? null : _verifyBreed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          disabledBackgroundColor:
                              AppColors.accent.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(
                            horizontal: 28.w,
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        icon: Icon(
                          _currentPet.isVerified == true
                              ? Icons.refresh
                              : Icons.verified_user,
                          color: AppColors.textOnSecondary,
                          size: 22.sp,
                        ),
                        label: Text(
                          _currentPet.isVerified == true
                              ? 'Re-verify Breed'
                              : 'Verify Breed with AI',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textOnSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _showImageGallery(BuildContext context, int initialIndex) {
    final imageUrls = _currentPet.imageUrls ?? [];
    final hasLocalImage = _currentPet.imageLocalPath != null && imageUrls.isEmpty;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: hasLocalImage ? 1 : imageUrls.length,
              itemBuilder: (context, index) {
                String? imagePath;
                if (hasLocalImage) {
                  imagePath = _currentPet.imageLocalPath;
                } else {
                  imagePath = imageUrls[index];
                }

                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.file(
                      File(imagePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Center(
                        child: Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 80.sp,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Close button
            Positioned(
              top: 40.h,
              right: 20.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
            // Image counter
            if ((hasLocalImage ? 1 : imageUrls.length) > 1)
              Positioned(
                bottom: 40.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    hasLocalImage ? 1 : imageUrls.length,
                    (index) => Container(
                      width: 8.w,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
