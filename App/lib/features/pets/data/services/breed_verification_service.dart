import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/api_config.dart';
import '../models/breed_prediction_model.dart';

class BreedVerificationService {
  final Dio _dio;

  BreedVerificationService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              sendTimeout: ApiConfig.sendTimeout,
              headers: {'Content-Type': 'application/json'},
            ),
          ) {
    // Add logging interceptor to display all API calls
    _dio.interceptors.add(LoggingInterceptor());
  }

  /// Convert image file to base64
  Future<String> _imageToBase64(XFile imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64Image';
  }

  /// Health check
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(ApiConfig.health);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get model information for a specific pet type
  Future<Map<String, dynamic>?> getModelInfo({
    String petType = 'dog', // 'dog' or 'cat'
  }) async {
    try {
      // Validate pet type
      if (!['dog', 'cat'].contains(petType.toLowerCase())) {
        print('Invalid pet type. Must be "dog" or "cat"');
        return null;
      }

      final response = await _dio.get(
        '${ApiConfig.modelInfo}?pet_type=${petType.toLowerCase()}',
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error getting model info: $e');
      return null;
    }
  }

  /// Single image prediction - Supports both dogs and cats
  Future<PredictionResult> predictBreed({
    required XFile imageFile,
    String petType = 'dog', // 'dog' or 'cat'
    bool useTTA = true,
    int topK = 5,
  }) async {
    try {
      String base64Image = await _imageToBase64(imageFile);

      // Validate pet type
      if (!['dog', 'cat'].contains(petType.toLowerCase())) {
        return PredictionResult(
          success: false,
          error: 'Invalid pet type. Must be "dog" or "cat"',
        );
      }

      print(
        "post body : image length: ${base64Image.length}, petType: $petType, useTTA: $useTTA, topK: $topK",
      );
      final response = await _dio.post(
        ApiConfig.predict,
        data: {
          'image': base64Image,
          'pet_type': petType.toLowerCase(),
          'use_tta': useTTA,
          'top_k': topK,
        },
      );

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(response.data);
      } else {
        return PredictionResult(
          success: false,
          error: 'Prediction failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return PredictionResult(
        success: false,
        error: 'Network error: ${e.message}',
      );
    } catch (e) {
      return PredictionResult(
        success: false,
        error: 'Error predicting breed: $e',
      );
    }
  }

  /// URL-based prediction - Supports both dogs and cats
  Future<PredictionResult> predictFromUrl({
    required String imageUrl,
    String petType = 'dog', // 'dog' or 'cat'
    bool useTTA = true,
    int topK = 1,
  }) async {
    try {
      // Validate pet type
      if (!['dog', 'cat'].contains(petType.toLowerCase())) {
        return PredictionResult(
          success: false,
          error: 'Invalid pet type. Must be "dog" or "cat"',
        );
      }

      final response = await _dio.post(
        ApiConfig.predictUrl,
        data: {
          'image_url': imageUrl,
          'pet_type': petType.toLowerCase(),
          'use_tta': useTTA,
          'top_k': topK,
        },
      );

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(response.data);
      } else {
        return PredictionResult(
          success: false,
          error: 'Prediction failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return PredictionResult(
        success: false,
        error: 'Network error: ${e.message}',
      );
    } catch (e) {
      return PredictionResult(
        success: false,
        error: 'Error predicting from URL: $e',
      );
    }
  }

  /// Batch prediction - Supports both dogs and cats
  Future<PredictionResult> predictBatch({
    required List<XFile> imageFiles,
    String petType = 'dog', // 'dog' or 'cat'
    bool useTTA = false,
    int topK = 3,
  }) async {
    try {
      // Validate pet type
      if (!['dog', 'cat'].contains(petType.toLowerCase())) {
        return PredictionResult(
          success: false,
          error: 'Invalid pet type. Must be "dog" or "cat"',
        );
      }

      final base64Images = <String>[];
      for (final file in imageFiles) {
        base64Images.add(await _imageToBase64(file));
      }

      final response = await _dio.post(
        ApiConfig.predictBatch,
        data: {
          'images': base64Images,
          'pet_type': petType.toLowerCase(),
          'use_tta': useTTA,
          'top_k': topK,
        },
      );

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(response.data);
      } else {
        return PredictionResult(
          success: false,
          error: 'Batch prediction failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return PredictionResult(
        success: false,
        error: 'Network error: ${e.message}',
      );
    } catch (e) {
      return PredictionResult(
        success: false,
        error: 'Error in batch prediction: $e',
      );
    }
  }

  /// Get supported breeds for a specific pet type
  Future<List<String>?> getSupportedBreeds({
    String petType = 'dog', // 'dog' or 'cat'
  }) async {
    try {
      // Validate pet type
      if (!['dog', 'cat'].contains(petType.toLowerCase())) {
        print('Invalid pet type. Must be "dog" or "cat"');
        return null;
      }

      final response = await _dio.get(
        '${ApiConfig.breeds}?pet_type=${petType.toLowerCase()}',
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return List<String>.from(data['breeds']);
      }
      return null;
    } catch (e) {
      print('Error getting breeds: $e');
      return null;
    }
  }
}

