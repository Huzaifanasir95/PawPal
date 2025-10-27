# PawPal Backend - Pet Breed Classification API

🐕🐱 A high-performance Go backend API for dog and cat breed classification using ConvNeXt V2 neural networks.

## 📱 Quick Start: How to Call from Flutter App

### 🐕 For DOG Classification
```dart
// Step 1: Pick a dog image
final bytes = await File(imagePath).readAsBytes();

// Step 2: Call DOG model
final result = await api.predictSingle(
  bytes,
  petType: 'dog',  // ← Use 'dog' for dogs
  topK: 5,
);

// Result: "Golden Retriever", "Labrador", etc. (120 breeds)
```

### 🐱 For CAT Classification
```dart
// Step 1: Pick a cat image
final bytes = await File(imagePath).readAsBytes();

// Step 2: Call CAT model
final result = await api.predictSingle(
  bytes,
  petType: 'cat',  // ← Use 'cat' for cats
  topK: 5,
);

// Result: "Siamese", "Persian", "Maine Coon", etc. (20 breeds)
```

### 🔑 Key Difference
- **Dogs**: `petType: 'dog'` → Returns one of 120 dog breeds
- **Cats**: `petType: 'cat'` → Returns one of 20 cat breeds

**That's it!** Same endpoint, just change the `pet_type` parameter. See [Full Flutter Integration](#-flutter-integration-guide) below for complete code.

---

## Features

- **🐕 120 Dog Breeds**: Classify from 120 different dog breeds with 92-95% accuracy
- **🐱 20 Cat Breeds**: Classify from 20 different cat breeds with 88-92% accuracy
- **🎯 Dual Model Support**: Toggle between dog and cat classification models
- **📊 High Accuracy**: ConvNeXt V2 Base architecture (88M parameters)
- **📸 Multiple Input Methods**: Upload base64 images or provide URLs
- **⚡ Batch Processing**: Process multiple images at once
- **🔄 Test-Time Augmentation**: Improved accuracy with TTA (4 augmentations)
- **🌐 RESTful API**: Easy integration with Flutter mobile apps
- **🧪 Built-in Testing**: Interactive HTML test interface with pet type toggle
- **🚀 Fast Inference**: ~10-12 seconds per prediction (CPU)

## Models Information

### 🐕 Dog Breed Classifier
- **Model**: ConvNeXt V2 Base (88M parameters)
- **Dataset**: Stanford Dogs Dataset
- **Classes**: 120 dog breeds
- **Accuracy**: 92-95%
- **Input Size**: 384x384 pixels
- **Model File**: `cat_breed_classifier_complete.pth` (350MB)

### 🐱 Cat Breed Classifier
- **Model**: ConvNeXt V2 Base (88M parameters)
- **Dataset**: Custom Cat Breeds Dataset
- **Classes**: 20 cat breeds (Abyssinian, American Bobtail, Bengal, British Shorthair, Maine Coon, Persian, Ragdoll, Siamese, Sphynx, etc.)
- **Accuracy**: 88-92%
- **Input Size**: 384x384 pixels
- **Model File**: `best_model_stage3.pth` (350MB)

## Quick Start

### Prerequisites

1. **Go 1.19+** (Already installed ✅)
2. **Python 3.8+** with required ML packages
3. **PyTorch model files** for both dogs and cats (Already available ✅)

### Installation

1. **Install Python Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
   
   Required packages:
   - torch (PyTorch)
   - torchvision
   - timm (PyTorch Image Models)
   - albumentations (Image augmentation)
   - opencv-python
   - pillow
   - numpy

2. **Build and Run the Server**:
   ```bash
   cd Backend
   go run cmd/api/main.go
   ```
   
   Or build the executable:
   ```bash
   go build -o pawpal-api cmd/api/main.go
   ./pawpal-api
   ```

3. **Test the API**:
   - **Web Interface**: http://localhost:8080/test
   - **Health Check**: http://localhost:8080/health
   - **API Documentation**: See endpoints below

## 🌐 API Endpoints for Flutter

### Endpoint Quick Reference

| Pet Type | Parameter | Breeds | Accuracy | Example |
|----------|-----------|--------|----------|---------|
| 🐕 **Dogs** | `pet_type: "dog"` | 120 breeds | 92-95% | Golden Retriever, Labrador, Poodle |
| 🐱 **Cats** | `pet_type: "cat"` | 20 breeds | 88-92% | Siamese, Persian, Maine Coon |

