$sourceApk = "C:\Flutter_AI\frontend_ai\ai_app\build\app\outputs\flutter-apk\app-release.apk"
$targetPublic = Join-Path $PSScriptRoot "public\app-release.apk"
$targetDist = Join-Path $PSScriptRoot "dist\app-release.apk"

if (Test-Path $sourceApk) {
    Copy-Item $sourceApk $targetPublic -Force
    if (Test-Path (Join-Path $PSScriptRoot "dist")) {
        Copy-Item $sourceApk $targetDist -Force
    }
    $sizeMb = [math]::Round((Get-Item $targetPublic).Length / 1MB, 2)
    Write-Host "Updated APK: $targetPublic ($sizeMb MB)" -ForegroundColor Green
} else {
    Write-Host "Source APK not found at $sourceApk" -ForegroundColor Yellow
}
