# 📱 DER LENG AI - Web Scanner & APK Download Portal

A responsive Flutter Web application designed for distributing Android APKs with instant dynamic QR code scanning and direct download capabilities.

---

## 🚀 Features

- **Dynamic QR Code**: Generates real-time QR codes that mobile phones can scan directly to download the `.apk` file or view the download landing page.
- **Direct APK Download**: One-click download button and direct file link (`/app-release.apk`).
- **LAN / WiFi IP Support**: Automatically supports your PC's local WiFi IP (e.g., `192.168.100.219:8085`) so smartphones connected to the same WiFi can scan and download without setup.
- **Android Install Guide**: Integrated 3-step instructions guiding users on enabling "Install Unknown Apps" on Android.
- **Modern Responsive UI**: Works across desktops, laptops, tablets, and mobile devices with light/dark theme support.

---

## 📂 Where to Put Your APK File

Your APK file is placed in:
```
web/app-release.apk
```
When built with `flutter build web`, it is automatically bundled into:
```
build/web/app-release.apk
```

### Automatic APK Update Script
Whenever you rebuild your main Flutter app (`frontend_ai/ai_app`), run:
```powershell
.\update-apk.ps1
# or double-click update-apk.bat
```
This automatically copies `frontend_ai\ai_app\build\app\outputs\flutter-apk\app-release.apk` to this website.

---

## 🌐 How to Run the Website

### Option 1: Instant Production Server (Fastest)
Double-click `serve-built-web.bat` or run:
```powershell
.\serve-built-web.ps1
```
This serves the production website on port **8085** bound to `0.0.0.0`.
- **Local PC**: `http://localhost:8085`
- **Phone / WiFi**: `http://192.168.100.219:8085`

### Option 2: Flutter Development Server
```powershell
flutter run -d chrome
# or to allow external phones on your WiFi:
.\start-server.ps1
```

---

## 📲 How Users Install the APK

1. Point your phone camera at the QR code displayed on the website.
2. Tap the link to begin downloading `app-release.apk`.
3. If Android prompts *"File might be harmful"*, tap **Download anyway**.
4. Open the downloaded file, allow **Install unknown apps** if requested, and tap **Install**.
