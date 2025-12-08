@echo off
REM PawPal - Quick Setup Script for Windows
REM This script helps verify prerequisites and setup the environment

echo ========================================
echo PawPal Quick Setup Check
echo ========================================
echo.

echo [1/6] Checking Go installation...
where go >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Go not found! Please install Go from https://go.dev/dl/
    set GO_INSTALLED=0
) else (
    go version
    set GO_INSTALLED=1
)
echo.

echo [2/6] Checking Python installation...
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Python not found! Please install Python from https://python.org
    set PYTHON_INSTALLED=0
) else (
    python --version
    set PYTHON_INSTALLED=1
)
echo.

echo [3/6] Checking Flutter installation...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Flutter not found! Please install Flutter from https://flutter.dev
    set FLUTTER_INSTALLED=0
) else (
    flutter --version | findstr "Flutter"
    set FLUTTER_INSTALLED=1
)
echo.

echo [4/6] Checking Git installation...
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Git not found! Please install Git from https://git-scm.com
    set GIT_INSTALLED=0
) else (
    git --version
    set GIT_INSTALLED=1
)
echo.

echo [5/6] Checking project structure...
if exist "Backend\go.mod" (
    echo [OK] Backend folder found
) else (
    echo [X] Backend folder not found!
)

if exist "AI_Chatbot\requirements.txt" (
    echo [OK] AI_Chatbot folder found
) else (
    echo [X] AI_Chatbot folder not found!
)

if exist "App\pubspec.yaml" (
    echo [OK] App folder found
) else (
    echo [X] App folder not found!
)
echo.

echo [6/6] Checking environment files...
if exist "Backend\.env" (
    echo [OK] Backend .env file exists
) else (
    echo [!] Backend .env file NOT found - you need to create it from .env.example
)

if exist "AI_Chatbot\venv" (
    echo [OK] Python virtual environment exists
) else (
    echo [!] Python virtual environment NOT found - run: python -m venv AI_Chatbot\venv
)

if exist "AI_Chatbot\vector_db" (
    echo [OK] Vector database exists
) else (
    echo [!] Vector database NOT found - run build_knowledge_base.py
)
echo.

echo ========================================
echo Setup Summary
echo ========================================

if %GO_INSTALLED%==1 if %PYTHON_INSTALLED%==1 if %FLUTTER_INSTALLED%==1 if %GIT_INSTALLED%==1 (
    echo [OK] All required tools are installed!
    echo.
    echo Next steps:
    echo 1. Create Backend\.env from Backend\.env.example
    echo 2. Update it with your Supabase credentials
    echo 3. Run: cd Backend ^&^& go mod download
    echo 4. Create Python venv: cd AI_Chatbot ^&^& python -m venv venv
    echo 5. Install Python deps: venv\Scripts\activate ^&^& pip install -r requirements.txt
    echo 6. Build knowledge base: python build_knowledge_base.py
    echo 7. Install Flutter deps: cd App ^&^& flutter pub get
    echo.
    echo Then run the start-all-services.bat script to start everything!
) else (
    echo [X] Some required tools are missing. Please install them first.
    echo.
    echo See SETUP_GUIDE.md for detailed installation instructions.
)
echo.
pause
