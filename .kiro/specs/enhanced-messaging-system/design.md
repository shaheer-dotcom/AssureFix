# Enhanced Messaging System - Design Document

## Overview

The Enhanced Messaging System builds upon the existing chat infrastructure to provide a comprehensive communication platform for customers and service providers. The design integrates profile picture display, voice calling capabilities, rich media sharing (images, voice notes, locations), and intelligent chat lifecycle management tied to booking statuses.

The system leverages the existing Flutter frontend with Dart, Node.js/Express backend with MongoDB, and introduces new integrations for voice calling and enhanced media handling.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Frontend                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Chat Screen  │  │ Voice Call   │  │ Media Picker │     │
│  │              │  │ Screen       │  │ Components   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                  │                  │             │
│  ┌──────────────────────────────────────────────────┐     │
│  │         Messaging Provider & Services             │     │
│  └──────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
                           │
                    REST API / WebSocket
                           │
┌─────────────────────────────────────────────────────────────┐
│                   Node.js/Express Backend                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Chat Routes  │  │ Call Service │  │ Notification │     │
│  │              │  │              │  │ Service      │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                  │                  │             │
│  ┌──────────────────────────────────────────────────┐     │
│  │              MongoDB Database                     │     │
│  │  - Chat Collection                                │     │
│  │  - Conversation Collection                        │     │
│  │  - Message Collection                             │     │
│  │  - Booking Collection                             │     │
│  └──────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
                           │
                    External Services
                           │
┌─────────────────────────────────────────────────────────────┐
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ WebRTC/Agora │  │ Google Maps  │  │ File Storage │     │
│  │ Voice Calls  │  │ API          │  │ (Local/S3)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

1. **Message Sending Flow**:
   - User composes message → Frontend validates → API request → Backend processes → Database stores → Notification sent → Receiver updates

2. **Voice Call Flow**:
   - User initiates call → Frontend requests call token → Backend generates token → WebRTC connection established → Audio streams exchanged → Call ends → Connection closed

3. **Media Upload Flow**:
   - User selects media → Frontend compresses → Upload to server → Server stores file → Returns file path → Message created with media reference

4. **Booking-Chat Lifecycle Flow**:
   - Booking created → Notification sent → Provider accepts → Conversation created/activated → Messages exchanged → Booking completed/cancelled → Conversation closed

## Components and Interfaces

### Frontend Components

#### 1. Enhanced Chat Screen (`whatsapp_chat_screen.dart`)

**Purpose**: Main chat interface with all messaging features

**Key Enhancements**:
- Profile picture display in header (fetch from user data)
- Voice call button integration
- Enhanced attachment menu (camera, gallery, location)
- Voice note recording UI with visual feedback
- Improved message bubble rendering for all media types
- Chat status indicator (active/closed based on booking)

**State Management**:
```dart
class _WhatsAppChatScreenState {
  String? receiverProfilePicture;
  bool isCallActive;
  bool isChatActive; // Based on booking status
  String? bookingId;
  // ... existing state
}
```

**New Methods**:
- `_loadReceiverProfile()`: Fetch receiver's profile picture
- `_initiateVoiceCall()`: Start voice call
- `_checkChatStatus()`: Verify if chat is active based on booking
- `_handleClosedChat()`: Display message when chat is closed

#### 2. Voice Call Screen (`voice_call_screen.dart`)

**Purpose**: Dedicated screen for voice call interface

**Features**:
- Display caller/receiver name and profile picture
- Call duration timer
- Mute/unmute button
- Speaker toggle
- End call button
- Connection status indicator

**State Management**:
```dart
class _VoiceCallScreenState {
  bool isMuted;
  bool isSpeakerOn;
  Duration callDuration;
  CallStatus status; // connecting, connected, ended
  AgoraRtcEngine? rtcEngine;
}
```

#### 3. Booking Notification Component (`booking_notification_widget.dart`)

**Purpose**: Display booking requests with accept/decline actions

**Features**:
- Show booking details (service, date, time, customer info)
- Accept button (green)
- Decline button (red)
- Loading state during action processing

**Props**:
```dart
class BookingNotificationWidget {
  final String bookingId;
  final String serviceName;
  final DateTime reservationDate;
  final String customerName;
  final String customerAddress;
  final Function(bool accepted) onAction;
}
```

#### 4. Media Picker Service (`media_picker_service.dart`)

**Purpose**: Centralized service for handling media selection and upload

