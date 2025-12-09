import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@injectable
class ImageService {
  // Maximum size for base64 encoded image (100KB reasonable for avatars)
  static const int maxAvatarSizeBytes = 100000;

  /// Convert image file to base64 data URL with size optimization
  Future<String?> _imageToBase64DataUrl(XFile imageFile) async {
    final bytes = await File(imageFile.path).readAsBytes();
    
    // Warn if image is too large
    if (bytes.length > maxAvatarSizeBytes) {
      debugPrint('⚠️  Image size (${(bytes.length / 1024).toStringAsFixed(1)}KB) exceeds 100KB recommended size for avatars');
      debugPrint('Recommendation: Use a smaller image or implement proper file upload to backend');
      // For now, still proceed but be aware this is a temporary solution
    }
    
    final base64String = base64Encode(bytes);
    
    // Determine MIME type from file extension
    final extension = imageFile.path.split('.').last.toLowerCase();
    final mimeType = _getMimeType(extension);
    
    // Return as data URL (data:image/jpeg;base64,...)
    return 'data:$mimeType;base64,$base64String';
  }

  /// Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Convert base64 string to image bytes (for display)
  Uint8List base64ToImage(String base64String) {
    // Handle data URLs
    if (base64String.startsWith('data:')) {
      final base64Data = base64String.split(',').last;
      return base64Decode(base64Data);
    }
    return base64Decode(base64String);
  }

  /// Upload a single image - returns base64 data URL
  /// TEMPORARY SOLUTION: Uses base64 encoding. In production, implement multipart file upload to backend.
  /// This is not scalable for large images or high volume. 
  /// TODO: Implement proper file upload endpoint in backend:
  /// - POST /api/upload with multipart/form-data
  /// - Store files on disk or cloud storage (S3, GCS, etc)
  /// - Return URL instead of embedding base64
  Future<String?> uploadImage(XFile imageFile, {String? folder}) async {
    try {
      // Convert image to base64 data URL with size warnings
      return await _imageToBase64DataUrl(imageFile);
    } catch (e) {
      debugPrint('❌ Failed to upload image: $e');
      return null;
    }
  }

  /// Upload multiple images - returns list of base64 data URLs
  Future<List<String>> uploadImages(List<XFile> imageFiles, {String? folder}) async {
    try {
      final List<String> imageUrls = [];

      for (final imageFile in imageFiles) {
        final imageUrl = await uploadImage(imageFile, folder: folder);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }

      return imageUrls;
    } catch (e) {
      debugPrint('❌ Failed to upload images: $e');
      return [];
    }
  }
}