**All endpoints use the same format** - just change the `pet_type` parameter!

### Base URL
```
Local: http://localhost:8080
Ngrok: https://your-ngrok-url.ngrok-free.app
Production: https://your-domain.com
```

---

### 1. Health Check
**Endpoint**: `GET /health`

**Description**: Check if the backend is running and get basic server info

**Response**:
```json
{
  "status": "healthy",
  "timestamp": "2025-10-27T10:30:00Z",
  "version": "1.0.0",
  "uptime": "2h30m45s",
  "model": {
    "name": "ConvNeXt V2 Base - Dog Breed Classifier",
    "pet_type": "dog",
    "version": "1.0",
    "classes": 120,
    "image_size": 384,
    "accuracy": "92-95%",
    "description": "ConvNeXt V2 Base model trained for dog breed classification"
  }
}
```

**Flutter Example**:
```dart
final response = await http.get(
  Uri.parse('$baseUrl/health'),
);
```

---

### 2. Get Model Information
**Endpoint**: `GET /api/v1/model/info?pet_type={dog|cat}`

**Description**: Get detailed information about a specific model

**Query Parameters**:
- `pet_type` (optional): `dog` or `cat` (default: `dog`)

**Response**:
```json
{
  "success": true,
  "model": {
    "name": "ConvNeXt V2 Base - Dog Breed Classifier",
    "pet_type": "dog",
    "version": "1.0",
    "classes": 120,
    "image_size": 384,
    "accuracy": "92-95%",
    "description": "ConvNeXt V2 Base model trained for dog breed classification"
  }
}
```

**Flutter Example**:
```dart
// Get dog model info
final response = await http.get(
  Uri.parse('$baseUrl/api/v1/model/info?pet_type=dog'),
);

// Get cat model info
final response = await http.get(
  Uri.parse('$baseUrl/api/v1/model/info?pet_type=cat'),
);
```

---

### 3. Single Image Prediction 🔥 **MAIN ENDPOINT**
**Endpoint**: `POST /api/v1/predict`

**Description**: Classify a single pet image (dog or cat)

**🐕 For Dogs - Use `"pet_type": "dog"`**  
**🐱 For Cats - Use `"pet_type": "cat"`**

**Request Body**:
```json
{
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
  "pet_type": "dog",
  "use_tta": true,
  "top_k": 5
}
```

**Parameters**:
- `image` (required): Base64 encoded image string (with or without data URL prefix)
- `pet_type` (required): `"dog"` or `"cat"`
- `use_tta` (optional): Enable Test-Time Augmentation for better accuracy (default: `false`)
- `top_k` (optional): Number of top predictions to return (1-10, default: 5)

**Response**:
```json
{
  "success": true,
  "pet_type": "dog",
  "predicted_breed": "Golden Retriever",
  "confidence": 0.9456,
  "top_predictions": [
    {
      "breed": "Golden Retriever",
      "confidence": 0.9456,
      "rank": 1
    },
    {
      "breed": "Labrador Retriever",
      "confidence": 0.0321,
      "rank": 2
    },
    {
      "breed": "Flat Coated Retriever",
      "confidence": 0.0123,
      "rank": 3
    }
  ],
  "process_time_ms": 11234.56,
  "used_tta": true,
  "model_info": {
    "name": "ConvNeXt V2 Base - Dog Breed Classifier",
    "pet_type": "dog",
    "version": "1.0",
    "classes": 120,
    "image_size": 384,
    "accuracy": "92-95%",
    "description": "ConvNeXt V2 Base model trained for dog breed classification"
  }
}
```

**Flutter Example**:
```dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// 🐕 Example 1: Classify a DOG image
Future<void> classifyDog(Uint8List imageBytes) async {
  String imageBase64 = base64Encode(imageBytes);
  
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/predict'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'image': 'data:image/jpeg;base64,$imageBase64',
      'pet_type': 'dog',  // ← For dogs
      'use_tta': true,
      'top_k': 5,
    }),
  );
  
  final result = jsonDecode(response.body);
  if (result['success']) {
    print('Dog Breed: ${result['predicted_breed']}');
    print('Confidence: ${(result['confidence'] * 100).toStringAsFixed(1)}%');
    // Output: "Golden Retriever", "Labrador", etc.
  }
}

// 🐱 Example 2: Classify a CAT image
Future<void> classifyCat(Uint8List imageBytes) async {
  String imageBase64 = base64Encode(imageBytes);
  
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/predict'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'image': 'data:image/jpeg;base64,$imageBase64',
      'pet_type': 'cat',  // ← For cats
      'use_tta': true,
      'top_k': 5,
    }),
  );
  
  final result = jsonDecode(response.body);
  if (result['success']) {
    print('Cat Breed: ${result['predicted_breed']}');
    print('Confidence: ${(result['confidence'] * 100).toStringAsFixed(1)}%');
    // Output: "Siamese", "Persian", "Maine Coon", etc.
  }
}
```

