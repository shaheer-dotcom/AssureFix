@echo off
echo ========================================
echo    FIXING CONNECTION ISSUE
echo ========================================
echo.

echo Current API Configuration:
echo - Frontend trying to connect to: http://192.168.100.7:5000
echo - Backend configured for port: 5000
echo.

echo Step 1: Checking if backend is running...
curl -s http://192.168.100.7:5000/api/health > nul
if %errorlevel% equ 0 (
    echo ✓ Backend is running and accessible
    goto :check_network
) else (
    echo ✗ Backend is not accessible
    echo.
)

echo Step 2: Checking if backend is running on localhost...
curl -s http://localhost:5000/api/health > nul
if %errorlevel% equ 0 (
    echo ✓ Backend is running on localhost
    echo ✗ But not accessible from network IP
    goto :fix_network
) else (
    echo ✗ Backend is not running at all
    goto :start_backend
)

:start_backend
echo.
echo SOLUTION 1: Starting Backend Server
echo ================================
echo.
echo The backend server is not running. Let's start it:
echo.
cd backend
echo Starting backend server...
start cmd /k "npm start"
echo.
echo Backend server is starting...
echo Wait 10 seconds for it to fully start, then test the app again.
echo.
timeout /t 10 /nobreak
goto :test_connection

:fix_network
echo.
echo SOLUTION 2: Network Configuration Issue
echo =====================================
echo.
echo Backend is running but not accessible from network IP.
echo This could be due to:
echo 1. Windows Firewall blocking port 5000
echo 2. Backend only listening on localhost
echo.
echo Checking Windows Firewall...
netsh advfirewall firewall show rule name="Node.js Server Port 5000" > nul
if %errorlevel% equ 0 (
    echo ✓ Firewall rule exists
) else (
    echo ✗ Firewall rule missing
    echo.
    echo Adding Windows Firewall rule for port 5000...
    netsh advfirewall firewall add rule name="Node.js Server Port 5000" dir=in action=allow protocol=TCP localport=5000
    echo ✓ Firewall rule added
)
echo.
goto :check_backend_binding

:check_backend_binding
echo Checking if backend is bound to all interfaces...
echo.
echo If backend is only listening on localhost (127.0.0.1),
echo it won't be accessible from the network IP (192.168.100.7).
echo.
echo Please check your backend server configuration.
echo Make sure it's listening on 0.0.0.0:5000, not just localhost:5000
echo.
goto :test_connection

:check_network
echo ✓ Backend is running and accessible
echo.
echo Step 3: Testing mobile device connection...
echo.
echo Make sure:
echo 1. Your mobile device is connected to the same WiFi network
echo 2. Your WiFi network allows device-to-device communication
echo 3. Your computer's IP address is actually 192.168.100.7
echo.
echo Current computer IP addresses:
ipconfig | findstr "IPv4"
echo.

:test_connection
echo.
echo ========================================
echo    TESTING CONNECTION
echo ========================================
echo.
echo Testing backend health endpoint...
curl -v http://192.168.100.7:5000/api/health
echo.
echo.
echo Testing login endpoint...
curl -X POST http://192.168.100.7:5000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"password\":\"test123\"}"
echo.
echo.

echo ========================================
echo    TROUBLESHOOTING STEPS
echo ========================================
echo.
echo If the connection still fails:
echo.
echo 1. VERIFY COMPUTER IP ADDRESS:
echo    - Run: ipconfig
echo    - Find your WiFi adapter's IPv4 address
echo    - Update frontend/lib/config/api_config.dart if different
echo.
echo 2. CHECK MOBILE DEVICE NETWORK:
echo    - Ensure mobile is on same WiFi as computer
echo    - Try accessing http://192.168.100.7:5000/api/health in mobile browser
echo.
echo 3. RESTART SERVICES:
echo    - Close backend server (Ctrl+C in backend terminal)
echo    - Run: npm start in backend directory
echo    - Rebuild and reinstall APK
echo.
echo 4. ALTERNATIVE IP ADDRESSES TO TRY:
echo    - Update api_config.dart with your actual IP address
echo    - Common patterns: 192.168.1.x, 192.168.0.x, 10.0.0.x
echo.
echo 5. FIREWALL CHECK:
echo    - Windows Defender Firewall
echo    - Allow Node.js through firewall
echo    - Allow port 5000 inbound connections
echo.
pause