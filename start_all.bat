@echo off
title MyAI Platform Launcher
echo ===================================================
echo   Starting MyAI Multimodal Platform
echo ===================================================

echo [1/3] Starting Python AI Service on port 8000...
start "MyAI - Python AI Service" powershell -NoExit -Command "cd C:\Flutter_AI; .\ai\.venv\Scripts\python.exe -m uvicorn main:app --app-dir ai --host 0.0.0.0 --port 8000"

echo [2/3] Starting Spring Boot Backend on port 8080...
start "MyAI - Spring Boot Backend" powershell -NoExit -Command "cd C:\Flutter_AI\backend_ai\ai; .\mvnw.cmd spring-boot:run"

echo Waiting 5 seconds for backend services to initialize...
timeout /t 5 /nobreak >nul

echo [3/3] Starting Flutter Frontend in Chrome...
cd C:\Flutter_AI\frontend_ai\ai_app
flutter run -d chrome

pause
