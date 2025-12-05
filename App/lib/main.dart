import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app/app.dart';
import 'core/di/service_locator.dart';
import 'core/services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API client and load stored tokens
  await ApiClient.instance.loadTokens();
  
  // Initialize dependency injection
  await configureDependencies();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const PawPawlApp());
}