---

### 4. Image URL Prediction
**Endpoint**: `POST /api/v1/predict/url`

**Description**: Classify a pet image from a URL

**Request Body**:
```json
{
  "image_url": "https://example.com/dog-image.jpg",
  "pet_type": "cat",
  "use_tta": false,
  "top_k": 3
}
```

**Parameters**:
- `image_url` (required): Valid HTTP/HTTPS URL to an image
- `pet_type` (required): `"dog"` or `"cat"`
- `use_tta` (optional): Enable Test-Time Augmentation (default: `false`)
- `top_k` (optional): Number of top predictions (1-10, default: 5)

**Response**: Same format as single image prediction

**Flutter Example**:
```dart
final response = await http.post(
  Uri.parse('$baseUrl/api/v1/predict/url'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'image_url': 'https://example.com/cat.jpg',
    'pet_type': 'cat',
    'use_tta': false,
    'top_k': 3,
  }),
);
```

---

### 5. Batch Prediction
**Endpoint**: `POST /api/v1/predict/batch`

**Description**: Classify multiple pet images at once (max 10 images)

**Request Body**:
```json
{
  "images": [
    "data:image/jpeg;base64,/9j/4AAQ...",
    "data:image/jpeg;base64,/9j/4BBR...",
    "data:image/jpeg;base64,/9j/4CCS..."
  ],
  "pet_type": "dog",
  "use_tta": false,
  "top_k": 3
}
```

**Parameters**:
- `images` (required): Array of base64 encoded images (1-10 images)
- `pet_type` (required): `"dog"` or `"cat"` (all images must be same type)
- `use_tta` (optional): Enable TTA (default: `false`, not recommended for batch)
- `top_k` (optional): Number of top predictions per image (default: 5)

**Response**:
```json
{
  "success": true,
  "pet_type": "dog",
  "results": [
    {
      "success": true,
      "pet_type": "dog",
      "predicted_breed": "Beagle",
      "confidence": 0.8921,
      "top_predictions": [...],
      "process_time_ms": 10123.45,
      "used_tta": false,
      "model_info": {...}
    },
    {
      "success": true,
      "pet_type": "dog",
      "predicted_breed": "Pug",
      "confidence": 0.9654,
      "top_predictions": [...],
      "process_time_ms": 9876.54,
      "used_tta": false,
      "model_info": {...}
    }
  ],
  "total_images": 2,
  "total_process_time_ms": 20000.00
}
```

**Flutter Example**:
```dart
List<String> base64Images = imageFiles.map((file) {
  return 'data:image/jpeg;base64,' + base64Encode(file.readAsBytesSync());
}).toList();

final response = await http.post(
  Uri.parse('$baseUrl/api/v1/predict/batch'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'images': base64Images,
    'pet_type': 'dog',
    'use_tta': false,
    'top_k': 3,
  }),
);
```

---

### 6. Get Supported Breeds
**Endpoint**: `GET /api/v1/breeds?pet_type={dog|cat}`

**Description**: Get list of all supported breeds for a pet type

**Query Parameters**:
- `pet_type` (required): `dog` or `cat`

**Response**:
```json
{
  "success": true,
  "pet_type": "dog",
  "total_count": 120,
  "breeds": [
    {
      "id": "n02085620-Chihuahua",
      "name": "Chihuahua",
      "clean_name": "Chihuahua"
    },
    {
      "id": "n02085782-Japanese_spaniel",
      "name": "Japanese Spaniel",
      "clean_name": "Japanese Spaniel"
    }
    // ... more breeds
  ]
}
```

**Flutter Example**:
```dart
// Get dog breeds
final response = await http.get(
  Uri.parse('$baseUrl/api/v1/breeds?pet_type=dog'),
);

// Get cat breeds
final response = await http.get(
  Uri.parse('$baseUrl/api/v1/breeds?pet_type=cat'),
);

final data = jsonDecode(response.body);
List<String> breeds = (data['breeds'] as List)
    .map((b) => b['name'] as String)
    .toList();
```

