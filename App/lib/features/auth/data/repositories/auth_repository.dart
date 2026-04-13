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
  GoogleSignIn? _googleSignIn;

  AuthUser? _currentUser;
  List<String> _assignedRoles = const [];
  String? _activeRole;
  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  // Get current user
  AuthUser? get currentUser => _currentUser;
  List<String> get assignedRoles => List.unmodifiable(_assignedRoles);
  String? get activeRole => _activeRole;

  // Stream of auth state changes
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  // Initialize - load tokens and user from storage
  Future<void> initialize() async {
    _debugLog('🔐 AUTH: Initializing auth repository...');
    await _apiClient.loadTokens();
    _debugLog(
      '🔐 AUTH: Tokens loaded. isAuthenticated: ${_apiClient.isAuthenticated}',
    );

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
          _assignedRoles = const [];
          _activeRole = null;
          _authStateController.add(null);
        }
      } catch (e) {
        _debugLog('🔐 AUTH: Failed to load user profile: $e');
        await _apiClient.clearTokens();
        _assignedRoles = const [];
        _activeRole = null;
        _authStateController.add(null);
      }
    } else {
      _debugLog('🔐 AUTH: No authentication tokens found');
      _assignedRoles = const [];
      _activeRole = null;
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
      final response = await _apiClient.post(
        '/api/v1/auth/signin',
        data: {'email': normalizedEmail, 'password': password},
      );

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
      final response = await _apiClient.post(
        '/api/v1/auth/signup',
        data: {
          'email': normalizedEmail,
          'password': password,
          if (displayName != null) 'displayName': displayName,
          if (accountType != null)
            'accountType': _normalizeAccountType(accountType),
        },
      );

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
      final response = await _apiClient.post(
        '/api/v1/auth/google',
        data: {
          'idToken': idToken,
          if (displayName != null) 'displayName': displayName,
          if (photoUrl != null) 'photoUrl': photoUrl,
          if (accountType != null) 'accountType': accountType,
        },
      );

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
    if (_googleSignIn != null) {
      try {
        await _googleSignIn!.signOut();
      } catch (e) {
        _debugLog('Google signout error (continuing anyway): $e');
      }
    }

    await _apiClient.clearTokens();
    _currentUser = null;
    _assignedRoles = const [];
    _activeRole = null;
    _authStateController.add(null);

    _debugLog('Sign out completed successfully');
  }

  // Reset password - request OTP/token (returns token for dev; in prod the token is emailed)
  Future<String> resetPassword(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final response = await _apiClient.post(
        '/api/v1/auth/password/reset-request',
        data: {'email': normalizedEmail},
      );
      // Backend returns reset_token in data (dev mode); in prod this comes via email
      final data = response.data as Map<String, dynamic>;
      final token =
          (data['data'] as Map<String, dynamic>?)?['reset_token'] as String? ??
          '';
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
      await _apiClient.post(
        '/api/v1/auth/password/reset',
        data: {'token': token, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Update user account type
  Future<void> updateAccountType(String accountType) async {
    final normalizedAccountType = _normalizeAccountType(accountType);
    if (normalizedAccountType == null || normalizedAccountType.isEmpty) {
      throw 'Invalid account type';
    }

    await addUserRole(normalizedAccountType);
    await switchRole(normalizedAccountType);
  }

  // Legacy compatibility wrapper for role switching.
  Future<void> setUserRole(String role) async {
    final normalizedRole = _normalizeAccountType(role);
    if (normalizedRole == null || normalizedRole.isEmpty) {
      throw 'Invalid role';
    }

    await addUserRole(normalizedRole);
    await switchRole(normalizedRole);
  }

  // Get all roles assigned to current user.
  Future<List<String>> getUserRoles({bool forceRefresh = false}) async {
    if (!forceRefresh && _assignedRoles.isNotEmpty) {
      return List<String>.from(_assignedRoles);
    }

    try {
      final response = await _apiClient.get('/api/v1/user/roles');
      if (response.data['success'] == true) {
        final payload =
            response.data['data'] as Map<String, dynamic>? ??
            <String, dynamic>{};
        final roles = _parseRoleList(
          payload['roles'],
          fallbackRole: _currentUser?.accountType,
        );
        final active =
            _normalizeAccountType(payload['activeRole']) ??
            _normalizeAccountType(_currentUser?.accountType) ??
            (roles.isNotEmpty ? roles.first : 'pet_owner');

        _updateRoleContext(roles: roles, activeRole: active);
        _syncCurrentUserAccountType(active);

        return List<String>.from(_assignedRoles);
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch user roles');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Assign a new role to current user without forcing immediate UI navigation.
  Future<void> addUserRole(String role) async {
    final normalizedRole = _normalizeAccountType(role);
    if (normalizedRole == null || normalizedRole.isEmpty) {
      throw 'Invalid role';
    }

    if (_assignedRoles.contains(normalizedRole)) {
      return;
    }

    try {
      final response = await _apiClient.post(
        '/api/v1/user/roles/add',
        data: {'role': normalizedRole},
      );

      if (response.data['success'] == true) {
        final payload =
            response.data['data'] as Map<String, dynamic>? ??
            <String, dynamic>{};
        final roles = _parseRoleList(
          payload['roles'],
          fallbackRole: normalizedRole,
        );
        final active =
            _normalizeAccountType(payload['activeRole']) ??
            _activeRole ??
            _normalizeAccountType(_currentUser?.accountType) ??
            (roles.isNotEmpty ? roles.first : normalizedRole);

        _updateRoleContext(roles: roles, activeRole: active);
        return;
      }

      throw Exception(response.data['message'] ?? 'Failed to add role');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Switch active role after backend validation.
  Future<void> switchRole(String role) async {
    final normalizedRole = _normalizeAccountType(role);
    if (normalizedRole == null || normalizedRole.isEmpty) {
      throw 'Invalid role';
    }

    if (_activeRole == normalizedRole &&
        _currentUser?.accountType == normalizedRole) {
      return;
    }

    try {
      final response = await _apiClient.post(
        '/api/v1/user/roles/switch',
        data: {'role': normalizedRole},
      );

      if (response.data['success'] == true) {
        final payload =
            response.data['data'] as Map<String, dynamic>? ??
            <String, dynamic>{};
        final roles = _parseRoleList(
          payload['roles'],
          fallbackRole: normalizedRole,
        );
        final active =
            _normalizeAccountType(payload['activeRole']) ?? normalizedRole;

        _updateRoleContext(roles: roles, activeRole: active);
        _syncCurrentUserAccountType(active);
        return;
      }

      throw Exception(response.data['message'] ?? 'Failed to switch role');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Get user account type
  Future<String?> getAccountType() async {
    if (_activeRole != null && _activeRole!.isNotEmpty) {
      return _activeRole;
    }

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
          final rawActiveRole =
              userData['activeRole'] ??
              userData['accountType'] ??
              userData['account_type'];
          final normalizedActiveRole =
              _normalizeAccountType(rawActiveRole) ?? 'pet_owner';
          final roles = _parseRoleList(
            userData['roles'],
            fallbackRole: normalizedActiveRole,
          );

          _updateRoleContext(roles: roles, activeRole: normalizedActiveRole);

          return AuthUser(
            id: userData['uid'] ?? userData['id'],
            email: userData['email'],
            displayName: userData['displayName'],
            accountType: normalizedActiveRole,
            photoUrl: userData['avatarUrl'],
            createdAt:
                userData['createdAt'] != null
                    ? DateTime.parse(userData['createdAt'])
                    : null,
            updatedAt:
                userData['updatedAt'] != null
                    ? DateTime.parse(userData['updatedAt'])
                    : null,
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
      if (accountType != null) {
        data['accountType'] = _normalizeAccountType(accountType);
      }
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

      await _apiClient.put('/api/v1/profile', data: data);

      // Update local user
      if (_currentUser != null) {
        final normalizedAccountType =
            accountType != null ? _normalizeAccountType(accountType) : null;

        if (normalizedAccountType != null) {
          _updateRoleContext(
            roles: _parseRoleList(
              _assignedRoles,
              fallbackRole: normalizedAccountType,
            ),
            activeRole: normalizedAccountType,
          );
        }

        _currentUser = AuthUser(
          id: _currentUser!.id,
          email: _currentUser!.email,
          displayName: displayName ?? _currentUser!.displayName,
          accountType:
              normalizedAccountType ?? _activeRole ?? _currentUser!.accountType,
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
    final rawActiveRole =
        user['activeRole'] ?? user['accountType'] ?? user['account_type'];
    final normalizedActiveRole =
        _normalizeAccountType(rawActiveRole) ?? 'pet_owner';
    final roles = _parseRoleList(
      user['roles'],
      fallbackRole: normalizedActiveRole,
    );

    _updateRoleContext(roles: roles, activeRole: normalizedActiveRole);

    return AuthResponse(
      user: AuthUser(
        id: user['uid'] ?? user['id'] ?? '',
        email: user['email'] ?? '',
        displayName: user['displayName'],
        accountType: normalizedActiveRole,
        photoUrl: user['avatarUrl'],
        createdAt:
            user['createdAt'] != null &&
                    user['createdAt'] != '0001-01-01T00:00:00Z'
                ? DateTime.parse(user['createdAt'])
                : null,
        updatedAt:
            user['updatedAt'] != null &&
                    user['updatedAt'] != '0001-01-01T00:00:00Z'
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
    await _apiClient.setTokens(
      authResponse.accessToken,
      authResponse.refreshToken,
    );

    final resolvedActiveRole =
        _activeRole ??
        _normalizeAccountType(authResponse.user.accountType) ??
        'pet_owner';
    final resolvedRoles = _parseRoleList(
      _assignedRoles,
      fallbackRole: resolvedActiveRole,
    );
    _updateRoleContext(roles: resolvedRoles, activeRole: resolvedActiveRole);

    _currentUser = authResponse.user.copyWith(accountType: resolvedActiveRole);
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

  List<String> _parseRoleList(dynamic rawRoles, {String? fallbackRole}) {
    final roles = <String>[];

    if (rawRoles is List) {
      for (final role in rawRoles) {
        final normalized = _normalizeAccountType(role);
        if (normalized != null && normalized.isNotEmpty) {
          roles.add(normalized);
        }
      }
    }

    if (roles.isEmpty) {
      final fallback = _normalizeAccountType(fallbackRole) ?? 'pet_owner';
      roles.add(fallback);
    }

    final deduped = <String>[];
    for (final role in roles) {
      if (!deduped.contains(role)) {
        deduped.add(role);
      }
    }
    return deduped;
  }

  void _updateRoleContext({
    required List<String> roles,
    required String activeRole,
  }) {
    final normalizedActive = _normalizeAccountType(activeRole) ?? 'pet_owner';
    final normalizedRoles = _parseRoleList(
      roles,
      fallbackRole: normalizedActive,
    );

    if (!normalizedRoles.contains(normalizedActive)) {
      normalizedRoles.add(normalizedActive);
    }

    _assignedRoles = normalizedRoles;
    _activeRole = normalizedActive;
  }

  void _syncCurrentUserAccountType(String activeRole) {
    if (_currentUser == null) return;

    final normalizedActive = _normalizeAccountType(activeRole) ?? 'pet_owner';
    if ((_currentUser!.accountType ?? 'pet_owner') == normalizedActive) {
      return;
    }

    _currentUser = _currentUser!.copyWith(
      accountType: normalizedActive,
      updatedAt: DateTime.now(),
    );
    _authStateController.add(_currentUser);
  }

  // Dispose
  void dispose() {
    _authStateController.close();
  }
}
