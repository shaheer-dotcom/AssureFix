import 'package:flutter/material.dart';

/// Reusable empty state widget for consistent empty states across the app
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
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

  /// Empty state for no search results
  factory EmptyStateWidget.noSearchResults({
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'We couldn\'t find any services matching your search.\nTry different keywords or area tags.',
      actionLabel: onRetry != null ? 'Search Again' : null,
      onAction: onRetry,
      iconColor: Colors.blue.shade200,
    );
  }

  /// Empty state for no bookings
  factory EmptyStateWidget.noBookings({
    required String bookingType,
    VoidCallback? onAction,
  }) {
    String message;
    String? actionLabel;
    
    switch (bookingType.toLowerCase()) {
      case 'active':
        message = 'You don\'t have any active bookings at the moment.\nBook a service to get started!';
        actionLabel = 'Find Services';
        break;
      case 'completed':
        message = 'You haven\'t completed any bookings yet.\nYour completed bookings will appear here.';
        actionLabel = null;
        break;
      case 'cancelled':
        message = 'You don\'t have any cancelled bookings.\nThat\'s great!';
        actionLabel = null;
        break;
      default:
        message = 'You don\'t have any bookings yet.\nStart by booking a service!';
        actionLabel = 'Find Services';
    }

    return EmptyStateWidget(
      icon: Icons.event_busy,
      title: 'No $bookingType Bookings',
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      iconColor: Colors.orange.shade200,
    );
  }

  /// Empty state for no services
  factory EmptyStateWidget.noServices({
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      icon: Icons.work_off,
      title: 'No Services Posted',
      message: 'You haven\'t posted any services yet.\nCreate your first service to start receiving bookings!',
      actionLabel: 'Post a Service',
      onAction: onAction,
      iconColor: Colors.green.shade200,
    );
  }

  /// Empty state for no messages/conversations
  factory EmptyStateWidget.noMessages({
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      icon: Icons.chat_bubble_outline,
      title: 'No Conversations',
      message: 'You don\'t have any messages yet.\nStart a conversation by booking a service or messaging a provider.',
      actionLabel: onAction != null ? 'Find Services' : null,
      onAction: onAction,
      iconColor: Colors.purple.shade200,
    );
  }

  /// Empty state for no notifications
  factory EmptyStateWidget.noNotifications() {
    return EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      message: 'You\'re all caught up!\nWe\'ll notify you about bookings, messages, and updates.',
      iconColor: Colors.teal.shade200,
    );
  }

  /// Empty state for no ratings
  factory EmptyStateWidget.noRatings({
    required bool isProvider,
  }) {
    return EmptyStateWidget(
      icon: Icons.star_border,
      title: 'No Ratings Yet',
      message: isProvider
          ? 'You haven\'t received any ratings yet.\nComplete bookings to start receiving ratings from customers.'
          : 'You haven\'t given any ratings yet.\nRate service providers after completing bookings.',
      iconColor: Colors.amber.shade200,
    );
  }

  /// Empty state for blocked users
  factory EmptyStateWidget.noBlockedUsers() {
    return EmptyStateWidget(
      icon: Icons.block,
      title: 'No Blocked Users',
      message: 'You haven\'t blocked anyone.\nBlocked users will appear here.',
      iconColor: Colors.red.shade200,
    );
  }

  /// Empty state for reports
  factory EmptyStateWidget.noReports() {
    return EmptyStateWidget(
      icon: Icons.report_off,
      title: 'No Reports',
      message: 'You haven\'t reported any users.\nReported users will appear here for admin review.',
      iconColor: Colors.orange.shade200,
    );
  }
}
