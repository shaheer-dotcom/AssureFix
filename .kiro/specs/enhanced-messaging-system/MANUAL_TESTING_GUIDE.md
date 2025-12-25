# Enhanced Messaging System - Manual Testing Guide

## Overview

This guide provides comprehensive manual testing procedures for the Enhanced Messaging System. Follow these test cases to validate all features work correctly on real devices under various conditions.

## Prerequisites

- Two physical devices (Android/iOS) or one physical device + emulator
- Two test accounts (one customer, one service provider)
- Active internet connection
- Backend server running
- Test images, audio files ready

## Test Environment Setup

### Device Setup
1. Install the app on both test devices
2. Log in with customer account on Device A
3. Log in with service provider account on Device B
4. Grant all permissions (camera, microphone, location, storage)
5. Ensure both devices have stable internet connection

### Backend Verification
1. Verify backend server is running
2. Check MongoDB connection is active
3. Verify Agora credentials are configured
4. Confirm file upload directory exists and is writable

---

## Test Suite 1: Profile Picture Display

### Test Case 1.1: Profile Picture in Chat Header
**Objective**: Verify profile pictures display correctly in chat interface

**Steps**:
1. On Device A (customer), navigate to a conversation with a service provider
2. Observe the chat header

**Expected Results**:
- ✓ Service provider's profile picture displays in header
- ✓ Image loads without errors
- ✓ Image is properly sized and centered

**Test with**:
- User with uploaded profile picture
- User without profile picture (should show initials fallback)

### Test Case 1.2: Profile Picture Tap Navigation
**Objective**: Verify tapping profile picture navigates to profile view

**Steps**:
1. In chat screen, tap on the profile picture in header
2. Observe navigation

**Expected Results**:
- ✓ Navigates to user profile view screen
- ✓ Correct user profile is displayed
- ✓ Back navigation returns to chat

### Test Case 1.3: Profile Pictures in Conversations List
**Objective**: Verify profile pictures display in conversations list

**Steps**:
1. Navigate to Messages tab
2. Observe conversation list items

**Expected Results**:
- ✓ Each conversation shows participant's profile picture
- ✓ Images load efficiently
- ✓ Fallback avatars display for users without pictures

---

## Test Suite 2: Voice Call Functionality

### Test Case 2.1: Initiate Voice Call
**Objective**: Verify voice call can be initiated from chat

**Steps**:
1. On Device A, open chat with Device B user
2. Tap the voice call button in header
3. Observe call screen

**Expected Results**:
- ✓ Call screen displays with receiver's name and picture
- ✓ "Calling..." status shows
- ✓ Device B receives call notification

### Test Case 2.2: Accept Voice Call
**Objective**: Verify incoming calls can be accepted

**Steps**:
1. On Device B, receive incoming call notification
2. Tap "Accept" button
3. Observe call connection

**Expected Results**:
- ✓ Call connects successfully
- ✓ Audio streams in both directions
- ✓ Call duration timer starts
- ✓ Mute and speaker buttons are functional

### Test Case 2.3: Reject Voice Call
**Objective**: Verify calls can be rejected

**Steps**:
1. On Device B, receive incoming call
2. Tap "Reject" button

**Expected Results**:
- ✓ Call is rejected
- ✓ Device A shows "Call rejected" message
- ✓ Both devices return to previous screen

### Test Case 2.4: End Active Call
**Objective**: Verify active calls can be ended

**Steps**:
1. Establish active call between devices
2. On either device, tap "End Call" button

**Expected Results**:
- ✓ Call ends immediately
- ✓ Call duration is recorded
- ✓ Both devices return to chat screen

### Test Case 2.5: Call Audio Controls
**Objective**: Verify mute and speaker controls work

**Steps**:
1. During active call, tap mute button
2. Speak into microphone
3. Tap mute again to unmute
4. Tap speaker button
5. Speak and listen

**Expected Results**:
- ✓ Mute prevents audio transmission
- ✓ Unmute restores audio transmission
- ✓ Speaker toggles between earpiece and loudspeaker
- ✓ Visual indicators update correctly

---

## Test Suite 3: Image Sending

### Test Case 3.1: Send Image from Gallery
**Objective**: Verify images can be sent from device gallery

