import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static String? _authToken;

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

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> sendOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Failed to send OTP');
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(String email, String otp, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'OTP verification failed');
    }
  }

  static Future<Map<String, dynamic>> resendOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Failed to resend OTP');
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user data');
    }
  }

  static Future<Map<String, dynamic>> createProfile(Map<String, dynamic> profileData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/profile'),
      headers: _headers,
      body: jsonEncode(profileData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Profile creation failed');
    }
  }

  // File upload
  static Future<String> uploadFile(File file, String fieldName) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload'),
    );
    
    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }
    
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['filePath'];
    } else {
      throw Exception('File upload failed');
    }
  }

  // Booking endpoints
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _headers,
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Booking creation failed');
    }
  }

  static Future<List<dynamic>> getUserBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/my-bookings'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Failed to get bookings');
    }
  }

  // Service endpoints
  static Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: _headers,
        body: jsonEncode(serviceData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        throw Exception(errorBody['message'] ?? 'Service creation failed');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid data format. Please check your input.');
      }
      rethrow;
    }
  }

  static Future<List<dynamic>> getUserServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/services/my-services'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Failed to get services');
    }
  }

  static Future<List<dynamic>> searchServices({String? query, String? category, String? location}) async {
    final queryParams = <String, String>{};
    if (query != null) queryParams['search'] = query;
    if (category != null) queryParams['category'] = category;
    if (location != null) queryParams['location'] = location;

    final uri = Uri.parse('$baseUrl/services').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // The backend returns an object with 'services' array, not a direct array
      if (responseData is Map<String, dynamic> && responseData.containsKey('services')) {
        return responseData['services'] as List<dynamic>;
      }
      // Fallback for direct array response
      return responseData as List<dynamic>;
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Search failed');
    }
  }

  // Rating endpoints
  static Future<Map<String, dynamic>> createRating(Map<String, dynamic> ratingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ratings'),
      headers: _headers,
      body: jsonEncode(ratingData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Rating creation failed');
    }
  }

  static Future<Map<String, dynamic>> getUserRatings(String userId, {String? type}) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$baseUrl/ratings/user/$userId').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Failed to get ratings');
    }
  }

  static Future<List<dynamic>> getGivenRatings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ratings/given'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Failed to get given ratings');
    }
  }

  static Future<Map<String, dynamic>> updateRating(String ratingId, Map<String, dynamic> ratingData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/ratings/$ratingId'),
      headers: _headers,
      body: jsonEncode(ratingData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Rating update failed');
    }
  }

  static Future<void> deleteRating(String ratingId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ratings/$ratingId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Rating deletion failed');
    }
  }

  // Service management endpoints
  static Future<Map<String, dynamic>> toggleServiceStatus(String serviceId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/services/$serviceId/toggle-status'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Failed to toggle service status');
    }
  }

  static Future<void> deleteService(String serviceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/services/$serviceId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      throw Exception(errorBody['message'] ?? 'Service deletion failed');
    }
  }
}