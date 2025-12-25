# Implementation Plan

## Overview

This implementation plan breaks down the Enhanced Messaging System into discrete, actionable coding tasks. Each task builds incrementally on previous work, ensuring a systematic approach to implementing all features.

## Tasks

- [x] 1. Backend: Enhance data models and database schema





  - Update Chat model to include bookingId, closedAt, closedReason fields
  - Update message schema to include imageUrl, deliveredAt, readAt fields
  - Update Booking model to include conversationId, notificationSent, acceptedAt fields
  - Create new Call model with all required fields
  - Add database indexes for performance optimization
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 6.10, 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 2. Backend: Implement booking-chat lifecycle management






  - [x] 2.1 Update booking creation endpoint to initialize conversation

    - Modify POST /api/bookings to create or find existing conversation
    - Link booking to conversation via conversationId field
    - Set conversation status based on booking status
    - _Requirements: 6.1, 7.1, 7.2_
  

  - [x] 2.2 Implement booking acceptance flow

    - Create PATCH /api/bookings/:id/accept endpoint
    - Update booking status to confirmed
    - Activate or create conversation when booking is accepted
    - Send notification to customer about acceptance
    - _Requirements: 6.4, 6.5, 6.6_
  

  - [x] 2.3 Implement booking completion and cancellation handlers

    - Create PATCH /api/bookings/:id/complete endpoint
    - Create PATCH /api/bookings/:id/cancel endpoint
    - Close conversation when booking is completed or cancelled
    - Set closedAt and closedReason fields in Chat model
    - _Requirements: 6.8, 6.9_
  

  - [x] 2.4 Add chat status validation to message sending

    - Update POST /api/chat/:id/messages to check booking status
    - Prevent message sending if booking is completed or cancelled
    - Return appropriate error message when chat is closed
    - _Requirements: 6.7, 6.10_
  

  - [x] 2.5 Implement chat reopening for repeat bookings

    - Create POST /api/chat/:id/reopen endpoint
    - Search for existing conversations between users
    - Reopen conversation and update status to active
    - Preserve message history when reopening
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 3. Backend: Enhance notification service for booking requests





  - [x] 3.1 Create booking notification payload structure


    - Define notification data structure with booking details
    - Include service name, date, time, customer info, address
    - Add action buttons data for accept/decline
    - _Requirements: 6.1, 6.2, 6.3_
  
  - [x] 3.2 Implement sendBookingNotification function

    - Create function to send push notification to service provider
    - Include all booking details in notification payload
    - Handle notification delivery failures gracefully
    - _Requirements: 6.1, 6.2_

- [x] 4. Backend: Implement voice call service and API





  - [x] 4.1 Set up Agora SDK integration


    - Install agora-access-token npm package
    - Configure Agora App ID and App Certificate in environment variables
    - Create utility functions for token generation
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_
  
  - [x] 4.2 Create Call model and routes


    - Implement Call mongoose model with schema
    - Create POST /api/calls/initiate endpoint
    - Create POST /api/calls/:callId/accept endpoint
    - Create POST /api/calls/:callId/reject endpoint
    - Create POST /api/calls/:callId/end endpoint
    - Create GET /api/calls/token endpoint
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 4.3 Implement call notification service


    - Create sendCallNotification function
    - Send push notification to receiver when call is initiated
    - Include caller information in notification
    - _Requirements: 2.2, 2.3_

- [x] 5. Backend: Enhance chat routes for profile pictures and media





  - [x] 5.1 Update chat endpoints to populate profile pictures


    - Modify GET /api/chat/my-chats to populate profile.profilePicture
    - Modify GET /api/chat/:id to include participant profile pictures
    - Ensure profile pictures are included in message sender data
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [x] 5.2 Enhance media upload handling


    - Update multer configuration to handle images separately
    - Add image compression logic before storage
    - Update message creation to support imageUrl in content
    - Validate image file types and sizes
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9_
  
  - [x] 5.3 Implement message delivery and read status tracking


    - Update message schema to track deliveredAt and readAt timestamps
    - Modify PATCH /api/chat/:id/read to set readAt timestamp
    - Add endpoint to mark messages as delivered
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 6. Frontend: Create voice call screen and service






  - [x] 6.1 Install and configure Agora Flutter SDK


    - Add agora_rtc_engine dependency to pubspec.yaml
    - Configure Android and iOS permissions for microphone
    - Initialize Agora engine in app startup
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_
  
  - [x] 6.2 Create VoiceCallScreen widget


    - Create new file frontend/lib/screens/calls/voice_call_screen.dart
    - Implement UI with caller/receiver info, profile picture, call duration
    - Add mute, speaker, and end call buttons
    - Display connection status indicator
    - _Requirements: 2.2, 2.3, 2.4, 2.5_
  
  - [x] 6.3 Implement VoiceCallService


    - Create new file frontend/lib/services/voice_call_service.dart
    - Implement initiateCall method to request call token from backend
    - Implement acceptCall method to join Agora channel
    - Implement endCall method to leave channel and update backend
    - Handle call state management (connecting, connected, ended)
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_
  
  - [x] 6.4 Integrate call functionality into chat screen



    - Add voice call button to chat screen app bar
    - Implement onPressed handler to initiate call
    - Navigate to VoiceCallScreen when call is initiated
    - Handle incoming call notifications
    - _Requirements: 2.1, 2.2_

