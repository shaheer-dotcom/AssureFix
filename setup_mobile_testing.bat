@echo off
echo ========================================
echo AssureFix Mobile Testing Setup
echo ========================================
echo.

echo Your Computer's IP Address:
echo WiFi: 192.168.100.7
echo.

echo ========================================
echo Step 1: Configure Windows Firewall
echo ========================================
echo Adding firewall rule for Node.js backend (port 5000)...
netsh advfirewall firewall add rule name="AssureFix Backend" dir=in action=allow protocol=TCP localport=5000
echo.

echo ========================================
echo Step 2: Mobile Device Setup Instructions
echo ========================================
echo.
echo To test the app on your mobile device:
echo.
echo 1. Make sure your mobile device is connected to the SAME WiFi network
echo    WiFi Network: Check your current WiFi name
echo.
echo 2. Install the APK on your mobile device:
echo    Location: frontend\build\app\outputs\flutter-apk\app-release.apk
echo.
echo 3. The app is configured to connect to:
echo    http://192.168.100.7:5000/api
echo.
echo 4. Start the backend server:
echo    Run: start_backend.bat
echo.
echo 5. Open the app on your mobile device
echo.

echo ========================================
echo Step 3: Troubleshooting
echo ========================================
echo.
echo If the app can't connect to the backend:
echo.
echo - Verify your computer's IP hasn't changed:
echo   Run: ipconfig
echo   Look for "Wireless LAN adapter Wi-Fi" IPv4 Address
echo.
echo - Make sure backend is running:
echo   You should see "Server running on port 5000"
echo.
echo - Test connection from mobile browser:
echo   Open: http://192.168.100.7:5000/api/health
echo   You should see a JSON response
echo.
echo - Check Windows Firewall:
echo   Make sure port 5000 is allowed
echo.
echo - Disable VPN if active
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
pause
