import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

/// Error types for media picker operations
enum MediaPickerErrorType {
  permissionDenied,
  pickError,
  uploadError,
  networkError,
  fileTooLarge,
  authError,
  cameraUnavailable,
}

/// Custom exception for media picker errors
class MediaPickerException implements Exception {
  final String message;
  final MediaPickerErrorType type;

  MediaPickerException(this.message, this.type);

  @override
  String toString() => message;
}

/// Service for handling media selection, compression, and upload
class MediaPickerService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from the device gallery
  /// 
  /// Returns the uploaded image path on success, null if cancelled
  /// Throws MediaPickerException with specific error types
  static Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) {
        return null; // User cancelled
      }

      // Compress the image
      final compressedImage = await compressImage(image);

      // Upload the compressed image
      final imagePath = await uploadImage(compressedImage);

      return imagePath;
    } on MediaPickerException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('permission') || e.toString().contains('denied')) {
        throw MediaPickerException(
          'Gallery access denied. Please enable gallery permissions in your device settings.',
          MediaPickerErrorType.permissionDenied,
        );
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw MediaPickerException(
          'Network error. Please check your internet connection and try again.',
          MediaPickerErrorType.networkError,
        );
      } else {
        throw MediaPickerException(
          'Failed to pick image from gallery. Please try again.',
          MediaPickerErrorType.pickError,
        );
      }
    }
  }

  /// Capture an image using the device camera
  /// 
  /// Returns the uploaded image path on success, null if cancelled
  /// Throws MediaPickerException with specific error types
  static Future<String?> captureImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) {
        return null; // User cancelled
      }

      // Compress the image
      final compressedImage = await compressImage(image);

      // Upload the compressed image
      final imagePath = await uploadImage(compressedImage);

      return imagePath;
    } on MediaPickerException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('permission') || e.toString().contains('denied')) {
        throw MediaPickerException(
          'Camera access denied. Please enable camera permissions in your device settings.',
          MediaPickerErrorType.permissionDenied,
        );
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw MediaPickerException(
          'Network error. Please check your internet connection and try again.',
          MediaPickerErrorType.networkError,
        );
      } else if (e.toString().contains('camera') || e.toString().contains('unavailable')) {
        throw MediaPickerException(
          'Camera is not available on this device.',
          MediaPickerErrorType.cameraUnavailable,
        );
      } else {
        throw MediaPickerException(
          'Failed to capture image from camera. Please try again.',
          MediaPickerErrorType.pickError,
        );
      }
    }
  }

  /// Compress an image file to reduce size while maintaining quality
  /// 
  /// Returns the compressed image as XFile
  static Future<XFile> compressImage(XFile image) async {
    try {
      // On web, compression is handled differently
      if (kIsWeb) {
        // For web, return the original image as compression is limited
        return image;
      }

      // Get temporary directory for storing compressed image
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Compress the image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 85,
        minWidth: 1200,
        minHeight: 1200,
      );

      if (compressedFile == null) {
        // If compression fails, return original
        return image;
      }

      return XFile(compressedFile.path);
    } catch (e) {
      // If compression fails, return original image
      return image;
    }
  }

  /// Upload an image to the server
  /// 
  /// Returns the server path of the uploaded image
  /// Throws MediaPickerException on error
  static Future<String> uploadImage(XFile image) async {
    try {
      // Use the existing API service to upload the image
      final imagePath = await ApiService.uploadProfilePicture(image);
      return imagePath;
    } catch (e) {
      if (e.toString().contains('network') || 
          e.toString().contains('connection') || 
          e.toString().contains('timeout') ||
          e.toString().contains('SocketException')) {
        throw MediaPickerException(
          'Network error. Please check your internet connection and try again.',
          MediaPickerErrorType.networkError,
        );
      } else if (e.toString().contains('413') || e.toString().contains('too large')) {
        throw MediaPickerException(
          'Image file is too large. Please choose a smaller image.',
          MediaPickerErrorType.fileTooLarge,
        );
      } else if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        throw MediaPickerException(
          'Authentication failed. Please login again.',
          MediaPickerErrorType.authError,
        );
      } else {
        throw MediaPickerException(
          'Failed to upload image. Please try again.',
          MediaPickerErrorType.uploadError,
        );
      }
    }
  }

  /// Clean up temporary files (optional utility method)
  static Future<void> cleanupTempFiles() async {
    try {
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        final files = tempDir.listSync();
        
        for (var file in files) {
          if (file.path.contains('compressed_')) {
            try {
              await file.delete();
            } catch (e) {
              // Ignore individual file deletion errors
            }
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}
