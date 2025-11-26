import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class ApiService {
  static String get baseUrl => ApiConfig.apiUrl;
  static String? _authToken;
  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  /// Handle HTTP response and throw appropriate exceptions
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw const FormatException('Invalid response format from server');
      }
    } else if (response.statusCode == 401) {
      // Try to get specific error message from response
      try {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final message = errorBody['message'] ?? errorBody['error'] ?? 'Invalid email or password';
        throw AuthException(message);
      } catch (e) {
        if (e is AuthException) rethrow;
        throw AuthException('Invalid email or password');
      }
    } else if (response.statusCode == 403) {
      throw AuthException('Access denied. You do not have permission to perform this action.');
    } else if (response.statusCode == 404) {
      throw ServerException('Resource not found', response.statusCode);
    } else if (response.statusCode >= 500) {
      throw ServerException('Server error. Please try again later.', response.statusCode);
    } else {
      try {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final message = errorBody['message'] ?? errorBody['error'] ?? 'Request failed with status ${response.statusCode}';
        throw ServerException(message, response.statusCode);
      } catch (e) {
        if (e is ServerException) rethrow;
        throw ServerException('Request failed with status ${response.statusCode}', response.statusCode);
      }
    }
  }

  /// Wrap API calls with error handling and timeout
  static Future<T> _executeRequest<T>(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      return _handleResponse(response) as T;
    } on TimeoutException {
      throw NetworkException('Request timed out. Please check your connection and try again.');
    } on FormatException catch (e) {
      throw ValidationException(e.message);
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      // Check for network-related errors
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('socket') ||
          errorString.contains('connection refused') || 
          errorString.contains('failed host lookup') ||
          errorString.contains('network')) {
        throw NetworkException();
      }
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ));
  }

  static Future<Map<String, dynamic>> sendOTP(String email) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
      }),
    ));
  }

  static Future<Map<String, dynamic>> verifyOTP(String email, String otp, String password) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'password': password,
      }),
    ));
  }

  static Future<Map<String, dynamic>> resendOTP(String email) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/auth/resend-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
      }),
    ));
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await _executeRequest(() => http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    ));
  }

  static Future<Map<String, dynamic>> createProfile(Map<String, dynamic> profileData) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/users/profile'),
      headers: _headers,
      body: jsonEncode(profileData),
    ));
  }

  // File upload (accepts both File and XFile)
  static Future<String> uploadFile(dynamic file, String fieldName) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );
      
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      
      // Handle web vs mobile/desktop differently
      if (kIsWeb) {
        // On web, read bytes from XFile
        final xFile = file as XFile;
        final bytes = await xFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: xFile.name,
        ));
      } else {
        // On mobile/desktop, use fromPath
        final xFile = file as XFile;
        request.files.add(await http.MultipartFile.fromPath(fieldName, xFile.path));
      }
      
      final response = await request.send().timeout(_timeout);
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['filePath'];
      } else {
        final errorData = responseBody.isNotEmpty ? jsonDecode(responseBody) : {};
        throw ServerException(errorData['message'] ?? 'File upload failed', response.statusCode);
      }
    } on TimeoutException {
      throw NetworkException('Upload timed out. Please check your connection and try again.');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      // Check for network-related errors
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('socket') ||
          errorString.contains('connection') ||
          errorString.contains('network')) {
        throw NetworkException();
      }
      throw ServerException('File upload failed: ${e.toString()}');
    }
  }

  // Upload profile picture (accepts both File and XFile)
  static Future<String> uploadProfilePicture(dynamic file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/profile-picture'),
      );
      
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      
      // Handle web vs mobile/desktop differently
      if (kIsWeb) {
        final xFile = file as XFile;
        final bytes = await xFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'profilePicture',
          bytes,
          filename: xFile.name,
        ));
      } else {
        final xFile = file as XFile;
        request.files.add(await http.MultipartFile.fromPath('profilePicture', xFile.path));
      }
      
      final response = await request.send().timeout(_timeout);
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['filePath'];
      } else {
        final errorData = responseBody.isNotEmpty ? jsonDecode(responseBody) : {};
        throw ServerException(errorData['message'] ?? 'Profile picture upload failed', response.statusCode);
      }
    } on TimeoutException {
      throw NetworkException('Upload timed out. Please check your connection and try again.');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('socket') ||
          errorString.contains('connection') ||
          errorString.contains('network')) {
        throw NetworkException();
      }
      throw ServerException('Profile picture upload failed: ${e.toString()}');
    }
  }

  // Upload banner image (accepts both File and XFile)
  static Future<String> uploadBanner(dynamic file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/banner'),
      );
      
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      
      // Handle web vs mobile/desktop differently
      if (kIsWeb) {
        final xFile = file as XFile;
        final bytes = await xFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'banner',
          bytes,
          filename: xFile.name,
        ));
      } else {
        final xFile = file as XFile;
        request.files.add(await http.MultipartFile.fromPath('banner', xFile.path));
      }
      
      final response = await request.send().timeout(_timeout);
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['filePath'];
      } else {
        final errorData = responseBody.isNotEmpty ? jsonDecode(responseBody) : {};
        throw ServerException(errorData['message'] ?? 'Banner upload failed', response.statusCode);
      }
    } on TimeoutException {
      throw NetworkException('Upload timed out. Please check your connection and try again.');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('socket') ||
          errorString.contains('connection') ||
          errorString.contains('network')) {
        throw NetworkException();
      }
      throw ServerException('Banner upload failed: ${e.toString()}');
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    return await _executeRequest(() => http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: _headers,
      body: jsonEncode(profileData),
    ));
  }

  // Booking endpoints
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _headers,
      body: jsonEncode(bookingData),
    ));
  }

  static Future<List<dynamic>> getUserBookings() async {
    return await _executeRequest(() => http.get(
      Uri.parse('$baseUrl/bookings/my-bookings'),
      headers: _headers,
    ));
  }

  static Future<Map<String, dynamic>> updateBookingStatus(String bookingId, String status, {String? cancellationReason}) async {
    final body = <String, dynamic>{'status': status};
    if (cancellationReason != null) {
      body['cancellationReason'] = cancellationReason;
    }
    
    return await _executeRequest(() => http.patch(
      Uri.parse('$baseUrl/bookings/$bookingId/status'),
      headers: _headers,
      body: jsonEncode(body),
    ));
  }

  // Service endpoints
  static Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/services'),
      headers: _headers,
      body: jsonEncode(serviceData),
    ));
  }

  static Future<List<dynamic>> getUserServices() async {
    return await _executeRequest(() => http.get(
      Uri.parse('$baseUrl/services/my-services'),
      headers: _headers,
    ));
  }

  static Future<List<dynamic>> searchServices({String? query, String? category, String? location}) async {
    final queryParams = <String, String>{};
    if (query != null) queryParams['search'] = query;
    if (category != null) queryParams['category'] = category;
    if (location != null) queryParams['location'] = location;

    final uri = Uri.parse('$baseUrl/services').replace(queryParameters: queryParams);
    final responseData = await _executeRequest<dynamic>(() => http.get(uri, headers: _headers));
    
    // The backend returns an object with 'services' array, not a direct array
    if (responseData is Map<String, dynamic> && responseData.containsKey('services')) {
      return responseData['services'] as List<dynamic>;
    }
    // Fallback for direct array response
    return responseData as List<dynamic>;
  }

  // Rating endpoints
  static Future<Map<String, dynamic>> createRating(Map<String, dynamic> ratingData) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/ratings'),
      headers: _headers,
      body: jsonEncode(ratingData),
    ));
  }

  static Future<Map<String, dynamic>> getUserRatings(String userId, {String? type}) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$baseUrl/ratings/user/$userId').replace(queryParameters: queryParams);
    return await _executeRequest(() => http.get(uri, headers: _headers));
  }

  static Future<List<dynamic>> getGivenRatings() async {
    return await _executeRequest(() => http.get(
      Uri.parse('$baseUrl/ratings/given'),
      headers: _headers,
    ));
  }

  static Future<Map<String, dynamic>> updateRating(String ratingId, Map<String, dynamic> ratingData) async {
    return await _executeRequest(() => http.put(
      Uri.parse('$baseUrl/ratings/$ratingId'),
      headers: _headers,
      body: jsonEncode(ratingData),
    ));
  }

  static Future<void> deleteRating(String ratingId) async {
    await _executeRequest(() => http.delete(
      Uri.parse('$baseUrl/ratings/$ratingId'),
      headers: _headers,
    ));
  }

  // Service management endpoints
  static Future<Map<String, dynamic>> toggleServiceStatus(String serviceId) async {
    return await _executeRequest(() => http.patch(
      Uri.parse('$baseUrl/services/$serviceId/toggle-status'),
      headers: _headers,
    ));
  }

  static Future<void> deleteService(String serviceId) async {
    await _executeRequest(() => http.delete(
      Uri.parse('$baseUrl/services/$serviceId'),
      headers: _headers,
    ));
  }

  static Future<Map<String, dynamic>> getServiceById(String serviceId) async {
    return await _executeRequest(() => http.get(
      Uri.parse('$baseUrl/services/$serviceId'),
      headers: _headers,
    ));
  }

  static Future<Map<String, dynamic>> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    return await _executeRequest(() => http.put(
      Uri.parse('$baseUrl/services/$serviceId'),
      headers: _headers,
      body: jsonEncode(serviceData),
    ));
  }

  // Notification endpoints
  static Future<List<dynamic>> getNotifications() async {
    final responseData = await _executeRequest<dynamic>(() => http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: _headers,
    ));
    
    // The backend returns an object with 'notifications' array, not a direct array
    if (responseData is Map<String, dynamic> && responseData.containsKey('notifications')) {
      return responseData['notifications'] as List<dynamic>;
    }
    // Fallback for direct array response
    return responseData as List<dynamic>;
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await _executeRequest(() => http.patch(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: _headers,
    ));
  }

  static Future<void> markAllNotificationsAsRead() async {
    await _executeRequest(() => http.patch(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: _headers,
    ));
  }

  static Future<int> getUnreadNotificationCount() async {
    try {
      final data = await _executeRequest<Map<String, dynamic>>(() => http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: _headers,
      ));
      return data['unreadCount'] ?? 0;
    } catch (e) {
      // Return 0 on error to avoid breaking the UI
      return 0;
    }
  }

  // Settings endpoints
  static Future<Map<String, dynamic>> requestPasswordChange(String newPassword) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/settings/change-password-request'),
      headers: _headers,
      body: jsonEncode({
        'newPassword': newPassword,
      }),
    ));
  }

  static Future<Map<String, dynamic>> verifyPasswordChange(String otp) async {
    return await _executeRequest(() => http.post(
      Uri.parse('$baseUrl/settings/change-password-verify'),
      headers: _headers,
      body: jsonEncode({
        'otp': otp,
      }),
    ));
  }

  static Future<Map<String, dynamic>> getFAQs({String? role}) async {
    final queryParams = <String, String>{};
    if (role != null) queryParams['role'] = role;

    final uri = Uri.parse('$baseUrl/settings/faqs').replace(queryParameters: queryParams);
    return await _executeRequest(() => http.get(uri, headers: _headers));
  }
}