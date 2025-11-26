# Widget Library

This directory contains reusable widgets for the AssureFix application.

## Available Widgets

### 1. CachedImageWidget
Optimized image loading with caching and placeholders.

**Usage:**
```dart
// Profile picture
CachedImageWidget.profile(
  imageUrl: user.profilePicture,
  size: 80,
)

// Banner image
CachedImageWidget.banner(
  imageUrl: provider.bannerImage,
  height: 200,
)

// Service image
CachedImageWidget.service(
  imageUrl: service.imageUrl,
  width: 120,
  height: 120,
)

// Thumbnail
CachedImageWidget.thumbnail(
  imageUrl: image.url,
  size: 60,
)
```

### 2. AvatarWidget
Avatar with fallback to initials.

**Usage:**
```dart
AvatarWidget(
  imageUrl: user.profilePicture,
  name: user.name,
  size: 40,
)
```

### 3. EmptyStateWidget
Consistent empty states across the app.

**Usage:**
```dart
// No search results
EmptyStateWidget.noSearchResults(
  onRetry: () => searchAgain(),
)

// No bookings
EmptyStateWidget.noBookings(
  bookingType: 'Active',
  onAction: () => navigateToSearch(),
)

// No services
EmptyStateWidget.noServices(
  onAction: () => navigateToPostService(),
)

// No messages
EmptyStateWidget.noMessages()

// No notifications
EmptyStateWidget.noNotifications()

// No ratings
EmptyStateWidget.noRatings(isProvider: true)

// Custom empty state
EmptyStateWidget(
  icon: Icons.custom_icon,
  title: 'Custom Title',
  message: 'Custom message',
  actionLabel: 'Action',
  onAction: () => doSomething(),
)
```

### 4. LoadingWidget
Consistent loading indicators.

**Usage:**
```dart
// Full screen loading
LoadingWidget(message: 'Loading...')

// Button loading indicator
ButtonLoadingIndicator(color: Colors.white)

// Overlay loading (blocks UI)
OverlayLoadingIndicator.show(context, message: 'Processing...')
OverlayLoadingIndicator.hide(context)
```

### 5. ConfirmationDialog
Reusable confirmation dialogs.

**Usage:**
```dart
// Cancel booking
final confirmed = await ConfirmationDialog.cancelBooking(context);
if (confirmed == true) {
  // Cancel the booking
}

// Delete service
final confirmed = await ConfirmationDialog.deleteService(context);

// Block user
final confirmed = await ConfirmationDialog.blockUser(context, userName);

// Unblock user
final confirmed = await ConfirmationDialog.unblockUser(context, userName);

// Ban user (admin)
final confirmed = await ConfirmationDialog.banUser(context, userName);

// Unban user (admin)
final confirmed = await ConfirmationDialog.unbanUser(context, userName);

// Logout
final confirmed = await ConfirmationDialog.logout(context);

// Complete booking
final confirmed = await ConfirmationDialog.completeBooking(context);

// Custom confirmation
final confirmed = await ConfirmationDialog.show(
  context,
  title: 'Confirm Action',
  message: 'Are you sure?',
  confirmText: 'Yes',
  cancelText: 'No',
  icon: Icons.warning,
  isDangerous: true,
);
```

### 6. RatingWidget
Display ratings with stars.

**Usage:**
```dart
RatingWidget(
  rating: 4.5,
  ratingCount: 120,
)
```

### 7. ReportDialog
Report user dialog.

**Usage:**
```dart
showDialog(
  context: context,
  builder: (context) => ReportDialog(
    userId: reportedUserId,
    userName: reportedUserName,
  ),
)
```

### 8. ValidatedTextField
Text field with built-in validation.

**Usage:**
```dart
ValidatedTextField(
  controller: controller,
  label: 'Email',
  validator: Validators.validateEmail,
)
```

## Utility Classes

### ErrorHandler
Centralized error handling.

