import 'package:flutter/material.dart';

/// Reusable confirmation dialog for consistent confirmation prompts across the app
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;
  final Color? iconColor;
  final bool isDangerous;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onCancel,
    this.confirmColor,
    this.icon,
    this.iconColor,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmColor = confirmColor ?? 
        (isDangerous ? Colors.red.shade700 : const Color(0xFF1565C0));
    final effectiveIconColor = iconColor ?? 
        (isDangerous ? Colors.red.shade700 : const Color(0xFF1565C0));

    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: effectiveIconColor, size: 28),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onCancel != null) {
              onCancel!();
            }
          },
          child: Text(
            cancelText,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveConfirmColor,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Show confirmation dialog
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    IconData? icon,
    Color? iconColor,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
        iconColor: iconColor,
        isDangerous: isDangerous,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Confirmation dialog for booking cancellation
  static Future<bool?> cancelBooking(BuildContext context) {
    return show(
      context,
      title: 'Cancel Booking',
      message: 'Are you sure you want to cancel this booking? This action cannot be undone.',
      confirmText: 'Yes, Cancel',
      cancelText: 'No, Keep It',
      icon: Icons.cancel_outlined,
      isDangerous: true,
    );
  }

  /// Confirmation dialog for service deletion
  static Future<bool?> deleteService(BuildContext context) {
    return show(
      context,
      title: 'Delete Service',
      message: 'Are you sure you want to delete this service? All associated data will be removed permanently.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_outline,
      isDangerous: true,
    );
  }

  /// Confirmation dialog for blocking a user
  static Future<bool?> blockUser(BuildContext context, String userName) {
    return show(
      context,
      title: 'Block User',
      message: 'Are you sure you want to block $userName? You won\'t be able to message or interact with them.',
      confirmText: 'Block',
      cancelText: 'Cancel',
      icon: Icons.block,
      isDangerous: true,
    );
  }

  /// Confirmation dialog for unblocking a user
  static Future<bool?> unblockUser(BuildContext context, String userName) {
    return show(
      context,
      title: 'Unblock User',
      message: 'Are you sure you want to unblock $userName? They will be able to interact with you again.',
      confirmText: 'Unblock',
      cancelText: 'Cancel',
      icon: Icons.check_circle_outline,
      confirmColor: const Color(0xFF4CAF50),
    );
  }

  /// Confirmation dialog for admin ban action
  static Future<bool?> banUser(BuildContext context, String userName) {
    return show(
      context,
      title: 'Ban User',
      message: 'Are you sure you want to ban $userName? They will be unable to access the platform.',
      confirmText: 'Ban User',
      cancelText: 'Cancel',
      icon: Icons.gavel,
      isDangerous: true,
    );
  }

  /// Confirmation dialog for admin unban action
  static Future<bool?> unbanUser(BuildContext context, String userName) {
    return show(
      context,
      title: 'Unban User',
      message: 'Are you sure you want to unban $userName? They will regain access to the platform.',
      confirmText: 'Unban',
      cancelText: 'Cancel',
      icon: Icons.check_circle_outline,
      confirmColor: const Color(0xFF4CAF50),
    );
  }

  /// Confirmation dialog for logout
  static Future<bool?> logout(BuildContext context) {
    return show(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      icon: Icons.logout,
      confirmColor: Colors.orange.shade700,
    );
  }

  /// Confirmation dialog for marking booking as complete
  static Future<bool?> completeBooking(BuildContext context) {
    return show(
      context,
      title: 'Complete Booking',
      message: 'Mark this booking as completed? You\'ll be asked to rate the service.',
      confirmText: 'Complete',
      cancelText: 'Cancel',
      icon: Icons.check_circle_outline,
      confirmColor: const Color(0xFF4CAF50),
    );
  }

  /// Confirmation dialog for deleting account
  static Future<bool?> deleteAccount(BuildContext context) {
    return show(
      context,
      title: 'Delete Account',
      message: 'Are you sure you want to delete your account? All your data will be permanently removed. This action cannot be undone.',
      confirmText: 'Delete Account',
      cancelText: 'Cancel',
      icon: Icons.warning_amber_rounded,
      isDangerous: true,
    );
  }
}
