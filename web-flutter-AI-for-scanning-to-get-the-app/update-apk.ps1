# Script to copy the latest built APK to the web distribution folder
$sourceApk = "C:\Flutter_AI\frontend_ai\ai_app\build\app\outputs\flutter-apk\app-release.apk"
$targetDir = $PSScriptRoot

$destinations = @(
    (Join-Path $targetDir "web\app-release.apk"),
    (Join-Path $targetDir "web\downloads\app-release.apk"),
    (Join-Path $targetDir "build\web\app-release.apk"),
    (Join-Path $targetDir "build\web\downloads\app-release.apk"),
    (Join-Path $targetDir "web-scanning\public\app-release.apk"),
    (Join-Path $targetDir "web-scanning\dist\app-release.apk")
)

if (Test-Path $sourceApk) {
    Write-Host "Found APK: $sourceApk" -ForegroundColor Green
    foreach ($dest in $destinations) {
        $parent = Split-Path -Path $dest -Parent
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Copy-Item $sourceApk $dest -Force
        Write-Host "Copied to: $dest" -ForegroundColor Gray
    }
    $sizeMb = [math]::Round((Get-Item $sourceApk).Length / 1MB, 2)
    Write-Host "Successfully updated APK across all web download targets ($sizeMb MB)!" -ForegroundColor Cyan
} else {
    Write-Host "Could not find $sourceApk" -ForegroundColor Yellow
}