---

## 🚀 Flutter Integration Guide

### Complete API Service Class

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PawPalApi {
  // IMPORTANT: Update this URL based on your setup
  // Local development: 'http://localhost:8080'
  // Ngrok tunnel: 'https://your-ngrok-url.ngrok-free.app'
  // Production: 'https://your-domain.com'
  static const String baseUrl = 'http://localhost:8080';
  
  /// Convert image file to base64 string
  static String imageToBase64(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
  
  /// Health check
  static Future<Map<String, dynamic>?> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Health check error: $e');
    }
    return null;
  }
  
  /// Get model information
  static Future<Map<String, dynamic>?> getModelInfo(String petType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/model/info?pet_type=$petType'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Get model info error: $e');
    }
    return null;
  }
  
  /// Predict breed from image file
  static Future<Map<String, dynamic>?> predictBreed({
    required File imageFile,
    required String petType, // 'dog' or 'cat'
    bool useTTA = true,
    int topK = 5,
  }) async {
    try {
      final base64Image = imageToBase64(imageFile);
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'pet_type': petType,
          'use_tta': useTTA,
          'top_k': topK,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Prediction failed: ${response.statusCode}');
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Prediction error: $e');
      return null;
    }
  }
  
  /// Predict breed from image URL
  static Future<Map<String, dynamic>?> predictFromUrl({
    required String imageUrl,
    required String petType,
    bool useTTA = false,
    int topK = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/predict/url'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image_url': imageUrl,
          'pet_type': petType,
          'use_tta': useTTA,
          'top_k': topK,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('URL prediction error: $e');
      return null;
    }
  }
  
  /// Batch prediction
  static Future<Map<String, dynamic>?> predictBatch({
    required List<File> imageFiles,
    required String petType,
    bool useTTA = false,
    int topK = 3,
  }) async {
    try {
      if (imageFiles.length > 10) {
        throw Exception('Maximum 10 images allowed');
      }
      
      final base64Images = imageFiles.map((f) => imageToBase64(f)).toList();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/predict/batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'images': base64Images,
          'pet_type': petType,
          'use_tta': useTTA,
          'top_k': topK,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('Batch prediction error: $e');
      return null;
    }
  }
  
  /// Get supported breeds
  static Future<List<Map<String, dynamic>>?> getSupportedBreeds(
    String petType,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/breeds?pet_type=$petType'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['breeds']);
      }
    } catch (e) {
      print('Get breeds error: $e');
    }
    return null;
  }
}
```

### Flutter Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PetBreedScreen extends StatefulWidget {
  @override
  _PetBreedScreenState createState() => _PetBreedScreenState();
}

class _PetBreedScreenState extends State<PetBreedScreen> {
  File? _selectedImage;
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  String _selectedPetType = 'dog'; // 'dog' or 'cat'
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null;
      });
    }
  }
  
  Future<void> _predictBreed() async {
    if (_selectedImage == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final result = await PawPalApi.predictBreed(
        imageFile: _selectedImage!,
        petType: _selectedPetType,
        useTTA: true,
        topK: 5,
      );
      
      setState(() => _result = result);
      
      if (result == null || !result['success']) {
        _showError(result?['message'] ?? 'Prediction failed');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🐾 PawPal - Pet Breed Classifier'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pet type toggle
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Select Pet Type',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'dog',
                          label: Text('🐕 Dog'),
                        ),
                        ButtonSegment(
                          value: 'cat',
                          label: Text('🐱 Cat'),
                        ),
                      ],
                      selected: {_selectedPetType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedPetType = newSelection.first;
                          _result = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Image preview
            if (_selectedImage != null)
              Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            SizedBox(height: 16),
            
            // Pick image button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImage,
              icon: Icon(Icons.photo_library),
              label: Text('Pick Image'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
              ),
            ),
            
            SizedBox(height: 8),
            
            // Predict button
            FilledButton.icon(
              onPressed: (_selectedImage != null && !_isLoading)
                  ? _predictBreed
                  : null,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.pets),
              label: Text(_isLoading ? 'Analyzing...' : 'Predict Breed'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.all(16),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Results
            if (_result != null && _result!['success'] == true) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _result!['predicted_breed'],
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${(_result!['confidence'] * 100).toStringAsFixed(1)}% Confidence',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Processed in ${(_result!['process_time_ms'] / 1000).toStringAsFixed(2)}s',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Predictions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 12),
                      ...(_result!['top_predictions'] as List).map((pred) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${pred['rank']}'),
                          ),
                          title: Text(pred['breed']),
                          trailing: Text(
                            '${(pred['confidence'] * 100).toStringAsFixed(1)}%',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  image_picker: ^1.0.4

dev_dependencies:
  flutter_test:
    sdk: flutter
```

