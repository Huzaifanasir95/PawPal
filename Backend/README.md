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
