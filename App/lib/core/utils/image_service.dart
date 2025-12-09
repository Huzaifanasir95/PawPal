import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

@injectable
class ImageService {
  // Recommended size after compression (200KB max for base64 in JSON)
  static const int maxAvatarSizeBytes = 200000;

  /// Compress image before uploading
  Future<XFile?> _compressImage(XFile imageFile) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final originalSize = await File(imageFile.path).length();
        final compressedSize = await File(result.path).length();
        debugPrint(
            '✅ Image compressed: ${(originalSize / 1024).round()}KB → ${(compressedSize / 1024).round()}KB');
        return result;
      }
      return imageFile;
    } catch (e) {
      debugPrint('⚠️  Compression failed: $e, using original');
      return imageFile;
    }
  }

  /// Convert image file to base64 data URL with compression
  Future<String?> _imageToBase64DataUrl(XFile imageFile) async {
    // Compress the image first
    final compressedFile = await _compressImage(imageFile);
    if (compressedFile == null) {
      return null;
    }

    final bytes = await File(compressedFile.path).readAsBytes();

    // Check final size
    if (bytes.length > maxAvatarSizeBytes) {
      debugPrint(
          '⚠️  Compressed image (${(bytes.length / 1024).toStringAsFixed(1)}KB) still exceeds 200KB');
      debugPrint('💡 Consider using an even smaller image or implement proper file upload');
    } else {
      debugPrint('✅ Image ready: ${(bytes.length / 1024).round()}KB');
    }

    final base64String = base64Encode(bytes);

    // Determine MIME type - always use JPEG after compression
    final mimeType = 'image/jpeg';

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