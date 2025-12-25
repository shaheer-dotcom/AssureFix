import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';

/// Reusable cached image widget with placeholders and error handling
class CachedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isProfilePicture;
  final bool isBanner;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.isProfilePicture = false,
    this.isBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null or empty image URL
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // Build full image URL
    final fullImageUrl = imageUrl!.startsWith('http')
        ? imageUrl!
        : '${ApiConfig.baseUrlWithoutApi}$imageUrl';

    Widget imageWidget = CachedNetworkImage(
      imageUrl: fullImageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorPlaceholder(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    if (isProfilePicture) {
      return _buildProfilePlaceholder();
    } else if (isBanner) {
      return _buildBannerPlaceholder();
    } else {
      return _buildDefaultPlaceholder();
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    if (isProfilePicture) {
      return _buildProfilePlaceholder();
    } else if (isBanner) {
      return _buildBannerPlaceholder();
    } else {
      return _buildDefaultPlaceholder();
    }
  }

  Widget _buildProfilePlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: borderRadius ?? BorderRadius.circular(50),
      ),
      child: Icon(
        Icons.person,
        size: (width ?? 80) * 0.5,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildBannerPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade200,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image,
        size: 48,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image,
        size: 48,
        color: Colors.grey.shade400,
      ),
    );
  }

  /// Factory constructor for profile pictures
  factory CachedImageWidget.profile({
    required String? imageUrl,
    double size = 80,
    BoxFit fit = BoxFit.cover,
  }) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: fit,
      borderRadius: BorderRadius.circular(size / 2),
      isProfilePicture: true,
    );
  }

  /// Factory constructor for banner images
  factory CachedImageWidget.banner({
    required String? imageUrl,
    double? width,
    double height = 200,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      isBanner: true,
    );
  }

  /// Factory constructor for service images
  factory CachedImageWidget.service({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );
  }

  /// Factory constructor for thumbnail images
  factory CachedImageWidget.thumbnail({
    required String? imageUrl,
    double size = 60,
    BoxFit fit = BoxFit.cover,
  }) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: fit,
      borderRadius: BorderRadius.circular(8),
    );
  }
}

/// Avatar widget with cached image and fallback
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedImageWidget.profile(
        imageUrl: imageUrl,
        size: size,
      );
    }

    // Fallback to initials
    final initials = _getInitials(name);
    final bgColor = backgroundColor ?? _generateColor(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  Color _generateColor(String? name) {
    if (name == null || name.isEmpty) return Colors.grey;
    
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index].shade600;
  }
}
