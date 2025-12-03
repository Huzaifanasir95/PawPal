import '../config/app_config.dart';

/// API Configuration for PawPal Backend
class ApiConfig {
  ApiConfig._();

  // Base URL - Automatically configured based on environment
  static String get baseUrl => AppConfig.backendBaseUrl;
  
  static const String apiVersion = 'v1';
  
  // Endpoints
  static const String health = '/health';
  static const String modelInfo = '/api/$apiVersion/model/info';
  static const String predict = '/api/$apiVersion/predict';
  static const String predictUrl = '/api/$apiVersion/predict/url';
  static const String predictBatch = '/api/$apiVersion/predict/batch';
  static const String breeds = '/api/$apiVersion/breeds';
  
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
