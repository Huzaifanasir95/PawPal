import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/api_client.dart';
import '../models/auth_user.dart';

@lazySingleton
class AuthRepository {
  final ApiClient _apiClient = ApiClient.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  AuthUser? _currentUser;
  final StreamController<AuthUser?> _authStateController = StreamController<AuthUser?>.broadcast();

  // Get current user
  AuthUser? get currentUser => _currentUser;

  // Stream of auth state changes
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  // Initialize - load tokens and user from storage
  Future<void> initialize() async {
    _debugLog('🔐 AUTH: Initializing auth repository...');
    await _apiClient.loadTokens();
    _debugLog('🔐 AUTH: Tokens loaded. isAuthenticated: ${_apiClient.isAuthenticated}');
    
    if (_apiClient.isAuthenticated) {
      try {
        _debugLog('🔐 AUTH: Loading user profile...');
        final user = await getUserProfile();
        if (user != null) {
          _currentUser = user;
          _debugLog('🔐 AUTH: User loaded: ${user.email}');
          _authStateController.add(_currentUser);
        } else {
          // Token might be invalid
          _debugLog('🔐 AUTH: Failed to load user profile, clearing tokens');
          await _apiClient.clearTokens();
          _authStateController.add(null);
        }
      } catch (e) {
        _debugLog('🔐 AUTH: Failed to load user profile: $e');
        await _apiClient.clearTokens();
        _authStateController.add(null);
      }
    } else {
      _debugLog('🔐 AUTH: No authentication tokens found');
      _authStateController.add(null);
    }
  }

  // Sign in with email and password
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final response = await _apiClient.post('/api/v1/auth/signin', data: {
        'email': normalizedEmail,
        'password': password,
      });

      final authResponse = _parseAuthResponse(response.data);
      await _handleAuthSuccess(authResponse);
      return _currentUser!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Sign up with email and password
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? accountType,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final response = await _apiClient.post('/api/v1/auth/signup', data: {
        'email': normalizedEmail,
        'password': password,
        if (displayName != null) 'displayName': displayName,
        if (accountType != null) 'accountType': _normalizeAccountType(accountType),
      });

      final authResponse = _parseAuthResponse(response.data);
      await _handleAuthSuccess(authResponse);
      return _currentUser!;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle({
    required String idToken,
    String? displayName,
    String? photoUrl,
    String? accountType,
  }) async {
    try {
      _debugLog('🔐 signInWithGoogle called with accountType: $accountType');
      // Send the ID token to our backend
      final response = await _apiClient.post('/api/v1/auth/google', data: {
        'idToken': idToken,
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (accountType != null) 'accountType': accountType,
      });

      final authResponse = _parseAuthResponse(response.data);
      
      // If accountType was provided, this is completing registration - always save auth
      // If no accountType and isNewUser=true, skip saving (they need to select account type)
      if (accountType != null || !authResponse.isNewUser) {
        _debugLog('💾 Saving auth tokens and user data');
        await _handleAuthSuccess(authResponse);
      } else {
        _debugLog('⏸️ Skipping auth save - user needs to select account type');
      }
      
      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw 'Failed to sign in with Google: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    _debugLog('Starting sign out process');

    // Try to sign out from backend, but continue regardless.
    try {
      await _apiClient.post('/api/v1/auth/signout', data: {});
    } catch (e) {
      _debugLog('Backend signout error (continuing anyway): $e');
    }

    // Google sign out can fail for non-Google users; do not block local logout.
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      _debugLog('Google signout error (continuing anyway): $e');
    }

    await _apiClient.clearTokens();
    _currentUser = null;
    _authStateController.add(null);

    _debugLog('Sign out completed successfully');
  }

