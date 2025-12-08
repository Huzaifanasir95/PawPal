import 'package:flutter/foundation.dart';

/// App Configuration
/// Change these values based on your environment
class AppConfig {
  AppConfig._();

  /// Backend API Base URL
  /// 
  /// Development with ngrok:
  /// - Set the ngrok URL here: 'https://your-ngrok-url.ngrok.io'
  /// - Get URL from: ngrok http 8081
  /// 
  /// Development (local):
  /// - Local: 'http://localhost:8081'
  /// - Android Emulator: 'http://10.0.2.2:8081'
  /// - iOS Simulator: 'http://localhost:8081'
  /// - Physical Device: 'http://YOUR_LOCAL_IP:8081' (e.g., 'http://192.168.1.100:8081')
  /// 
  /// Production:
  /// - Use your production server URL: 'https://api.yoursite.com'
  
  /// 🎯 UPDATE THIS TO YOUR NGROK URL FOR EMULATOR TESTING
  /// Replace with your ngrok URL from: ngrok http 8081
  static const String ngrokUrl = 'https://terminational-severer-aubrianna.ngrok-free.dev'; // ngrok URL for emulator

  static String get backendBaseUrl {
    // If ngrok URL is configured, use it (works for emulator, device, and simulator)
    if (ngrokUrl.isNotEmpty) {
      return ngrokUrl;
    }

    if (kDebugMode) {
      // Development mode (without ngrok)
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
      return 'https://api.pawpawl.com'; // Replace with your production URL
    }
  }

  /// For physical devices in development (local network), uncomment and set your local IP address
  // static const String developmentPhysicalDeviceUrl = 'http://192.168.1.100:8081';
}

