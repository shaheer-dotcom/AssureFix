@echo off
echo Fixing Flutter clean issue...
echo.

echo Step 1: Stopping any running Flutter/Dart processes...
taskkill /F /IM dart.exe 2>nul
taskkill /F /IM flutter.exe 2>nul
ping 127.0.0.1 -n 3 >nul

echo Step 2: Attempting to remove locked directories manually...
cd frontend

echo.
echo IMPORTANT: If directories cannot be removed, please:
echo   1. Close your IDE (VS Code, Android Studio, etc.)
echo   2. Close File Explorer windows showing the frontend folder
echo   3. Close any running Flutter apps or debug sessions
echo   4. Then run this script again
echo.

if exist build (
    echo Removing build directory...
    rmdir /s /q build 2>nul
    if exist build (
        echo [WARNING] Could not remove build directory. It may still be in use.
        echo Please close any programs using these files and try again.
    ) else (
        echo [SUCCESS] Build directory removed successfully.
    )
)

if exist .dart_tool (
    echo Removing .dart_tool directory...
    rmdir /s /q .dart_tool 2>nul
    if exist .dart_tool (
        echo [WARNING] Could not remove .dart_tool directory. It may still be in use.
        echo Please close any programs using these files and try again.
    ) else (
        echo [SUCCESS] .dart_tool directory removed successfully.
    )
)

echo.
echo Step 3: Running flutter clean...
call flutter clean

echo.
echo Clean process completed!
cd ..
pause

