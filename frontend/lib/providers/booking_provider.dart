import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.createBooking(bookingData);
      final booking = Booking.fromJson(response);
      _bookings.add(booking);
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> loadUserBookings() async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.getUserBookings();
      _bookings = response.map((json) => Booking.fromJson(json)).toList();
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }
}