- [x] 7. Frontend: Enhance chat screen with profile pictures







  - [x] 7.1 Update chat screen to fetch and display receiver profile picture



    - Modify WhatsAppChatScreen to accept receiverId parameter
    - Create _loadReceiverProfile method to fetch user data
    - Update app bar to display profile picture instead of avatar with initials
    - Use CachedNetworkImage for profile picture display
    - Implement fallback to initials avatar if no profile picture
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  
  - [x] 7.2 Add profile picture tap navigation


    - Make profile picture in app bar tappable
    - Navigate to UserProfileViewScreen on tap
    - Pass receiver's userId to profile screen
    - _Requirements: 1.5_
  
  - [x] 7.3 Update conversations list to show profile pictures


    - Modify conversations_screen.dart to display profile pictures
    - Use CachedNetworkImage for each conversation item
    - Implement fallback avatars for users without profile pictures
    - _Requirements: 1.1, 1.2, 1.3_

- [x] 8. Frontend: Implement image sending via camera and gallery






  - [x] 8.1 Create MediaPickerService


    - Create new file frontend/lib/services/media_picker_service.dart
    - Implement pickImageFromGallery method using ImagePicker
    - Implement captureImageFromCamera method using ImagePicker
    - Implement compressImage method using image compression package
    - Implement uploadImage method to send to backend
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9_
  
  - [x] 8.2 Update attachment menu in chat screen


    - Modify _showAttachmentOptions to include Camera and Gallery options
    - Add onTap handlers for camera and gallery options
    - Display loading indicator while uploading images
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  
  - [x] 8.3 Fix image message sending functionality



    - Update _pickAndSendImage method to use MediaPickerService
    - Update _takeAndSendPhoto method to use MediaPickerService
    - Ensure images are properly uploaded and message is sent
    - Handle upload errors and display error messages
    - _Requirements: 3.4, 3.5, 3.6, 3.7_
  
  - [x] 8.4 Enhance image message display


    - Update _buildMessageBubble to properly render image messages
    - Implement full-screen image view on tap
    - Add zoom and pan capabilities to full-screen view
    - Display loading placeholder while images load
    - _Requirements: 3.8, 3.9_

- [x] 9. Frontend: Fix and enhance location sharing






  - [x] 9.1 Create LocationService


    - Create new file frontend/lib/services/location_service.dart
    - Implement getCurrentLocation method using Geolocator
    - Implement getAddressFromCoordinates using Geocoding
    - Implement openInMaps method using url_launcher
    - Handle location permission requests
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8_
  
  - [x] 9.2 Fix location sending in chat screen



    - Update _sendLocation method to use LocationService
    - Request location permissions before accessing location
    - Display loading indicator while fetching location
    - Handle permission denial gracefully
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.8_
  
  - [x] 9.3 Fix location message display and map opening


    - Update location message rendering in _buildMessageBubble
    - Ensure location messages display map icon and address
    - Fix onTap handler to properly open maps application
    - Test with Google Maps and other map apps
    - _Requirements: 4.6, 4.7_

- [x] 10. Frontend: Fix and enhance voice note functionality





  - [x] 10.1 Create VoiceRecordingService


    - Create new file frontend/lib/services/voice_recording_service.dart
    - Implement startRecording method using AudioRecorder
    - Implement stopRecording method and return file path
    - Implement cancelRecording method
    - Implement getAudioDuration method
    - Implement uploadVoiceNote method to send to backend
    - Handle microphone permission requests
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.9, 5.10_
  
  - [x] 10.2 Fix voice note recording in chat screen


    - Update _startRecording method to use VoiceRecordingService
    - Update _stopRecording method to upload and send voice note
    - Update _cancelRecording method to discard recording
    - Display recording indicator with elapsed time
    - Handle recording errors and display error messages
    - _Requirements: 5.2, 5.3, 5.4, 5.5, 5.9, 5.10_
  
  - [x] 10.3 Fix voice note playback


    - Update _playVoiceMessage method to properly play audio
    - Display play/pause button based on playback state
    - Show playback progress indicator
    - Handle audio playback errors
    - _Requirements: 5.6, 5.7, 5.8_

- [x] 11. Frontend: Implement booking notification UI





  - [x] 11.1 Create BookingNotificationWidget


    - Create new file frontend/lib/widgets/booking_notification_widget.dart
    - Display booking details (service, date, time, customer info)
    - Add Accept button with green styling
    - Add Decline button with red styling
    - Show loading state during action processing
    - _Requirements: 6.1, 6.2, 6.3_
  
  - [x] 11.2 Integrate booking notifications in notification screen


    - Update notifications_screen.dart to display booking notifications
    - Add onAccept handler to call booking acceptance API
    - Add onDecline handler to call booking rejection API
    - Navigate to chat screen after accepting booking
    - _Requirements: 6.3, 6.4, 6.5, 6.6_

