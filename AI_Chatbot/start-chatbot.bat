@echo off
REM PawPal - AI Chatbot Startup Script

echo Starting PawPal AI Chatbot Server...
echo.

cd AI_Chatbot

if not exist "venv" (
    echo [ERROR] Virtual environment not found!
    echo Creating virtual environment...
    python -m venv venv
    echo.
    echo Installing dependencies...
    call venv\Scripts\activate
    pip install -r requirements.txt
)

echo Activating virtual environment...
call venv\Scripts\activate

if not exist "vector_db" (
    echo.
    echo [WARNING] Vector database not found!
    echo Building knowledge base (this will take 5-10 minutes)...
    python build_knowledge_base.py
)

echo.
echo Starting FastAPI server on port 8000...
echo Press Ctrl+C to stop
echo.

python chatbot_fastapi_server.py

pause
