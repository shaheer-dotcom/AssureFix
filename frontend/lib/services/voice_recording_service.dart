import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';

/// Error types for voice recording operations
enum VoiceRecordingErrorType {
  permissionDenied,
  recordingError,
  uploadError,
  networkError,
  fileTooLarge,
  authError,
  microphoneUnavailable,
}

/// Custom exception for voice recording errors
class VoiceRecordingException implements Exception {
  final String message;
  final VoiceRecordingErrorType type;

  VoiceRecordingException(this.message, this.type);

  @override
  String toString() => message;
}

/// Service for handling voice note recording, playback, and upload
class VoiceRecordingService {
  static final AudioRecorder _audioRecorder = AudioRecorder();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static String? _currentRecordingPath;
  static DateTime? _recordingStartTime;
  
  // Maximum recording duration in seconds (2 minutes)
  static const int maxRecordingDuration = 120;

  /// Start recording audio
  /// 
  /// Requests microphone permission if not already granted
  /// Returns true if recording started successfully
  /// Throws VoiceRecordingException on error
  static Future<bool> startRecording() async {
    try {
      print('VoiceRecordingService: Checking microphone permission...');
      
      // First check using permission_handler for more reliable permission checking
      final micPermission = await Permission.microphone.status;
      print('VoiceRecordingService: Permission status: $micPermission');
      
      if (!micPermission.isGranted) {
        print('VoiceRecordingService: Requesting permission...');
        final status = await Permission.microphone.request();
        print('VoiceRecordingService: New permission status: $status');
        
        if (status.isDenied) {
          throw VoiceRecordingException(
            'Microphone permission denied. Please enable microphone access in Settings > Apps > AssureFix > Permissions.',
            VoiceRecordingErrorType.permissionDenied,
          );
        }
        
        if (status.isPermanentlyDenied) {
          throw VoiceRecordingException(
            'Microphone permission permanently denied. Please go to Settings > Apps > AssureFix > Permissions and enable microphone access.',
            VoiceRecordingErrorType.permissionDenied,
          );
        }
      }
      
      // Double-check with AudioRecorder
      bool hasPermission = await _audioRecorder.hasPermission();
      print('VoiceRecordingService: AudioRecorder has permission: $hasPermission');
      
      if (!hasPermission) {
        throw VoiceRecordingException(
          'Microphone access not available. Please check your device settings.',
          VoiceRecordingErrorType.permissionDenied,
        );
      }

      // Generate unique file path
      print('VoiceRecordingService: Getting temporary directory...');
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      print('VoiceRecordingService: Recording to: $filePath');
      
      // Start recording with optimized configuration for voice
      print('VoiceRecordingService: Starting recording...');
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000, // Reduced from 128000 for smaller files
          sampleRate: 44100,
          numChannels: 1, // Mono for voice notes
        ),
        path: filePath,
      );
      
      _currentRecordingPath = filePath;
      _recordingStartTime = DateTime.now();
      print('VoiceRecordingService: Recording started successfully');
      
