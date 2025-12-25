# Quick Start - Build & Test

## 1. Update IP Address ⚠️

**File**: `frontend/lib/config/api_config.dart`

```dart
static const String _localNetworkIp = 'YOUR_IP_HERE'; // ← Change this!
```

**Find your IP**:
```bash
ipconfig
```
Look for "IPv4 Address" under WiFi adapter.

---

## 2. Build APK

```bash
build_apk.bat
```

Wait for build to complete (~5-10 minutes).

---

## 3. Install

**APK Location**: `frontend/build/app/outputs/flutter-apk/app-release.apk`

Transfer to phone and install.

---

## 4. Test

1. Open app
2. Login with credentials
3. Should navigate to home screen

---

## Requirements

- ✅ Android 11+ device
- ✅ Phone on same WiFi as computer
- ✅ Backend server running

---

## APK Size

**~250 MB** - This is normal and required for login to work.

---

## Issues?

See `FINAL_FIX_SUMMARY.md` for troubleshooting.

---

**That's it!** Your app is ready to use. 🚀