**Steps**:
1. In chat screen, tap attachment button
2. Select "Gallery" option
3. Choose an image from gallery
4. Wait for upload

**Expected Results**:
- ✓ Gallery opens correctly
- ✓ Selected image uploads successfully
- ✓ Loading indicator displays during upload
- ✓ Image appears in chat as message
- ✓ Receiver sees image message

### Test Case 3.2: Capture and Send Photo
**Objective**: Verify photos can be captured and sent

**Steps**:
1. In chat screen, tap attachment button
2. Select "Camera" option
3. Capture a photo
4. Confirm and send

**Expected Results**:
- ✓ Camera opens correctly
- ✓ Photo is captured successfully
- ✓ Photo uploads and sends
- ✓ Image appears in chat
- ✓ Receiver sees image message

### Test Case 3.3: View Full-Screen Image
**Objective**: Verify images can be viewed in full screen

**Steps**:
1. In chat, tap on an image message
2. Observe full-screen view
3. Pinch to zoom
4. Pan around image

**Expected Results**:
- ✓ Image opens in full-screen view
- ✓ Zoom functionality works
- ✓ Pan functionality works
- ✓ Back button returns to chat

### Test Case 3.4: Large Image Handling
**Objective**: Verify large images are handled properly

**Steps**:
1. Select a large image (>5MB) from gallery
2. Send the image

**Expected Results**:
- ✓ Image is compressed before upload
- ✓ Upload completes successfully
- ✓ Image quality is acceptable
- ✓ No app crashes or freezes

---

## Test Suite 4: Location Sharing

### Test Case 4.1: Share Current Location
**Objective**: Verify current location can be shared

**Steps**:
1. In chat screen, tap attachment button
2. Select "Location" option
3. Grant location permission if prompted
4. Wait for location to be retrieved

**Expected Results**:
- ✓ Location permission is requested
- ✓ Current location is retrieved
- ✓ Address is geocoded correctly
- ✓ Location message is sent
- ✓ Receiver sees location with address

### Test Case 4.2: Open Location in Maps
**Objective**: Verify shared locations open in maps app

**Steps**:
1. Tap on a location message
2. Observe maps app opening

**Expected Results**:
- ✓ Maps app opens
- ✓ Correct location is displayed
- ✓ Location pin is accurate

### Test Case 4.3: Location Permission Denied
**Objective**: Verify graceful handling of denied permissions

**Steps**:
1. Deny location permission
2. Try to share location

**Expected Results**:
- ✓ Error message displays
- ✓ Instructions for enabling permission shown
- ✓ App doesn't crash

---

## Test Suite 5: Voice Notes

### Test Case 5.1: Record Voice Note
**Objective**: Verify voice notes can be recorded

**Steps**:
1. In chat screen, long-press microphone button
2. Speak for 10 seconds
3. Release button

**Expected Results**:
- ✓ Recording starts immediately
- ✓ Recording indicator displays with timer
- ✓ Recording stops on release
- ✓ Voice note uploads and sends
- ✓ Receiver sees voice note message

### Test Case 5.2: Cancel Voice Recording
**Objective**: Verify recordings can be cancelled

**Steps**:
1. Long-press microphone button
2. Slide to cancel area
3. Release

**Expected Results**:
- ✓ Recording is cancelled
- ✓ No message is sent
- ✓ Recording is discarded

### Test Case 5.3: Play Voice Note
**Objective**: Verify voice notes can be played

**Steps**:
1. Tap play button on a voice note message
2. Observe playback
3. Tap pause during playback

**Expected Results**:
- ✓ Audio plays correctly
- ✓ Play button changes to pause
- ✓ Progress indicator updates
- ✓ Pause stops playback
- ✓ Duration displays correctly

### Test Case 5.4: Long Voice Note
**Objective**: Verify long recordings are handled

**Steps**:
1. Record a voice note for 2 minutes
2. Send the recording

**Expected Results**:
- ✓ Recording stops at 2-minute limit
- ✓ Upload completes successfully
- ✓ Playback works correctly

---

## Test Suite 6: Booking-Chat Lifecycle

### Test Case 6.1: Booking Creation and Notification
**Objective**: Verify booking creates notification for provider

**Steps**:
1. On Device A (customer), create a new booking with Device B provider
2. On Device B, check notifications

