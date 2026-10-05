# MyAI - PowerShell One-Click Launcher
$rootDir = $PSScriptRoot

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "          Starting MyAI Project Services           " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# 1. Python FastAPI Backend (Port 8000)
Write-Host "[1/3] Starting Python AI Service (Port 8000)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$rootDir\ai'; .\.venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload"

# 2. Java Spring Boot Backend (Port 8080)
Write-Host "[2/3] Starting Java Spring Boot Backend (Port 8080)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$rootDir\backend_ai\ai'; .\mvnw.cmd spring-boot:run"

# 3. Flutter Web App
Write-Host "[3/3] Starting Flutter Web App (Chrome)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$rootDir\frontend_ai\ai_app'; flutter run -d chrome"

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "All 3 services are launching in their own windows!" -ForegroundColor Yellow
Write-Host " - Python AI Service:  http://localhost:8000/docs" -ForegroundColor White
Write-Host " - Spring Boot API:    http://localhost:8080" -ForegroundColor White
Write-Host " - Flutter Web App:    Launching Chrome..." -ForegroundColor White
Write-Host "===================================================" -ForegroundColor Cyan
