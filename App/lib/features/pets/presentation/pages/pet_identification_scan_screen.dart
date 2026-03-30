import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/breed_prediction_model.dart';
import '../../data/services/breed_verification_service.dart';

class PetIdentificationScanScreen extends StatefulWidget {
  const PetIdentificationScanScreen({super.key});

  @override
  State<PetIdentificationScanScreen> createState() =>
      _PetIdentificationScanScreenState();
}

class _PetIdentificationScanScreenState
    extends State<PetIdentificationScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final BreedVerificationService _breedService = BreedVerificationService();

  File? _selectedImage;
  PredictionResult? _scanResult;
  bool _isScanning = false;
  String _petType = 'dog';

  Future<void> _pickAndScan(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
      _scanResult = null;
    });

    await _scanBreed();
  }

  Future<void> _scanBreed() async {
    final image = _selectedImage;
    if (image == null) return;

    setState(() {
      _isScanning = true;
    });

    final result = await _breedService.predictBreed(
      imageFile: image,
      petType: _petType,
      useTTA: true,
      topK: 5,
    );

    if (!mounted) return;
    setState(() {
      _scanResult = result;
      _isScanning = false;
    });
  }

  String _percent(double value) {
    final percent = (value * 100).clamp(0, 100);
    return '${percent.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EEF2),
      appBar: AppBar(
        title: const Text('Pet Identification'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6F8),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFBCD0D9)),
                ),
                child: Text(
                  'Scan a random pet image to identify breed. Result is temporary and will not be saved to your account or database.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                height: 220.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFCAD8DF)),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.document_scanner_rounded,
                            size: 48.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'No image selected yet',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(17.r),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Dog'),
                      selected: _petType == 'dog',
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() => _petType = 'dog');
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Cat'),
                      selected: _petType == 'cat',
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() => _petType = 'cat');
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isScanning ? null : () => _pickAndScan(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Scan Camera'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isScanning
                          ? null
                          : () => _pickAndScan(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('From Gallery'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              if (_isScanning)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: 8.h),
                      Text(
                        'Analyzing pet breed...',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_scanResult != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFCAD8DF)),
                  ),
                  child: _scanResult!.success
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Match: ${_scanResult!.predicted ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Confidence: ${_percent(_scanResult!.confidence ?? 0)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            ..._scanResult!.predictions.take(5).map((prediction) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${prediction.rank}. ${prediction.breed}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _percent(prediction.confidence),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        )
                      : Text(
                          _scanResult!.error ??
                              'Unable to identify breed for this image.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFFC62828),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}