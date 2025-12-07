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

## 🐾 Pet Management API

### 🔰 Overview
Complete CRUD operations for managing pets in the PawPal application. All pet endpoints require authentication (JWT token in Authorization header).

### 📋 Pet Model
```dart
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String type;           // "dog" or "cat"
  final String breed;
  final int age;
  final String ageUnit;        // "years", "months", "weeks"
  final String gender;         // "male" or "female"
  final String color;
  final double weight;
  final String weightUnit;     // "kg" or "lbs"
  final String? imageUrl;
  final String? imageLocalPath;
  final List<String>? imageUrls;
  final bool isVerified;
  final double? verificationConfidence;
  final String? verifiedBreed;
  final String? bio;
  final bool isAdopted;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

### 1️⃣ Create Pet

**Endpoint:** `POST /api/v1/pets`

**Flutter Example:**
```dart
Future<Map<String, dynamic>> createPet({
  required String accessToken,
  required String name,
  required String type,
  required String breed,
  required int age,
  required String ageUnit,
  required String gender,
  required String color,
  required double weight,
  required String weightUnit,
  String? bio,
}) async {
  final response = await http.post(
    Uri.parse('http://localhost:8081/api/v1/pets'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      'name': name,
      'type': type,
      'breed': breed,
      'age': age,
      'ageUnit': ageUnit,
      'gender': gender,
      'color': color,
      'weight': weight,
      'weightUnit': weightUnit,
      'bio': bio,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create pet: ${response.body}');
  }
}
```

**Request:**
```json
POST /api/v1/pets
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Buddy",
  "type": "dog",
  "breed": "Golden Retriever",
  "age": 3,
  "ageUnit": "years",
  "gender": "male",
  "color": "golden",
  "weight": 30.5,
  "weightUnit": "kg",
  "bio": "Friendly and energetic golden retriever"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Pet created successfully",
  "pet": {
    "id": "66b637c0-a982-432c-a9a6-f14810a851c9",
    "ownerId": "caf30610-0280-4447-b106-665301bf83fc",
    "name": "Buddy",
    "type": "dog",
    "breed": "Golden Retriever",
    "age": 3,
    "ageUnit": "years",
    "gender": "male",
    "color": "golden",
    "weight": 30.5,
    "weightUnit": "kg",
    "isVerified": false,
    "bio": "Friendly and energetic golden retriever",
    "isAdopted": false,
    "createdAt": "2025-12-07T09:18:03.417343Z",
    "updatedAt": "2025-12-07T09:18:03.417343Z"
  }
}
```

---

### 2️⃣ Get All User's Pets

**Endpoint:** `GET /api/v1/pets`

**Flutter Example:**
```dart
Future<List<dynamic>> getUserPets(String accessToken) async {
  final response = await http.get(
    Uri.parse('http://localhost:8081/api/v1/pets'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['pets'];
  } else {
    throw Exception('Failed to get pets: ${response.body}');
  }
}
```

**Request:**
```
GET /api/v1/pets
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
  "success": true,
  "pets": [
    {
      "id": "66b637c0-a982-432c-a9a6-f14810a851c9",
      "ownerId": "caf30610-0280-4447-b106-665301bf83fc",
      "name": "Buddy",
      "type": "dog",
      "breed": "Golden Retriever",
      "age": 3,
      "ageUnit": "years",
      "gender": "male",
      "color": "golden",
      "weight": 30.5,
      "weightUnit": "kg",
      "isVerified": false,
      "bio": "Friendly and energetic golden retriever",
      "isAdopted": false,
      "createdAt": "2025-12-07T09:18:03.417343Z",
      "updatedAt": "2025-12-07T09:18:03.417343Z"
    }
  ],
  "count": 1
}
```

---

### 3️⃣ Get Single Pet by ID

**Endpoint:** `GET /api/v1/pets/:id`

**Flutter Example:**
```dart
Future<Map<String, dynamic>> getPetById(String accessToken, String petId) async {
  final response = await http.get(
    Uri.parse('http://localhost:8081/api/v1/pets/$petId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['pet'];
  } else {
    throw Exception('Failed to get pet: ${response.body}');
  }
}
```

**Request:**
```
GET /api/v1/pets/66b637c0-a982-432c-a9a6-f14810a851c9
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
  "success": true,
  "pet": {
    "id": "66b637c0-a982-432c-a9a6-f14810a851c9",
    "ownerId": "caf30610-0280-4447-b106-665301bf83fc",
    "name": "Buddy",
    "type": "dog",
    "breed": "Golden Retriever",
    "age": 3,
    "ageUnit": "years",
    "gender": "male",
    "color": "golden",
    "weight": 30.5,
    "weightUnit": "kg",
    "isVerified": false,
    "bio": "Friendly and energetic golden retriever",
    "isAdopted": false,
    "createdAt": "2025-12-07T09:18:03.417343Z",
    "updatedAt": "2025-12-07T09:18:03.417343Z"
  }
}
```

---

### 4️⃣ Update Pet

**Endpoint:** `PUT /api/v1/pets/:id`

**Flutter Example:**
```dart
Future<Map<String, dynamic>> updatePet({
  required String accessToken,
  required String petId,
  String? name,
  int? age,
  String? bio,
  double? weight,
  // ... other optional fields
}) async {
  final body = <String, dynamic>{};
  if (name != null) body['name'] = name;
  if (age != null) body['age'] = age;
  if (bio != null) body['bio'] = bio;
  if (weight != null) body['weight'] = weight;

  final response = await http.put(
    Uri.parse('http://localhost:8081/api/v1/pets/$petId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to update pet: ${response.body}');
  }
}
```

**Request:**
```json
PUT /api/v1/pets/66b637c0-a982-432c-a9a6-f14810a851c9
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Buddy Updated",
  "age": 4,
  "bio": "Updated bio: Very friendly golden retriever"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Pet updated successfully",
  "pet": {
    "id": "66b637c0-a982-432c-a9a6-f14810a851c9",
    "ownerId": "caf30610-0280-4447-b106-665301bf83fc",
    "name": "Buddy Updated",
    "type": "dog",
    "breed": "Golden Retriever",
    "age": 4,
    "ageUnit": "years",
    "gender": "male",
    "color": "golden",
    "weight": 30.5,
    "weightUnit": "kg",
    "isVerified": false,
    "bio": "Updated bio: Very friendly golden retriever",
    "isAdopted": false,
    "createdAt": "2025-12-07T09:18:03.417343Z",
    "updatedAt": "2025-12-07T09:18:04.115301Z"
  }
}
```

---

### 5️⃣ Delete Pet

**Endpoint:** `DELETE /api/v1/pets/:id`

**Flutter Example:**
```dart
Future<void> deletePet(String accessToken, String petId) async {
  final response = await http.delete(
    Uri.parse('http://localhost:8081/api/v1/pets/$petId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete pet: ${response.body}');
  }
}
```

**Request:**
```
DELETE /api/v1/pets/66b637c0-a982-432c-a9a6-f14810a851c9
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Pet deleted successfully"
}
```

---

### 6️⃣ Get Verified Pets

**Endpoint:** `GET /api/v1/pets/verified`

Get all pets that have been verified by the AI breed classifier.

**Flutter Example:**
```dart
Future<List<dynamic>> getVerifiedPets(String accessToken) async {
  final response = await http.get(
    Uri.parse('http://localhost:8081/api/v1/pets/verified'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['pets'];
  } else {
    throw Exception('Failed to get verified pets: ${response.body}');
  }
}
```

---

### 7️⃣ Search Pets by Breed

**Endpoint:** `GET /api/v1/pets/search?breed=<breed_name>`

**Flutter Example:**
```dart
Future<List<dynamic>> searchPetsByBreed(String accessToken, String breed) async {
  final response = await http.get(
    Uri.parse('http://localhost:8081/api/v1/pets/search?breed=$breed'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['pets'];
  } else {
    throw Exception('Failed to search pets: ${response.body}');
  }
}
```

**Request:**
```
GET /api/v1/pets/search?breed=Golden%20Retriever
Authorization: Bearer <access_token>
```

---

### 8️⃣ Get Pet Count

**Endpoint:** `GET /api/v1/pets/count`

**Flutter Example:**
```dart
Future<int> getPetCount(String accessToken) async {
  final response = await http.get(
    Uri.parse('http://localhost:8081/api/v1/pets/count'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['count'];
  } else {
    throw Exception('Failed to get pet count: ${response.body}');
  }
}
```

---

### 🛠️ Complete Pet Service Class

Here's a complete Flutter service class for pet management:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class PetService {
  final String baseUrl = 'http://localhost:8081/api/v1';
  
  Future<Map<String, dynamic>> createPet({
    required String accessToken,
    required String name,
    required String type,
    required String breed,
    required int age,
    required String ageUnit,
    required String gender,
    required String color,
    required double weight,
    required String weightUnit,
    String? bio,
    String? imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'name': name,
        'type': type,
        'breed': breed,
        'age': age,
        'ageUnit': ageUnit,
        'gender': gender,
        'color': color,
        'weight': weight,
        'weightUnit': weightUnit,
        'bio': bio,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create pet: ${response.body}');
    }
  }

  Future<List<dynamic>> getUserPets(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pets'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pets'];
    } else {
      throw Exception('Failed to get pets: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getPetById(String accessToken, String petId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pets/$petId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pet'];
    } else if (response.statusCode == 404) {
      throw Exception('Pet not found');
    } else {
      throw Exception('Failed to get pet: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updatePet({
    required String accessToken,
    required String petId,
    String? name,
    int? age,
    String? bio,
    double? weight,
    String? imageUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (age != null) body['age'] = age;
    if (bio != null) body['bio'] = bio;
    if (weight != null) body['weight'] = weight;
    if (imageUrl != null) body['imageUrl'] = imageUrl;

    final response = await http.put(
      Uri.parse('$baseUrl/pets/$petId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('Not authorized to update this pet');
    } else if (response.statusCode == 404) {
      throw Exception('Pet not found');
    } else {
      throw Exception('Failed to update pet: ${response.body}');
    }
  }

  Future<void> deletePet(String accessToken, String petId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/pets/$petId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 403) {
      throw Exception('Not authorized to delete this pet');
    } else if (response.statusCode == 404) {
      throw Exception('Pet not found');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to delete pet: ${response.body}');
    }
  }

  Future<List<dynamic>> getVerifiedPets(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pets/verified'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pets'];
    } else {
      throw Exception('Failed to get verified pets: ${response.body}');
    }
  }

  Future<List<dynamic>> searchPetsByBreed(String accessToken, String breed) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pets/search?breed=$breed'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pets'];
    } else {
      throw Exception('Failed to search pets: ${response.body}');
    }
  }

  Future<int> getPetCount(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pets/count'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'];
    } else {
      throw Exception('Failed to get pet count: ${response.body}');
    }
  }
}
```

---

### 🧪 Testing Pet Management

Run the PowerShell test script:
```powershell
.\Backend\scripts\test_pets.ps1
```

This will test all pet endpoints:
- ✅ Create Pet
- ✅ Get All User's Pets
- ✅ Get Single Pet by ID
- ✅ Update Pet
- ✅ Delete Pet

**Test Output:**
```
============================================================
TEST 1: Create Pet
============================================================
PASS - Pet created successfully!
Pet ID: 66b637c0-a982-432c-a9a6-f14810a851c9

============================================================
TEST 2: Get All User's Pets
============================================================
PASS - Pets retrieved successfully!
Total Pets: 1

============================================================
TEST 3: Get Single Pet by ID
============================================================
PASS - Pet retrieved successfully!

============================================================
TEST 4: Update Pet
============================================================
PASS - Pet updated successfully!
Updated Name: Buddy Updated

============================================================
TEST 5: Delete Pet
============================================================
PASS - Pet deleted successfully!
```

---

### 🔒 Authorization

All pet endpoints verify ownership:
- Only the pet owner can **update** or **delete** their pets
- Users can only view their own pets via `GET /api/v1/pets`
- `GET /api/v1/pets/:id` requires the requester to be the owner
- 403 Forbidden returned if user tries to modify another user's pet

---

## 🤖 AI Breed Verification

### 🔰 Overview
Automatically verify pet breeds using AI-powered image classification. The system uses ConvNeXt V2 models trained on 120 dog breeds and multiple cat breeds with 92-95% accuracy.

### 📋 How It Works

1. User creates a pet with basic information
2. User uploads a photo of their pet
3. AI analyzes the image and predicts the breed
4. Pet record is updated with:
   - `isVerified: true`
   - `verificationConfidence: 0.95` (example)
   - `verifiedBreed: "Golden Retriever"`

---

### 1️⃣ Verify Pet Breed (Base64 Image)

**Endpoint:** `POST /api/v1/pets/verify`

Upload a base64-encoded image to verify a pet's breed.

**Flutter Example:**
```dart
import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> verifyPetBreed({
  required String accessToken,
  required String petId,
  required File imageFile,
  bool useETTA = false,
  int topK = 5,
}) async {
  // Read and encode image
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);

  final response = await http.post(
    Uri.parse('http://localhost:8081/api/v1/pets/verify'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      'petId': petId,
      'image': base64Image,
      'useETTA': useETTA,
      'topK': topK,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Verification failed: ${response.body}');
  }
}
```

**Request:**
```json
POST /api/v1/pets/verify
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "petId": "66b637c0-a982-432c-a9a6-f14810a851c9",
  "image": "base64_encoded_image_data...",
  "useETTA": false,
  "topK": 5
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Pet breed verified successfully",
  "pet": {
    "id": "66b637c0-a982-432c-a9a6-f14810a851c9",
    "ownerId": "caf30610-0280-4447-b106-665301bf83fc",
    "name": "Buddy",
    "type": "dog",
    "breed": "Golden Retriever",
    "isVerified": true,
    "verificationConfidence": 0.9534,
    "verifiedBreed": "Golden Retriever",
    "createdAt": "2025-12-07T09:18:03.417343Z",
    "updatedAt": "2025-12-07T10:30:15.123456Z"
  },
  "prediction": {
    "success": true,
    "petType": "dog",
    "predicted": "Golden Retriever",
    "confidence": 0.9534,
    "predictions": [
      {
        "breed": "Golden Retriever",
        "confidence": 0.9534,
        "rank": 1
      },
      {
        "breed": "Labrador Retriever",
        "confidence": 0.0312,
        "rank": 2
      },
      {
        "breed": "Flat Coated Retriever",
        "confidence": 0.0089,
        "rank": 3
      }
    ],
    "processTime": 1234.56,
    "usedTTA": false,
    "modelInfo": {
      "name": "ConvNeXt V2 Base - Dog Breed Classifier",
      "petType": "dog",
      "version": "1.0",
      "classes": 120,
      "imageSize": 384,
      "accuracy": "92-95%",
      "description": "ConvNeXt V2 Base model trained for dog breed classification"
    }
  }
}
```

---

### 2️⃣ Verify Pet Breed (File Upload)

**Endpoint:** `POST /api/v1/pets/verify/file`

Upload an image file directly using multipart/form-data.

**Flutter Example:**
```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<Map<String, dynamic>> verifyPetBreedFromFile({
  required String accessToken,
  required String petId,
  required File imageFile,
  bool useETTA = false,
  int topK = 5,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://localhost:8081/api/v1/pets/verify/file'),
  );

  request.headers['Authorization'] = 'Bearer $accessToken';
  request.fields['petId'] = petId;
  request.fields['useETTA'] = useETTA.toString();
  request.fields['topK'] = topK.toString();
  
  // Add image file
  request.files.add(
    await http.MultipartFile.fromPath('image', imageFile.path),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Verification failed: ${response.body}');
  }
}
```

**Request:**
```
POST /api/v1/pets/verify/file
Authorization: Bearer <access_token>
Content-Type: multipart/form-data

petId: 66b637c0-a982-432c-a9a6-f14810a851c9
image: <binary_image_file>
useETTA: false
topK: 5
```

**Response:** Same as base64 verification endpoint.

---

### 3️⃣ Verify Pet Breed (Image URL)

**Endpoint:** `POST /api/v1/pets/verify/url`

Provide an image URL for the backend to download and verify.

**Flutter Example:**
```dart
Future<Map<String, dynamic>> verifyPetBreedFromURL({
  required String accessToken,
  required String petId,
  required String imageUrl,
  bool useETTA = false,
  int topK = 5,
}) async {
  final response = await http.post(
    Uri.parse('http://localhost:8081/api/v1/pets/verify/url'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      'petId': petId,
      'imageUrl': imageUrl,
      'useETTA': useETTA,
      'topK': topK,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Verification failed: ${response.body}');
  }
}
```

**Request:**
```json
POST /api/v1/pets/verify/url
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "petId": "66b637c0-a982-432c-a9a6-f14810a851c9",
  "imageUrl": "https://example.com/my-pet-image.jpg",
  "useETTA": false,
  "topK": 5
}
```

**Response:** Same as base64 verification endpoint.

---

### 4️⃣ Upload Pet Image

**Endpoint:** `POST /api/v1/uploads/image`

Upload a single pet image to the server.

**Flutter Example:**
```dart
Future<Map<String, dynamic>> uploadPetImage({
  required String accessToken,
  required File imageFile,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://localhost:8081/api/v1/uploads/image'),
  );

  request.headers['Authorization'] = 'Bearer $accessToken';
  request.files.add(
    await http.MultipartFile.fromPath('image', imageFile.path),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Upload failed: ${response.body}');
  }
}
```

**Request:**
```
POST /api/v1/uploads/image
Authorization: Bearer <access_token>
Content-Type: multipart/form-data

image: <binary_image_file>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Image uploaded successfully",
  "filename": "a1b2c3d4e5f6.jpg",
  "url": "http://localhost:8081/uploads/a1b2c3d4e5f6.jpg",
  "path": "./assets/uploads/a1b2c3d4e5f6.jpg",
  "size": 204800
}
```

---

### 5️⃣ Upload Multiple Pet Images

**Endpoint:** `POST /api/v1/uploads/images`

Upload up to 5 pet images at once.

**Flutter Example:**
```dart
Future<Map<String, dynamic>> uploadMultiplePetImages({
  required String accessToken,
  required List<File> imageFiles,
}) async {
  if (imageFiles.length > 5) {
    throw Exception('Maximum 5 images allowed');
  }

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://localhost:8081/api/v1/uploads/images'),
  );

  request.headers['Authorization'] = 'Bearer $accessToken';
  
  for (var file in imageFiles) {
    request.files.add(
      await http.MultipartFile.fromPath('images', file.path),
    );
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Upload failed: ${response.body}');
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Uploaded 3 image(s) successfully",
  "count": 3,
  "files": [
    {
      "filename": "a1b2c3d4e5f6.jpg",
      "url": "http://localhost:8081/uploads/a1b2c3d4e5f6.jpg",
      "path": "./assets/uploads/a1b2c3d4e5f6.jpg",
      "size": 204800
    },
    {
      "filename": "b2c3d4e5f6a7.jpg",
      "url": "http://localhost:8081/uploads/b2c3d4e5f6a7.jpg",
      "path": "./assets/uploads/b2c3d4e5f6a7.jpg",
      "size": 198400
    }
  ]
}
```

---

### 6️⃣ Delete Uploaded Image

**Endpoint:** `DELETE /api/v1/uploads/image/:filename`

Delete a previously uploaded image.

**Flutter Example:**
```dart
Future<void> deleteUploadedImage({
  required String accessToken,
  required String filename,
}) async {
  final response = await http.delete(
    Uri.parse('http://localhost:8081/api/v1/uploads/image/$filename'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Delete failed: ${response.body}');
  }
}
```

**Request:**
```
DELETE /api/v1/uploads/image/a1b2c3d4e5f6.jpg
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Image deleted successfully"
}
```

---

### 🛠️ Complete AI Verification Service Class

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AIVerificationService {
  final String baseUrl = 'http://localhost:8081/api/v1';
  
  // Verify from base64
  Future<Map<String, dynamic>> verifyFromBase64({
    required String accessToken,
    required String petId,
    required String base64Image,
    bool useETTA = false,
    int topK = 5,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pets/verify'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'petId': petId,
        'image': base64Image,
        'useETTA': useETTA,
        'topK': topK,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Verification failed: ${response.body}');
    }
  }

  // Verify from file
  Future<Map<String, dynamic>> verifyFromFile({
    required String accessToken,
    required String petId,
    required File imageFile,
    bool useETTA = false,
    int topK = 5,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/pets/verify/file'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['petId'] = petId;
    request.fields['useETTA'] = useETTA.toString();
    request.fields['topK'] = topK.toString();
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Verification failed: ${response.body}');
    }
  }

  // Verify from URL
  Future<Map<String, dynamic>> verifyFromURL({
    required String accessToken,
    required String petId,
    required String imageUrl,
    bool useETTA = false,
    int topK = 5,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pets/verify/url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'petId': petId,
        'imageUrl': imageUrl,
        'useETTA': useETTA,
        'topK': topK,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Verification failed: ${response.body}');
    }
  }

  // Upload single image
  Future<Map<String, dynamic>> uploadImage({
    required String accessToken,
    required File imageFile,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/uploads/image'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }

  // Upload multiple images
  Future<Map<String, dynamic>> uploadMultipleImages({
    required String accessToken,
    required List<File> imageFiles,
  }) async {
    if (imageFiles.length > 5) {
      throw Exception('Maximum 5 images allowed');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/uploads/images'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';
    
    for (var file in imageFiles) {
      request.files.add(
        await http.MultipartFile.fromPath('images', file.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }

  // Delete image
  Future<void> deleteImage({
    required String accessToken,
    required String filename,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/uploads/image/$filename'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Delete failed: ${response.body}');
    }
  }
}
```

---

### 🧪 Testing AI Breed Verification

Run the PowerShell test script:
```powershell
.\Backend\scripts\test_ai_verification.ps1
```

This will test:
- ✅ User registration and login
- ✅ Pet creation
- ✅ AI breed verification from URL
- ✅ Verification results with confidence scores
- ✅ Database updates (isVerified, verificationConfidence, verifiedBreed)
- ✅ Top-5 breed predictions

**Expected Output:**
```
============================================================
STEP 4: Verify Pet Breed with AI
============================================================
✅ PASS - Pet breed verified!

--- Verification Results ---
Is Verified: True
Verified Breed: Golden Retriever
Confidence: 95.34%

--- AI Prediction Details ---
Predicted Breed: Golden Retriever
Confidence: 95.34%
Process Time: 1234.56 ms
Used TTA: False

--- Top 5 Predictions ---
1. Golden Retriever - 95.34%
2. Labrador Retriever - 3.12%
3. Flat Coated Retriever - 0.89%
4. Chesapeake Bay Retriever - 0.34%
5. Irish Setter - 0.21%
```

---

### 📊 Supported Parameters

**`useETTA`** (bool):
- `false`: Standard prediction (faster, ~1-2 seconds)
- `true`: Test-Time Augmentation (more accurate, ~5-10 seconds)

**`topK`** (int):
- Number of top predictions to return (1-10)
- Default: 5
- Recommended: 3-5 for best UX

---

### 🎯 Model Information

**Dog Breed Classifier:**
- Model: ConvNeXt V2 Base
- Classes: 120 breeds
- Accuracy: 92-95%
- Input Size: 384x384 pixels

**Cat Breed Classifier:**
- Model: ConvNeXt V2 Base
- Classes: Multiple breeds
- Accuracy: 88-92%
- Input Size: 384x384 pixels

---

### 🔒 Authorization & Validation

All verification endpoints:
- ✅ Require authentication (JWT token)
- ✅ Validate pet ownership (only owner can verify)
- ✅ Validate image format (JPEG, PNG, WebP)
- ✅ Validate file size (max 10MB)
- ✅ Validate pet type (dog/cat)
- ✅ Return 403 Forbidden if user doesn't own the pet
- ✅ Return 404 Not Found if pet doesn't exist

---

## 💬 RAG Chatbot System

### 🔰 Overview
24/7 AI-powered veterinary assistant using **Retrieval-Augmented Generation (RAG)** with **Groq's Llama-3.3-70B** for fast, accurate pet health advice.

### 🎯 Features
- ✅ **AI-Powered Veterinary Guidance** - Common health queries & concerns
- ✅ **Personalized Advice** - Based on pet breed, age, weight, health conditions
- ✅ **24/7 Availability** - Sub-second response times (when FastAPI server running)
- ✅ **Context-Aware** - Uses RAG with veterinary knowledge base
- ✅ **Streaming Support** - Real-time responses like ChatGPT
- ✅ **Knowledge Base** - ASPCA pet care, medications, nutrition data

### 📋 How It Works

```
User Query
    ↓
Query Embedding (SentenceTransformer)
    ↓
Vector Search (ChromaDB)
    ↓
Retrieve Top-K Relevant Documents
    ↓
Build Prompt with Context
    ↓
Groq LLM (llama-3.3-70b-versatile)
    ↓
AI-Generated Answer
```

### 🚀 Quick Start

**Start FastAPI Server (Recommended for 10x faster responses):**
```bash
cd AI_Chatbot
python chatbot_fastapi_server.py
```

Server will be available at `http://localhost:8000`

**Alternative:** Backend will use exec mode (slower) if FastAPI server not running.

---

### 1️⃣ Query Chatbot (Standard)

**Endpoint:** `POST /api/v1/chatbot/query`

Ask the AI chatbot a pet health question.

**Flutter Example:**
```dart
Future<Map<String, dynamic>> queryChatbot({
  required String message,
  Map<String, dynamic>? petProfile,
}) async {
  final response = await http.post(
    Uri.parse('http://localhost:8081/api/v1/chatbot/query'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'message': message,
      'pet_profile': petProfile,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Chatbot query failed: ${response.body}');
  }
}
```

**Request:**
```json
POST /api/v1/chatbot/query
Content-Type: application/json

{
  "message": "What should I feed my Golden Retriever puppy?",
  "pet_profile": {
    "name": "Buddy",
    "breed": "Golden Retriever",
    "age": 6,
    "age_unit": "months",
    "weight": 15.5,
    "weight_unit": "kg"
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "answer": "For a 6-month-old Golden Retriever puppy weighing 15.5 kg, here are the feeding recommendations:\n\n**Diet Basics:**\n- Feed high-quality puppy food formulated for large breeds\n- 3-4 meals per day at this age\n- Approximately 3-4 cups of food daily (split across meals)\n- Ensure adequate protein (22-24%) for growth\n\n**Key Nutrients:**\n- Controlled calcium and phosphorus for bone development\n- DHA for brain and eye development\n- Balanced omega fatty acids for coat health\n\n**Important Notes:**\n- Transition to adult food around 12-18 months\n- Avoid overfeeding to prevent rapid growth issues\n- Always provide fresh water\n- Consult your vet for personalized portion sizes\n\nWould you like specific brand recommendations or have questions about treats?",
  "query": "What should I feed my Golden Retriever puppy?",
  "enhanced_query": "puppy nutrition golden retriever 6 months feeding schedule",
  "sources": [
    {
      "content": "Golden Retriever puppies require...",
      "source": "healthy_pets_happy_owners_data.json",
      "relevance": 0.89
    }
  ]
}
```

---

### 2️⃣ Query Chatbot (Streaming)

**Endpoint:** `POST /api/v1/chatbot/stream`

Get real-time streaming responses (like ChatGPT).

**Flutter Example:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Stream<String> queryChatbotStream({
  required String message,
  Map<String, dynamic>? petProfile,
}) async* {
  final request = http.Request(
    'POST',
    Uri.parse('http://localhost:8081/api/v1/chatbot/stream'),
  );
  
  request.headers['Content-Type'] = 'application/json';
  request.body = jsonEncode({
    'message': message,
    'pet_profile': petProfile,
  });

  final response = await request.send();
  
  await for (var chunk in response.stream.transform(utf8.decoder)) {
    // Parse Server-Sent Events
    final lines = chunk.split('\n');
    for (var line in lines) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (data.trim().isNotEmpty) {
          yield data;
        }
      }
    }
  }
}

// Usage in UI
void _streamChatResponse() async {
  String fullResponse = '';
  
  await for (var chunk in queryChatbotStream(
    message: 'What are signs of dehydration in dogs?',
  )) {
    setState(() {
      fullResponse += chunk;
    });
  }
}
```

**Request:**
```json
POST /api/v1/chatbot/stream
Content-Type: application/json

{
  "message": "What are signs of dehydration in dogs?",
  "pet_profile": {
    "name": "Max",
    "type": "dog",
    "breed": "Labrador"
  }
}
```

**Response (Server-Sent Events):**
```
data: Signs of dehydration in dogs include:

data: 1. **Dry Nose and Gums**

data: - Nose feels dry or warm

data: - Gums are sticky or tacky

data: 2. **Loss of Skin Elasticity**

data: - Gently pinch skin on back of neck

data: - Slow return indicates dehydration

data: [END]
```

---

### 🛠️ Complete Chatbot Service Class

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotService {
  final String baseUrl = 'http://localhost:8081/api/v1';
  
  // Standard query
  Future<Map<String, dynamic>> query({
    required String message,
    Map<String, dynamic>? petProfile,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot/query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'pet_profile': petProfile,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Chatbot query failed: ${response.body}');
    }
  }

  // Streaming query
  Stream<String> queryStream({
    required String message,
    Map<String, dynamic>? petProfile,
  }) async* {
    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/chatbot/stream'),
    );
    
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'message': message,
      'pet_profile': petProfile,
    });

    final response = await request.send();
    
    await for (var chunk in response.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      for (var line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data.trim().isNotEmpty && data != '[END]') {
            yield data;
          }
        }
      }
    }
  }

  // Query with context from pet health journal
  Future<Map<String, dynamic>> queryWithHealthContext({
    required String message,
    required String petId,
    required String accessToken,
  }) async {
    // First, get pet details
    final petResponse = await http.get(
      Uri.parse('$baseUrl/pets/$petId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (petResponse.statusCode != 200) {
      throw Exception('Failed to get pet details');
    }

    final petData = jsonDecode(petResponse.body)['pet'];
    
    // Build pet profile
    final petProfile = {
      'name': petData['name'],
      'type': petData['type'],
      'breed': petData['breed'],
      'age': petData['age'],
      'age_unit': petData['ageUnit'],
      'weight': petData['weight'],
      'weight_unit': petData['weightUnit'],
      'verified_breed': petData['verifiedBreed'],
    };

    // Query chatbot with pet context
    return await query(
      message: message,
      petProfile: petProfile,
    );
  }
}
```

---

### 📊 Example Queries

**General Health:**
```json
{
  "message": "What are common symptoms of kennel cough?"
}
```

**Diet & Nutrition:**
```json
{
  "message": "What foods are toxic to dogs?",
  "pet_profile": {
    "type": "dog",
    "breed": "Beagle",
    "age": 5,
    "age_unit": "years"
  }
}
```

**Emergency Assessment:**
```json
{
  "message": "My dog ate chocolate, what should I do?",
  "pet_profile": {
    "name": "Max",
    "type": "dog",
    "weight": 25,
    "weight_unit": "kg"
  }
}
```

**Breed-Specific Advice:**
```json
{
  "message": "What health issues are common in Golden Retrievers?",
  "pet_profile": {
    "breed": "Golden Retriever",
    "age": 3,
    "age_unit": "years"
  }
}
```

---

### 🧪 Testing RAG Chatbot

**Test with HTML Page:**
```
http://localhost:8081/test/chatbot
```

**Test Streaming:**
```
http://localhost:8081/test/chatbot_stream
```

**Test with PowerShell:**
```powershell
$body = @{
    message = "What vaccines does a puppy need?"
    pet_profile = @{
        type = "dog"
        age = 8
        age_unit = "weeks"
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8081/api/v1/chatbot/query" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

---

### ⚡ Performance

**With FastAPI Server (Recommended):**
- First query: ~1-2 seconds (model warm-up)
- Subsequent queries: ~300-800ms
- Model stays loaded in memory
- 10x faster than exec mode

**Without FastAPI Server (Exec Mode):**
- Each query: ~5-10 seconds
- Model reloads every time
- Fallback mode (works but slow)

**To Start FastAPI Server:**
```bash
cd AI_Chatbot
python chatbot_fastapi_server.py
```

Server logs will show:
```
🚀 Initializing PawPal RAG System...
✅ RAG System ready! Server is now blazing fast!
INFO: Uvicorn running on http://0.0.0.0:8000
```

---

### 🧠 Knowledge Base

The RAG system uses the following data sources:

1. **ASPCA Pet Care Data** - General pet health information
2. **Healthy Pets Data** - Nutrition and wellness guidelines
3. **Medications Database** - Common pet medications and dosages
4. **Dog Health Guides** - Breed-specific health information
5. **Cat Health Guides** - Feline-specific care
6. **Emergency Guidelines** - First aid and emergency care
7. **Nutrition Data** - Diet recommendations by breed/age

**Total Knowledge Base Size:** ~500+ documents, 50k+ tokens

---

### 🔒 Privacy & Security

- ✅ Uses Groq API (not storing conversation data)
- ✅ Pet profiles optional (better context)
- ✅ No authentication required for chatbot endpoint (public)
- ✅ Can be used anonymously
- ✅ No conversation history stored

**Note:** For personalized health tracking, integrate with pet health journals (requires authentication).

---

### 🎨 UI Integration Tips

**Simple Chat Widget:**
```dart
class ChatWidget extends StatefulWidget {
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ChatbotService _chatbot = ChatbotService();
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    try {
      final response = await _chatbot.query(message: userMessage);
      
      setState(() {
        _messages.add(ChatMessage(
          text: response['answer'],
          isUser: false,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return ChatBubble(
                text: message.text,
                isUser: message.isUser,
              );
            },
          ),
        ),
        if (_isLoading) CircularProgressIndicator(),
        ChatInput(
          controller: _controller,
          onSend: _sendMessage,
        ),
      ],
    );
  }
}
```

**Streaming Chat Widget:**
```dart
Future<void> _sendStreamingMessage() async {
  final userMessage = _controller.text;
  _controller.clear();

  setState(() {
    _messages.add(ChatMessage(text: userMessage, isUser: true));
    _messages.add(ChatMessage(text: '', isUser: false)); // Placeholder
  });

  final responseIndex = _messages.length - 1;
  String fullResponse = '';

  await for (var chunk in _chatbot.queryStream(message: userMessage)) {
    fullResponse += chunk;
    setState(() {
      _messages[responseIndex] = ChatMessage(
        text: fullResponse,
        isUser: false,
      );
    });
  }
}
```

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
