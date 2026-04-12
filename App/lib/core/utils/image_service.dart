import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart' hide XFile;

@injectable
class ImageService {
  // Recommended size after compression (200KB max for base64 in JSON)
  static const int maxAvatarSizeBytes = 200000;

  /// Compress image before uploading
  Future<Uint8List> _compressImage(
    XFile imageFile,
    CompressFormat format,
  ) async {
    try {
      final originalBytes = await imageFile.readAsBytes();
      var optimizedBytes = originalBytes;

      // Multiple quality passes to keep payload small while preserving usable quality.
      for (final quality in [75, 65, 55, 45]) {
        final compressed = await FlutterImageCompress.compressWithList(
          originalBytes,
          quality: quality,
          minWidth: 1024,
          minHeight: 1024,
          format: format,
        );

        if (compressed.isNotEmpty) {
          optimizedBytes = Uint8List.fromList(compressed);
          if (optimizedBytes.length <= maxAvatarSizeBytes) {
            break;
          }
        }
      }

      if (optimizedBytes.length != originalBytes.length) {
        debugPrint(
          '✅ Image compressed: ${(originalBytes.length / 1024).round()}KB → ${(optimizedBytes.length / 1024).round()}KB',
        );
      }

      return optimizedBytes;
    } catch (e) {
      debugPrint('⚠️  Compression failed: $e, using original');
      return imageFile.readAsBytes();
    }
  }

  /// Convert image file to base64 data URL with compression
  Future<String?> _imageToBase64DataUrl(XFile imageFile) async {
    final extension = _extractExtension(imageFile);
    final compressFormat = _getCompressFormat(extension);

    final bytes = await _compressImage(imageFile, compressFormat);
    if (bytes.isEmpty) return null;

    // Check final size
    if (bytes.length > maxAvatarSizeBytes) {
      debugPrint(
        '⚠️  Compressed image (${(bytes.length / 1024).toStringAsFixed(1)}KB) still exceeds 200KB',
      );
      debugPrint(
        '💡 Consider using an even smaller image or implement proper file upload',
      );
    } else {
      debugPrint('✅ Image ready: ${(bytes.length / 1024).round()}KB');
    }

    final base64String = base64Encode(bytes);

    // Determine MIME type from the selected compression format.
    final mimeType = _getMimeTypeForFormat(compressFormat);

    // Return as data URL (data:image/jpeg;base64,...)
    return 'data:$mimeType;base64,$base64String';
  }

  String _extractExtension(XFile imageFile) {
    final source = imageFile.name.isNotEmpty ? imageFile.name : imageFile.path;
    final dotIndex = source.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == source.length - 1) {
      return '';
    }
    return source.substring(dotIndex + 1).toLowerCase();
  }

  CompressFormat _getCompressFormat(String extension) {
    switch (extension) {
      case 'png':
        return CompressFormat.png;
      case 'webp':
        return CompressFormat.webp;
      default:
        return CompressFormat.jpeg;
    }
  }

  String _getMimeTypeForFormat(CompressFormat format) {
    switch (format) {
      case CompressFormat.png:
        return 'image/png';
      case CompressFormat.webp:
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
  Future<List<String>> uploadImages(
    List<XFile> imageFiles, {
    String? folder,
  }) async {
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
