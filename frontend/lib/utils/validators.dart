/// Form validation utilities
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    
    // Check for at least one letter and one number
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces, dashes, and parentheses
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it contains only digits and optional + at start
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleanedValue)) {
      return 'Please enter a valid phone number (10-15 digits)';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    if (value.trim().length > 50) {
      return '$fieldName must not exceed 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {
    String fieldName = 'This field',
    double? min,
    double? max,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName must not exceed $max';
    }
    
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    
    if (price > 1000000) {
      return 'Price seems too high. Please verify.';
    }
    
    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.trim().length < 10) {
      return 'Please enter a complete address (at least 10 characters)';
    }
    
    if (value.trim().length > 200) {
      return 'Address is too long (maximum 200 characters)';
    }
    
    return null;
  }

  // Description validation
  static String? validateDescription(String? value, {
    int minLength = 10,
    int maxLength = 500,
  }) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    
    if (value.trim().length < minLength) {
      return 'Description must be at least $minLength characters';
    }
    
    if (value.trim().length > maxLength) {
      return 'Description must not exceed $maxLength characters';
    }
    
    return null;
  }

  // OTP validation
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'OTP must be 6 digits';
    }
    
    return null;
  }

  // CNIC validation (Pakistan)
  static String? validateCNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNIC is required';
    }
    
    // Remove dashes
    final cleanedValue = value.replaceAll('-', '');
    
    if (!RegExp(r'^[0-9]{13}$').hasMatch(cleanedValue)) {
      return 'CNIC must be 13 digits (e.g., 12345-1234567-1)';
    }
    
    return null;
  }

  // Rating validation
  static String? validateRating(int? value) {
    if (value == null || value == 0) {
      return 'Please select a rating';
    }
    
    if (value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }
    
    return null;
  }

  // Review text validation
  static String? validateReview(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'Review is required';
    }
    
    if (value != null && value.isNotEmpty) {
      if (value.trim().length < 5) {
        return 'Review must be at least 5 characters';
      }
      
      if (value.trim().length > 500) {
        return 'Review must not exceed 500 characters';
      }
    }
    
    return null;
  }

  // File size validation (in bytes)
  static String? validateFileSize(int? fileSize, {int maxSizeMB = 5}) {
    if (fileSize == null) {
      return 'File is required';
    }
    
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    if (fileSize > maxSizeBytes) {
      return 'File size must not exceed ${maxSizeMB}MB';
    }
    
    return null;
  }

  // File type validation
  static String? validateFileType(String? fileName, List<String> allowedExtensions) {
    if (fileName == null || fileName.isEmpty) {
      return 'File is required';
    }
    
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'Only ${allowedExtensions.join(', ')} files are allowed';
    }
    
    return null;
  }

  // Image file validation
  static String? validateImageFile(String? fileName, int? fileSize) {
    final typeError = validateFileType(fileName, ['jpg', 'jpeg', 'png', 'gif', 'webp']);
    if (typeError != null) return typeError;
    
    final sizeError = validateFileSize(fileSize, maxSizeMB: 5);
    if (sizeError != null) return sizeError;
    
    return null;
  }

  // Document file validation
  static String? validateDocumentFile(String? fileName, int? fileSize) {
    final typeError = validateFileType(fileName, ['pdf', 'jpg', 'jpeg', 'png']);
    if (typeError != null) return typeError;
    
    final sizeError = validateFileSize(fileSize, maxSizeMB: 10);
    if (sizeError != null) return sizeError;
    
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value, {
    DateTime? minDate,
    DateTime? maxDate,
    String fieldName = 'Date',
  }) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (minDate != null && value.isBefore(minDate)) {
      return '$fieldName cannot be before ${_formatDate(minDate)}';
    }
    
    if (maxDate != null && value.isAfter(maxDate)) {
      return '$fieldName cannot be after ${_formatDate(maxDate)}';
    }
    
    return null;
  }

  // Future date validation
  static String? validateFutureDate(DateTime? value, {String fieldName = 'Date'}) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(value.year, value.month, value.day);
    
    if (selectedDate.isBefore(today)) {
      return '$fieldName must be today or in the future';
    }
    
    return null;
  }

  // Helper method to format date
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Tag validation
  static String? validateTags(List<String>? tags, {
    int minTags = 1,
    int maxTags = 10,
    String fieldName = 'Tags',
  }) {
    if (tags == null || tags.isEmpty) {
      return 'At least $minTags ${fieldName.toLowerCase()} ${minTags == 1 ? 'is' : 'are'} required';
    }
    
    if (tags.length < minTags) {
      return 'At least $minTags ${fieldName.toLowerCase()} ${minTags == 1 ? 'is' : 'are'} required';
    }
    
    if (tags.length > maxTags) {
      return 'Maximum $maxTags ${fieldName.toLowerCase()} allowed';
    }
    
    return null;
  }

  // URL validation
  static String? validateURL(String? value, {bool required = false}) {
    if (!required && (value == null || value.isEmpty)) {
      return null;
    }
    
    if (required && (value == null || value.isEmpty)) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value!)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
}
