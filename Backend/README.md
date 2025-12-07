# PawPal Backend API

🐾 A high-performance Go backend API for the PawPal mobile application with authentication, pet management, and AI-powered features.

## 🚀 Base URL
```
http://localhost:8081
```

## 📱 Flutter Integration Guide

### 🔐 Authentication Flow

#### 1️⃣ User Registration (Sign Up)
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> signUp({
  required String email,
  required String password,
  required String displayName,
}) async {
  final response = await http.post(
    Uri.parse('http://localhost:8081/api/v1/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
      'displayName': displayName,
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    // Store tokens securely (use flutter_secure_storage)
    String accessToken = data['accessToken'];
    String refreshToken = data['refreshToken'];
    return data;
  } else {
    throw Exception('Registration failed: ${response.body}');
  }
}
```

**Request:**
```json
POST /api/v1/auth/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "displayName": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "User created successfully",
  "user": {
    "uid": "8720177f-82e3-42c0-acc6-2c1ae7d59b47",
    "email": "user@example.com",
    "displayName": "John Doe",
    "accountType": "pet_owner",
    "createdAt": "2025-12-07T06:21:26.585996Z",
    "updatedAt": "2025-12-07T06:21:26.585996Z"
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "9da11f6ee6b637c109038ca992ffba4f...",
  "expiresIn": 86400
}
```

---

#### 2️⃣ User Login (Sign In)
```dart
Future<Map<String, dynamic>> signIn({
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('http://localhost:8081/api/v1/auth/signin'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    String accessToken = data['accessToken'];
    String refreshToken = data['refreshToken'];
    // Store tokens securely
    return data;
  } else {
    throw Exception('Login failed: ${response.body}');
  }
}
```

**Request:**
```json
POST /api/v1/auth/signin
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "user": {
    "uid": "8720177f-82e3-42c0-acc6-2c1ae7d59b47",
    "email": "user@example.com",
    "displayName": "John Doe",
    "accountType": "pet_owner",
    "createdAt": "2025-12-07T06:21:26.585996Z",
    "updatedAt": "2025-12-07T06:21:26.585996Z"
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "874dd473257d0cf865a1e46b7f3533e2...",
  "expiresIn": 86400
}
```

---

#### 3️⃣ Get User Profile (Protected Route)
```dart
Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
  final response = await http.get(
    Uri.parse('http://localhost:8081/api/v1/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    // Token expired, refresh it
    throw Exception('Token expired');
  } else {
    throw Exception('Failed to get profile');
  }
}
```

**Request:**
```http
GET /api/v1/profile
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "uid": "8720177f-82e3-42c0-acc6-2c1ae7d59b47",
    "email": "user@example.com",
    "displayName": "John Doe",
    "accountType": "pet_owner",
    "createdAt": "2025-12-07T06:21:26.585996Z",
    "updatedAt": "2025-12-07T06:21:26.585996Z"
  }
}
```

---

#### 4️⃣ Update User Profile
```dart
Future<Map<String, dynamic>> updateProfile({
  required String accessToken,
  String? displayName,
  String? accountType,
}) async {
  final response = await http.put(
    Uri.parse('http://localhost:8081/api/v1/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      if (displayName != null) 'displayName': displayName,
      if (accountType != null) 'accountType': accountType,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to update profile');
  }
}
```

**Request:**
```json
PUT /api/v1/profile
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "displayName": "John Smith",
  "accountType": "premium"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "uid": "8720177f-82e3-42c0-acc6-2c1ae7d59b47",
    "email": "user@example.com",
    "displayName": "John Smith",
    "accountType": "premium",
    "createdAt": "2025-12-07T06:21:26.585996Z",
    "updatedAt": "2025-12-07T06:21:26.585996Z"
  }
}
```

---

#### 5️⃣ Refresh Access Token
```dart
Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
  final response = await http.post(
    Uri.parse('http://localhost:8081/api/v1/auth/refresh'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'refreshToken': refreshToken,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    String newAccessToken = data['accessToken'];
    String newRefreshToken = data['refreshToken'];
    // Update stored tokens
    return data;
  } else {
    // Refresh token expired, user needs to login again
    throw Exception('Session expired, please login again');
  }
}
```

**Request:**
```json
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "874dd473257d0cf865a1e46b7f3533e2..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6...",
  "expiresIn": 86400
}
```

---

#### 6️⃣ User Logout (Sign Out)
```dart
Future<void> signOut({
  required String refreshToken,
}) async {
  final response = await http.post(
    Uri.parse('http://localhost:8081/api/v1/auth/signout'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'refreshToken': refreshToken,
    }),
  );

  if (response.statusCode == 200) {
    // Clear stored tokens
    print('Logged out successfully');
  } else {
    throw Exception('Logout failed');
  }
}
```

**Request:**
```json
POST /api/v1/auth/signout
Content-Type: application/json

