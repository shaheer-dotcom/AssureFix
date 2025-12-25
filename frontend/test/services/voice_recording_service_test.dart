import 'package:flutter_test/flutter_test.dart';
import 'package:servicehub/services/voice_recording_service.dart';

void main() {
  group('VoiceRecordingService', () {
    group('VoiceRecordingException', () {
      test('should create exception with message and type', () {
        final exception = VoiceRecordingException(
          'Recording failed',
          VoiceRecordingErrorType.recordingError,
        );

        expect(exception.message, equals('Recording failed'));
        expect(exception.type, equals(VoiceRecordingErrorType.recordingError));
        expect(exception.toString(), equals('Recording failed'));
      });

      test('should have all error types defined', () {
        expect(VoiceRecordingErrorType.values.length, greaterThan(0));
        expect(VoiceRecordingErrorType.values, contains(VoiceRecordingErrorType.permissionDenied));
        expect(VoiceRecordingErrorType.values, contains(VoiceRecordingErrorType.recordingError));
        expect(VoiceRecordingErrorType.values, contains(VoiceRecordingErrorType.uploadError));
        expect(VoiceRecordingErrorType.values, contains(VoiceRecordingErrorType.networkError));
        expect(VoiceRecordingErrorType.values, contains(VoiceRecordingErrorType.fileTooLarge));
        expect(VoiceRecordingErrorType.values, contains(VoiceRecordingErrorType.authError));
        expect(VoiceRecordingErrorType.values, contains(VoiceRecordingErrorType.microphoneUnavailable));
      });
    });

    group('Constants', () {
      test('should have maximum recording duration defined', () {
        expect(VoiceRecordingService.maxRecordingDuration, equals(120));
      });

      test('should have reasonable maximum duration (2 minutes)', () {
        expect(VoiceRecordingService.maxRecordingDuration, greaterThan(0));
        expect(VoiceRecordingService.maxRecordingDuration, lessThanOrEqualTo(300));
      });
    });

    group('getRecordingElapsedTime', () {
      test('should return 0 when not recording', () {
        final elapsed = VoiceRecordingService.getRecordingElapsedTime();
        expect(elapsed, equals(0));
      });
    });

    group('hasExceededMaxDuration', () {
      test('should return false when not recording', () {
        final exceeded = VoiceRecordingService.hasExceededMaxDuration();
        expect(exceeded, equals(false));
      });
    });

    group('Error Type Classification', () {
      test('should have distinct error types for different scenarios', () {
        final permissionError = VoiceRecordingException(
          'Permission denied',
          VoiceRecordingErrorType.permissionDenied,
        );
        final uploadError = VoiceRecordingException(
          'Upload failed',
          VoiceRecordingErrorType.uploadError,
        );

        expect(permissionError.type, isNot(equals(uploadError.type)));
      });
    });
  });
}
