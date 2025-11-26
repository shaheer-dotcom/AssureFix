# Mobile Testing Guide for AssureFix

## Prerequisites

### 1. Network Setup
- **Computer IP Address**: `192.168.100.7` (Wi-Fi)
- **Backend Port**: `5000`
- **Mobile devices MUST be connected to the same Wi-Fi network** (192.168.100.x)

### 2. Backend Configuration
The backend is already configured to:
- Accept connections from mobile apps (no CORS origin required)
- Allow local network IPs (192.168.x.x, 10.0.x.x)
- Listen on all network interfaces (0.0.0.0)

### 3. Firewall Setup
**IMPORTANT**: Windows Firewall must allow connections on port 5000

#### Option A: Run the automated script (Recommended)
1. Right-click `setup_firewall.bat`
2. Select "Run as Administrator"
3. Follow the prompts

#### Option B: Manual setup
1. Open Windows Defender Firewall
2. Click "Advanced settings"
3. Click "Inbound Rules" → "New Rule"
4. Select "Port" → Next
5. Select "TCP" and enter port `5000` → Next
6. Select "Allow the connection" → Next
7. Check all profiles (Domain, Private, Public) → Next
8. Name it "AssureFix Backend" → Finish

## Testing Steps

### Step 1: Start the Backend
```bash
# Run from project root
start_backend.bat
```

You should see:
```
🚀 Server running on port 5000 in development mode
📱 Local access: http://localhost:5000
📱 Network access: http://192.168.100.7:5000
📱 Mobile API endpoint: http://192.168.100.7:5000/api
```

### Step 2: Verify Backend is Accessible
From your mobile browser, visit:
```
http://192.168.100.7:5000/api/health
```

You should see a JSON response indicating the server is running.

### Step 3: Install the APK
1. Transfer `frontend/build/app/outputs/flutter-apk/app-release.apk` to your mobile device
2. Enable "Install from Unknown Sources" in your device settings
3. Install the APK
4. Open the AssureFix app

### Step 4: Test the App
1. **Sign Up**: Create a new account
2. **Login**: Log in with your credentials
3. **Profile**: Complete your profile setup
4. **Services**: Browse or create services
5. **Messaging**: Test real-time chat functionality

## Troubleshooting

### Issue: App crashes on startup
**Solution**: 
- Ensure you're using the latest APK build
- Check that all permissions are granted in app settings

### Issue: "Network Error" or "Cannot connect to server"
**Solutions**:
1. Verify mobile is on the same Wi-Fi network (192.168.100.x)
2. Check backend is running (`start_backend.bat`)
3. Verify firewall allows port 5000 (run `setup_firewall.bat`)
4. Test backend accessibility from mobile browser first

### Issue: "Connection timeout"
**Solutions**:
1. Check your computer's IP hasn't changed:
   ```bash
   ipconfig
   ```
   Look for "Wi-Fi adapter" → "IPv4 Address"
2. If IP changed, update `frontend/lib/config/api_config.dart`
3. Rebuild the APK with `build_apk.bat`

### Issue: Images/files not uploading
**Solution**:
- Grant Camera and Storage permissions in app settings
- Check backend logs for upload errors

## Testing on Multiple Devices

### Same Network (Recommended)
- All devices connect to the same Wi-Fi network
- Use the same APK on all devices
- Each device will connect to `http://192.168.100.7:5000/api`

### Different Networks (Advanced)
For testing across different networks, you'll need:
1. Deploy backend to a cloud server (AWS, Heroku, DigitalOcean)
2. Update `api_config.dart` with the cloud server URL
3. Rebuild the APK
4. Use HTTPS for production

## Building a New APK

If you need to rebuild the APK (e.g., IP address changed):

```bash
# Run from project root
build_apk.bat
```

The new APK will be at:
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```

## Current Configuration

- **API Endpoint**: `http://192.168.100.7:5000/api`
- **Backend IP**: `192.168.100.7`
- **Backend Port**: `5000`
- **APK Location**: `frontend/build/app/outputs/flutter-apk/app-release.apk`
- **APK Size**: ~52MB

## Security Notes

⚠️ **This configuration is for DEVELOPMENT/TESTING only**

For production deployment:
- Use HTTPS (not HTTP)
- Deploy backend to a proper server
- Use environment-specific configurations
- Implement proper authentication tokens
- Enable rate limiting
- Use a production database

## Support

If you encounter issues:
1. Check backend logs in the terminal
2. Check mobile app logs (use `adb logcat` if connected via USB)
3. Verify network connectivity
4. Ensure firewall rules are active
