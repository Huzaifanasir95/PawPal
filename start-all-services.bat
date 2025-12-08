@echo off
REM PawPal - Start All Services
REM This script starts Backend, AI Chatbot, and Flutter app in separate windows

echo ========================================
echo Starting PawPal Services
echo ========================================
echo.

REM Check if .env exists
if not exist "Backend\.env" (
    echo [ERROR] Backend\.env file not found!
    echo Please create it from Backend\.env.example and configure it.
    pause
    exit /b 1
)

echo [1/3] Starting Backend API Server (Go)...
start "PawPal Backend" cmd /k "cd Backend && go run cmd\api\main.go"
timeout /t 3 /nobreak >nul

echo [2/3] Starting AI Chatbot Server (Python)...
start "PawPal Chatbot" cmd /k "cd AI_Chatbot && venv\Scripts\activate && python chatbot_fastapi_server.py"
timeout /t 5 /nobreak >nul

echo [3/3] Starting Flutter App...
start "PawPal Flutter" cmd /k "cd App && flutter run"

echo.
echo ========================================
echo All services started!
echo ========================================
echo.
echo Backend API:     http://localhost:8081
echo Chatbot API:     http://localhost:8000
echo Flutter App:     Running in emulator/device
echo.
echo Press any key to stop all services...
pause >nul

REM Kill all services
taskkill /FI "WindowTitle eq PawPal Backend*" /T /F >nul 2>&1
taskkill /FI "WindowTitle eq PawPal Chatbot*" /T /F >nul 2>&1
taskkill /FI "WindowTitle eq PawPal Flutter*" /T /F >nul 2>&1

echo.
echo All services stopped.
pause
