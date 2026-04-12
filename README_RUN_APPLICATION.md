# PawPal - Complete Setup and Run Guide (Windows)

This document explains all required tools, installation steps, environment setup, and service startup order for the full PawPal project.

## 1) What You Are Running

PawPal consists of multiple apps/services:

1. Backend API (Go + Gin + Supabase PostgreSQL)
2. Mobile/Desktop client app (Flutter)
3. AI chatbot service (Python FastAPI, optional but recommended)
4. Admin portal (Next.js, optional)

## 2) System Requirements

Minimum machine recommendations:

1. OS: Windows 10/11 (64-bit)
2. RAM: 8 GB minimum, 16 GB recommended
3. Free disk: 10+ GB (more if you add ML model files)
4. Internet: required for package install and Supabase access

## 3) Required Software and How to Install

Install these tools before running the project.

### 3.1 Core tools

1. Git
2. Go (required by Backend)
3. Flutter SDK (required by App)
4. Python 3.9+ (required by AI_Chatbot and prediction script)
5. Node.js 18+ and npm (required by admin-portal)

Optional install using winget:

```bat
winget install Git.Git
winget install GoLang.Go
winget install Python.Python.3.11
winget install OpenJS.NodeJS.LTS
```

Install Flutter from official docs:

1. Download Flutter SDK zip
2. Extract to a stable path (example: `C:\src\flutter`)
3. Add `C:\src\flutter\bin` to PATH

### 3.2 Windows-specific Flutter requirements

For Windows desktop build/run:

1. Visual Studio 2022 with Desktop development with C++ workload
2. Windows Developer Mode enabled (needed for symlinks)

Enable Developer Mode:

```bat
start ms-settings:developers
```

For Android emulator (optional):

1. Android Studio
2. Android SDK + platform tools
3. At least one AVD emulator

### 3.3 Verify your installation

Run these commands and confirm versions are returned:

```bat
git --version
go version
flutter --version
flutter doctor -v
python --version
node --version
npm --version
```

## 4) Repository Paths

Assuming root path:

`d:\D drive\SEm 08\FYP\PawPal`

Main modules:

1. Backend: `Backend`
2. Flutter app: `App`
3. Chatbot: `AI_Chatbot`
4. Admin portal: `admin-portal`

## 5) Backend Setup (Required)

### 5.1 Configure environment variables

You already created `Backend/.env`, which is good.

Important keys for backend startup:

1. `PORT` (default: `8081`)
2. `SupabaseConnectionString` or `SUPABASE_CONNECTION_STRING`
3. `SUPABASE_JWT_SECRET` (or `JWT_SECRET`)

Important keys for prediction endpoints (`/predict`):

1. `PYTHON_PATH`
2. `PYTHON_SCRIPT_PATH`
3. `DOG_MODEL_PATH`
4. `DOG_CLASS_NAMES_PATH`
5. `CAT_MODEL_PATH`
6. `CAT_CLASS_NAMES_PATH`
7. `USE_GPU` (optional)
8. `USE_TTA` (optional)

Note: `Backend/.env.example` contains some legacy key names. Use the key names above for the current backend code.

### 5.2 Optional one-time migration

If database tables are not created yet:

```bat
cd /d "d:\D drive\SEm 08\FYP\PawPal\Backend"
go run run_migration.go
```

### 5.3 Start backend API

Open Terminal A:

```bat
cd /d "d:\D drive\SEm 08\FYP\PawPal\Backend"
go run cmd/api/main.go
```

Expected startup messages:

1. Connected to Supabase
2. Routes listed by Gin
3. Listening on `:8081`

### 5.4 Verify backend health

Open Terminal B:

```bat
curl http://localhost:8081/health
```

If healthy JSON returns, backend is running correctly.

## 6) Flutter App Setup (Required)

### 6.1 Configure API base URL

File to edit:

`App/lib/core/config/app_config.dart`

For local backend on same machine (recommended):

```dart
static const String ngrokUrl = '';
```

For ngrok tunnel mode:

