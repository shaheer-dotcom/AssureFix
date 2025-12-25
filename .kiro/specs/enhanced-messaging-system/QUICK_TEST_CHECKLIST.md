# Enhanced Messaging System - Quick Test Checklist

## Pre-Test Setup ✓

- [ ] Backend server running and accessible
- [ ] MongoDB database connected
- [ ] Agora credentials configured
- [ ] Two test devices ready (or 1 device + emulator)
- [ ] Test accounts created (1 customer, 1 service provider)
- [ ] App installed on both devices
- [ ] All permissions granted initially
- [ ] Test media files prepared (images, locations)

---

## Core Features Quick Test

### 1. Profile Pictures (3 tests)
- [ ] Profile picture displays in chat header
- [ ] Tap profile picture navigates to profile view
- [ ] Profile pictures show in conversations list

### 2. Voice Calls (5 tests)
- [ ] Initiate call from chat screen
- [ ] Accept incoming call
- [ ] Reject incoming call
- [ ] End active call
- [ ] Mute/unmute and speaker toggle work

### 3. Image Sending (4 tests)
- [ ] Send image from gallery
- [ ] Capture and send photo from camera
- [ ] View image in full-screen with zoom
- [ ] Large images compress and upload

### 4. Location Sharing (3 tests)
- [ ] Share current location
- [ ] Open location in maps app
- [ ] Handle location permission denial

### 5. Voice Notes (4 tests)
- [ ] Record and send voice note
- [ ] Cancel recording
- [ ] Play voice note
- [ ] Long voice note (2 min limit)

### 6. Booking-Chat Lifecycle (5 tests)
- [ ] Booking creates notification for provider
- [ ] Accept booking activates chat
- [ ] Complete booking closes chat
- [ ] Cancel booking closes chat
- [ ] Repeat booking reopens existing chat

### 7. Message Status (3 tests)
- [ ] Sent message shows single checkmark
- [ ] Delivered message shows double checkmark
- [ ] Read message shows blue checkmarks

---

## Network & Permissions Quick Test

### Network Conditions (4 tests)
- [ ] Slow network - features still work
- [ ] Intermittent connectivity - messages queue
- [ ] Offline mode - messages queue and send later
- [ ] Poor network during call - graceful degradation

### Permissions (5 tests)
- [ ] Camera permission request and handling
- [ ] Microphone permission for voice notes
- [ ] Microphone permission for calls
- [ ] Location permission request and handling
- [ ] Storage permission for gallery access

---

## Edge Cases Quick Test

### Critical Edge Cases (8 tests)
- [ ] Large file upload (>10MB)
- [ ] Very long text message (1000+ chars)
- [ ] Rapid message sending (10 messages quickly)
- [ ] Simultaneous call attempts
- [ ] Special characters and emojis
- [ ] App backgrounding during upload/call
- [ ] Low storage space handling
- [ ] Low battery mode functionality

---

## Cross-Platform Quick Test

### Platform Compatibility (3 tests)
- [ ] Android to iOS messaging works
- [ ] Test on multiple Android versions
- [ ] Test on multiple iOS versions

---

## UI/UX Quick Test

### User Experience (3 tests)
- [ ] Loading indicators display correctly
- [ ] Error messages are clear and helpful
- [ ] UI adapts to different screen sizes

---

## Critical Path Test (Must Pass)

This is the absolute minimum test path that must work:

1. [ ] **Setup**: Login on both devices
2. [ ] **Booking**: Customer creates booking → Provider receives notification
3. [ ] **Accept**: Provider accepts → Chat activates
4. [ ] **Text**: Send text message both ways
5. [ ] **Image**: Send image from gallery
6. [ ] **Voice**: Record and send voice note
7. [ ] **Location**: Share location
8. [ ] **Call**: Initiate and complete voice call
9. [ ] **Status**: Verify message read status updates
10. [ ] **Complete**: Complete booking → Chat closes
11. [ ] **Repeat**: Create new booking → Chat reopens with history

---

## Smoke Test (5 Minutes)

Quick validation that basic functionality works:

1. [ ] Login works
2. [ ] Can view conversations list
3. [ ] Can open a chat
4. [ ] Can send text message
5. [ ] Can send image
6. [ ] Can initiate voice call
7. [ ] Profile pictures display
8. [ ] No crashes or major errors

---

## Regression Test Checklist

After bug fixes, verify:

- [ ] Fixed issue is resolved
- [ ] Related functionality still works
- [ ] No new issues introduced
- [ ] Performance not degraded

---

## Device-Specific Checklist

### Android Testing
- [ ] Test on Android 10
- [ ] Test on Android 11
- [ ] Test on Android 12
- [ ] Test on Android 13+
- [ ] Test on different manufacturers (Samsung, Google, etc.)

### iOS Testing
- [ ] Test on iOS 13
- [ ] Test on iOS 14
- [ ] Test on iOS 15
- [ ] Test on iOS 16+
- [ ] Test on different devices (iPhone, iPad)

---

## Performance Checklist

- [ ] Chat screen loads within 2 seconds
- [ ] Images compress before upload
- [ ] Message pagination works (50 per batch)
- [ ] Profile pictures are cached
- [ ] Thumbnails load before full images
- [ ] Voice notes limited to 2 minutes
- [ ] Lazy loading for message media

---

## Security Checklist

- [ ] JWT tokens validated on all requests
- [ ] Users can only access their own conversations
- [ ] File types validated on upload
- [ ] File sizes limited (10MB max)
- [ ] Call tokens are time-limited
- [ ] Blocked users cannot communicate

---

## Accessibility Checklist

- [ ] Screen reader support
- [ ] Sufficient color contrast
- [ ] Touch targets are adequate size
- [ ] Text is scalable
- [ ] Alternative text for images

---

## Final Validation

Before sign-off, confirm:

- [ ] All critical features tested and working
- [ ] All high-priority bugs fixed
- [ ] Documentation updated
- [ ] Known issues documented
- [ ] Stakeholder approval obtained

---

## Quick Issue Log

| # | Feature | Issue | Severity | Status |
|---|---------|-------|----------|--------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |

---

## Notes Section

**Date**: _______________  
**Tester**: _______________  
**Build Version**: _______________  
**Test Duration**: _______________

**General Notes**:
_______________________________________________
_______________________________________________
_______________________________________________

**Blockers**:
_______________________________________________
_______________________________________________

**Recommendations**:
_______________________________________________
_______________________________________________
