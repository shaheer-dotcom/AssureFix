@echo off
echo ========================================
echo AssureFix Backend Connectivity Test
echo ========================================
echo.

echo Testing backend connectivity...
echo.

echo 1. Checking if backend is running on port 5000...
netstat -an | findstr ":5000" >nul 2>&1
if %errorLevel% equ 0 (
    echo    ✓ Backend is listening on port 5000
) else (
    echo    ✗ Backend is NOT running on port 5000
    echo    Please start the backend with start_backend.bat
    echo.
    pause
    exit /b 1
)

echo.
echo 2. Checking firewall rules...
netsh advfirewall firewall show rule name="AssureFix Backend" >nul 2>&1
if %errorLevel% equ 0 (
    echo    ✓ Firewall rule exists
) else (
    echo    ✗ Firewall rule NOT found
    echo    Please run setup_firewall.bat as Administrator
)

echo.
echo 3. Your network configuration:
echo.
ipconfig | findstr /C:"IPv4 Address" /C:"Wireless LAN adapter Wi-Fi"
echo.

echo 4. Mobile devices should connect to:
echo    http://192.168.100.7:5000/api
echo.

echo 5. Test from mobile browser:
echo    http://192.168.100.7:5000/api/health
echo.

echo ========================================
echo Test Complete
echo ========================================
echo.
pause