      return true;
    } on VoiceRecordingException {
      rethrow;
    } catch (e) {
      print('VoiceRecordingService: Error starting recording: $e');
      
      if (e.toString().contains('permission') || e.toString().contains('denied')) {
        throw VoiceRecordingException(
          'Microphone permission denied. Please enable microphone access in Settings > Apps > AssureFix > Permissions.',
          VoiceRecordingErrorType.permissionDenied,
        );
      } else if (e.toString().contains('microphone') || e.toString().contains('unavailable')) {
        throw VoiceRecordingException(
          'Microphone is not available on this device.',
          VoiceRecordingErrorType.microphoneUnavailable,
        );
      } else {
        throw VoiceRecordingException(
          'Failed to start recording: ${e.toString()}',
          VoiceRecordingErrorType.recordingError,
        );
      }
    }
  }
  
  /// Check if recording has exceeded maximum duration
  static bool hasExceededMaxDuration() {
    if (_recordingStartTime == null) return false;
    final elapsed = DateTime.now().difference(_recordingStartTime!).inSeconds;
    return elapsed >= maxRecordingDuration;
  }

  /// Stop recording and return the file path
  /// 
  /// Returns the path to the recorded audio file, or null if recording failed
  /// Throws VoiceRecordingException on error
  static Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _recordingStartTime = null;
      
      if (path != null && path.isNotEmpty) {
        _currentRecordingPath = path;
        return path;
      }
      
      return null;
    } catch (e) {
      _recordingStartTime = null;
      throw VoiceRecordingException(
        'Failed to stop recording. Please try again.',
        VoiceRecordingErrorType.recordingError,
      );
    }
  }

  /// Cancel recording without saving
  /// 
  /// Stops the recording and deletes the temporary file
  /// Throws VoiceRecordingException on error
  static Future<void> cancelRecording() async {
    try {
      await _audioRecorder.stop();
      
      // Delete the temporary file if it exists
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
        _currentRecordingPath = null;
      }
      
      _recordingStartTime = null;
    } catch (e) {
      _recordingStartTime = null;
      throw VoiceRecordingException(
        'Failed to cancel recording. Please try again.',
        VoiceRecordingErrorType.recordingError,
      );
    }
  }

  /// Get the duration of an audio file in seconds
  /// 
  /// Returns the duration in seconds, or 0 if unable to determine
  static Future<int> getAudioDuration(String filePath) async {
    try {
      await _audioPlayer.setSourceDeviceFile(filePath);
      final duration = await _audioPlayer.getDuration();
      return duration?.inSeconds ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get the elapsed recording time in seconds
  /// 
  /// Returns the number of seconds since recording started, or 0 if not recording
  static int getRecordingElapsedTime() {
    if (_recordingStartTime == null) {
      return 0;
    }
    return DateTime.now().difference(_recordingStartTime!).inSeconds;
  }

  /// Upload voice note to the backend
  /// 
  /// Returns the server path to the uploaded voice note
  /// Throws VoiceRecordingException on error
  static Future<String> uploadVoiceNote(String filePath, String conversationId) async {
    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw VoiceRecordingException(
          'Authentication required. Please login again.',
          VoiceRecordingErrorType.authError,
        );
      }
      
      // Convert file path to XFile for upload
      final xFile = XFile(filePath);
      
      // Get audio duration before upload
      final duration = await getAudioDuration(filePath);
      
      // Create multipart request - use correct endpoint
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrlWithoutApi}/api/chat/$conversationId/messages'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['messageType'] = 'voice';
      request.fields['duration'] = duration.toString();
      
      // Add file with correct field name
      if (kIsWeb) {
        final bytes = await xFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'voice',
          bytes,
          filename: xFile.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('voice', xFile.path));
      }
      
      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw VoiceRecordingException(
            'Upload timed out. Please check your connection and try again.',
            VoiceRecordingErrorType.networkError,
          );
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend returns the message object - the message is created automatically
        // We just need to return success indicator - the message will be loaded via polling
        // Return the message ID so we can identify it
        return responseData['_id']?.toString() ?? 'success';
      } else {
        throw VoiceRecordingException(
          responseData['message'] ?? 'Failed to upload voice note. Please try again.',
          VoiceRecordingErrorType.uploadError,
        );
      }
    } catch (e) {
      if (e.toString().contains('network') || 
          e.toString().contains('connection') || 
          e.toString().contains('timeout') ||
          e.toString().contains('SocketException')) {
        throw VoiceRecordingException(
          'Network error. Please check your internet connection and try again.',
          VoiceRecordingErrorType.networkError,
        );
      } else if (e.toString().contains('413') || e.toString().contains('too large')) {
        throw VoiceRecordingException(
          'Voice note file is too large. Please record a shorter message.',
          VoiceRecordingErrorType.fileTooLarge,
        );
      } else if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        throw VoiceRecordingException(
          'Authentication failed. Please login again.',
          VoiceRecordingErrorType.authError,
        );
      } else {
        throw VoiceRecordingException(
          'Failed to upload voice note. Please try again.',
          VoiceRecordingErrorType.uploadError,
        );
      }
    }
  }

  /// Check if microphone permission is granted
  static Future<bool> hasPermission() async {
    try {
      return await _audioRecorder.hasPermission();
    } catch (e) {
      return false;
    }
  }

  /// Dispose of resources
  static Future<void> dispose() async {
    try {
      await _audioRecorder.dispose();
      await _audioPlayer.dispose();
    } catch (e) {
      // Ignore disposal errors
    }
  }
}