/// Custom Dio Logging Interceptor
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print(
      '╔════════════════════════════════════════════════════════════════════',
    );
    print('║ 🚀 API REQUEST');
    print(
      '╠════════════════════════════════════════════════════════════════════',
    );
    print('║ Method: ${options.method}');
    print('║ URL: ${options.baseUrl}${options.path}');
    print('║ Endpoint: ${options.path}');

    if (options.queryParameters.isNotEmpty) {
      print('║ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        print('║   • $key: $value');
      });
    }

    print('║ Headers:');
    options.headers.forEach((key, value) {
      if (key.toLowerCase() == 'content-type') {
        print('║   • $key: $value');
      }
    });

    if (options.data != null) {
      print('║ Request Body:');
      if (options.data is Map) {
        final data = options.data as Map<String, dynamic>;
        data.forEach((key, value) {
          if (key == 'image' && value is String && value.length > 100) {
            // For base64 images, show truncated version
            final imagePreview = value.substring(0, 100);
            print('║   • $key: $imagePreview... (${value.length} chars)');
          } else if (key == 'images' && value is List) {
            print('║   • $key: [List of ${value.length} images]');
          } else {
            print('║   • $key: $value');
          }
        });
      } else {
        print('║   • ${options.data}');
      }
    }

    print(
      '║ Timeout: ${options.connectTimeout?.inSeconds}s (connect), '
      '${options.receiveTimeout?.inSeconds}s (receive), '
      '${options.sendTimeout?.inSeconds}s (send)',
    );
    print(
      '╚════════════════════════════════════════════════════════════════════',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '╔════════════════════════════════════════════════════════════════════',
    );
    print('║ ✅ API RESPONSE');
    print(
      '╠════════════════════════════════════════════════════════════════════',
    );
    print(
      '║ Status Code: ${response.statusCode} ${response.statusMessage ?? ''}',
    );
    print('║ URL: ${response.requestOptions.path}');
    print('║ Response Time: ${DateTime.now().millisecondsSinceEpoch}ms');

    try {
      print('║ Response Headers:');
      response.headers.forEach((key, values) {
        if (key.toLowerCase().contains('content')) {
          print('║   • $key: ${values.join(', ')}');
        }
      });
    } catch (e) {
      // Headers might be empty, ignore
    }

    print('║ Response Body:');
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;

      // Special formatting for breed prediction responses
      if (data.containsKey('success') && data.containsKey('predictions')) {
        print('║   • success: ${data['success']}');
        print('║   • predicted: ${data['predicted']}');
        print(
          '║   • confidence: ${data['confidence']} (${(data['confidence'] * 100).toStringAsFixed(2)}%)',
        );
        print('║   • process_time: ${data['process_time']}s');
        print('║   • used_tta: ${data['used_tta']}');
        print('║ Top Predictions:');
        if (data['predictions'] is List) {
          final predictions = data['predictions'] as List;
          for (int i = 0; i < predictions.length; i++) {
            final pred = predictions[i];
            final breed = pred['breed'] ?? 'Unknown';
            final conf = pred['confidence'] ?? 0;
            final rank = pred['rank'] ?? i + 1;
            print('║   $rank. $breed: ${(conf * 100).toStringAsFixed(2)}%');
          }
        }
      } else {
        // Generic response formatting
        data.forEach((key, value) {
          if (value is List && value.length > 5) {
            print('║   • $key: [List with ${value.length} items]');
          } else if (value.toString().length > 100) {
            print('║   • $key: ${value.toString().substring(0, 100)}...');
          } else {
            print('║   • $key: $value');
          }
        });
      }
    } else if (response.data is String) {
      print('║   • ${response.data}');
    } else {
      print('║   • ${response.data}');
    }

    print(
      '╚════════════════════════════════════════════════════════════════════',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      '╔════════════════════════════════════════════════════════════════════',
    );
    print('║ ❌ API ERROR');
    print(
      '╠════════════════════════════════════════════════════════════════════',
    );
    print('║ Type: ${err.type}');
    print('║ URL: ${err.requestOptions.path}');
    print('║ Status Code: ${err.response?.statusCode ?? 'N/A'}');
    print('║ Message: ${err.message}');

    if (err.response?.data != null) {
      print('║ Error Response:');
      if (err.response?.data is Map) {
        final data = err.response?.data as Map<String, dynamic>;
        data.forEach((key, value) {
          print('║   • $key: $value');
        });
      } else {
        print('║   • ${err.response?.data}');
      }
    }

    print(
      '║ Request Path: ${err.requestOptions.baseUrl}${err.requestOptions.path}',
    );
    print('║ Method: ${err.requestOptions.method}');
    print(
      '╚════════════════════════════════════════════════════════════════════',
    );

    handler.next(err);
  }
}
