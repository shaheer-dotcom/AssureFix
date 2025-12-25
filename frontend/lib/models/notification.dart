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
  final BookingNotificationData? bookingData;

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
    this.bookingData,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    BookingNotificationData? bookingData;
    
    // Parse booking data if this is a booking notification with populated relatedBooking
    if (json['type'] == 'booking' && json['relatedBooking'] is Map) {
      final bookingMap = json['relatedBooking'] as Map<String, dynamic>;
      bookingData = BookingNotificationData.fromJson(bookingMap);
    }
    
    // Parse booking data from bookingData field (for completion confirmations)
    if (json['bookingData'] is Map) {
      bookingData = BookingNotificationData.fromBookingDataJson(
        json['bookingData'] as Map<String, dynamic>
      );
    }
    
    return AppNotification(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'update',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      relatedBooking: json['relatedBooking'] is String 
          ? json['relatedBooking']?.toString()
          : (json['relatedBooking'] is Map 
              ? json['relatedBooking']['_id']?.toString()
              : null),
      relatedMessage: json['relatedMessage']?.toString(),
      isRead: json['isRead'] == true,
      actionUrl: json['actionUrl']?.toString(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String()
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String()
      ),
      bookingData: bookingData,
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
      if (bookingData != null) 'bookingData': bookingData!.toJson(),
    };
  }

  IconData get icon {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'booking_completion_confirmation':
        return Icons.check_circle_outline;
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
      case 'booking_completion_confirmation':
        return const Color(0xFFFF9800);
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


class BookingNotificationData {
  final String bookingId;
  final String serviceName;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final DateTime reservationDate;
  final int hoursBooked;
  final double totalAmount;
  final String status;
  final String bookingType;

  BookingNotificationData({
    required this.bookingId,
    required this.serviceName,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.reservationDate,
    required this.hoursBooked,
    required this.totalAmount,
    required this.status,
    this.bookingType = 'reservation',
  });

  factory BookingNotificationData.fromJson(Map<String, dynamic> json) {
    // Extract service name
    String serviceName = 'Unknown Service';
    if (json['serviceId'] is Map) {
      serviceName = json['serviceId']['serviceName']?.toString() ?? 'Unknown Service';
    }

    // Extract customer name
    String customerName = 'Unknown Customer';
    if (json['customerId'] is Map) {
      final profile = json['customerId']['profile'];
      if (profile is Map) {
        customerName = profile['name']?.toString() ?? 'Unknown Customer';
      }
    }

    // Extract customer details
    final customerDetails = json['customerDetails'] as Map<String, dynamic>? ?? {};
    
    return BookingNotificationData(
      bookingId: json['_id']?.toString() ?? '',
      serviceName: serviceName,
      customerName: customerName,
      customerPhone: customerDetails['phoneNumber']?.toString() ?? '',
      customerAddress: customerDetails['exactAddress']?.toString() ?? '',
      reservationDate: DateTime.parse(
        json['reservationDate'] ?? DateTime.now().toIso8601String()
      ),
      hoursBooked: (json['hoursBooked'] ?? 1) is int 
          ? json['hoursBooked'] 
          : int.tryParse(json['hoursBooked'].toString()) ?? 1,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      bookingType: json['bookingType']?.toString() ?? 'reservation',
    );
  }

  // Factory for bookingData field in notification
  factory BookingNotificationData.fromBookingDataJson(Map<String, dynamic> json) {
    return BookingNotificationData(
      bookingId: json['bookingId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? 'Unknown Service',
      customerName: json['customerName']?.toString() ?? 'Unknown Customer',
      customerPhone: json['customerPhone']?.toString() ?? '',
      customerAddress: json['customerAddress']?.toString() ?? '',
      reservationDate: DateTime.parse(
        json['reservationDate'] ?? DateTime.now().toIso8601String()
      ),
      hoursBooked: (json['hoursBooked'] ?? 1) is int 
          ? json['hoursBooked'] 
          : int.tryParse(json['hoursBooked'].toString()) ?? 1,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      bookingType: json['bookingType']?.toString() ?? 'reservation',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'serviceName': serviceName,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'reservationDate': reservationDate.toIso8601String(),
      'hoursBooked': hoursBooked,
      'totalAmount': totalAmount,
      'status': status,
      'bookingType': bookingType,
    };
  }
}
