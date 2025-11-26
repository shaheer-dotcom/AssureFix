# Mobile APK Build Guide

## Prerequisites
1. Flutter SDK installed
2. Android SDK installed
3. Your computer and phone on the same WiFi network

## Step 1: Find Your Computer's IP Address

Run this command in CMD:
```bash
ipconfig
```

Look for "IPv4 Address" under your WiFi adapter (e.g., `192.168.1.100`)

## Step 2: Update API Configuration

Open `frontend/lib/config/api_config.dart` and replace the IP address:

```dart
return 'http://YOUR_IP_ADDRESS:5000/api';
```

Example:
```dart
return 'http://192.168.1.100:5000/api';
```

## Step 3: Build the APK

### Option A: Simple Build (using current config)
```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --debug
```

### Option B: Build with custom API URL (no code changes needed)
```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.100:5000/api
```

## Step 4: Install on Your Phone

1. The APK will be located at:
   ```
   frontend/build/app/outputs/flutter-apk/app-debug.apk
   ```

2. Transfer the APK to your phone via:
   - USB cable
   - Email
   - Cloud storage (Google Drive, Dropbox)
   - ADB: `adb install frontend/build/app/outputs/flutter-apk/app-debug.apk`

3. On your phone:
   - Enable "Install from Unknown Sources" in Settings
   - Open the APK file
   - Click "Install"

## Step 5: Start the Backend

Make sure your backend is running and accessible:

```bash
cd backend
npm start
```

The backend should be running on port 5000.

## Testing Checklist

- [ ] Backend is running on your computer
- [ ] Phone and computer are on the same WiFi
- [ ] API URL uses your computer's IP address
- [ ] APK is installed on phone
- [ ] App can connect to backend (test login)

## Troubleshooting

### Cannot connect to backend
- Check if backend is running: `http://YOUR_IP:5000/api` in browser
- Check firewall settings (allow port 5000)
- Verify both devices are on same network
- Try pinging your computer from phone

### Build fails
- Run `flutter doctor` to check setup
- Make sure Android SDK is installed
- Update Flutter: `flutter upgrade`

### APK won't install
- Enable "Install from Unknown Sources"
- Check if you have enough storage
- Try uninstalling previous version first

## Production Build

For a release build (smaller size, better performance):

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://YOUR_SERVER_URL/api
```

Note: Release builds require signing keys. For testing, debug builds are sufficient.