{
  "refreshToken": "874dd473257d0cf865a1e46b7f3533e2..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Signed out successfully"
}
```

---

### 🔑 Complete Flutter Authentication Service Example

```dart
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://localhost:8081';
  final storage = FlutterSecureStorage();

  // Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'accessToken', value: data['accessToken']);
        await storage.write(key: 'refreshToken', value: data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      print('SignUp Error: $e');
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'accessToken', value: data['accessToken']);
        await storage.write(key: 'refreshToken', value: data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      print('SignIn Error: $e');
      return false;
    }
  }

  // Get Profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else if (response.statusCode == 401) {
        // Try to refresh token
        await refreshAccessToken();
        return getProfile(); // Retry
      }
      return null;
    } catch (e) {
      print('GetProfile Error: $e');
      return null;
    }
  }

  // Refresh Token
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await storage.read(key: 'refreshToken');
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'accessToken', value: data['accessToken']);
        await storage.write(key: 'refreshToken', value: data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      print('RefreshToken Error: $e');
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      final refreshToken = await storage.read(key: 'refreshToken');
      if (refreshToken != null) {
        await http.post(
          Uri.parse('$baseUrl/api/v1/auth/signout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      }
    } finally {
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
    }
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await storage.read(key: 'accessToken');
    return accessToken != null;
  }
}
```

---

### 📦 Required Flutter Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
```

---

## 🔒 Authentication Details

### Token Information
- **Access Token**: JWT token valid for **24 hours** (86400 seconds)
- **Refresh Token**: SHA-256 hash valid for **30 days**
- **Storage**: Use `flutter_secure_storage` to store tokens securely on device

### Security Headers
All protected routes require the `Authorization` header:
```
Authorization: Bearer <accessToken>
```

### Error Responses

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Invalid or expired token"
}
```

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Invalid request: <error details>"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Internal server error"
}
```

---

## 🗺️ API Endpoints Reference

### Authentication Endpoints
| Method | Endpoint | Protected | Description |
|--------|----------|-----------|-------------|
| POST | `/api/v1/auth/signup` | ❌ | Register new user |
| POST | `/api/v1/auth/signin` | ❌ | Login user |
| POST | `/api/v1/auth/refresh` | ❌ | Refresh access token |
| POST | `/api/v1/auth/signout` | ❌ | Logout user |
| GET | `/api/v1/profile` | ✅ | Get user profile |
| PUT | `/api/v1/profile` | ✅ | Update user profile |

### Other Available Endpoints
| Method | Endpoint | Protected | Description |
|--------|----------|-----------|-------------|
| GET | `/health` | ❌ | Health check |
| POST | `/api/v1/predict` | ✅ | Predict pet breed (single) |
| POST | `/api/v1/predict/batch` | ✅ | Predict pet breeds (batch) |
| POST | `/api/v1/chatbot/query` | ✅ | AI chatbot query |

---

## 🚀 Getting Started

### Prerequisites
- Go 1.19+
- PostgreSQL (via Supabase)

### Environment Setup
Create a `.env` file in the Backend directory:
```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_ACCESS_EXPIRY=24h
JWT_REFRESH_EXPIRY=720h

# Server Configuration
PORT=8081
```

### Running the Backend
```bash
cd Backend
go run cmd/api/main.go
```

Server will start on `http://localhost:8081`

### Testing Authentication
Run the PowerShell test script:
```powershell
.\Backend\scripts\test_auth.ps1
```

This will test all authentication endpoints:
- ✅ User Registration
- ✅ User Login
- ✅ Get Profile
- ✅ Update Profile
- ✅ Logout

---

## 🏗️ Architecture

### Database (Supabase PostgreSQL)
- **Users Table**: Stores user accounts with bcrypt password hashing
- **Refresh Tokens Table**: Manages refresh tokens with expiry
- **Row Level Security**: Enabled on all tables

### Authentication Flow
1. User signs up → Backend creates user in Supabase → Returns JWT tokens
2. User signs in → Backend verifies credentials → Returns JWT tokens
3. User accesses protected route → Backend validates JWT → Returns data
4. Token expires → User refreshes token → Backend issues new tokens
5. User logs out → Backend invalidates refresh token

### Security Features
- ✅ Password hashing with bcrypt (cost 10)
- ✅ JWT-based authentication
- ✅ Refresh token rotation
- ✅ Token expiration (24h access, 30d refresh)
- ✅ Secure token storage recommendations
- ✅ CORS enabled for Flutter apps

---

## 📝 License
MIT License - See LICENSE file for details

---

## 🤝 Contributing
Contributions welcome! Please open an issue or submit a pull request.

---

## 📧 Support
For questions or issues, please contact the development team.
