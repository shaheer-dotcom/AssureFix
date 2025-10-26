import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get hasProfile => _user?.profile != null;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        ApiService.setAuthToken(token);
        final userData = await ApiService.getCurrentUser();
        _user = User.fromJson(userData);
      }
    } catch (e) {
      // Token might be invalid, clear it
      await logout();
    }
    setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.login(email, password);
      final token = response['token'];
      final userData = response['user'];
      
      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
      ApiService.setAuthToken(token);
      _user = User.fromJson(userData);
      
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    setLoading(true);
    setError(null);
    
    try {
      await ApiService.sendOTP(email);
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> sendOTP(String email) async {
    setLoading(true);
    setError(null);
    
    try {
      await ApiService.sendOTP(email);
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOTP(String email, String otp, String password) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.verifyOTP(email, otp, password);
      final token = response['token'];
      final userData = response['user'];
      
      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
      ApiService.setAuthToken(token);
      _user = User.fromJson(userData);
      
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> resendOTP(String email) async {
    setLoading(true);
    setError(null);
    
    try {
      await ApiService.resendOTP(email);
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> createProfile(Map<String, dynamic> profileData) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.createProfile(profileData);
      _user = User.fromJson(response);
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    ApiService.clearAuthToken();
    _user = null;
    notifyListeners();
  }
}