**Expected Results**:
- ✓ Notification appears on Device B
- ✓ Booking details are complete (service, date, time, customer info)
- ✓ Accept and Decline buttons are visible

### Test Case 6.2: Accept Booking and Activate Chat
**Objective**: Verify accepting booking activates conversation

**Steps**:
1. On Device B, tap "Accept" on booking notification
2. Navigate to Messages tab
3. On Device A, check Messages tab

**Expected Results**:
- ✓ Booking status changes to confirmed
- ✓ Conversation appears in Messages tab on both devices
- ✓ Chat is active and messages can be sent
- ✓ Customer receives acceptance notification

### Test Case 6.3: Complete Booking and Close Chat
**Objective**: Verify completing booking closes conversation

**Steps**:
1. Complete the booking (mark as completed)
2. Try to send a message in the chat

**Expected Results**:
- ✓ Chat status changes to closed
- ✓ Message input is disabled
- ✓ "Chat closed" message displays
- ✓ Reason shows as "completed"

### Test Case 6.4: Cancel Booking and Close Chat
**Objective**: Verify cancelling booking closes conversation

**Steps**:
1. Cancel an active booking
2. Try to send a message in the chat

**Expected Results**:
- ✓ Chat status changes to closed
- ✓ Message input is disabled
- ✓ "Chat closed" message displays
- ✓ Reason shows as "cancelled"

### Test Case 6.5: Reopen Chat for Repeat Booking
**Objective**: Verify repeat bookings reopen existing chat

**Steps**:
1. Create a new booking with same provider (after previous was completed)
2. Check Messages tab

**Expected Results**:
- ✓ Existing conversation is reopened
- ✓ Previous message history is preserved
- ✓ Chat status is active
- ✓ New messages can be sent

---

## Test Suite 7: Message Delivery and Read Status

### Test Case 7.1: Message Sent Status
**Objective**: Verify sent messages show single checkmark

**Steps**:
1. Send a text message
2. Observe message bubble

**Expected Results**:
- ✓ Single gray checkmark appears
- ✓ Checkmark appears immediately after sending

### Test Case 7.2: Message Delivered Status
**Objective**: Verify delivered messages show double checkmark

**Steps**:
1. Send a message to online user
2. Wait for delivery
3. Observe message bubble

**Expected Results**:
- ✓ Double gray checkmark appears
- ✓ Status updates in real-time

### Test Case 7.3: Message Read Status
**Objective**: Verify read messages show blue checkmarks

**Steps**:
1. Send a message
2. On receiver device, open the chat
3. On sender device, observe message bubble

**Expected Results**:
- ✓ Double blue checkmark appears
- ✓ Status updates when receiver opens chat
- ✓ Read timestamp is recorded

---

## Test Suite 8: Network Conditions

### Test Case 8.1: Slow Network
**Objective**: Verify app handles slow network gracefully

**Steps**:
1. Enable network throttling or use slow connection
2. Send text message
3. Send image
4. Initiate voice call

**Expected Results**:
- ✓ Loading indicators display appropriately
- ✓ Messages eventually send successfully
- ✓ Images upload with progress indicator
- ✓ Call quality degrades but doesn't crash
- ✓ No app freezes or crashes

### Test Case 8.2: Intermittent Connectivity
**Objective**: Verify app handles connection drops

**Steps**:
1. Send a message
2. Disable internet connection mid-send
3. Re-enable connection

**Expected Results**:
- ✓ Message queues for sending
- ✓ Error message displays
- ✓ Message sends when connection restored
- ✓ No duplicate messages

### Test Case 8.3: Offline Message Queuing
**Objective**: Verify messages queue when offline

**Steps**:
1. Disable internet connection
2. Send multiple messages
3. Re-enable connection

**Expected Results**:
- ✓ Messages show as pending
- ✓ Messages send in order when online
- ✓ Status updates correctly
- ✓ No messages are lost

### Test Case 8.4: Call During Poor Network
**Objective**: Verify call behavior with poor connection

**Steps**:
1. Initiate call with poor network
2. Observe call quality
3. Monitor connection status

**Expected Results**:
- ✓ Connection status indicator shows poor quality
- ✓ Audio may be choppy but call doesn't drop immediately
- ✓ Reconnection attempts are made
- ✓ User can manually end call