**Methods**:
```dart
class MediaPickerService {
  Future<String?> pickImageFromGallery();
  Future<String?> captureImageFromCamera();
  Future<File> compressImage(File image);
  Future<String> uploadImage(File image);
}
```

#### 5. Location Service (`location_service.dart`)

**Purpose**: Handle location retrieval and geocoding

**Methods**:
```dart
class LocationService {
  Future<Position> getCurrentLocation();
  Future<String> getAddressFromCoordinates(double lat, double lng);
  Future<void> openInMaps(double lat, double lng);
}
```

#### 6. Voice Recording Service (`voice_recording_service.dart`)

**Purpose**: Manage audio recording and playback

**Methods**:
```dart
class VoiceRecordingService {
  Future<void> startRecording();
  Future<String?> stopRecording();
  void cancelRecording();
  Future<int> getAudioDuration(String filePath);
  Future<String> uploadVoiceNote(File audioFile);
}
```

### Backend Components

#### 1. Enhanced Chat Routes (`/api/chat`)

**Existing Endpoints** (to be enhanced):
- `GET /api/chat/my-chats` - Add profile picture population
- `GET /api/chat/:id` - Add booking status check
- `POST /api/chat/:id/messages` - Add booking status validation

**New Endpoints**:
- `GET /api/chat/:id/status` - Check if chat is active based on booking
- `POST /api/chat/:id/reopen` - Reopen closed chat for new booking

#### 2. Voice Call Service (`/api/calls`)

**New Endpoints**:
- `POST /api/calls/initiate` - Generate call token and notify receiver
- `POST /api/calls/:callId/accept` - Accept incoming call
- `POST /api/calls/:callId/reject` - Reject incoming call
- `POST /api/calls/:callId/end` - End active call
- `GET /api/calls/token` - Get Agora/WebRTC token for call

**Call Model**:
```javascript
{
  callId: ObjectId,
  callerId: ObjectId (ref: User),
  receiverId: ObjectId (ref: User),
  conversationId: ObjectId (ref: Conversation),
  status: enum ['initiated', 'ringing', 'active', 'ended', 'rejected'],
  startTime: Date,
  endTime: Date,
  duration: Number
}
```

#### 3. Enhanced Booking Routes (`/api/bookings`)

**Enhanced Endpoints**:
- `POST /api/bookings` - Create booking and send notification
- `PATCH /api/bookings/:id/accept` - Accept booking and create/activate conversation
- `PATCH /api/bookings/:id/complete` - Complete booking and close conversation
- `PATCH /api/bookings/:id/cancel` - Cancel booking and close conversation

#### 4. Notification Service Enhancement

**New Methods**:
```javascript
async function sendBookingNotification(booking, provider) {
  // Send push notification with booking details
  // Include action buttons for accept/decline
}

async function sendCallNotification(call, receiver) {
  // Send push notification for incoming call
}
```

#### 5. Media Upload Service

**Enhanced Methods**:
```javascript
async function uploadMedia(file, type) {
  // Validate file type and size
  // Compress if image
  // Store in uploads directory or S3
  // Return file path/URL
}
```

## Data Models

### Enhanced Chat Model

```javascript
const chatSchema = new mongoose.Schema({
  participants: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }],
  serviceId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
    required: true
  },
  bookingId: {  // NEW: Link to current booking
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking'
  },
  messages: [messageSchema],
  status: {
    type: String,
    enum: ['pending', 'active', 'closed'],  // UPDATED: Add 'closed'
    default: 'pending'
  },
  lastMessage: {
    type: Date,
    default: Date.now
  },
  closedAt: Date,  // NEW: Track when chat was closed
  closedReason: String  // NEW: 'completed' or 'cancelled'
}, {
  timestamps: true
});
```

### Enhanced Message Schema (within Chat)

```javascript
const messageSchema = new mongoose.Schema({
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  messageType: {
    type: String,
    enum: ['text', 'voice', 'image', 'location', 'booking_request'],  // UPDATED: Add 'image'
    default: 'text'
  },
  content: {
    text: String,
    voiceUrl: String,
    imageUrl: String,  // NEW: For image messages
    location: {
      latitude: Number,
      longitude: Number,
      address: String
    },
    bookingData: {
      serviceId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Service'
      }
    }
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  isRead: {
    type: Boolean,
    default: false
  },
  deliveredAt: Date,  // NEW: Track delivery time
  readAt: Date  // NEW: Track read time
});
```

