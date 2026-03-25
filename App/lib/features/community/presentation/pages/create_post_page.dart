import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/image_service.dart';
import '../../data/models/post.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;
  String _selectedCategory = PostCategory.general;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick images')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to take photo')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitPost() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content')),
      );
      return;
    }

    // Show loading
    setState(() => _isLoading = true);

    try {
      List<String>? imageIds;

      // Upload images if any selected
      if (_selectedImages.isNotEmpty) {
        final imageService = getIt<ImageService>();
        imageIds = await imageService.uploadImages(_selectedImages);
      }

      // Dispatch create post event
      context.read<CommunityBloc>().add(
        CommunityEvent.createPost(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          imageUrls: imageIds,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.accent,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Post',
          style: AppTextStyles.onboardingTitle.copyWith(
            fontSize: 20.sp,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  )
                : Text(
                    'Post',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            Text(
              'Title',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: const Color(0xFF324B49),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _titleController,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Enter post title...',
                hintStyle: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: const Color(0xFFA1A1A1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFAAD5D1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFAAD5D1), width: 2),
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),

            SizedBox(height: 20.h),

            // Category Dropdown
            Text(
              'Category',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: const Color(0xFF324B49),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFAAD5D1)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  items: PostCategory.values
                      .where((cat) => cat != PostCategory.all) // Exclude 'all' from creation
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              PostCategory.getLabel(category),
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 14.sp,
                                color: const Color(0xFF324B49),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Content Field
            Text(
              'Content',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: const Color(0xFF324B49),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _contentController,
              maxLines: 8,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: const Color(0xFFA1A1A1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFAAD5D1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFAAD5D1), width: 2),
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),

            SizedBox(height: 20.h),

            // Image Section
            Text(
              'Photos',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: const Color(0xFF324B49),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            // Image Picker Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: Icon(
                      Icons.photo_library,
                      size: 20.w,
                      color: AppColors.accent,
                    ),
                    label: Text(
                      'Gallery',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: Icon(
                      Icons.camera_alt,
                      size: 20.w,
                      color: AppColors.accent,
                    ),
                    label: Text(
                      'Camera',
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Selected Images Preview
            if (_selectedImages.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                'Selected Images (${_selectedImages.length})',
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: const Color(0xFF324B49),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: 100.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100.w,
                      height: 100.h,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4.h,
                            right: 4.w,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 24.w,
                                height: 24.h,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}