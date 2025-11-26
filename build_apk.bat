@echo off
echo Building AssureFix APK...
echo.

cd frontend

echo Step 1: Cleaning previous build...
call flutter clean

echo.
echo Step 2: Getting dependencies...
call flutter pub get

echo.
echo Step 3: Building release APK...
call flutter build apk --release

echo.
echo Build complete!
echo APK location: frontend\build\app\outputs\flutter-apk\app-release.apk
echo.

cd ..
pause
