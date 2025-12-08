@echo off
REM PawPal - Backend Only Startup Script
REM Quick start for backend development

echo Starting PawPal Backend API...
echo.

cd Backend

if not exist ".env" (
    echo [ERROR] .env file not found!
    echo Creating from .env.example...
    copy .env.example .env
    echo.
    echo Please edit Backend\.env with your Supabase credentials before running.
    pause
    exit /b 1
)

echo Checking Go dependencies...
go mod download
go mod tidy

echo.
echo Starting server on port 8081...
echo Press Ctrl+C to stop
echo.

go run cmd\api\main.go

pause