### Android Configuration

**android/app/src/main/AndroidManifest.xml**:
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <application
        android:usesCleartextTraffic="true"
        ...>
    </application>
</manifest>
```

### iOS Configuration

**ios/Runner/Info.plist**:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos to classify pet breeds</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take pet photos</string>
```

---

## 🔧 Configuration

## 🔧 Configuration

### Environment Variables
```bash
# Server Configuration
PORT=8080                          # Server port
ENVIRONMENT=development            # development/production
DEBUG=true                         # Enable debug logging

# Model Configuration  
USE_GPU=true                       # Use GPU for inference (if available)
USE_TTA=true                       # Enable Test-Time Augmentation by default

# Dog Model Paths (can be overridden)
DOG_MODEL_PATH=d:\PawPal\ML_Models\dogs\model\cat_breed_classifier_complete.pth
DOG_CLASS_NAMES_PATH=d:\PawPal\ML_Models\dogs\model\class_names.json

# Cat Model Paths (can be overridden)
CAT_MODEL_PATH=d:\PawPal\ML_Models\cats\model\best_model_stage3.pth
CAT_CLASS_NAMES_PATH=d:\PawPal\ML_Models\cats\model\class_names.json

# Python Configuration
PYTHON_PATH=python                 # Python executable path
PYTHON_SCRIPT_PATH=d:\PawPal\Backend\scripts\python\predict.py
PYTHON_TIMEOUT=30                  # Timeout in seconds
```

### Model Files Location
```
PawPal/
├── ML_Models/
│   ├── dogs/
│   │   └── model/
│   │       ├── cat_breed_classifier_complete.pth (350MB)
│   │       └── class_names.json (120 breeds)
│   └── cats/
│       └── model/
│           ├── best_model_stage3.pth (350MB)
│           └── class_names.json (20 breeds)
└── Backend/
    └── scripts/
        └── python/
            └── predict.py
```

## Project Structure

```
Backend/
├── cmd/api/                 # Main application
│   └── main.go
├── internal/
│   ├── config/             # Configuration management
│   ├── handlers/           # HTTP handlers
│   ├── middleware/         # HTTP middleware
│   ├── models/            # Data structures
│   ├── services/          # Business logic
│   └── utils/             # Utilities
├── pkg/logger/            # Logging package
├── scripts/python/        # Python ML bridge
├── web/                   # Test HTML interface
├── assets/uploads/        # File uploads
├── go.mod                 # Go dependencies
├── requirements.txt       # Python dependencies
└── README.md             # This file
```

## 📊 Performance

- **Inference Time**: 
  - CPU: ~10-12 seconds per prediction (with TTA)
  - GPU: ~3-5 seconds per prediction (with TTA)
  - Without TTA: ~3-4 seconds (CPU), ~1-2 seconds (GPU)
- **Throughput**: ~5-6 images/minute with TTA, ~20 images/minute without TTA
- **Memory Usage**: 
  - CPU: ~1.5GB RAM
  - GPU: ~2GB GPU memory
- **Model Size**: 350MB per model (700MB total for both)
- **Accuracy**: 
  - Dogs: 92-95% (120 breeds)
  - Cats: 88-92% (20 breeds)

## 📸 Supported Image Formats

- **JPEG** (.jpg, .jpeg)
- **PNG** (.png)
- **WebP** (.webp)
- **Maximum size**: 50MB per image
- **Recommended size**: 384x384 to 1024x1024 pixels
- **Aspect ratio**: Any (will be resized to 384x384 internally)

## 🧪 Testing the API

### 1. HTML Test Interface (Recommended)
1. Start the server: `go run cmd/api/main.go`
2. Open browser: http://localhost:8080/test
3. Select pet type (Dog 🐕 or Cat 🐱)
4. Upload an image or paste URL
5. Click "Predict Breed"
6. See results with confidence scores

### 2. Using Ngrok for Mobile Testing
```powershell
# Terminal 1: Start backend
cd d:\PawPal\Backend
go run cmd/api/main.go

# Terminal 2: Start ngrok tunnel
ngrok http 8080

# Copy the https URL (e.g., https://abc123.ngrok-free.app)
# Update your Flutter app's baseUrl to use this URL
```