- [x] 12. Frontend: Implement chat lifecycle management











  - [x] 12.1 Add chat status checking to chat screen


    - Create _checkChatStatus method to verify booking status
    - Call API to get current booking status
    - Update isChatActive state based on booking status
    - Disable message input when chat is closed
    - _Requirements: 6.7, 6.8, 6.9, 6.10_
  
  - [x] 12.2 Display closed chat indicator


    - Create _handleClosedChat method to show closed message
    - Display banner or message when chat is closed
    - Show reason for closure (completed or cancelled)
    - Prevent message sending when chat is closed
    - _Requirements: 6.9, 6.10_
  
  - [x] 12.3 Implement chat reopening for repeat bookings


    - Update booking creation flow to check for existing conversations
    - Reopen closed conversations when new booking is created
    - Preserve message history in reopened conversations
    - Update chat status to active when reopened
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 13. Frontend: Implement message delivery and read status





  - [x] 13.1 Update message model to include delivery and read status


    - Add deliveredAt and readAt fields to Message model
    - Update Message.fromJson to parse new fields
    - _Requirements: 8.1, 8.2, 8.3, 8.4_
  
  - [x] 13.2 Update message bubble to display status indicators


    - Modify _buildMessageBubble to show checkmark indicators
    - Display single checkmark for sent messages
    - Display double checkmark for delivered messages
    - Display blue double checkmark for read messages
    - _Requirements: 8.1, 8.2, 8.3, 8.4_
  
  - [x] 13.3 Implement real-time status updates


    - Update messages provider to handle status updates
    - Mark messages as read when chat screen is opened
    - Update UI when message status changes
    - _Requirements: 8.3, 8.4, 8.5_

- [x] 14. Frontend: Implement error handling and user feedback






  - [x] 14.1 Add error handling for media uploads

    - Display error messages when image upload fails
    - Display error messages when voice note upload fails
    - Show retry option for failed uploads
    - _Requirements: 9.1, 9.2_
  

  - [x] 14.2 Add error handling for location services

    - Display error when location retrieval fails
    - Show permission instructions when location is denied
    - Handle geocoding failures gracefully
    - _Requirements: 9.3, 9.7_
  

  - [x] 14.3 Add error handling for voice calls

    - Display error when call fails to connect
    - Show appropriate message for busy/unavailable users
    - Implement call timeout mechanism
    - Return to chat screen on call failure
    - _Requirements: 9.5, 9.6_
  
  - [x] 14.4 Implement network error handling


    - Display error when network is unavailable
    - Queue messages for sending when connection is restored
    - Show connection status indicator
    - _Requirements: 9.4, 9.6_
  
  - [x] 14.5 Add permission error handling


    - Display clear permission request dialogs
    - Show instructions for enabling permissions in settings
    - Handle permanently denied permissions
    - _Requirements: 9.7_

- [x] 15. Frontend: Implement performance optimizations






  - [x] 15.1 Add image compression and caching

    - Compress images before upload (max 1200x1200, 85% quality)
    - Use CachedNetworkImage for all profile pictures
    - Implement lazy loading for message images
    - Display thumbnails before full images
    - _Requirements: 10.2, 10.4, 10.5_
  
  - [x] 15.2 Implement message pagination


    - Add pagination to message loading (50 messages per batch)
    - Load older messages on scroll to top
    - Display loading indicator while fetching messages
    - _Requirements: 10.3_
  
  - [x] 15.3 Optimize voice note handling


    - Limit voice note recording to 2 minutes
    - Compress audio files before upload
    - Stream audio playback instead of downloading entire file
    - _Requirements: 10.6_
  

  - [x] 15.4 Implement lazy loading for message media

    - Load media only when visible in viewport
    - Unload media when scrolled out of view
    - Improve scroll performance with lazy loading
    - _Requirements: 10.7_

- [x] 16. Testing and validation







  - [x] 16.1 Write unit tests for backend services


    - Test booking-chat lifecycle logic
    - Test call service methods
    - Test notification service
    - Test media upload validation
    - _Requirements: All_
  
  - [x] 16.2 Write unit tests for frontend services


    - Test MediaPickerService methods
    - Test LocationService methods
    - Test VoiceRecordingService methods
    - Test VoiceCallService methods
    - _Requirements: All_
  
  - [x] 16.3 Write integration tests


    - Test complete booking to chat flow
    - Test media upload and display flow
    - Test voice call flow
    - Test chat reopening flow
    - _Requirements: All_
  
  - [x] 16.4 Perform manual testing


    - Test all features with real devices
    - Test with different network conditions
    - Test permission scenarios
    - Test edge cases (large files, long messages, etc.)
    - _Requirements: All_

- [x] 17. Documentation and deployment preparation





  - Update API documentation with new endpoints
  - Document Agora SDK setup and configuration
  - Create deployment checklist
  - Prepare database migration scripts
  - Update environment variable documentation
  - _Requirements: All_
