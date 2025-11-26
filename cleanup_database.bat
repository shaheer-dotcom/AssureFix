@echo off
echo ========================================
echo   AssureFix Database Cleanup Script
echo ========================================
echo.
echo WARNING: This will delete:
echo   - All services
echo   - All bookings
echo   - All conversations
echo   - All messages
echo.
echo User accounts and ratings will be preserved.
echo.
set /p confirm="Are you sure you want to continue? (yes/no): "

if /i not "%confirm%"=="yes" (
    echo.
    echo Cleanup cancelled.
    pause
    exit /b 0
)

echo.
echo Starting cleanup...
echo.

cd backend
node scripts/cleanup_database.js

cd ..
echo.
pause