### Call Model (New)

```javascript
const callSchema = new mongoose.Schema({
  callerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  receiverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  conversationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Chat'
  },
  status: {
    type: String,
    enum: ['initiated', 'ringing', 'active', 'ended', 'rejected', 'missed'],
    default: 'initiated'
  },
  startTime: {
    type: Date,
    default: Date.now
  },
  endTime: Date,
  duration: Number,  // in seconds
  agoraChannelName: String,
  agoraToken: String
}, {
  timestamps: true
});
```

### Enhanced Booking Model

```javascript
// Add new fields to existing Booking model
{
  // ... existing fields
  conversationId: {  // NEW: Link to chat conversation
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Chat'
  },
  notificationSent: {  // NEW: Track if notification was sent
    type: Boolean,
    default: false
  },
  acceptedAt: Date,  // NEW: Track when booking was accepted
  // ... existing fields
}
```

## Error Handling

### Frontend Error Handling

1. **Network Errors**:
   - Display user-friendly error messages
   - Implement retry mechanism for failed uploads
   - Queue messages for sending when offline

2. **Permission Errors**:
   - Check permissions before accessing camera/microphone/location
   - Display permission request dialogs with clear explanations
   - Provide navigation to settings if permissions are permanently denied

3. **Media Errors**:
   - Handle image compression failures
   - Validate file sizes before upload
   - Display error for unsupported file types

4. **Call Errors**:
   - Handle connection failures gracefully
   - Display appropriate messages for busy/unavailable users
   - Implement call timeout mechanism

### Backend Error Handling

1. **Validation Errors**:
   - Validate all input data
   - Return clear error messages with field-specific details

2. **Database Errors**:
   - Handle connection failures
   - Implement transaction rollback for critical operations

3. **File Upload Errors**:
   - Validate file types and sizes
   - Handle storage failures
   - Clean up failed uploads

4. **Booking Status Errors**:
   - Prevent message sending in closed chats
   - Return appropriate status codes and messages

## Testing Strategy

### Unit Tests

**Frontend**:
- Media picker service methods
- Location service methods
- Voice recording service methods
- Message formatting utilities
- Date/time formatting functions

**Backend**:
- Chat route handlers
- Call service methods
- Notification service methods
- Media upload validation
- Booking-chat lifecycle logic

### Integration Tests

**Frontend**:
- Chat screen with all message types
- Voice call flow (initiate, accept, end)
- Media upload and display
- Location sharing and map opening
- Voice note recording and playback

**Backend**:
- Complete message sending flow
- Booking creation to chat activation
- Chat closure on booking completion
- Chat reopening for repeat bookings
- Call initiation and management

### End-to-End Tests

1. **Complete Booking Flow**:
   - Customer creates booking
   - Provider receives notification
   - Provider accepts booking
   - Chat becomes active
   - Users exchange messages
   - Booking is completed
   - Chat is closed

2. **Media Sharing Flow**:
   - User sends image from gallery
   - User captures and sends photo
   - User shares location
   - User sends voice note
   - Receiver views all media types

3. **Voice Call Flow**:
   - User initiates call
   - Receiver receives notification
   - Receiver accepts call
   - Audio connection established
   - Users communicate
   - Call is ended

4. **Repeat Booking Flow**:
   - Customer books same provider again
   - Existing chat is reopened
   - Previous messages are visible
   - New messages can be sent

### Manual Testing Scenarios

1. **Profile Picture Display**:
   - Test with uploaded profile pictures
   - Test with no profile picture (fallback)
   - Test for both customer and provider

2. **Network Conditions**:
   - Test with slow network
   - Test with intermittent connectivity
   - Test offline message queuing

3. **Permission Scenarios**:
   - Test with all permissions granted
   - Test with permissions denied
   - Test permission request flows

4. **Edge Cases**:
   - Test with very long messages
   - Test with large image files
   - Test with long voice notes
   - Test rapid message sending
   - Test simultaneous calls

## Performance Considerations

### Frontend Optimization

1. **Image Handling**:
   - Compress images before upload (max 1200x1200, 85% quality)
   - Use cached network images for profile pictures
   - Implement lazy loading for message images
   - Display thumbnails before full images

2. **Message Loading**:
   - Implement pagination (50 messages per page)
   - Load older messages on scroll
   - Cache recent conversations

