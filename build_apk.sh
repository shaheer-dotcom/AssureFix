#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Building AssureFix APK..."
echo

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}[ERROR] Flutter is not found in PATH!${NC}"
    echo "Please install Flutter and add it to your PATH."
    echo
    exit 1
fi

# Check Android SDK
if [ -z "$ANDROID_HOME" ]; then
    echo -e "${YELLOW}[WARNING] ANDROID_HOME is not set!${NC}"
    echo
    echo "Android SDK is required to build APK files."
    echo
    echo "Quick fix:"
    echo "1. Install Android Studio from: https://developer.android.com/studio"
    echo "2. Set ANDROID_HOME environment variable"
    echo "3. Or run: ./setup_android_sdk.sh for detailed instructions"
    echo
    echo "Common Android SDK locations:"
    echo "  Linux: ~/Android/Sdk"
    echo "  macOS: ~/Library/Android/sdk"
    echo "  Or: $HOME/AppData/Local/Android/Sdk (if using Git Bash on Windows)"
    echo
    read -p "Do you want to continue anyway? (y/n): " continue
    if [[ ! "$continue" =~ ^[Yy]$ ]]; then
        echo "Build cancelled."
        exit 1
    fi
fi

cd frontend || exit 1

echo "Step 1: Checking Flutter setup..."
flutter doctor
echo

echo "Step 2: Cleaning previous build..."
flutter clean

echo
echo "Step 3: Getting dependencies..."
flutter pub get

echo
echo "Step 4: Accepting Android licenses (if needed)..."
# Try to accept licenses non-interactively, but don't fail if it requires input
yes | flutter doctor --android-licenses 2>/dev/null || true

echo
echo "Step 5: Building release APK..."

# Check if API URL is provided as argument
BUILD_CMD="flutter build apk --release"
if [ -n "$1" ]; then
    echo "Using API URL: $1"
    BUILD_CMD="flutter build apk --release --dart-define=API_BASE_URL=$1"
else
    echo "No API URL provided. Using default configuration."
    echo "You can configure it in Settings after installing the app."
    echo "Or provide it as argument: ./build_apk.sh http://192.168.100.7:5000/api"
fi

if eval "$BUILD_CMD"; then
    echo
    echo "========================================"
    echo -e "${GREEN}Build complete!${NC}"
    echo "========================================"
    echo "APK location: frontend/build/app/outputs/flutter-apk/app-release.apk"
    echo
else
    echo
    echo -e "${RED}[ERROR] Build failed!${NC}"
    echo
    echo "Common issues:"
    echo "- Android SDK not installed (run ./setup_android_sdk.sh)"
    echo "- Android licenses not accepted (run: flutter doctor --android-licenses)"
    echo "- Missing SDK platform (install via Android Studio)"
    echo
    echo "See ANDROID_SDK_SETUP.md for detailed help."
    echo
    cd ..
    exit 1
fi

cd ..
echo
read -p "Press Enter to continue..."


