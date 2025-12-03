import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@injectable
class ImageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Convert image file to base64 string
  Future<String> _imageToBase64(XFile imageFile) async {
    final bytes = await File(imageFile.path).readAsBytes();
    return base64Encode(bytes);
  }

  /// Convert base64 string to image bytes (for display)
  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  /// Upload a single image to Firestore as base64
  Future<String> uploadImage(XFile imageFile, {String? folder = 'posts'}) async {
    try {
      // Convert image to base64
      final base64String = await _imageToBase64(imageFile);

      // Create a unique document ID
      final docId = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name.hashCode}';

      // Store in Firestore
      await _firestore.collection('images').doc(docId).set({
        'base64Data': base64String,
        'fileName': imageFile.name,
        'folder': folder,
        'uploadedAt': FieldValue.serverTimestamp(),
        'size': base64String.length,
      });

      // Return the document ID as the "URL"
      return docId;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Upload multiple images to Firestore as base64
  Future<List<String>> uploadImages(List<XFile> imageFiles, {String? folder = 'posts'}) async {
    try {
      final List<String> imageIds = [];

      for (final imageFile in imageFiles) {
        final imageId = await uploadImage(imageFile, folder: folder);
        imageIds.add(imageId);
      }

      return imageIds;
    } catch (e) {
      throw 'Failed to upload images: $e';
    }
  }

  /// Get image data from Firestore
  Future<String?> getImageBase64(String imageId) async {
    try {
      final doc = await _firestore.collection('images').doc(imageId).get();
      if (doc.exists) {
        return doc.data()?['base64Data'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete an image from Firestore
  Future<void> deleteImage(String imageId) async {
    try {
      await _firestore.collection('images').doc(imageId).delete();
    } catch (e) {
      throw 'Failed to delete image: $e';
    }
  }

  /// Delete multiple images from Firestore
  Future<void> deleteImages(List<String> imageIds) async {
    try {
      for (final imageId in imageIds) {
        await deleteImage(imageId);
      }
    } catch (e) {
      throw 'Failed to delete images: $e';
    }
  }
}