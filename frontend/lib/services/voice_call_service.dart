import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/token_manager.dart';

class VoiceCallService {
  static const Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, String>> get _headers async {
    final headers = {
      'Content-Type': 'application/json',
    };
    // Get auth token from TokenManager
    final token = await TokenManager.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
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
      throw AuthException('Authentication failed. Please login again.');
    } else if (response.statusCode == 403) {
      throw AuthException('Access denied.');
    } else if (response.statusCode == 404) {
      throw ServerException('Resource not found', response.statusCode);
    } else if (response.statusCode >= 500) {
      throw ServerException('Server error. Please try again later.', response.statusCode);
    } else {
      try {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final message = errorBody['message'] ?? errorBody['error'] ?? 'Request failed';
        throw ServerException(message, response.statusCode);
      } catch (e) {
        if (e is ServerException) rethrow;
        throw ServerException('Request failed', response.statusCode);
      }
    }
  }

  /// Initiate a voice call
  /// Returns call data including callId, channelName, token, and uid
  static Future<Map<String, dynamic>> initiateCall({
    required String receiverId,
    required String conversationId,
  }) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/calls/initiate'),
        headers: headers,
        body: jsonEncode({
          'receiverId': receiverId,
          'conversationId': conversationId,
        }),
      ).timeout(_timeout);

      final data = _handleResponse(response);
      
      // Expected response structure:
      // {
      //   "callId": "...",
      //   "channelName": "...",
      //   "token": "...",
      //   "uid": 12345,
      //   "status": "initiated"
      // }
      
      return data as Map<String, dynamic>;
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Failed to initiate call: ${e.toString()}');
    }
  }

  /// Accept an incoming call
  static Future<Map<String, dynamic>> acceptCall({
    required String callId,
  }) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/calls/$callId/accept'),
        headers: headers,
      ).timeout(_timeout);

      final data = _handleResponse(response);
      
      // Expected response structure:
      // {
      //   "callId": "...",
      //   "channelName": "...",
      //   "token": "...",
      //   "uid": 12345,
      //   "status": "active"
      // }
      
      return data as Map<String, dynamic>;
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Failed to accept call: ${e.toString()}');
    }
  }

  /// Reject an incoming call
  static Future<Map<String, dynamic>> rejectCall({
    required String callId,
  }) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/calls/$callId/reject'),
        headers: headers,
      ).timeout(_timeout);

      final data = _handleResponse(response);
      return data as Map<String, dynamic>;
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Failed to reject call: ${e.toString()}');
    }
  }

  /// End an active call
  static Future<Map<String, dynamic>> endCall({
    required String callId,
    required int duration,
  }) async {
    try {
      final headers = await _headers;
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/calls/$callId/end'),
        headers: headers,
        body: jsonEncode({
          'duration': duration,
        }),
      ).timeout(_timeout);

      final data = _handleResponse(response);
      return data as Map<String, dynamic>;
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Failed to end call: ${e.toString()}');
    }
  }

  /// Get Agora token for joining a call
  /// This is used when receiving a call notification
  static Future<Map<String, dynamic>> getCallToken({
    required String channelName,
    required int uid,
  }) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/calls/token?channelName=$channelName&uid=$uid'),
        headers: headers,
      ).timeout(_timeout);

      final data = _handleResponse(response);
      
      // Expected response structure:
      // {
      //   "token": "...",
      //   "channelName": "...",
      //   "uid": 12345
      // }
      
      return data as Map<String, dynamic>;
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Failed to get call token: ${e.toString()}');
    }
  }
}