**Usage:**
```dart
// Show error snackbar
ErrorHandler.showErrorSnackBar(
  context,
  'Error message',
  onRetry: () => retryAction(),
)

// Show success snackbar
ErrorHandler.showSuccessSnackBar(context, 'Success!')

// Show error dialog
ErrorHandler.showErrorDialog(
  context,
  'Error Title',
  'Error message',
  onRetry: () => retryAction(),
)

// Build error widget
ErrorHandler.buildErrorWidget(
  message: 'Error occurred',
  onRetry: () => retryAction(),
)

// Build network error widget
ErrorHandler.buildNetworkErrorWidget(
  onRetry: () => retryAction(),
)

// Get error message from exception
final message = ErrorHandler.getErrorMessage(error);
```

### ImageHelper
Image picking and compression.

**Usage:**
```dart
// Pick image with source selection
final file = await ImageHelper.pickImage(context);

// Pick from gallery
final file = await ImageHelper.pickImageFromGallery();

// Pick from camera
final file = await ImageHelper.pickImageFromCamera();

// Compress image
final compressed = await ImageHelper.compressImage(file);

// Compress for upload (auto quality adjustment)
final compressed = await ImageHelper.compressForUpload(file, maxSizeMB: 2);

// Validate image
final error = ImageHelper.validateImageFile(file, maxSizeMB: 5);

// Get file size
final sizeMB = ImageHelper.getFileSizeInMB(file);

// Build image URL
final url = ImageHelper.getImageUrl(imagePath);
```

### Validators
Form validation functions.

**Usage:**
```dart
// Email
validator: Validators.validateEmail

// Password
validator: (value) => Validators.validatePassword(value, minLength: 6)

// Confirm password
validator: (value) => Validators.validateConfirmPassword(value, password)

// Phone number
validator: Validators.validatePhoneNumber

// Name
validator: (value) => Validators.validateName(value, fieldName: 'Full Name')

// Required field
validator: (value) => Validators.validateRequired(value, fieldName: 'Field')

// Number
validator: (value) => Validators.validateNumber(value, min: 0, max: 100)

// Price
validator: Validators.validatePrice

// Address
validator: Validators.validateAddress

// Description
validator: (value) => Validators.validateDescription(value, minLength: 10)

// OTP
validator: Validators.validateOTP

// CNIC
validator: Validators.validateCNIC

// Rating
validator: Validators.validateRating

// Review
validator: (value) => Validators.validateReview(value, required: false)

// File size
validator: (value) => Validators.validateFileSize(fileSize, maxSizeMB: 5)

// File type
validator: (value) => Validators.validateFileType(fileName, ['jpg', 'png'])

// Image file
validator: (value) => Validators.validateImageFile(fileName, fileSize)

// Document file
validator: (value) => Validators.validateDocumentFile(fileName, fileSize)

// Date
validator: (value) => Validators.validateDate(date, minDate: DateTime.now())

// Future date
validator: (value) => Validators.validateFutureDate(date)

// Tags
validator: (value) => Validators.validateTags(tags, minTags: 1, maxTags: 10)

// URL
validator: (value) => Validators.validateURL(value, required: false)
```

## Best Practices

1. **Always use cached images** for network images to improve performance
2. **Compress images before upload** using `ImageHelper.compressForUpload()`
3. **Use empty state widgets** instead of plain text for better UX
4. **Use confirmation dialogs** for destructive actions
5. **Use centralized validators** for consistent validation
6. **Show loading indicators** during async operations
7. **Handle errors gracefully** with retry options
8. **Use consistent error messages** via ErrorHandler

## Performance Tips

1. Images are automatically cached by `CachedImageWidget`
2. Use `memCacheWidth` and `memCacheHeight` for better memory management
3. Compress images before upload to reduce bandwidth
4. Use placeholders to improve perceived performance
5. Lazy load images in list views (handled automatically by ListView.builder)
