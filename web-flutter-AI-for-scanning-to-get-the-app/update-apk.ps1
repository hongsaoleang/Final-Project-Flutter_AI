# Script to copy the latest built APK to the web distribution folder
$sourceApk = "C:\Flutter_AI\frontend_ai\ai_app\build\app\outputs\flutter-apk\app-release.apk"
$targetDir = $PSScriptRoot
$targetWeb = Join-Path $targetDir "web\app-release.apk"
$targetDownloads = Join-Path $targetDir "web\downloads\app-release.apk"

if (Test-Path $sourceApk) {
    Write-Host "Found APK: $sourceApk" -ForegroundColor Green
    Copy-Item $sourceApk $targetWeb -Force
    Copy-Item $sourceApk $targetDownloads -Force
    $sizeMb = [math]::Round((Get-Item $targetWeb).Length / 1MB, 2)
    Write-Host "Successfully updated APK for download ($sizeMb MB)!" -ForegroundColor Cyan
    Write-Host "Destination: $targetWeb" -ForegroundColor Gray
} else {
    Write-Host "Could not find $sourceApk" -ForegroundColor Yellow
    Write-Host "You can manually place your .apk file at: $targetWeb" -ForegroundColor White
}