```dart
static const String ngrokUrl = 'https://YOUR-NGROK-URL.ngrok-free.dev';
```

If using ngrok mode, run:

```bat
ngrok http 8081
```

### 6.2 Install Flutter dependencies

Open Terminal C:

```bat
cd /d "d:\D drive\SEm 08\FYP\PawPal\App"
flutter pub get
flutter devices
```

### 6.3 Run Flutter app

Fastest option (web):

```bat
flutter run -d chrome
```

Windows desktop option:

```bat
flutter run -d windows
```

Android emulator option:

```bat
flutter emulators
flutter emulators --launch <emulator_id>
flutter run -d <device_id>
```

## 7) AI Chatbot Setup (Optional but Recommended)

Backend can run without chatbot server. If chatbot API is not running, backend falls back to slower exec mode.

### 7.1 Create Python venv and install packages

Open Terminal D:

```bat
cd /d "d:\D drive\SEm 08\FYP\PawPal\AI_Chatbot"
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

### 7.2 Build vector DB

```bat
python build_knowledge_base.py
```

### 7.3 Run chatbot FastAPI server

```bat
python chatbot_fastapi_server.py
```

### 7.4 Verify chatbot health

```bat
curl http://localhost:8000/health
```

## 8) Admin Portal Setup (Optional)

Open Terminal E:

```bat
cd /d "d:\D drive\SEm 08\FYP\PawPal\admin-portal"
copy .env.local.example .env.local
npm install
npm run dev
```

Open in browser:

`http://localhost:3000`

## 9) Recommended Terminal Layout

Use this layout for full local stack:

1. Terminal A: Backend (`go run cmd/api/main.go`)
2. Terminal B: Health checks / curl testing
3. Terminal C: Flutter app (`flutter run ...`)
4. Terminal D: AI chatbot (optional)
5. Terminal E: Admin portal (optional)

## 10) Common Errors and Fixes

### Error: `bind: Only one usage of each socket address`

Cause: Port 8081 already used by another backend process.

Fix:

```bat
netstat -ano | findstr :8081
tasklist /FI "PID eq <PID>"
taskkill /PID <PID> /F
```

Then restart backend once.

### Error: `Building with plugins requires symlink support`

Fix:

1. Enable Developer Mode
2. Reopen terminal
3. Run `flutter run -d windows` again

### Backend starts but API calls fail from app

Fix:

1. Recheck `ngrokUrl` in `app_config.dart`
2. Use local mode (`''`) if backend is local
3. If ngrok mode, ensure tunnel is active and URL matches exactly

### Database connection fails

Fix:

1. Confirm `SupabaseConnectionString` in `Backend/.env`
2. Confirm connection string is valid and SSL mode is correct
3. Confirm network/firewall allows outbound connection

### `/predict` endpoint fails

Fix:

1. Confirm prediction script path exists (`Backend/scripts/python/predict.py`)
2. Set `PYTHON_PATH` and `PYTHON_SCRIPT_PATH`
3. Set correct model/class names paths (`DOG_MODEL_PATH`, `DOG_CLASS_NAMES_PATH`, `CAT_MODEL_PATH`, `CAT_CLASS_NAMES_PATH`)
4. Ensure those files actually exist on disk

### Chatbot warning in backend logs

Message about FastAPI chatbot not running is non-blocking.

To remove warning and improve speed, start chatbot server on port 8000.

## 11) Security Checklist (Important)

If secret keys were shared in screenshots/messages:

1. Rotate Supabase service role key
2. Rotate DB password/connection string
3. Rotate JWT secret
4. Update `.env` and `.env.local` files after rotation

Do not commit secret keys to Git.

## 12) Stop All Running Services

In each terminal where a service is running:

1. Press `Ctrl + C`

## 13) Quick Start Summary

If you only want the core app quickly:

1. Start backend in `Backend`
2. Confirm `http://localhost:8081/health`
3. Set Flutter `ngrokUrl = ''`
4. Run Flutter (`flutter run -d chrome`)

You are done.