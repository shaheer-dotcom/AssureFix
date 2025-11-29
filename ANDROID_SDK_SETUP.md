# 📱 Android SDK Setup Guide for Windows

This guide will help you install Android SDK so you can build APK files for your Flutter app.

## 🎯 Quick Solution: Install Android Studio (Recommended)

### Option 1: Full Android Studio Installation (Easiest)

1. **Download Android Studio:**
   - Go to [developer.android.com/studio](https://developer.android.com/studio)
   - Download Android Studio for Windows
   - File size: ~1 GB

2. **Install Android Studio:**
   - Run the installer
   - Follow the setup wizard
   - It will automatically install:
     - Android SDK
     - Android SDK Platform-Tools
     - Android Emulator
     - All required components

3. **First Launch Setup:**
   - Open Android Studio
   - Go through the setup wizard
   - It will download additional SDK components
   - This may take 10-20 minutes

4. **Verify Installation:**
   ```bash
   flutter doctor
   ```
   You should see Android toolchain checked ✅

5. **Accept Android Licenses:**
   ```bash
   flutter doctor --android-licenses
   ```
   Type `y` for each license prompt

### Option 2: Command-Line Tools Only (Lighter)

If you don't want the full Android Studio IDE, you can install just the SDK:

1. **Download Command-Line Tools:**
   - Go to [developer.android.com/studio#command-tools](https://developer.android.com/studio#command-tools)
   - Download "Command line tools only" for Windows
   - Extract to a folder (e.g., `C:\Android\cmdline-tools`)

2. **Set Environment Variables:**
   - Open System Properties → Environment Variables
   - Add new System Variable:
     - **Variable name:** `ANDROID_HOME`
     - **Variable value:** `C:\Android` (or your SDK location)
   - Edit `Path` variable, add:
     - `%ANDROID_HOME%\platform-tools`
     - `%ANDROID_HOME%\tools`
     - `%ANDROID_HOME%\cmdline-tools\latest\bin`

3. **Install SDK Components:**
   ```bash
   # Open new Command Prompt (to load environment variables)
   sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
   ```

4. **Verify:**
   ```bash
   flutter doctor
   ```

## 🔧 After Installation

### 1. Verify Flutter Setup:
```bash
cd frontend
flutter doctor
```

You should see:
```
[✓] Android toolchain - develop for Android devices
```

### 2. Accept Android Licenses:
```bash
flutter doctor --android-licenses
```

Type `y` for each license agreement.

### 3. Build Your APK:
```bash
# From project root
.\build_apk.bat

# Or manually:
cd frontend
flutter build apk --release
```

## 🚨 Troubleshooting

### Issue: "ANDROID_HOME not set"
**Solution:**
1. Find your Android SDK location:
   - Android Studio: Usually at `C:\Users\YourName\AppData\Local\Android\Sdk`
   - Or check Android Studio → Settings → Appearance & Behavior → System Settings → Android SDK
2. Set environment variable:
   ```bash
   # In PowerShell (as Administrator)
   [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\YourName\AppData\Local\Android\Sdk", "Machine")
   ```
3. Restart your terminal/IDE

### Issue: "Android licenses not accepted"
**Solution:**
```bash
flutter doctor --android-licenses
# Type 'y' for each prompt
```

### Issue: "SDK platform not found"
**Solution:**
1. Open Android Studio
2. Go to Tools → SDK Manager
3. Install:
   - Android SDK Platform (latest, e.g., Android 13 - API 33)
   - Android SDK Build-Tools
   - Android SDK Platform-Tools

### Issue: "Gradle build failed"
**Solution:**
```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

## 📋 Minimum Requirements

For building APK, you need:
- ✅ Android SDK Platform (API 21 or higher)
- ✅ Android SDK Build-Tools
- ✅ Android SDK Platform-Tools
- ✅ Java JDK (usually comes with Android Studio)

## 🎯 Quick Check Commands

```bash
# Check Flutter installation
flutter doctor

# Check Android SDK location
echo %ANDROID_HOME%

# Check if adb (Android Debug Bridge) is available
adb version

# List installed SDK platforms
sdkmanager --list_installed
```

## 💡 Tips

1. **Android Studio is recommended** - It includes everything and makes updates easier
2. **Keep SDK updated** - Android Studio will prompt for updates
3. **Use Flutter doctor** - It tells you exactly what's missing
4. **Accept all licenses** - Required for building APKs

## ✅ Verification Checklist

After installation, verify:
- [ ] `flutter doctor` shows Android toolchain as checked
- [ ] `ANDROID_HOME` environment variable is set
- [ ] Android licenses are accepted
- [ ] `flutter build apk --release` works without errors

---

**Need help?** Run `flutter doctor -v` for detailed diagnostic information.


