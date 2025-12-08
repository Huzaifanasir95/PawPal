# 🐾 PawPal - Complete Setup Guide

This guide will help you set up and run the entire PawPal application stack on Windows.

## 📋 Prerequisites

### Required Software

1. **Go 1.25+** - [Download](https://go.dev/dl/)
2. **Python 3.8+** - [Download](https://www.python.org/downloads/)
3. **Flutter SDK 3.7.2+** - [Download](https://docs.flutter.dev/get-started/install/windows)
4. **Node.js 16+** (optional, for additional tooling) - [Download](https://nodejs.org/)
5. **Git** - [Download](https://git-scm.com/download/win)
6. **Android Studio** (for Flutter development) - [Download](https://developer.android.com/studio)

### Accounts & API Keys Needed

- ✅ **Supabase Account** - [supabase.com](https://supabase.com) (Free tier available)
- ✅ **Groq API Key** - [console.groq.com](https://console.groq.com) (Free tier available)
- ✅ **Firebase Project** - [console.firebase.google.com](https://console.firebase.google.com)

---

## 🚀 Quick Start (Recommended Order)

### Step 1: Backend Setup (Go + Supabase)

#### 1.1 Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note down these values from Settings > API:
   - `Project URL` (SUPABASE_URL)
   - `anon public` key (SUPABASE_ANON_KEY)
   - `service_role` key (SUPABASE_SERVICE_ROLE_KEY)
3. From Settings > Database, note:
   - Connection string (host, password)

#### 1.2 Run Database Migrations

1. Open Supabase SQL Editor
2. Run the migration file:
   ```
   Backend/migrations/001_initial_schema.sql
   ```
3. Verify tables were created in Table Editor

#### 1.3 Configure Backend Environment

```bash
cd Backend
copy .env.example .env
```

Edit `.env` with your actual values:

```env
# Server Configuration
PORT=8081
ENVIRONMENT=development

# Supabase Configuration
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
SUPABASE_JWT_SECRET=your_jwt_secret_here

# Database Configuration
DB_HOST=aws-0-region.pooler.supabase.com
DB_PORT=6543
DB_USER=postgres.YOUR_PROJECT
DB_PASSWORD=your_database_password
DB_NAME=postgres
DB_SSLMODE=require

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_ACCESS_TOKEN_EXPIRY=24h
JWT_REFRESH_TOKEN_EXPIRY=720h

# AI Chatbot Configuration
CHATBOT_API_URL=http://localhost:8000
GROQ_API_KEY=your_groq_api_key_here

# Python
PYTHON_EXECUTABLE=python
```

#### 1.4 Install Go Dependencies

```bash
cd Backend
go mod download
go mod tidy
```

#### 1.5 Build and Run Backend

```bash
# Option 1: Run directly
go run cmd/api/main.go

# Option 2: Build executable first
go build -o pawpal-backend.exe cmd/api/main.go
pawpal-backend.exe
```

Expected output:
```
Starting PawPal Backend API server on port 8081
Access at: http://localhost:8081
```

Test it:
```bash
curl http://localhost:8081/health
```

---

### Step 2: AI Chatbot Setup (Python + FastAPI)

#### 2.1 Create Python Virtual Environment

```bash
cd AI_Chatbot

# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate
```

#### 2.2 Install Python Dependencies

```bash
pip install -r requirements.txt
```

This will install:
- LangChain (RAG framework)
- FastAPI + Uvicorn (API server)
- ChromaDB (vector database)
- Sentence Transformers (embeddings)
- Document loaders (PyPDF, python-docx)

#### 2.3 Configure Groq API Key

Edit `AI_Chatbot/src/rag_pipeline.py` and update the API key (line ~32):

```python
groq_api_key: str = "YOUR_GROQ_API_KEY_HERE",
```

Or set environment variable:
```bash
set GROQ_API_KEY=your_groq_api_key_here
```

#### 2.4 Build Knowledge Base (First Time Only)

```bash
python build_knowledge_base.py
```

This will:
- Process all documents in `knowledge_base/` folder
- Create embeddings
- Store in ChromaDB vector database (`vector_db/` folder)
- Takes 5-10 minutes depending on dataset size

Expected output:
```
📂 Scanning knowledge_base for documents...
Loading PDFs: 100%
Loading Text files: 100%
✅ Knowledge base built successfully!
Total documents: 1500+
```

#### 2.5 Start Chatbot API Server

```bash
python chatbot_fastapi_server.py
```

Expected output:
```
🚀 Initializing PawPal RAG System...
✅ RAG System ready! Server is now blazing fast!
INFO:     Uvicorn running on http://0.0.0.0:8000
```

Test it:
```bash
curl -X POST http://localhost:8000/api/chatbot/query ^
  -H "Content-Type: application/json" ^
  -d "{\"message\": \"What should I feed my dog?\"}"
```

**Keep this terminal open** - the chatbot server needs to run continuously.

---

### Step 3: ML Models Setup (Optional - for Breed Classification)

The ML models are optional if you just want to test the app without breed classification.

#### 3.1 Check if Models Exist

Navigate to:
- `ML_Models/dogs/` - Should contain `.pth` model file
- `ML_Models/cats/` - Should contain `.pth` model file

If models don't exist, you'll need to train them using the Jupyter notebooks in the respective folders.

#### 3.2 Update Model Paths in Backend

Edit `Backend/internal/config/config.go` (lines 69-93) with correct paths:

```go
ModelPath: "d:\\D drive\\SEm 07\\fyp\\project_code\\PawPal\\ML_Models\\dogs\\model\\dog_breed_classifier.pth",
ClassNamesPath: "d:\\D drive\\SEm 07\\fyp\\project_code\\PawPal\\ML_Models\\dogs\\model\\class_names.json",
```

Or use relative paths and set environment variables in `.env`.

---

### Step 4: Flutter App Setup

#### 4.1 Install Flutter Dependencies

```bash
cd App

# Get all dependencies
flutter pub get

# Generate code (for Freezed models)
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 4.2 Configure Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android app to your Firebase project
3. Download `google-services.json` → Place in `App/android/app/`
4. Add iOS app (if targeting iOS)
5. Download `GoogleService-Info.plist` → Place in `App/ios/Runner/`

#### 4.3 Update API Base URL

Edit `App/lib/core/services/api_client.dart` and update the base URL to your backend:

```dart
static const String baseUrl = 'http://localhost:8081/api/v1';
// Or use your computer's IP for physical device testing:
// static const String baseUrl = 'http://192.168.1.XXX:8081/api/v1';
```

#### 4.4 Run Flutter App

**Option 1: Using Emulator**
```bash
# List available devices
flutter devices

# Run on emulator
flutter run
```

**Option 2: Using Physical Device**
```bash
# Enable USB debugging on your Android device
# Connect via USB
flutter devices
flutter run -d <device-id>
```

**Option 3: Chrome (Web)**
```bash
flutter run -d chrome
```

---

## 🔧 Development Workflow

### Running All Services Together

You'll need **3 terminal windows**:

**Terminal 1 - Backend (Go):**
```bash
cd Backend
go run cmd/api/main.go
# Runs on http://localhost:8081
```

**Terminal 2 - AI Chatbot (Python):**
```bash
cd AI_Chatbot
venv\Scripts\activate
python chatbot_fastapi_server.py
# Runs on http://localhost:8000
```

**Terminal 3 - Flutter App:**
```bash
cd App
flutter run
```

---

## 🧪 Testing the Setup

### 1. Test Backend API

```bash
# Health check
curl http://localhost:8081/health

# Sign up test user
curl -X POST http://localhost:8081/api/v1/auth/signup ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"password\":\"Test123!\",\"displayName\":\"Test User\"}"
```

### 2. Test AI Chatbot

```bash
curl -X POST http://localhost:8000/api/chatbot/query ^
  -H "Content-Type: application/json" ^
  -d "{\"message\":\"My dog is coughing, what should I do?\"}"
```

### 3. Test Flutter App

1. Launch app on emulator
2. Complete onboarding
3. Sign up with a new account
4. Select role (Pet Owner or Vet)
5. Add a pet profile
6. Navigate through the app

---

## 📁 Project Structure Reference

```
PawPal/
├── Backend/              # Go API Server
│   ├── cmd/api/         # Entry point
│   ├── internal/        # Core logic
│   ├── .env            # Environment variables (create this)
│   └── go.mod          # Go dependencies
│
├── AI_Chatbot/          # Python RAG Chatbot
│   ├── src/            # RAG pipeline
│   ├── knowledge_base/ # Veterinary documents
│   ├── vector_db/      # ChromaDB storage (generated)
│   ├── venv/           # Virtual environment (create this)
│   └── requirements.txt
│
├── ML_Models/           # Breed Classification Models
│   ├── dogs/           # Dog breed classifier
│   └── cats/           # Cat breed classifier
│
└── App/                 # Flutter Mobile App
    ├── lib/            # Dart source code
    ├── android/        # Android configuration
    ├── ios/            # iOS configuration
    └── pubspec.yaml    # Flutter dependencies
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: Backend Won't Start
**Error:** `Failed to initialize Supabase`
- **Solution:** Check `.env` file has correct Supabase credentials
- Verify Supabase project is active
- Check database migrations were run

### Issue 2: Chatbot Returns Errors
**Error:** `Groq API error`
- **Solution:** Check Groq API key is valid
- Verify API key has not exceeded free tier limits
- Check internet connection

### Issue 3: Flutter Build Errors
**Error:** `build_runner` errors
- **Solution:** 
  ```bash
  flutter clean
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

### Issue 4: Python Module Not Found
**Error:** `ModuleNotFoundError: No module named 'langchain'`
- **Solution:** Activate virtual environment first:
  ```bash
  cd AI_Chatbot
  venv\Scripts\activate
  pip install -r requirements.txt
  ```

### Issue 5: Port Already in Use
**Error:** `bind: address already in use`
- **Solution:** Change port in `.env` or kill process:
  ```bash
  # Find process on port 8081
  netstat -ano | findstr :8081
  # Kill process (replace PID)
  taskkill /PID <PID> /F
  ```

---

## 🔐 Security Notes

**For Development:**
- Default credentials are fine for local testing
- Keep `.env` files in `.gitignore`

**For Production:**
- Generate strong JWT secrets
- Use environment variables, not hardcoded values
- Enable Supabase Row Level Security (RLS)
- Use HTTPS/SSL certificates
- Implement rate limiting

---

## 📚 Additional Resources

- **Backend API Docs:** See `Backend/README.md`
- **Chatbot Docs:** See `AI_Chatbot/README.md`
- **ML Models:** See `ML_Models/README.md`
- **Project Documentation:** See `Documentation/` folder

---

## 🆘 Getting Help

If you encounter issues:

1. Check the error logs in each terminal
2. Verify all environment variables are set correctly
3. Ensure all services are running (Backend + Chatbot)
4. Check firewall/antivirus isn't blocking ports
5. Review the component-specific README files

---

## ✅ Quick Checklist

Before running the app, ensure:

- [ ] Go installed and in PATH
- [ ] Python installed and in PATH
- [ ] Flutter installed and in PATH
- [ ] Supabase project created
- [ ] Database migrations run
- [ ] `.env` file created in Backend
- [ ] Virtual environment created for Python
- [ ] Python dependencies installed
- [ ] Knowledge base built (vector_db exists)
- [ ] Groq API key configured
- [ ] Flutter dependencies installed
- [ ] Firebase configured (google-services.json added)

---

**Happy Coding! 🐾**
