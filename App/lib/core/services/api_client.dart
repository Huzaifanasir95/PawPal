import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/app_config.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  String? _accessToken;
  String? _refreshToken;
  String? _userId;

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.backendBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptor for auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        print('📤 [${options.method}] ${options.path}');
        if (options.data != null) {
          print('   Data: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ [${response.statusCode}] ${response.requestOptions.path}');
        print('   Response: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('❌ [${error.response?.statusCode}] ${error.requestOptions.path}');
        print('   Error: ${error.message}');
        if (error.response?.data != null) {
          print('   Error Data: ${error.response?.data}');
        }
        
        // If 401, try to refresh token
        if (error.response?.statusCode == 401 && _refreshToken != null) {
          try {
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              // Retry the request
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $_accessToken';
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            }
          } catch (e) {
            // Refresh failed, logout
            await clearTokens();
          }
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  // Token management
  Future<void> setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    
    // Extract user ID from JWT token
    try {
      final decoded = JwtDecoder.decode(accessToken);
      _userId = decoded['user_id'] as String?;
    } catch (e) {
      // Handle JWT decode error silently
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    if (_userId != null) {
      await prefs.setString('user_id', _userId!);
    }
  }

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _userId = prefs.getString('user_id');
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
  }

  bool get isAuthenticated => _accessToken != null;

  String? get accessToken => _accessToken;
  
  String? get userId => _userId;

  Future<bool> _refreshAccessToken() async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': _refreshToken},
        options: Options(headers: {}), // Don't include auth header
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        
        return true;
      }
    } catch (e) {
      // Handle refresh error silently
    }
    return false;
  }

  // API Methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}
