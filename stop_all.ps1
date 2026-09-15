Write-Host "Stopping all MyAI background services..." -ForegroundColor Cyan

# Stop Python uvicorn on port 8000
$port8000 = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if ($port8000) {
    Stop-Process -Id $port8000.OwningProcess -Force -ErrorAction SilentlyContinue
    Write-Host "Stopped Python AI engine on port 8000." -ForegroundColor Green
}

# Stop Java Spring Boot on port 8080
$port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($port8080) {
    Stop-Process -Id $port8080.OwningProcess -Force -ErrorAction SilentlyContinue
    Write-Host "Stopped Spring Boot backend on port 8080." -ForegroundColor Green
}

Write-Host "All MyAI services stopped." -ForegroundColor Cyan