### 3. Postman Collection
- Import `PawPal_API_Collection.postman_collection.json`
- Set base URL to `http://localhost:8080`
- Test all endpoints with sample data

### 4. cURL Examples

```bash
# Health check
curl http://localhost:8080/health

# Get dog model info
curl "http://localhost:8080/api/v1/model/info?pet_type=dog"

# Get cat model info
curl "http://localhost:8080/api/v1/model/info?pet_type=cat"

# Predict dog breed from URL
curl -X POST http://localhost:8080/api/v1/predict/url \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://example.com/dog.jpg",
    "pet_type": "dog",
    "use_tta": true,
    "top_k": 5
  }'

# Predict cat breed from URL
curl -X POST http://localhost:8080/api/v1/predict/url \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://example.com/cat.jpg",
    "pet_type": "cat",
    "use_tta": true,
    "top_k": 5
  }'

# Get all dog breeds
curl "http://localhost:8080/api/v1/breeds?pet_type=dog"

# Get all cat breeds
curl "http://localhost:8080/api/v1/breeds?pet_type=cat"
```

## ⚠️ Error Handling

The API returns consistent error responses with helpful messages:

### Error Response Format
```json
{
  "success": false,
  "error": "Error description",
  "code": 400
}
```

### Common Error Codes
- **400 Bad Request**: Invalid input (missing pet_type, invalid image, etc.)
- **500 Internal Server Error**: Server or model error
- **413 Payload Too Large**: Image exceeds 50MB limit

### Common Errors and Solutions

#### 1. "Invalid pet type. Must be 'dog' or 'cat'"
```json
{
  "success": false,
  "error": "Invalid pet type. Must be 'dog' or 'cat'",
  "code": 400
}
```
**Solution**: Ensure `pet_type` field is either `"dog"` or `"cat"`

#### 2. "Image validation failed"
```json
{
  "success": false,
  "error": "Image validation failed: invalid base64 encoding",
  "code": 400
}
```
**Solution**: Check base64 encoding is correct, image is valid format (JPEG/PNG)

#### 3. "Prediction failed: failed to execute python script"
```json
{
  "success": false,
  "error": "Prediction failed: failed to execute python script: exit status 1",
  "code": 500
}
```
**Solution**: Check Python dependencies are installed, model files exist

#### 4. "Batch size too large"
```json
{
  "success": false,
  "error": "Batch size too large. Maximum 10 images allowed.",
  "code": 400
}
```
**Solution**: Send maximum 10 images per batch request

### Flutter Error Handling Example

```dart
try {
  final result = await PawPalApi.predictBreed(
    imageFile: imageFile,
    petType: 'dog',
    useTTA: true,
    topK: 5,
  );
  
  if (result == null) {
    // Network error or timeout
    showError('Could not connect to server. Check your connection.');
  } else if (!result['success']) {
    // API returned error
    showError(result['error'] ?? 'Prediction failed');
  } else {
    // Success!
    showResults(result);
  }
} catch (e) {
  // Exception during request
  showError('Unexpected error: $e');
}
```

## 🚀 Development

### Running in Development Mode
```bash
# Set environment variables (Windows PowerShell)
$env:DEBUG="true"
$env:ENVIRONMENT="development"
$env:USE_GPU="false"  # Set to true if you have GPU

# Run the server
cd d:\PawPal\Backend
go run cmd/api/main.go
```

### Building for Production
```bash
# Build executable
cd d:\PawPal\Backend
go build -o pawpal-api.exe cmd/api/main.go

# Run executable
./pawpal-api.exe
```

### Project Structure
```
Backend/
├── cmd/
│   └── api/
│       └── main.go              # Application entry point
├── internal/
│   ├── config/
│   │   └── config.go            # Configuration management
│   ├── handlers/
│   │   └── handlers.go          # HTTP request handlers
│   ├── middleware/
│   │   └── middleware.go        # CORS, logging middleware
│   ├── models/
│   │   └── types.go             # Data models & types
│   ├── services/
│   │   └── prediction.go        # ML prediction service
│   └── utils/
│       └── image.go             # Image processing utilities
├── pkg/
│   └── logger/
│       └── logger.go            # Logging utilities
├── scripts/
│   └── python/
│       └── predict.py           # Python ML bridge script
├── web/
│   └── test.html                # HTML test interface
├── assets/
│   └── uploads/                 # Temporary file uploads
├── go.mod                       # Go dependencies
├── go.sum                       # Go dependency checksums
├── requirements.txt             # Python dependencies
└── README.md                    # This file
```

