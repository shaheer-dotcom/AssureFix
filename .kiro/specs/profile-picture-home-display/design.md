# Design Document

## Overview

This design addresses the issue where profile pictures are not properly displayed on home screens for both customer and service provider panels. The customer home screen currently shows a hardcoded localhost URL that doesn't work properly, and the service provider home screen lacks profile picture display entirely. The solution will leverage the existing `AvatarWidget` component and ensure consistent implementation across both panels.

## Architecture

### Current State Analysis

**Customer Home Screen (`customer_home_screen.dart`):**
- Lines 169-189: Has profile picture logic but uses hardcoded `http://localhost:5000` URL
- Uses `CircleAvatar` with `NetworkImage` directly instead of the existing `AvatarWidget`
- Has error handling via `onBackgroundImageError` but only logs to console
- Shows fallback with user's initial when profile picture is null

**Service Provider Home Screen (`service_provider_home_screen.dart`):**
- Lines 135-149: Only displays welcome text, no profile picture at all
- Missing the entire profile picture section that exists in customer home screen

**Existing Components:**
- `AvatarWidget` (in `cached_image_widget.dart`): A robust, reusable component that:
  - Handles image caching via `CachedNetworkImage`
  - Properly constructs URLs using `ApiConfig.baseUrlWithoutApi`
  - Provides automatic fallback to initials
  - Generates color-coded backgrounds based on name
  - Handles null/empty image URLs gracefully

## Components and Interfaces

### Modified Components

#### 1. Customer Home Screen
**File:** `frontend/lib/screens/home/customer_home_screen.dart`

**Changes:**
- Replace the custom `CircleAvatar` + `NetworkImage` implementation (lines 169-189)
- Use the existing `AvatarWidget` component instead
- Remove hardcoded localhost URL
- Simplify error handling (delegated to `AvatarWidget`)

**Implementation:**
```dart
// Replace lines 169-189 with:
AvatarWidget(
  imageUrl: user?.profile?.profilePicture,
  name: profile?.name,
  size: 60,
  backgroundColor: Theme.of(context).primaryColor,
)
```

#### 2. Service Provider Home Screen
**File:** `frontend/lib/screens/home/service_provider_home_screen.dart`

**Changes:**
- Add profile picture display section before the welcome text (around line 135)
- Use the same `AvatarWidget` implementation as customer screen
- Maintain consistent layout with customer home screen

**Implementation:**
```dart
// Add after line 134 (inside Column, before welcome text):
Row(
  children: [
    AvatarWidget(
      imageUrl: user?.profile?.profilePicture,
      name: profile?.name,
      size: 60,
      backgroundColor: Theme.of(context).primaryColor,
    ),
    const SizedBox(width: 16),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile?.name ?? 'Service Provider',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  ],
),
const SizedBox(height: 24),
```

### Unchanged Components

#### AvatarWidget
**File:** `frontend/lib/widgets/cached_image_widget.dart`

**No changes needed** - This component already provides all required functionality:
- Proper URL construction using `ApiConfig.baseUrlWithoutApi`
- Image caching via `CachedNetworkImage`
- Automatic fallback to initials
- Error handling
- Circular shape with customizable size

## Data Models

### User Profile Data
The existing user profile model already contains the necessary data:

```dart
class User {
  Profile? profile;
  // ...
}

class Profile {
  String name;
  String? profilePicture;  // Relative path like '/uploads/profiles/image.jpg'
  // ...
}
```

**Image URL Construction:**
- Backend stores relative path: `/uploads/profiles/image.jpg`
- `AvatarWidget` → `CachedImageWidget` constructs full URL
- Uses `ApiConfig.baseUrlWithoutApi` (e.g., `http://192.168.100.7:5000`)
- Final URL: `http://192.168.100.7:5000/uploads/profiles/image.jpg`

## Error Handling

### Image Loading Failures

**Handled by `AvatarWidget` and `CachedImageWidget`:**

1. **Null/Empty URL**: Automatically shows fallback with initials
2. **Network Error**: `CachedNetworkImage` error widget shows fallback
3. **Invalid URL**: Error widget triggers, shows fallback
4. **404 Not Found**: Error widget triggers, shows fallback

**Fallback Behavior:**
- Displays circular container with user's initials
- Background color generated from name (consistent per user)
- White text with bold font
- Size matches the requested avatar size

### User Experience

**Loading State:**
- `CachedNetworkImage` shows loading placeholder during image fetch
- Smooth fade-in animation when image loads (300ms)

**Error State:**
- Silent failure - no error messages shown to user
- Seamless fallback to initials avatar
- No console logs in production (handled internally by `CachedNetworkImage`)

## Testing Strategy

### Manual Testing

1. **Profile Picture Display**
   - Test with user who has uploaded profile picture
   - Verify image loads correctly on both home screens
   - Check that image is circular with correct size (60px radius)

2. **Fallback Scenarios**
   - Test with user who has no profile picture
   - Verify initials display correctly
   - Check background color is consistent

3. **Error Scenarios**
   - Test with invalid image URL in database
   - Test with deleted image file
   - Verify graceful fallback to initials

4. **Network Scenarios**
   - Test with slow network connection
   - Verify loading placeholder appears
   - Test with no network connection
   - Verify fallback appears after timeout

5. **Cross-Panel Consistency**
   - Compare customer and service provider home screens
   - Verify identical styling and behavior
   - Check positioning and spacing match

### Visual Regression Testing

1. **Customer Home Screen**
   - Screenshot with profile picture
   - Screenshot with fallback initials
   - Compare with current implementation

2. **Service Provider Home Screen**
   - Screenshot with profile picture
   - Screenshot with fallback initials
   - Verify matches customer screen styling

### Edge Cases

1. **Long Names**: Test with very long user names (overflow handling)
2. **Special Characters**: Test names with emojis, unicode characters
3. **Empty Name**: Test with empty or null name field
4. **Multiple Spaces**: Test names with multiple spaces
5. **Single Character**: Test single-character names

## Implementation Notes

### Import Requirements

Both home screen files need to import the `AvatarWidget`:
```dart
import '../../widgets/cached_image_widget.dart';
```

### Styling Consistency

Both screens should use:
- Avatar size: 60 pixels
- Spacing after avatar: 16 pixels
- Welcome text font size: 14 pixels
- Name text font size: 24 pixels
- Name text weight: bold

### Performance Considerations

- `CachedNetworkImage` automatically caches images to disk
- Subsequent loads are instant (no network request)
- Cache is managed automatically by the package
- No additional performance optimization needed

### Accessibility

- Avatar has semantic meaning (user identification)
- Fallback initials are readable and high contrast
- No additional accessibility work required

## Migration Path

1. Update customer home screen to use `AvatarWidget`
2. Update service provider home screen to add profile picture section
3. Test both screens with various user profiles
4. Deploy and monitor for any issues

No database migrations or backend changes required.
