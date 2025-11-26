@echo off
echo Setting up Windows Firewall rules for AssureFix backend...
echo.
echo This will allow incoming connections on port 5000
echo Administrator privileges required!
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires Administrator privileges
    echo Please right-click and select "Run as Administrator"
    pause
    exit /b 1
)

echo Adding firewall rule for Node.js backend (port 5000)...
netsh advfirewall firewall delete rule name="AssureFix Backend" >nul 2>&1
netsh advfirewall firewall add rule name="AssureFix Backend" dir=in action=allow protocol=TCP localport=5000

if %errorLevel% equ 0 (
    echo.
    echo ✓ Firewall rule added successfully!
    echo.
    echo Your backend is now accessible from mobile devices on the same network
    echo Mobile devices should connect to: http://192.168.100.7:5000/api
) else (
    echo.
    echo ✗ Failed to add firewall rule
    echo Please check your Windows Firewall settings manually
)

echo.
pause