---

## Test Suite 9: Permission Scenarios

### Test Case 9.1: Camera Permission
**Objective**: Verify camera permission handling

**Steps**:
1. Deny camera permission
2. Try to capture photo
3. Grant permission from settings
4. Try again

**Expected Results**:
- ✓ Permission request dialog appears
- ✓ Error message on denial
- ✓ Instructions to enable in settings
- ✓ Camera works after granting permission

### Test Case 9.2: Microphone Permission (Voice Notes)
**Objective**: Verify microphone permission for voice notes

**Steps**:
1. Deny microphone permission
2. Try to record voice note
3. Grant permission
4. Try again

**Expected Results**:
- ✓ Permission request appears
- ✓ Error message on denial
- ✓ Recording works after granting

### Test Case 9.3: Microphone Permission (Voice Calls)
**Objective**: Verify microphone permission for calls

**Steps**:
1. Deny microphone permission
2. Try to initiate call
3. Grant permission
4. Try again

**Expected Results**:
- ✓ Permission request appears before call
- ✓ Call doesn't initiate without permission
- ✓ Call works after granting

### Test Case 9.4: Location Permission
**Objective**: Verify location permission handling

**Steps**:
1. Deny location permission
2. Try to share location
3. Grant permission
4. Try again

**Expected Results**:
- ✓ Permission request appears
- ✓ Error message on denial
- ✓ Location sharing works after granting

### Test Case 9.5: Storage Permission
**Objective**: Verify storage permission for gallery access

**Steps**:
1. Deny storage permission
2. Try to select image from gallery
3. Grant permission
4. Try again

**Expected Results**:
- ✓ Permission request appears
- ✓ Gallery doesn't open without permission
- ✓ Gallery access works after granting

---

## Test Suite 10: Edge Cases

### Test Case 10.1: Large File Upload
**Objective**: Verify handling of large files

**Steps**:
1. Try to send image larger than 10MB
2. Try to send very long voice note

**Expected Results**:
- ✓ Large images are compressed
- ✓ Files exceeding limits show error
- ✓ Clear error message displays
- ✓ No app crash

### Test Case 10.2: Very Long Messages
**Objective**: Verify long text message handling

**Steps**:
1. Type a very long message (1000+ characters)
2. Send the message

**Expected Results**:
- ✓ Message sends successfully
- ✓ Message displays correctly in bubble
- ✓ Scrolling works in message bubble
- ✓ No text truncation issues

### Test Case 10.3: Rapid Message Sending
**Objective**: Verify rapid consecutive messages

**Steps**:
1. Send 10 messages quickly in succession
2. Observe message delivery

**Expected Results**:
- ✓ All messages send successfully
- ✓ Messages appear in correct order
- ✓ No messages are lost
- ✓ No duplicate messages
- ✓ Status updates correctly for all

### Test Case 10.4: Simultaneous Calls
**Objective**: Verify handling of simultaneous call attempts

**Steps**:
1. Device A calls Device B
2. Before answering, Device B calls Device A

**Expected Results**:
- ✓ One call takes precedence
- ✓ Other call shows busy/unavailable
- ✓ No app crash
- ✓ Clear error message

### Test Case 10.5: Special Characters in Messages
**Objective**: Verify special character handling

