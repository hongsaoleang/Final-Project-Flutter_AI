@echo off
title MyAI - Launch All Services
echo ===================================================
echo           Starting MyAI Project Services
echo ===================================================

cd /d "%~dp0"

echo [1/3] Starting Python AI Service (Port 8000)...
start "MyAI - Python AI Service" cmd /k "cd ai && .\.venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload"

echo [2/3] Starting Java Spring Boot Backend (Port 8080)...
start "MyAI - Spring Boot Backend" cmd /k "cd backend_ai\ai && mvnw.cmd spring-boot:run"

echo [3/3] Starting Flutter App (Chrome)...
start "MyAI - Flutter Web" cmd /k "cd frontend_ai\ai_app && flutter run -d chrome"

echo ===================================================
echo All 3 services have been launched in separate windows!
echo - Python AI:     http://localhost:8000/docs
echo - Spring Boot:   http://localhost:8080
echo - Flutter App:   Running on Chrome
echo ===================================================
pause
