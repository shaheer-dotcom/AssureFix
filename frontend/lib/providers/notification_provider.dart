import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.getNotifications();
      _notifications = response.map((json) => AppNotification.fromJson(json)).toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification.fromJson({
          ..._notifications[index].toJson(),
          'isRead': true,
        });
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsAsRead();
      _notifications = _notifications.map((n) => AppNotification.fromJson({
        ...n.toJson(),
        'isRead': true,
      })).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await ApiService.getUnreadNotificationCount();
      _unreadCount = count;
      notifyListeners();
    } catch (e) {
      // Silently fail for unread count
    }
  }
}
