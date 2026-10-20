# 📱 DER LENG AI - Web Scanning & APK Portal (Vite + React)

A modern, high-performance web portal for scanning to install the DER LENG AI Android APK.

---

## 🚀 How to Run

In this folder (`C:\Flutter_AI\web-flutter-AI-for-scanning-to-get-the-app\web-scanning`):

```bash
# Start Vite development server (accessible over Wi-Fi)
npm run dev
# or double-click dev.bat
```

### URLs:
- **Local PC**: `http://localhost:5173`
- **Phone / Wi-Fi**: `http://192.168.100.219:5173`
- **Direct APK**: `http://192.168.100.219:5173/app-release.apk`

---

## 📂 APK File Location
Your APK file is located in:
```
public/app-release.apk
```
Any file in `public/` is directly served by Vite and ready for 1-click download.

### To Update APK:
Whenever you build a new APK in Flutter:
```powershell
.\update-apk.ps1
# or double-click update-apk.bat
```
