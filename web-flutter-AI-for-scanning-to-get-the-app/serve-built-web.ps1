# Serve the production web app using Python HTTP server
$localIp = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } | Select-Object -ExpandProperty IPAddress | Select-Object -Last 1)
$port = 8085
$webDir = Join-Path $PSScriptRoot "build\web"

if (-not (Test-Path $webDir)) {
    Write-Host "Production build not found. Running flutter build web..." -ForegroundColor Yellow
    flutter build web --release
}

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "       DER LENG AI - Web Server (Production)               " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "Access URL (Localhost): http://localhost:$port" -ForegroundColor White
Write-Host "Scan/Access URL (LAN):  http://$($localIp):$port" -ForegroundColor Yellow
Write-Host "Direct APK File:        http://$($localIp):$port/app-release.apk" -ForegroundColor White
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "Serving files from: $webDir" -ForegroundColor Gray
Write-Host "Press Ctrl+C to stop the server." -ForegroundColor Yellow

$pythonExe = "python"
if (Test-Path "C:\Flutter_AI\ai\.venv\Scripts\python.exe") {
    $pythonExe = "C:\Flutter_AI\ai\.venv\Scripts\python.exe"
}

& $pythonExe -m http.server $port --directory $webDir --bind 0.0.0.0
