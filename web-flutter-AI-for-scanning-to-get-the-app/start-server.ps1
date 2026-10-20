# Start the Flutter Web APK Distribution Site
$localIp = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } | Select-Object -ExpandProperty IPAddress | Select-Object -Last 1)
$port = 8085

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "     DER LENG AI - APK Download & QR Portal Server         " -ForegroundColor Green
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "Your Local LAN IP:  http://$($localIp):$port" -ForegroundColor Yellow
Write-Host "Localhost URL:      http://localhost:$port" -ForegroundColor White
Write-Host "Direct APK File:    http://$($localIp):$port/app-release.apk" -ForegroundColor White
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "Starting web server on 0.0.0.0:$port (accessible by mobile)..." -ForegroundColor Gray

flutter run -d web-server --web-hostname 0.0.0.0 --web-port $port
