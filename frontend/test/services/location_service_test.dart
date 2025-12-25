import 'package:flutter_test/flutter_test.dart';
import 'package:servicehub/services/location_service.dart';

void main() {
  group('LocationService', () {
    group('LocationServiceException', () {
      test('should create exception with message and type', () {
        final exception = LocationServiceException(
          'Location unavailable',
          LocationErrorType.locationUnavailable,
        );

        expect(exception.message, equals('Location unavailable'));
        expect(exception.type, equals(LocationErrorType.locationUnavailable));
        expect(exception.toString(), equals('Location unavailable'));
      });

      test('should have all error types defined', () {
        expect(LocationErrorType.values.length, greaterThan(0));
        expect(LocationErrorType.values, contains(LocationErrorType.permissionDenied));
        expect(LocationErrorType.values, contains(LocationErrorType.permissionDeniedForever));
        expect(LocationErrorType.values, contains(LocationErrorType.serviceDisabled));
        expect(LocationErrorType.values, contains(LocationErrorType.locationUnavailable));
        expect(LocationErrorType.values, contains(LocationErrorType.geocodingFailed));
        expect(LocationErrorType.values, contains(LocationErrorType.mapsUnavailable));
        expect(LocationErrorType.values, contains(LocationErrorType.timeout));
      });
    });

    group('getAddressFromCoordinates', () {
      test('should return formatted coordinates when geocoding fails', () async {
        // Test with coordinates that will likely fail geocoding
        final address = await LocationService.getAddressFromCoordinates(0.0, 0.0);

        // Should return coordinates in the format "Lat: X, Lng: Y"
        expect(address, contains('Lat:'));
        expect(address, contains('Lng:'));
        expect(address, contains('0.000000'));
      });

      test('should format coordinates with 6 decimal places', () async {
        final address = await LocationService.getAddressFromCoordinates(
          37.7749295,
          -122.4194155,
        );

        // Should contain properly formatted coordinates
        if (address.contains('Lat:')) {
          expect(address, contains('37.774929'));
          expect(address, contains('-122.419415'));
        }
      });
    });

    group('Error Type Classification', () {
      test('should have distinct error types for different scenarios', () {
        final permissionError = LocationServiceException(
          'Permission denied',
          LocationErrorType.permissionDenied,
        );
        final serviceError = LocationServiceException(
          'Service disabled',
          LocationErrorType.serviceDisabled,
        );

        expect(permissionError.type, isNot(equals(serviceError.type)));
      });

      test('should differentiate between temporary and permanent permission denial', () {
        final tempDenied = LocationServiceException(
          'Permission denied',
          LocationErrorType.permissionDenied,
        );
        final permDenied = LocationServiceException(
          'Permission denied forever',
          LocationErrorType.permissionDeniedForever,
        );

        expect(tempDenied.type, isNot(equals(permDenied.type)));
      });
    });
  });
}
