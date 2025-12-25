@echo off
echo ========================================
echo    UNIVERSAL APK TESTING GUIDE
echo ========================================
echo.

echo APK Details:
echo - File: frontend\build\app\outputs\flutter-apk\app-release.apk
echo - Size: ~299MB (Universal - all architectures)
echo - Compatibility: Android 4.4+ (API 19) to Android 14+
echo - Architectures: arm64-v8a, armeabi-v7a, x86, x86_64
echo.

echo ========================================
echo    VOICE RECORDING - NEW METHOD
echo ========================================
echo.
echo How to use Voice Recording:
echo 1. Tap the microphone button to START recording
echo 2. You'll see a red recording indicator with timer
echo 3. Tap the GREEN SEND button to send the voice note
echo 4. Tap the RED CANCEL button to cancel recording
echo.
echo Key Changes:
echo - No more long-press (was unreliable)
echo - Clear visual feedback with timer
echo - Separate send/cancel buttons
echo - Better state management
echo.

echo ========================================
echo    LOCATION SHARING - SIMPLIFIED
echo ========================================
echo.
echo How to use Location Sharing:
echo 1. Tap attachment button (paperclip)
echo 2. Select "Location"
echo 3. Allow location permissions
echo 4. Location will be sent with address
echo.
echo How to open Location Links:
echo 1. Tap on received location message
echo 2. Will try to open in maps app
echo 3. If no maps app, opens in browser
echo 4. If that fails, shows coordinates to copy
echo.

echo ========================================
echo    INSTALLATION INSTRUCTIONS
echo ========================================
echo.
echo For ALL Android devices (4.4+):
echo.
echo 1. Enable Unknown Sources:
echo    - Android 8+: Settings ^> Apps ^> Special access ^> Install unknown apps
echo    - Android 7-: Settings ^> Security ^> Unknown sources
echo.
echo 2. Transfer APK to device:
echo    - USB cable, Bluetooth, or cloud storage
echo    - File location: frontend\build\app\outputs\flutter-apk\app-release.apk
echo.
echo 3. Install APK:
echo    - Tap the APK file on device
echo    - Follow installation prompts
echo    - Grant permissions when asked
echo.
echo 4. Required Permissions:
echo    - Microphone (for voice recording)
echo    - Location (for location sharing)
echo    - Camera (for photos)
echo    - Storage (for media files)
echo.

echo ========================================
echo    TROUBLESHOOTING
echo ========================================
echo.
echo If Voice Recording doesn't work:
echo 1. Check microphone permission in Settings ^> Apps ^> AssureFix ^> Permissions
echo 2. Try restarting the app
echo 3. Make sure device has enough storage space
echo 4. Test with shorter recordings (under 1 minute)
echo.
echo If Location Links don't open:
echo 1. Install Google Maps or any maps app
echo 2. Check location permission in Settings ^> Apps ^> AssureFix ^> Permissions
echo 3. Enable GPS/Location services in device settings
echo 4. If still fails, coordinates will be shown to copy manually
echo.
echo If App crashes on startup:
echo 1. Clear app data: Settings ^> Apps ^> AssureFix ^> Storage ^> Clear Data
echo 2. Restart device
echo 3. Reinstall APK
echo 4. Make sure device has at least 1GB free storage
echo.

echo ========================================
echo    TESTING CHECKLIST
echo ========================================
echo.
echo Test these features after installation:
echo.
echo [ ] App launches without crashing
echo [ ] Login works correctly
echo [ ] Chat messages send/receive
echo [ ] Voice recording: Tap mic ^> Record ^> Tap send
echo [ ] Location sharing: Attachment ^> Location
echo [ ] Location links: Tap location message
echo [ ] Photo sharing: Attachment ^> Camera/Gallery
echo [ ] Voice calls work
echo.

echo ========================================
echo    BACKEND CONNECTION
echo ========================================
echo.
echo Make sure backend is running:
curl -s http://192.168.100.7:5000/api/health > nul
if %errorlevel% equ 0 (
    echo ✓ Backend is running on 192.168.100.7:5000
) else (
    echo ✗ Backend is not running
    echo   Please start backend server first
    echo   Run: start_backend.bat
)
echo.
echo Make sure phone is on same WiFi network (192.168.100.x)
echo.

echo ========================================
echo    APK READY FOR TESTING
echo ========================================
echo.
echo The universal APK is now ready and should work on:
echo - All Android versions (4.4 to 14+)
echo - All device architectures (32-bit, 64-bit, Intel)
echo - All Android phone brands (Samsung, Xiaomi, OnePlus, etc.)
echo.
echo Install and test the voice recording and location features!
echo.
pause