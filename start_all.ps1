# ============================================================
# MyAI Platform - Master Startup Script
# Starts:
#   1. PostgreSQL Database (Port 5433)
#   2. Python AI Orchestrator & PyTorch Engine (Port 8000)
#   3. Spring Boot REST Backend (Port 8080)
#   4. Flutter Multimodal Frontend (Chrome)
# ============================================================

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  Starting MyAI Multimodal AI Platform" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 1. Verify PostgreSQL Service
Write-Host "[1/4] Checking PostgreSQL service..." -ForegroundColor Yellow
$pgService = Get-Service -Name "postgresql-x64-18" -ErrorAction SilentlyContinue
if ($pgService -and $pgService.Status -ne "Running") {
    Start-Service -Name "postgresql-x64-18"
    Write-Host "  Started PostgreSQL 18 service." -ForegroundColor Green
} else {
    Write-Host "  PostgreSQL 18 is running on port 5433." -ForegroundColor Green
}

# 2. Start Python AI Service (Port 8000) in new window
Write-Host "[2/4] Launching Python AI Engine (FastAPI on port 8000)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:\Flutter_AI; .\ai\.venv\Scripts\python.exe -m uvicorn main:app --app-dir ai --host 0.0.0.0 --port 8000"

# 3. Start Spring Boot Backend (Port 8080) in new window
Write-Host "[3/4] Launching Spring Boot Backend (Port 8080)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:\Flutter_AI\backend_ai\ai; .\mvnw.cmd spring-boot:run"

# Wait 5 seconds for backend services to bind
Write-Host "Waiting 5 seconds for backend servers to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# 4. Launch Flutter Frontend in Chrome
Write-Host "[4/4] Launching Flutter Frontend..." -ForegroundColor Yellow
cd C:\Flutter_AI\frontend_ai\ai_app
flutter run -d chrome
