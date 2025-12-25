@echo off
echo ========================================
echo    DETECTING CORRECT IP ADDRESS
echo ========================================
echo.

echo Current API configuration uses: 192.168.100.7
echo.

echo Detecting your actual IP addresses...
echo.

echo All network adapters:
ipconfig | findstr /C:"IPv4 Address"
echo.

echo WiFi adapter specifically:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /A "Wireless LAN adapter Wi-Fi" -A 10 ^| findstr "IPv4 Address"') do (
    set WIFI_IP=%%a
    set WIFI_IP=!WIFI_IP: =!
    echo WiFi IP: !WIFI_IP!
)

echo.
echo Ethernet adapter:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /A "Ethernet adapter" -A 10 ^| findstr "IPv4 Address"') do (
    set ETH_IP=%%a
    set ETH_IP=!ETH_IP: =!
    echo Ethernet IP: !ETH_IP!
)

echo.
echo ========================================
echo    TESTING CURRENT CONFIGURATION
echo ========================================
echo.

echo Testing backend on current IP (192.168.100.7)...
curl -s --connect-timeout 5 http://192.168.100.7:5000/api/health
if %errorlevel% equ 0 (
    echo ✓ Backend accessible on 192.168.100.7
    echo Current configuration is correct!
    goto :end
) else (
    echo ✗ Backend not accessible on 192.168.100.7
)

echo.
echo Testing backend on localhost...
curl -s --connect-timeout 5 http://localhost:5000/api/health
if %errorlevel% equ 0 (
    echo ✓ Backend is running on localhost
    echo ✗ But not accessible from network
    echo.
    echo SOLUTION: Backend needs to listen on all interfaces (0.0.0.0)
    echo Check your backend server configuration.
) else (
    echo ✗ Backend is not running
    echo.
    echo SOLUTION: Start the backend server
    echo Run: npm start in the backend directory
)

echo.
echo ========================================
echo    QUICK FIXES
echo ========================================
echo.

echo 1. START BACKEND SERVER:
echo    cd backend
echo    npm start
echo.

echo 2. CHECK YOUR ACTUAL IP:
echo    Run: ipconfig
echo    Look for "Wireless LAN adapter Wi-Fi" section
echo    Find the IPv4 Address line
echo.

echo 3. UPDATE API CONFIG IF NEEDED:
echo    Edit: frontend/lib/config/api_config.dart
echo    Change: _localNetworkIp = 'YOUR_ACTUAL_IP'
echo    Rebuild APK: flutter build apk --release
echo.

echo 4. FIREWALL RULE:
echo    Add Windows Firewall rule for port 5000
echo    Or temporarily disable Windows Firewall for testing
echo.

echo 5. NETWORK TROUBLESHOOTING:
echo    - Ensure mobile and computer on same WiFi
echo    - Try accessing http://YOUR_IP:5000/api/health in mobile browser
echo    - Check router settings for device isolation
echo.

:end
echo.
echo Run this script again after making changes to test the connection.
echo.
pause