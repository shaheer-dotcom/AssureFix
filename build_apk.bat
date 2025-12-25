@echo off
echo Building AssureFix APK...
echo.

cd frontend

echo Step 1: Stopping Gradle daemon...
call android\gradlew.bat --stop 2>nul
timeout /t 3 /nobreak >nul

echo Step 2: Cleaning previous build...
call flutter clean

echo.
echo Step 3: Getting dependencies...
call flutter pub get

echo.
echo Step 4: Building release APK (Android 11+ only, arm64-v8a)...
echo Note: Minification disabled to ensure login works correctly
call flutter build apk --release --target-platform android-arm64

echo.
if exist build\app\outputs\flutter-apk\app-release.apk (
    echo Build complete! APK created for Android 11+ (arm64-v8a only):
    echo.
    echo APK Location: frontend\build\app\outputs\flutter-apk\app-release.apk
    for %%A in (build\app\outputs\flutter-apk\app-release.apk) do (
        set /a size_mb=%%~zA/1048576
        echo Size: %%~zA bytes ^(~!size_mb! MB^)
    )
    echo.
    echo This APK is optimized for Android 11+ devices only.
) else (
    echo Build failed! APK not found.
    echo Check the output above for errors.
)
echo.

cd ..
pause
