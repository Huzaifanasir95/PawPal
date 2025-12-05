import 'package:flutter/foundation.dart';

/// App Configuration
/// Change these values based on your environment
class AppConfig {
  AppConfig._();

  /// Backend API Base URL
  /// 
  /// Development:
  /// - Local: 'http://localhost:8081'
  /// - Android Emulator: 'http://10.0.2.2:8081'
  /// - iOS Simulator: 'http://localhost:8081'
  /// - Physical Device: 'http://YOUR_LOCAL_IP:8081' (e.g., 'http://192.168.1.100:8081')
  /// 
  /// Production:
  /// - Use your production server URL: 'https://api.yoursite.com'
  static String get backendBaseUrl {
    if (kDebugMode) {
      // Development mode
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Android emulator
        return 'http://10.0.2.2:8081';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS simulator
        return 'http://localhost:8081';
      } else {
        // Default for other platforms
        return 'http://localhost:8081';
      }
    } else {
      // Production mode - Change this to your production URL
      return 'http://localhost:8081';
    }
  }

  /// For physical devices in development, override the URL here
  /// Uncomment and set your local IP address
  // static const String developmentPhysicalDeviceUrl = 'http://192.168.1.100:8081';
}