**Steps**:
1. Send messages with emojis
2. Send messages with special characters (!@#$%^&*)
3. Send messages with multiple languages

**Expected Results**:
- ✓ All characters display correctly
- ✓ No encoding issues
- ✓ Messages send and receive properly

### Test Case 10.6: App Backgrounding During Operations
**Objective**: Verify app handles backgrounding

**Steps**:
1. Start uploading large image
2. Background the app
3. Return to app
4. During active call, background app
5. Return to app

**Expected Results**:
- ✓ Upload continues in background
- ✓ Upload completes successfully
- ✓ Call continues in background
- ✓ Call audio works when backgrounded
- ✓ App state is preserved

### Test Case 10.7: Low Storage Space
**Objective**: Verify handling of low storage

**Steps**:
1. Fill device storage to near capacity
2. Try to capture photo
3. Try to record voice note

**Expected Results**:
- ✓ Error message displays
- ✓ Clear indication of storage issue
- ✓ No app crash

### Test Case 10.8: Low Battery Mode
**Objective**: Verify app works in low battery mode

**Steps**:
1. Enable low battery/power saving mode
2. Test all features

**Expected Results**:
- ✓ All features continue to work
- ✓ Performance may be reduced but functional
- ✓ No unexpected crashes

---

## Test Suite 11: Cross-Platform Testing

### Test Case 11.1: Android to iOS Communication
**Objective**: Verify cross-platform messaging

**Steps**:
1. Use Android device as Device A
2. Use iOS device as Device B
3. Test all message types between devices

**Expected Results**:
- ✓ All message types work bidirectionally
- ✓ Media displays correctly on both platforms
- ✓ Voice calls work between platforms
- ✓ No platform-specific issues

### Test Case 11.2: Different Android Versions
**Objective**: Verify compatibility across Android versions

**Steps**:
1. Test on Android 10, 11, 12, 13+
2. Test all features on each version

**Expected Results**:
- ✓ All features work on all versions
- ✓ UI displays correctly
- ✓ Permissions work as expected

### Test Case 11.3: Different iOS Versions
**Objective**: Verify compatibility across iOS versions

**Steps**:
1. Test on iOS 13, 14, 15, 16+
2. Test all features on each version

**Expected Results**:
- ✓ All features work on all versions
- ✓ UI displays correctly
- ✓ Permissions work as expected

---

## Test Suite 12: UI/UX Validation

### Test Case 12.1: Loading States
**Objective**: Verify all loading indicators work

**Steps**:
1. Observe loading states for:
   - Message sending
   - Image uploading
   - Voice note uploading
   - Location retrieval
   - Call connecting

**Expected Results**:
- ✓ Loading indicators display appropriately
- ✓ Indicators disappear when operation completes
- ✓ User understands operation is in progress

### Test Case 12.2: Error Messages
**Objective**: Verify error messages are clear

**Steps**:
1. Trigger various errors intentionally
2. Read error messages

**Expected Results**:
- ✓ Error messages are user-friendly
- ✓ Messages explain what went wrong
- ✓ Messages suggest how to fix
- ✓ No technical jargon

### Test Case 12.3: Responsive Design
**Objective**: Verify UI adapts to different screen sizes

**Steps**:
1. Test on small phone (5" screen)
2. Test on large phone (6.5"+ screen)
3. Test on tablet

**Expected Results**:
- ✓ UI elements are properly sized
- ✓ Text is readable
- ✓ Buttons are tappable
- ✓ No UI overlap or cutoff

---

## Test Execution Checklist

### Pre-Testing
- [ ] Backend server is running
- [ ] Database is accessible
- [ ] Test accounts are created
- [ ] Devices are prepared
- [ ] Permissions are reset for fresh testing

### During Testing
- [ ] Document all issues found
- [ ] Take screenshots of errors
- [ ] Note device models and OS versions
- [ ] Record network conditions
- [ ] Log timestamps of issues

### Post-Testing
- [ ] Compile test results
- [ ] Categorize issues by severity
- [ ] Create bug reports for failures
- [ ] Verify all test cases executed
- [ ] Sign off on passed features

---

## Issue Reporting Template

When issues are found, document them using this template:

```
**Issue ID**: [Unique identifier]
**Test Case**: [Test case number and name]
**Severity**: [Critical/High/Medium/Low]
**Device**: [Device model and OS version]
**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**: [What should happen]
**Actual Result**: [What actually happened]
**Screenshots**: [Attach screenshots]
**Additional Notes**: [Any other relevant information]
```

---

## Sign-Off

### Tester Information
- **Tester Name**: _______________
- **Date**: _______________
- **Devices Used**: _______________

### Test Results Summary
- **Total Test Cases**: _______________
- **Passed**: _______________
- **Failed**: _______________
- **Blocked**: _______________

### Approval
- [ ] All critical features tested and working
- [ ] All high-priority issues documented
- [ ] System ready for deployment

**Signature**: _______________
**Date**: _______________

---

## Notes

- This guide should be executed by QA team or designated testers
- Each test case should be executed at least once
- Critical features should be tested multiple times
- Document any deviations from expected results
- Retest after bug fixes are applied
