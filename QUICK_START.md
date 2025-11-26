# Quick Start Guide - AssureFix Mobile Testing

## 🚀 Get Started in 3 Steps

### Step 1: Setup Firewall (One-time setup)
Right-click `setup_firewall.bat` → **Run as Administrator**

This allows mobile devices to connect to your backend.

### Step 2: Start Backend
Double-click `start_backend.bat`

Wait for:
```
🚀 Server running on port 5000
📱 Mobile API endpoint: http://192.168.100.7:5000/api
```

### Step 3: Install APK on Mobile
1. Transfer `frontend/build/app/outputs/flutter-apk/app-release.apk` to your phone
2. Install the APK
3. Open AssureFix app

## ✅ Requirements
- Mobile device on same Wi-Fi network (192.168.100.x)
- Backend running on your computer
- Firewall configured (Step 1)

## 📱 APK Details
- **Location**: `frontend/build/app/outputs/flutter-apk/app-release.apk`
- **Size**: 52MB
- **API Endpoint**: `http://192.168.100.7:5000/api`
- **Compatible**: Android 5.0+ (API 21+)

## 🔧 If Something Goes Wrong

### App won't install
- Enable "Install from Unknown Sources" in phone settings

### App crashes on open
- Grant all permissions when prompted
- Reinstall the APK

### "Network Error" in app
1. Check mobile is on Wi-Fi (192.168.100.x)
2. Check backend is running
3. Test in mobile browser: `http://192.168.100.7:5000/api/health`

### Backend not accessible
- Run `setup_firewall.bat` as Administrator
- Restart backend with `start_backend.bat`

## 📖 Full Documentation
See `MOBILE_TESTING_GUIDE.md` for detailed instructions.

## 🔄 Rebuild APK (if needed)
If your computer's IP changes, run:
```bash
build_apk.bat
```

---

**Current Configuration**
- Computer IP: `192.168.100.7`
- Backend Port: `5000`
- Build Date: Nov 20, 2024