  // Reset password - request OTP/token (returns token for dev; in prod the token is emailed)
  Future<String> resetPassword(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final response = await _apiClient.post('/api/v1/auth/password/reset-request', data: {
        'email': normalizedEmail,
      });
      // Backend returns reset_token in data (dev mode); in prod this comes via email
      final data = response.data as Map<String, dynamic>;
      final token = (data['data'] as Map<String, dynamic>?)?['reset_token'] as String? ?? '';
      return token;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Confirm password reset with token + new password
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post('/api/v1/auth/password/reset', data: {
        'token': token,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Update user account type
  Future<void> updateAccountType(String accountType) async {
    try {
      final normalizedAccountType = _normalizeAccountType(accountType);
      await _apiClient.put('/api/v1/profile', data: {
        'accountType': normalizedAccountType,
      });
      
      if (_currentUser != null) {
        _currentUser = AuthUser(
          id: _currentUser!.id,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          accountType: normalizedAccountType,
          photoUrl: _currentUser!.photoUrl,
          createdAt: _currentUser!.createdAt,
          updatedAt: DateTime.now(),
        );
        _authStateController.add(_currentUser);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Set user role (vet or petowner)
  Future<void> setUserRole(String role) async {
    try {
      final normalizedRole = _normalizeAccountType(role);
      final response = await _apiClient.post('/api/v1/auth/set-role', data: {
        'role': normalizedRole,
      });
      
      if (response.data['success'] == true) {
        // Reload user profile to get updated role
        final user = await getUserProfile();
        if (user != null) {
          _currentUser = user;
          _authStateController.add(_currentUser);
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to set user role');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Get user account type
  Future<String?> getAccountType() async {
    if (_currentUser != null) {
      return _currentUser!.accountType;
    }
    
    try {
      final user = await getUserProfile();
      return user?.accountType;
    } catch (e) {
      _debugLog('Error getting account type: $e');
      return null;
    }
  }

  // Get user profile from backend
  Future<AuthUser?> getUserProfile() async {
    try {
      final response = await _apiClient.get('/api/v1/profile');
      
      if (response.statusCode == 200) {
        // API returns {success: true, data: {...}} or {success: true, user: {...}}
        final userData = response.data['data'] ?? response.data['user'];
        
        if (userData != null) {
          final rawAccountType = userData['accountType'] ?? userData['account_type'];
          return AuthUser(
            id: userData['uid'] ?? userData['id'],
            email: userData['email'],
            displayName: userData['displayName'],
            accountType: _normalizeAccountType(rawAccountType),
            photoUrl: userData['avatarUrl'],
            createdAt: userData['createdAt'] != null ? DateTime.parse(userData['createdAt']) : null,
            updatedAt: userData['updatedAt'] != null ? DateTime.parse(userData['updatedAt']) : null,
          );
        }
      }
      return null;
    } catch (e) {
      _debugLog('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? accountType,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['displayName'] = displayName;
      if (accountType != null) data['accountType'] = _normalizeAccountType(accountType);
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

      await _apiClient.put('/api/v1/profile', data: data);

      // Update local user
      if (_currentUser != null) {
        final normalizedAccountType = accountType != null
            ? _normalizeAccountType(accountType)
            : null;
        _currentUser = AuthUser(
          id: _currentUser!.id,
          email: _currentUser!.email,
          displayName: displayName ?? _currentUser!.displayName,
          accountType: normalizedAccountType ?? _currentUser!.accountType,
          photoUrl: avatarUrl ?? _currentUser!.photoUrl,
          createdAt: _currentUser!.createdAt,
          updatedAt: DateTime.now(),
        );
        _authStateController.add(_currentUser);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Helper: Parse auth response
  AuthResponse _parseAuthResponse(Map<String, dynamic> data) {
    final user = data['user'];
    final isNewUser = data['isNewUser'] ?? false;
    final rawAccountType = user['accountType'] ?? user['account_type'];
    
    return AuthResponse(
      user: AuthUser(
        id: user['uid'] ?? user['id'] ?? '',
        email: user['email'] ?? '',
        displayName: user['displayName'],
        accountType: _normalizeAccountType(rawAccountType),
        photoUrl: user['avatarUrl'],
        createdAt: user['createdAt'] != null && user['createdAt'] != '0001-01-01T00:00:00Z' 
            ? DateTime.parse(user['createdAt']) 
            : null,
        updatedAt: user['updatedAt'] != null && user['updatedAt'] != '0001-01-01T00:00:00Z'
            ? DateTime.parse(user['updatedAt']) 
            : null,
      ),
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
      isNewUser: isNewUser,
    );
  }

  // Helper: Handle successful auth
  Future<void> _handleAuthSuccess(AuthResponse authResponse) async {
    _debugLog('🎯 _handleAuthSuccess: Saving tokens and updating user');
    await _apiClient.setTokens(authResponse.accessToken, authResponse.refreshToken);
    _currentUser = authResponse.user;
    _debugLog('📢 Broadcasting auth state: ${_currentUser!.email}');
    _authStateController.add(_currentUser);
    _debugLog('✅ Auth state broadcasted');
  }

  // Helper: Handle Dio errors
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        return data['message'];
      }
      switch (e.response!.statusCode) {
        case 400:
          return 'Invalid request';
        case 401:
          return 'Invalid email or password';
        case 409:
          return 'An account with this email already exists';
        case 500:
          return 'Server error. Please try again later';
        default:
          return 'Something went wrong';
      }
    }
    return 'Network error. Please check your connection';
  }

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  String? _normalizeAccountType(dynamic accountType) {
    if (accountType == null) return null;

    final normalized = accountType.toString().trim().toLowerCase();
    switch (normalized) {
      case 'pet_owner':
      case 'petowner':
      case 'pet-owner':
      case 'pet owner':
      case 'owner':
        return 'pet_owner';
      case 'vet':
      case 'veterinarian':
      case 'veterinary':
        return 'vet';
      case 'seller':
      case 'vendor':
      case 'merchant':
      case 'shop_owner':
      case 'shop owner':
      case 'shopowner':
        return 'seller';
      case 'caregiver':
      case 'care_giver':
      case 'pet_caregiver':
        return 'caregiver';
      default:
        return normalized;
    }
  }

  // Dispose
  void dispose() {
    _authStateController.close();
  }
}