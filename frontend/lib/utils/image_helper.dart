import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart' as compress;
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';

/// Image helper utilities for loading, caching, and compressing images
class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Show image source selection dialog
  static Future<File?> pickImage(BuildContext context) async {
    return await showDialog<File?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImageFromGallery();
                if (context.mounted) {
                  Navigator.pop(context, file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImageFromCamera();
                if (context.mounted) {
                  Navigator.pop(context, file);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Compress image file
  static Future<File?> compressImage(File file, {int quality = 85}) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf('.');
      final outPath = '${filePath.substring(0, lastIndex)}_compressed${filePath.substring(lastIndex)}';
      
      final result = await compress.FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
      );
      
      if (result != null) {
        return File(result.path);
      }
      return file;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file;
    }
  }

  /// Compress image before upload with automatic quality adjustment
  static Future<File?> compressForUpload(File file, {double maxSizeMB = 2}) async {
    try {
      // Check current size
      double currentSizeMB = getFileSizeInMB(file);
      
      // If already small enough, return as is
      if (currentSizeMB <= maxSizeMB) {
        return file;
      }
      
      // Calculate quality based on size ratio
      int quality = 85;
      if (currentSizeMB > maxSizeMB * 2) {
        quality = 70;
      } else if (currentSizeMB > maxSizeMB * 1.5) {
        quality = 75;
      }
      
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf('.');
      final outPath = '${filePath.substring(0, lastIndex)}_upload${filePath.substring(lastIndex)}';
      
      final result = await compress.FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: quality,
        minWidth: 1920,
        minHeight: 1920,
      );
      
      if (result != null) {
        final compressedFile = File(result.path);
        final compressedSizeMB = getFileSizeInMB(compressedFile);
        
        // If still too large, compress more aggressively
        if (compressedSizeMB > maxSizeMB && quality > 60) {
          return await compressForUpload(compressedFile, maxSizeMB: maxSizeMB);
        }
        
        return compressedFile;
      }
      return file;
    } catch (e) {
      debugPrint('Error compressing image for upload: $e');
      return file;
    }
  }

  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Validate image file
  static String? validateImageFile(File? file, {double maxSizeMB = 5}) {
    if (file == null) {
      return 'Please select an image';
    }
    
    final sizeMB = getFileSizeInMB(file);
    if (sizeMB > maxSizeMB) {
      return 'Image size must not exceed ${maxSizeMB}MB';
    }
    
    final extension = file.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'Only JPG, PNG, GIF, and WebP images are allowed';
    }
    
    return null;
  }

  /// Build network image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Build full URL from API base URL
    final baseUrl = ApiConfig.apiUrl.replaceAll('/api', '');
    return '$baseUrl/$imagePath';
  }
}

/// Cached network image widget with placeholder and error handling
class CachedNetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final url = ImageHelper.getImageUrl(imageUrl);
    
    if (url.isEmpty) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        memCacheWidth: width != null ? (width! * 2).toInt() : null,
        memCacheHeight: height != null ? (height! * 2).toInt() : null,
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;
    
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;
    
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.broken_image,
        size: 48,
        color: Colors.grey.shade400,
      ),
    );
  }
}

/// Profile picture widget with circular shape
class ProfilePictureWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final IconData defaultIcon;

  const ProfilePictureWidget({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.defaultIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImageWidget(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(
          defaultIcon,
          size: size * 0.5,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

/// Banner image widget
class BannerImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final IconData defaultIcon;

  const BannerImageWidget({
    super.key,
    required this.imageUrl,
    this.height = 200,
    this.defaultIcon = Icons.image,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImageWidget(
      imageUrl: imageUrl,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorWidget: Container(
        width: double.infinity,
        height: height,
        color: Colors.grey.shade300,
        child: Icon(
          defaultIcon,
          size: 64,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

/// Service image widget with rounded corners
class ServiceImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const ServiceImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 120,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.home_repair_service,
          size: 48,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
