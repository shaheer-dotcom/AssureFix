@echo off
echo Building AssureFix APK...
echo.

REM Check if API URL is provided as argument
set API_URL=%1
if "%API_URL%"=="" (
    echo Usage: build_apk.bat [API_URL]
    echo Example: build_apk.bat http://192.168.100.7:5000/api
    echo Example: build_apk.bat https://your-app.onrender.com/api
    echo.
    echo If no API URL is provided, the app will use default configuration.
    echo You can also configure it in Settings after installing the app.
    echo.
    set /p use_default="Continue with default configuration? (y/n): "
    if /i not "!use_default!"=="y" (
        echo Build cancelled.
        pause
        exit /b 1
    )
    set BUILD_CMD=flutter build apk --release
) else (
    echo Using API URL: %API_URL%
    set BUILD_CMD=flutter build apk --release --dart-define=API_BASE_URL=%API_URL%
)

REM Check if Flutter is available
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not found in PATH!
    echo Please install Flutter and add it to your PATH.
    echo.
    pause
    exit /b 1
)

REM Check Android SDK
if not defined ANDROID_HOME (
    echo [WARNING] ANDROID_HOME is not set!
    echo.
    echo Android SDK is required to build APK files.
    echo.
    echo Quick fix:
    echo 1. Install Android Studio from: https://developer.android.com/studio
    echo 2. After installation, ANDROID_HOME will be set automatically
    echo 3. Or run: setup_android_sdk.bat for detailed instructions
    echo.
    echo Common Android SDK location:
    echo   C:\Users\%USERNAME%\AppData\Local\Android\Sdk
    echo.
    echo Do you want to continue anyway? (y/n)
    set /p continue="> "
    if /i not "%continue%"=="y" (
        echo Build cancelled.
        pause
        exit /b 1
    )
)

cd frontend

echo Step 1: Checking Flutter setup...
call flutter doctor
echo.

echo Step 2: Cleaning previous build...
call flutter clean

echo.
echo Step 3: Getting dependencies...
call flutter pub get

echo.
echo Step 4: Accepting Android licenses (if needed)...
call flutter doctor --android-licenses <nul 2>nul

echo.
echo Step 5: Building release APK...
call %BUILD_CMD%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build complete!
    echo ========================================
    echo APK location: frontend\build\app\outputs\flutter-apk\app-release.apk
    echo.
) else (
    echo.
    echo [ERROR] Build failed!
    echo.
    echo Common issues:
    echo - Android SDK not installed (run setup_android_sdk.bat)
    echo - Android licenses not accepted (run: flutter doctor --android-licenses)
    echo - Missing SDK platform (install via Android Studio)
    echo.
    echo See ANDROID_SDK_SETUP.md for detailed help.
    echo.
)

cd ..
pause