## 🌐 Deployment Options

### Option 1: Ngrok (For Testing/Development)
```powershell
# Terminal 1: Start backend
cd d:\PawPal\Backend
go run cmd/api/main.go

# Terminal 2: Start ngrok
ngrok http 8080

# Use the https URL in your Flutter app
# Example: https://abc123.ngrok-free.app
```

**Pros**: Instant, free, perfect for testing
**Cons**: URL changes on restart, not for production

### Option 2: Railway.app (Recommended for Production)
```bash
# 1. Create Dockerfile in Backend folder
# 2. Push to GitHub
# 3. Connect Railway to your repo
# 4. Deploy automatically
```

**Pros**: Docker support, $5/month, perfect for ML apps
**Cons**: Requires deployment setup

### Option 3: Google Cloud Run
**Pros**: Pay per use, auto-scaling
**Cons**: Requires Google Cloud account

### Option 4: DigitalOcean App Platform
**Pros**: Simple deployment, $5/month
**Cons**: Limited free tier

## 🔐 Security Considerations

### For Production:
1. **HTTPS Only**: Use SSL/TLS certificates
2. **API Keys**: Implement API key authentication
3. **Rate Limiting**: Limit requests per user/IP
4. **Input Validation**: Validate all inputs thoroughly
5. **CORS**: Configure proper CORS policies
6. **File Size Limits**: Enforce max upload size (50MB)
7. **Environment Variables**: Never commit secrets to Git

## Flutter Integration

This backend is designed to work seamlessly with Flutter mobile apps. Here's how to integrate it:

### 1. API Base Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'http://your-server:8080'; // Change for production
  static const String apiVersion = 'v1';
  
  // Endpoints
  static const String health = '/health';
  static const String modelInfo = '/api/$apiVersion/model/info';
  static const String predict = '/api/$apiVersion/predict';
  static const String predictUrl = '/api/$apiVersion/predict/url';
  static const String predictBatch = '/api/$apiVersion/predict/batch';
  static const String breeds = '/api/$apiVersion/breeds';
}
```

### 2. API Service Class

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class PawPalApiService {
  static const String _baseUrl = ApiConfig.baseUrl;
  
  // Convert image to base64
  static String imageToBase64(File imageFile) {
    Uint8List imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64Image';
  }
  
  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl${ApiConfig.health}'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Get model information
  static Future<Map<String, dynamic>?> getModelInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.modelInfo}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting model info: $e');
      return null;
    }
  }
  
  // Single image prediction
  static Future<Map<String, dynamic>?> predictBreed({
    required File imageFile,
    bool useTTA = true,
    int topK = 5,
  }) async {
    try {
      String base64Image = imageToBase64(imageFile);
      
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.predict}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'use_tta': useTTA,
          'top_k': topK,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Prediction failed: ${response.statusCode}');
        return jsonDecode(response.body); // May contain error info
      }
    } catch (e) {
      print('Error predicting breed: $e');
      return null;
    }
  }
  
  // URL-based prediction
  static Future<Map<String, dynamic>?> predictFromUrl({
    required String imageUrl,
    bool useTTA = true,
    int topK = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.predictUrl}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image_url': imageUrl,
          'use_tta': useTTA,
          'top_k': topK,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('Error predicting from URL: $e');
      return null;
    }
  }
  
  // Batch prediction
  static Future<Map<String, dynamic>?> predictBatch({
    required List<File> imageFiles,
    bool useTTA = false, // Usually disabled for batch to save time
    int topK = 3,
  }) async {
    try {
      List<String> base64Images = imageFiles
          .map((file) => imageToBase64(file))
          .toList();
      
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.predictBatch}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'images': base64Images,
          'use_tta': useTTA,
          'top_k': topK,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('Error in batch prediction: $e');
      return null;
    }
  }
  
  // Get supported breeds
  static Future<List<String>?> getSupportedBreeds() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.breeds}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return List<String>.from(data['breeds']);
      }
      return null;
    } catch (e) {
      print('Error getting breeds: $e');
      return null;
    }
  }
}
```

### 3. Response Models

