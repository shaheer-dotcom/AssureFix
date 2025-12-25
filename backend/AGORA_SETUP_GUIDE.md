# Agora SDK Setup and Configuration Guide

## Overview

This guide provides step-by-step instructions for setting up and configuring the Agora SDK for voice calling functionality in the Enhanced Messaging System.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Agora Account Setup](#agora-account-setup)
3. [Backend Configuration](#backend-configuration)
4. [Frontend Configuration](#frontend-configuration)
5. [Testing Voice Calls](#testing-voice-calls)
6. [Troubleshooting](#troubleshooting)
7. [Security Best Practices](#security-best-practices)

---

## Prerequisites

- Node.js 16+ installed
- Flutter SDK 3.0+ installed
- Active Agora account (free tier available)
- Basic understanding of WebRTC concepts

---

## Agora Account Setup

### Step 1: Create an Agora Account

1. Visit [Agora Console](https://console.agora.io/)
2. Click "Sign Up" and create a free account
3. Verify your email address
4. Complete the registration process

### Step 2: Create a New Project

1. Log in to the Agora Console
2. Navigate to "Projects" in the left sidebar
3. Click "Create" button
4. Enter project details:
   - **Project Name:** AssureFix Voice Calls (or your preferred name)
   - **Use Case:** Social (or appropriate category)
   - **Authentication Mechanism:** Select "Secured mode: APP ID + Token"
5. Click "Submit"

### Step 3: Get Your Credentials

After creating the project, you'll see:

1. **App ID**: A unique identifier for your project
   - Example: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`
   - Copy this value

2. **App Certificate**: Required for token generation
   - Click the "Edit" icon next to your project
   - Enable "Primary Certificate"
   - Copy the certificate value
   - **Important:** Keep this secret and never expose it in client-side code

### Step 4: Configure Project Settings

1. In the project settings, configure:
   - **Status:** Enable the project
   - **Stage:** Development or Production
   - **Features:** Enable "Voice Call"
   
2. Optional: Configure additional settings:
   - **Co-host Token:** Enable if needed
   - **Cloud Recording:** Enable if you want to record calls
   - **Real-time Transcription:** Enable if needed

---

## Backend Configuration

### Step 1: Install Dependencies

The Agora token generation package should already be installed. If not:

```bash
cd backend
npm install agora-access-token
```

### Step 2: Configure Environment Variables

1. Open or create `backend/.env` file
2. Add your Agora credentials:

```env
# Agora Voice Call Configuration
AGORA_APP_ID=your_agora_app_id_here
AGORA_APP_CERTIFICATE=your_agora_app_certificate_here
```

3. Replace the placeholder values with your actual credentials from Step 3 above

**Example:**
```env
AGORA_APP_ID=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
AGORA_APP_CERTIFICATE=1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p
```

### Step 3: Verify Token Generation Utility

The token generation utility is located at `backend/utils/agoraToken.js`. It should contain:

```javascript
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

const AGORA_APP_ID = process.env.AGORA_APP_ID;
const AGORA_APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE;

/**
 * Generate Agora RTC token
 * @param {string} channelName - Channel name
 * @param {number} uid - User ID (0 for auto-assignment)
 * @param {string} role - 'publisher' or 'subscriber'
 * @returns {string} Agora token
 */
function generateAgoraToken(channelName, uid = 0, role = 'publisher') {
  if (!AGORA_APP_ID || !AGORA_APP_CERTIFICATE) {
    throw new Error('Agora credentials not configured');
  }

  const expirationTimeInSeconds = 3600; // 1 hour
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  const roleType = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

  const token = RtcTokenBuilder.buildTokenWithUid(
    AGORA_APP_ID,
    AGORA_APP_CERTIFICATE,
    channelName,
    uid,
    roleType,
    privilegeExpiredTs
  );

  return token;
}

/**
 * Generate unique channel name for a call
 * @param {string} callerId - Caller user ID
 * @param {string} receiverId - Receiver user ID
 * @returns {string} Channel name
 */
function generateChannelName(callerId, receiverId) {
  // Sort IDs to ensure consistent channel name regardless of who initiates
  const ids = [callerId, receiverId].sort();
  return `call_${ids[0]}_${ids[1]}_${Date.now()}`;
}

module.exports = {
  generateAgoraToken,
  generateChannelName
};
```

### Step 4: Test Backend Configuration

Create a test script to verify token generation:

```bash
node -e "
const { generateAgoraToken } = require('./utils/agoraToken');
try {
  const token = generateAgoraToken('test_channel', 0, 'publisher');
  console.log('✓ Token generated successfully');
  console.log('Token length:', token.length);
} catch (error) {
  console.error('✗ Error:', error.message);
}
"
```

If successful, you should see:
```
✓ Token generated successfully
Token length: 200+ characters
```

---

## Frontend Configuration

### Step 1: Install Agora Flutter SDK

1. Open `frontend/pubspec.yaml`
2. Verify `agora_rtc_engine` is in dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  agora_rtc_engine: ^6.2.6  # or latest version
  # ... other dependencies
```

3. Install dependencies:

```bash
cd frontend
flutter pub get
```

### Step 2: Configure Android Permissions

1. Open `frontend/android/app/src/main/AndroidManifest.xml`
2. Add required permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Agora Voice Call Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

### Step 3: Configure iOS Permissions

1. Open `frontend/ios/Runner/Info.plist`
2. Add required permissions:

```xml
<dict>
    <!-- Agora Voice Call Permissions -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs access to your microphone for voice calls</string>
    
    <key>NSCameraUsageDescription</key>
    <string>This app needs access to your camera for video calls</string>
    
    <!-- ... other keys -->
</dict>
```

### Step 4: Initialize Agora Engine

The Agora engine is initialized in `VoiceCallService`. Verify the initialization code:

```dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VoiceCallService {
  RtcEngine? _engine;
  
  Future<void> initializeEngine() async {
    // Create Agora engine instance
    _engine = createAgoraRtcEngine();
    
    // Initialize with App ID (received from backend)
    await _engine!.initialize(RtcEngineContext(
      appId: appId, // This comes from backend API response
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    
    // Enable audio
    await _engine!.enableAudio();
    
    // Set up event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Successfully joined channel: ${connection.channelId}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('Remote user joined: $remoteUid');
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print('Remote user left: $remoteUid');
        },
        onError: (ErrorCodeType err, String msg) {
          print('Agora error: $err - $msg');
        },
      ),
    );
  }
}
```

### Step 5: Configure API Endpoint

Ensure the frontend is configured to call the correct backend API:

```dart
// In your API service or constants file
const String BASE_URL = 'http://localhost:5000/api';
const String CALLS_ENDPOINT = '$BASE_URL/calls';
```

For mobile testing, use your computer's IP address:
```dart
const String BASE_URL = 'http://192.168.1.100:5000/api';
```

---

## Testing Voice Calls

### Test Scenario 1: Local Testing (Two Browser Tabs)

1. Start the backend server:
   ```bash
   cd backend
   npm start
   ```

2. Start the frontend:
   ```bash
   cd frontend
   flutter run -d chrome --web-port=8082
   ```

3. Open two browser tabs:
   - Tab 1: Login as User A
   - Tab 2: Login as User B

4. In Tab 1:
   - Navigate to a chat with User B
   - Click the voice call button
   - Verify call initiation

5. In Tab 2:
   - Verify incoming call notification appears
   - Accept the call
   - Verify audio connection

6. Test call features:
   - Mute/unmute
   - Speaker on/off
   - End call

### Test Scenario 2: Mobile Testing

1. Build and install the app on a physical device:
   ```bash
   cd frontend
   flutter build apk --debug
   # or for iOS
   flutter build ios --debug
   ```

2. Ensure your mobile device is on the same network as your development machine

3. Update the API base URL to use your computer's IP address

4. Test call between mobile device and web browser

### Test Scenario 3: Production Testing

1. Deploy backend to a server with HTTPS
2. Update frontend API configuration
3. Test calls between production builds

---

## Troubleshooting

### Issue: "Agora credentials not configured"

**Solution:**
- Verify `.env` file exists in backend directory
- Check that `AGORA_APP_ID` and `AGORA_APP_CERTIFICATE` are set
- Restart the backend server after updating `.env`

### Issue: Token generation fails

**Solution:**
- Verify App Certificate is enabled in Agora Console
- Check that credentials are copied correctly (no extra spaces)
- Ensure `agora-access-token` package is installed

### Issue: Cannot join channel

**Solution:**
- Check network connectivity
- Verify token is not expired (default: 1 hour)
- Ensure App ID matches between backend and Agora Console
- Check browser/app permissions for microphone access

### Issue: No audio in call

**Solution:**
- Check microphone permissions in browser/device settings
- Verify `enableAudio()` is called after engine initialization
- Test microphone with other applications
- Check speaker/headphone connection

### Issue: Call drops frequently

**Solution:**
- Check network stability
- Reduce video quality if using video calls
- Verify Agora service status: https://status.agora.io/
- Check for firewall blocking UDP ports

### Issue: "Failed to initialize Agora engine"

**Solution:**
- Verify Agora SDK is properly installed
- Check Android/iOS permissions are configured
- Ensure minimum SDK versions are met:
  - Android: minSdkVersion 21
  - iOS: iOS 9.0+

### Issue: Echo or feedback during call

**Solution:**
- Enable echo cancellation in Agora settings
- Use headphones instead of speaker
- Reduce speaker volume
- Ensure only one device is playing audio

---

## Security Best Practices

### 1. Never Expose App Certificate

- **DO NOT** include App Certificate in client-side code
- **DO NOT** commit `.env` file to version control
- **DO** generate tokens on the backend server
- **DO** use environment variables for credentials

### 2. Token Expiration

- Set appropriate token expiration times (default: 1 hour)
- Implement token refresh mechanism for long calls
- Invalidate tokens after call ends

### 3. Channel Name Security

- Use unpredictable channel names
- Include timestamp in channel name
- Validate user permissions before generating tokens

### 4. Rate Limiting

- Implement rate limiting on call initiation endpoints
- Prevent spam calling
- Monitor for abuse patterns

### 5. User Verification

- Verify user is authenticated before allowing calls
- Check user is participant in conversation
- Validate receiver exists and is available

### 6. Production Deployment

- Use HTTPS for all API endpoints
- Enable Agora's IP whitelist feature
- Monitor Agora usage and costs
- Set up alerts for unusual activity

---

## Agora Console Features

### Usage Monitoring

1. Navigate to Agora Console → Usage
2. Monitor:
   - Total call minutes
   - Active users
   - Peak concurrent users
   - Call quality metrics

### Quality Monitoring

1. Navigate to Agora Console → Quality
2. View:
   - Call quality scores
   - Network conditions
   - Audio/video bitrates
   - Packet loss rates

### Analytics

1. Navigate to Agora Console → Analytics
2. Analyze:
   - User engagement
   - Call duration distribution
   - Geographic distribution
   - Device types

---

## Cost Optimization

### Free Tier

Agora provides 10,000 free minutes per month:
- Voice calls: 10,000 minutes
- Video calls: 10,000 minutes
- Recording: 10,000 minutes

### Paid Plans

After exceeding free tier:
- Voice calls: $0.99 per 1,000 minutes
- Video calls: $3.99 per 1,000 minutes (SD)
- Recording: $1.49 per 1,000 minutes

### Optimization Tips

1. **Implement call duration limits**
   - Set maximum call duration (e.g., 30 minutes)
   - Warn users before limit is reached

2. **Monitor usage**
   - Set up usage alerts in Agora Console
   - Track usage per user/feature

3. **Optimize audio quality**
   - Use appropriate audio profiles
   - Disable video when not needed

4. **Clean up resources**
   - End calls properly
   - Leave channels when done
   - Destroy engine instances

---

## Advanced Configuration

### Audio Profiles

Configure audio quality based on use case:

```dart
// High quality for music
await _engine!.setAudioProfile(
  profile: AudioProfileType.audioProfileMusicHighQuality,
  scenario: AudioScenarioType.audioScenarioGameStreaming,
);

// Standard quality for voice calls (recommended)
await _engine!.setAudioProfile(
  profile: AudioProfileType.audioProfileDefault,
  scenario: AudioScenarioType.audioScenarioChatroom,
);
```

### Echo Cancellation

Enable advanced echo cancellation:

```dart
await _engine!.setParameters('{"che.audio.enable.agc": true}');
await _engine!.setParameters('{"che.audio.enable.aec": true}');
await _engine!.setParameters('{"che.audio.enable.ns": true}');
```

### Network Quality Callback

Monitor network quality during calls:

```dart
_engine!.registerEventHandler(
  RtcEngineEventHandler(
    onNetworkQuality: (RtcConnection connection, int uid, 
                       QualityType txQuality, QualityType rxQuality) {
      print('Network quality - TX: $txQuality, RX: $rxQuality');
      // Update UI based on network quality
    },
  ),
);
```

---

## Support Resources

### Official Documentation

- [Agora Documentation](https://docs.agora.io/)
- [Flutter SDK Reference](https://docs.agora.io/en/voice-calling/get-started/get-started-sdk?platform=flutter)
- [API Reference](https://api-ref.agora.io/en/voice-sdk/flutter/6.x/API/rtc_api_overview.html)

### Community Support

- [Agora Developer Community](https://www.agora.io/en/community/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/agora)
- [GitHub Issues](https://github.com/AgoraIO/Flutter-SDK/issues)

### Contact Support

- Email: support@agora.io
- Console: Submit ticket through Agora Console
- Sales: sales@agora.io

---

## Changelog

### Version 1.0 (Initial Setup)
- Basic voice call functionality
- Token generation on backend
- Flutter SDK integration
- Android and iOS configuration

---

**Last Updated:** December 3, 2025
