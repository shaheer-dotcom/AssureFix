@echo off
echo Building Optimized AssureFix APK (Reduced Size)...
echo.

cd frontend

echo Step 1: Stopping Gradle daemon...
call android\gradlew.bat --stop 2>nul
timeout /t 3 /nobreak >nul

echo Step 2: Cleaning old build files...
if exist build\app\outputs\flutter-apk rmdir /s /q build\app\outputs\flutter-apk

echo Step 3: Getting dependencies...
call flutter pub get

echo.
echo Step 4: Building optimized APKs (split by architecture)...
echo This will create smaller APKs for each device type
call flutter build apk --release --split-per-abi --shrink --obfuscate --split-debug-info=build/app/outputs/symbols

echo.
if exist build\app\outputs\flutter-apk\app-arm64-v8a-release.apk (
    echo ========================================
    echo Build complete! APKs created:
    echo ========================================
    echo.
    echo ARM 64-bit (Modern phones - USE THIS ONE):
    echo Location: frontend\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
    for %%A in (build\app\outputs\flutter-apk\app-arm64-v8a-release.apk) do (
        set /a size_mb=%%~zA/1048576
        echo Size: %%~zA bytes ^(~!size_mb! MB^)
    )
    echo.
    echo ARM 32-bit (Older phones):
    echo Location: frontend\build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
    for %%A in (build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk) do (
        set /a size_mb=%%~zA/1048576
        echo Size: %%~zA bytes ^(~!size_mb! MB^)
    )
    echo.
    echo ========================================
    echo IMPORTANT: Use the ARM 64-bit version for WhatsApp!
    echo It should be under 100 MB now.
    echo ========================================
) else (
    echo Build failed! APK not found.
)
echo.

cd ..
pause
