import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String userId;
  final String type; // 'booking', 'message', 'admin', 'update'
  final String title;
  final String message;
  final String? relatedBooking;
  final String? relatedMessage;
  final bool isRead;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedBooking,
    this.relatedMessage,
    required this.isRead,
    this.actionUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'update',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      relatedBooking: json['relatedBooking']?.toString(),
      relatedMessage: json['relatedMessage']?.toString(),
      isRead: json['isRead'] == true,
      actionUrl: json['actionUrl']?.toString(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String()
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String()
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'relatedBooking': relatedBooking,
      'relatedMessage': relatedMessage,
      'isRead': isRead,
      'actionUrl': actionUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  IconData get icon {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'message':
        return Icons.message;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'update':
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case 'booking':
        return const Color(0xFF1565C0);
      case 'message':
        return const Color(0xFF4CAF50);
      case 'admin':
        return const Color(0xFFFF6B6B);
      case 'update':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }
}
