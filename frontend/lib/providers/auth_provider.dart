import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/error_handler.dart';

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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    setLoading(true);
    try {
      print('AuthProvider: Checking auth status');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('AuthProvider: Token found: ${token != null && token.isNotEmpty}');
      
      if (token != null && token.isNotEmpty) {
        ApiService.setAuthToken(token);
        print('AuthProvider: Fetching current user');
        final userData = await ApiService.getCurrentUser();
        _user = User.fromJson(userData);
        print('AuthProvider: User authenticated successfully');
      } else {
        print('AuthProvider: No token found');
      }
    } catch (e) {
      print('AuthProvider: Auth check failed: $e');
      // Token might be invalid, clear it
      await logout();
    }
    setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('AuthProvider: Starting login for $email');
      final response = await ApiService.login(email, password);
      print('AuthProvider: Login response received');
      
      final token = response['token'];
      final userData = response['user'];
      
      if (token == null || token.isEmpty) {
        throw Exception('No token received from server');
      }
      
      print('AuthProvider: Token received, saving to SharedPreferences');
      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
      // Verify token was saved
      final savedToken = prefs.getString('auth_token');
      print('AuthProvider: Token saved successfully: ${savedToken != null && savedToken.isNotEmpty}');
      
      ApiService.setAuthToken(token);
      _user = User.fromJson(userData);
      print('AuthProvider: User object created, login successful');
      
      _isLoading = false;
      notifyListeners();
      print('AuthProvider: notifyListeners called, UI should update');
      return true;
    } catch (e) {
      print('AuthProvider: Login error: $e');
      _error = ErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
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
      setError(ErrorHandler.getErrorMessage(e));
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
      setError(ErrorHandler.getErrorMessage(e));
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
      setError(ErrorHandler.getErrorMessage(e));
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
      setError(ErrorHandler.getErrorMessage(e));
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
      setError(ErrorHandler.getErrorMessage(e));
      setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.updateProfile(profileData);
      _user = User.fromJson(response);
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError(ErrorHandler.getErrorMessage(e));
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