3. **Voice Notes**:
   - Limit recording duration to 2 minutes
   - Compress audio files before upload
   - Stream audio playback instead of downloading entire file

### Backend Optimization

1. **Database Queries**:
   - Index frequently queried fields (conversationId, senderId, timestamp)
   - Use population selectively to avoid over-fetching
   - Implement query result caching for user profiles

2. **File Storage**:
   - Store files in efficient format
   - Implement CDN for media delivery (future enhancement)
   - Clean up orphaned files periodically

3. **Real-time Updates**:
   - Use WebSocket for message delivery
   - Implement message batching for high-frequency updates
   - Optimize notification payload size

## Security Considerations

1. **Authentication**:
   - Verify JWT tokens on all API requests
   - Validate user is participant in conversation before allowing access

2. **File Upload Security**:
   - Validate file types (whitelist approach)
   - Limit file sizes (10MB max)
   - Scan uploaded files for malware (future enhancement)
   - Generate unique filenames to prevent overwriting

3. **Call Security**:
   - Generate time-limited tokens for voice calls
   - Validate call participants
   - Implement call encryption (WebRTC default)

4. **Data Privacy**:
   - Respect blocked user relationships
   - Prevent access to closed conversations
   - Implement message deletion (future enhancement)

## Third-Party Integrations

### 1. Agora SDK (Voice Calling)

**Purpose**: Provide real-time voice communication

**Integration Points**:
- Frontend: `agora_rtc_engine` Flutter package
- Backend: Agora REST API for token generation

**Configuration**:
```dart
// Frontend
AgoraRtcEngine.create(appId);
engine.joinChannel(token, channelName, null, userId);
```

```javascript
// Backend
const RtcTokenBuilder = require('agora-access-token').RtcTokenBuilder;
const token = RtcTokenBuilder.buildTokenWithUid(appId, appCertificate, channelName, uid, role, expireTime);
```

### 2. Google Maps API (Location Services)

**Purpose**: Display and open shared locations

**Integration Points**:
- Frontend: `url_launcher` package to open maps
- Backend: Google Geocoding API for address lookup

**Usage**:
```dart
// Open location in maps
final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
await launchUrl(Uri.parse(url));
```

### 3. Image Picker & Camera

**Purpose**: Capture and select images

**Integration Points**:
- Frontend: `image_picker` Flutter package (already integrated)

**Usage**:
```dart
final XFile? image = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 1200,
  maxHeight: 1200,
  imageQuality: 85,
);
```

### 4. Audio Recording & Playback

**Purpose**: Record and play voice notes

**Integration Points**:
- Frontend: `record` package for recording, `audioplayers` for playback (already integrated)

**Usage**:
```dart
// Recording
await AudioRecorder().start(RecordConfig(), path: filePath);
final path = await AudioRecorder().stop();

// Playback
await AudioPlayer().play(UrlSource(audioUrl));
```

## Migration and Deployment

### Database Migration

1. **Add new fields to existing collections**:
   - Add `bookingId`, `closedAt`, `closedReason` to Chat collection
   - Add `imageUrl`, `deliveredAt`, `readAt` to message schema
   - Add `conversationId`, `notificationSent`, `acceptedAt` to Booking collection

2. **Create new Call collection**

3. **Update indexes**:
   - Add index on `Chat.bookingId`
   - Add index on `Call.callerId` and `Call.receiverId`

### Deployment Steps

1. **Backend Deployment**:
   - Deploy database migrations
   - Deploy updated API routes
   - Deploy new call service
   - Configure Agora credentials
   - Test API endpoints

2. **Frontend Deployment**:
   - Update Flutter dependencies
   - Build and test on Android/iOS
   - Deploy to app stores (staged rollout)

3. **Monitoring**:
   - Monitor API error rates
   - Track call connection success rates
   - Monitor media upload failures
   - Track notification delivery rates

## Future Enhancements

1. **Video Calling**: Extend voice calling to support video
2. **Message Reactions**: Allow users to react to messages with emojis
3. **Message Editing**: Allow users to edit sent messages
4. **Message Deletion**: Allow users to delete messages
5. **Typing Indicators**: Show when the other user is typing
6. **Online Status**: Display user online/offline status
7. **Message Search**: Search within conversation history
8. **File Sharing**: Support document and PDF sharing
9. **Group Chats**: Support multi-user conversations
10. **End-to-End Encryption**: Implement E2E encryption for messages