```dart
class PredictionResult {
  final bool success;
  final String? predicted;
  final double? confidence;
  final List<BreedPrediction> predictions;
  final double processTime;
  final bool usedTTA;
  final String? message;
  
  PredictionResult({
    required this.success,
    this.predicted,
    this.confidence,
    required this.predictions,
    required this.processTime,
    required this.usedTTA,
    this.message,
  });
  
  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      success: json['success'] ?? false,
      predicted: json['predicted'],
      confidence: json['confidence']?.toDouble(),
      predictions: (json['predictions'] as List?)
          ?.map((p) => BreedPrediction.fromJson(p))
          .toList() ?? [],
      processTime: json['process_time']?.toDouble() ?? 0.0,
      usedTTA: json['used_tta'] ?? false,
      message: json['message'],
    );
  }
}

class BreedPrediction {
  final String breed;
  final double confidence;
  final int rank;
  
  BreedPrediction({
    required this.breed,
    required this.confidence,
    required this.rank,
  });
  
  factory BreedPrediction.fromJson(Map<String, dynamic> json) {
    return BreedPrediction(
      breed: json['breed'] ?? '',
      confidence: json['confidence']?.toDouble() ?? 0.0,
      rank: json['rank'] ?? 0,
    );
  }
}
```

### 4. Flutter Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DogBreedScreen extends StatefulWidget {
  @override
  _DogBreedScreenState createState() => _DogBreedScreenState();
}

class _DogBreedScreenState extends State<DogBreedScreen> {
  File? _selectedImage;
  PredictionResult? _result;
  bool _isLoading = false;
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null;
      });
    }
  }
  
  Future<void> _predictBreed() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await PawPalApiService.predictBreed(
        imageFile: _selectedImage!,
        useTTA: true,
        topK: 5,
      );
      
      if (response != null) {
        setState(() {
          _result = PredictionResult.fromJson(response);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dog Breed Classifier')),
      body: Column(
        children: [
          if (_selectedImage != null)
            Image.file(_selectedImage!, height: 300),
          
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
          
          ElevatedButton(
            onPressed: _selectedImage != null && !_isLoading 
                ? _predictBreed 
                : null,
            child: _isLoading 
                ? CircularProgressIndicator() 
                : Text('Predict Breed'),
          ),
          
          if (_result != null && _result!.success)
            Expanded(
              child: ListView.builder(
                itemCount: _result!.predictions.length,
                itemBuilder: (context, index) {
                  final prediction = _result!.predictions[index];
                  return ListTile(
                    title: Text(prediction.breed),
                    subtitle: Text('${(prediction.confidence * 100).toStringAsFixed(1)}%'),
                    leading: CircleAvatar(
                      child: Text('${prediction.rank}'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
```

### 5. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  image_picker: ^1.0.4
  
dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 6. Network Configuration

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- For HTTP traffic in debug mode -->
<application
    android:usesCleartextTraffic="true"
    ... >
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 7. Error Handling

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ApiException: $message';
}

// Enhanced API calls with better error handling
static Future<PredictionResult> predictBreedSafe({
  required File imageFile,
  bool useTTA = true,
  int topK = 5,
}) async {
  try {
    final response = await predictBreed(
      imageFile: imageFile,
      useTTA: useTTA,
      topK: topK,
    );
    
    if (response == null) {
      throw ApiException('No response from server');
    }
    
    return PredictionResult.fromJson(response);
  } catch (e) {
    throw ApiException('Prediction failed: $e');
  }
}
```

### 8. Production Deployment

For production, update the base URL:
```dart
static const String baseUrl = 'https://your-domain.com'; // Your production server
```

### 9. Testing the Integration

1. Start the Go backend server
2. Ensure your Flutter app can reach the server
3. Test with sample dog images
4. Monitor logs for debugging

This integration provides a complete bridge between your Flutter mobile app and the Go backend API for seamless dog breed classification!

## Troubleshooting

### Common Issues

1. **Python Script Fails**
   - Ensure all Python packages are installed
   - Check Python path in configuration
   - Verify model files exist

2. **Model Loading Errors**
   - Check model file paths
   - Ensure sufficient disk space
   - Verify PyTorch installation

3. **GPU Issues**
   - Install CUDA-compatible PyTorch
   - Set `USE_GPU=false` for CPU-only mode

### Logs
Enable debug logging with `DEBUG=true` to see detailed information.

## License

This project is part of the PawPal application suite.

## Model Information

- **Architecture**: ConvNeXt V2 Base
- **Parameters**: 88M
- **Training Dataset**: Stanford Dogs Dataset
- **Classes**: 120 dog breeds
- **Accuracy**: 92-95%
- **Input Size**: 384x384 pixels