# Utility Classes Documentation

This directory contains utility classes that provide common functionality across the application.

## Error Handling (`error_handler.dart`)

Comprehensive error handling utilities for consistent error management throughout the app.

### Features:
- **Custom Exception Classes**: NetworkException, ServerException, ValidationException, AuthException
- **Error Message Parsing**: Converts various exception types to user-friendly messages
- **Error Display Helpers**:
  - `showErrorSnackBar()` - Display error with optional retry button
  - `showSuccessSnackBar()` - Display success messages
  - `showErrorDialog()` - Show error in a dialog with retry option
  - `buildErrorWidget()` - Build error UI with retry button
  - `buildNetworkErrorWidget()` - Specialized network error UI

### Usage Example:
```dart
try {
  await ApiService.login(email, password);
} catch (e) {
  final message = ErrorHandler.getErrorMessage(e);
  ErrorHandler.showErrorSnackBar(context, message, onRetry: _retry);
}
```

## Form Validation (`validators.dart`)

Comprehensive form validation utilities for all input types.

### Available Validators:
- `validateEmail()` - Email format validation
- `validatePassword()` - Password strength validation (min length, letters, numbers)
- `validateConfirmPassword()` - Password confirmation matching
- `validatePhoneNumber()` - Phone number format (10-15 digits)
- `validateName()` - Name validation (2-50 characters, letters only)
- `validateRequired()` - Required field validation
- `validateNumber()` - Number validation with min/max
- `validatePrice()` - Price validation (> 0, < 1M)
- `validateAddress()` - Address validation (10-200 characters)
- `validateDescription()` - Description validation (customizable length)
- `validateOTP()` - 6-digit OTP validation
- `validateCNIC()` - Pakistan CNIC validation (13 digits)
- `validateRating()` - Rating validation (1-5 stars)
- `validateReview()` - Review text validation (5-500 characters)
- `validateFileSize()` - File size validation
- `validateFileType()` - File extension validation
- `validateImageFile()` - Combined image validation
- `validateDocumentFile()` - Combined document validation
- `validateDate()` - Date validation with min/max
- `validateFutureDate()` - Ensure date is today or future
- `validateTags()` - Tag array validation
- `validateURL()` - URL format validation

### Usage Example:
```dart
TextFormField(
  controller: emailController,
  validator: Validators.validateEmail,
)
```

## Image Handling (`image_helper.dart`)

Utilities for image picking, compression, and optimized display with caching.

### Features:
- **Image Picking**:
  - `pickImageFromGallery()` - Pick from gallery with auto-resize
  - `pickImageFromCamera()` - Take photo with auto-resize
  - `pickImage()` - Show source selection dialog
- **Image Compression**:
  - `compressImage()` - Compress image to reduce file size
  - `getFileSizeInMB()` - Get file size in megabytes
- **Image Validation**:
  - `validateImageFile()` - Validate size and format
- **URL Building**:
  - `getImageUrl()` - Build full URL from relative path

### Widgets:
- `CachedNetworkImageWidget` - Base cached image with placeholder/error
- `ProfilePictureWidget` - Circular profile picture
- `BannerImageWidget` - Full-width banner image
- `ServiceImageWidget` - Service thumbnail with rounded corners

### Usage Example:
```dart
// Pick and compress image
final file = await ImageHelper.pickImage(context);
if (file != null) {
  final compressed = await ImageHelper.compressImage(file);
  // Upload compressed file
}

// Display cached image
ProfilePictureWidget(
  imageUrl: user.profilePicture,
  size: 80,
)
```

## Network Checking (`network_checker.dart`)

Utilities for checking network connectivity before API calls.

### Features:
- `hasInternetConnection()` - Check if device has internet
- `ensureConnectivity()` - Throw exception if no connection

### Usage Example:
```dart
try {
  await NetworkChecker.ensureConnectivity();
  final data = await ApiService.getData();
} catch (e) {
  // Handle network error
}
```

## Loading Widgets (`loading_widget.dart`)

Reusable loading indicators for consistent loading states.

### Widgets:
- `LoadingWidget` - Center-aligned loading with optional message
- `ButtonLoadingIndicator` - Small inline loading for buttons
- `OverlayLoadingIndicator` - Full-screen overlay loading

### Usage Example:
```dart
// In widget tree
if (isLoading) LoadingWidget(message: 'Loading data...')

// In button
ElevatedButton(
  onPressed: isLoading ? null : _submit,
  child: isLoading 
    ? ButtonLoadingIndicator() 
    : Text('Submit'),
)

// Overlay
OverlayLoadingIndicator.show(context, message: 'Uploading...');
// Later...
OverlayLoadingIndicator.hide(context);
```

## Validated Text Fields (`validated_text_field.dart`)

Enhanced text field widgets with built-in validation and better UX.

### Widgets:
- `ValidatedTextField` - Base text field with inline validation
- `PhoneTextField` - Phone number field with formatting
- `EmailTextField` - Email field with validation
- `PasswordTextField` - Password field with show/hide toggle
- `PriceTextField` - Price field with currency symbol

### Features:
- Auto-validation on user interaction
- Consistent styling across the app
- Input formatters for specific types
- Better error display

### Usage Example:
```dart
EmailTextField(
  controller: emailController,
  validator: Validators.validateEmail,
  onChanged: (value) => setState(() {}),
)

PasswordTextField(
  controller: passwordController,
  label: 'New Password',
  validator: Validators.validatePassword,
)
```

## Best Practices

1. **Error Handling**: Always use `ErrorHandler.getErrorMessage()` to parse exceptions
2. **Validation**: Use validators from `Validators` class for consistency
3. **Images**: Always compress images before upload using `ImageHelper.compressImage()`
4. **Loading States**: Use appropriate loading widgets based on context
5. **Network**: Check connectivity for critical operations
6. **Caching**: Use `CachedNetworkImageWidget` for all network images

## Integration with API Service

The API service (`api_service.dart`) has been enhanced to:
- Automatically handle timeouts (30 seconds)
- Parse and throw appropriate custom exceptions
- Handle network errors gracefully
- Provide consistent error messages

All providers should use `ErrorHandler.getErrorMessage()` when catching exceptions from API calls.
