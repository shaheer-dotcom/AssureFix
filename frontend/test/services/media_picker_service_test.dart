import 'package:flutter_test/flutter_test.dart';
import 'package:servicehub/services/media_picker_service.dart';

void main() {
  group('MediaPickerService', () {
    group('MediaPickerException', () {
      test('should create exception with message and type', () {
        final exception = MediaPickerException(
          'Test error',
          MediaPickerErrorType.permissionDenied,
        );

        expect(exception.message, equals('Test error'));
        expect(exception.type, equals(MediaPickerErrorType.permissionDenied));
        expect(exception.toString(), equals('Test error'));
      });

      test('should have all error types defined', () {
        expect(MediaPickerErrorType.values.length, greaterThan(0));
        expect(MediaPickerErrorType.values, contains(MediaPickerErrorType.permissionDenied));
        expect(MediaPickerErrorType.values, contains(MediaPickerErrorType.pickError));
        expect(MediaPickerErrorType.values, contains(MediaPickerErrorType.uploadError));
        expect(MediaPickerErrorType.values, contains(MediaPickerErrorType.networkError));
        expect(MediaPickerErrorType.values, contains(MediaPickerErrorType.fileTooLarge));
        expect(MediaPickerErrorType.values, contains(MediaPickerErrorType.authError));
        expect(MediaPickerErrorType.values, contains(MediaPickerErrorType.cameraUnavailable));
      });
    });

    group('Error Type Classification', () {
      test('should have distinct error types for different scenarios', () {
        final permissionError = MediaPickerException(
          'Permission denied',
          MediaPickerErrorType.permissionDenied,
        );
        final networkError = MediaPickerException(
          'Network error',
          MediaPickerErrorType.networkError,
        );

        expect(permissionError.type, isNot(equals(networkError.type)));
      });
    });
  });
}
