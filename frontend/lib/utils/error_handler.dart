import 'dart:io';
import 'package:flutter/material.dart';

/// Custom exception classes for better error handling
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection. Please check your network settings.']);
  
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed. Please login again.']);
  
  @override
  String toString() => message;
}

/// Error handler utility class
class ErrorHandler {
  /// Parse and format error messages from exceptions
  static String getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    } else if (error is ServerException) {
      return error.message;
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is AuthException) {
      return error.message;
    } else if (error is SocketException) {
      return 'Cannot connect to server. Make sure:\n1. Backend is running\n2. Phone and PC are on same WiFi\n3. IP address is correct (192.168.100.7)';
    } else if (error is HttpException) {
      return 'Server error. Please try again later.';
    } else if (error is FormatException) {
      return 'Invalid data format received from server.';
    } else if (error is Exception) {
      final errorString = error.toString();
      
      // Check for connection-related errors
      if (errorString.contains('Failed to fetch') || 
          errorString.contains('Connection refused') ||
          errorString.contains('Failed host lookup') ||
          errorString.contains('Network is unreachable') ||
          errorString.contains('Connection timed out')) {
        return 'Cannot connect to server. Make sure:\n1. Backend is running\n2. Phone and PC are on same WiFi\n3. IP address is correct (192.168.100.7)';
      }
      
      // Remove "Exception: " prefix if present
      if (errorString.startsWith('Exception: ')) {
        return errorString.substring(11);
      }
      return errorString;
    } else {
      final errorString = error.toString();
      
      // Check for connection-related errors in any error type
      if (errorString.contains('Failed to fetch') || 
          errorString.contains('Connection refused') ||
          errorString.contains('Failed host lookup') ||
          errorString.contains('Network is unreachable') ||
          errorString.contains('Connection timed out')) {
        return 'Cannot connect to server. Make sure:\n1. Backend is running\n2. Phone and PC are on same WiFi\n3. IP address is correct (192.168.100.7)';
      }
      
      return errorString;
    }
  }

  /// Show error snackbar with retry option
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: duration,
      ),
    );
  }

  /// Show error dialog with retry option
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Build error widget with retry button
  static Widget buildErrorWidget({
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build network error widget
  static Widget buildNetworkErrorWidget({VoidCallback? onRetry}) {
    return buildErrorWidget(
      message: 'No internet connection. Please check your network settings and try again.',
      onRetry: onRetry,
      icon: Icons.wifi_off,
    );
  }
}
