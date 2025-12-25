@echo off
echo Testing Voice and Location Permissions...
echo.

echo Checking if backend is running...
curl -s http://192.168.100.7:5000/api/health > nul
if %errorlevel% equ 0 (
    echo ✓ Backend is running
) else (
    echo ✗ Backend is not running - please start it first
    echo Run: start_backend.bat
    pause
    exit /b 1
)

echo.
echo Permission troubleshooting steps:
echo.
echo 1. Voice Recording Issues:
echo    - Go to Settings ^> Apps ^> AssureFix ^> Permissions
echo    - Enable Microphone permission
echo    - Make sure "Allow only while using the app" is selected
echo.
echo 2. Location Sharing Issues:
echo    - Go to Settings ^> Apps ^> AssureFix ^> Permissions  
echo    - Enable Location permission
echo    - Make sure "Allow only while using the app" is selected
echo    - Go to Settings ^> Location and turn on Location services
echo    - Make sure GPS is enabled
echo.
echo 3. If permissions are already granted:
echo    - Try force-closing the app and reopening it
echo    - Clear app cache: Settings ^> Apps ^> AssureFix ^> Storage ^> Clear Cache
echo    - Restart your device
echo.
echo 4. Network Issues:
echo    - Make sure your phone is on the same WiFi network as this computer
echo    - Check Windows Firewall settings
echo.
pause