import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

/// Error types for location service operations
enum LocationErrorType {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  locationUnavailable,
  geocodingFailed,
  mapsUnavailable,
  timeout,
}

/// Custom exception for location service errors
class LocationServiceException implements Exception {
  final String message;
  final LocationErrorType type;

  LocationServiceException(this.message, this.type);

  @override
  String toString() => message;
}

/// Service for handling location-related operations
/// 
/// Provides methods for:
/// - Getting current device location
/// - Converting coordinates to human-readable addresses
/// - Opening locations in maps applications
class LocationService {
  /// Get the current device location
  /// 
  /// Handles permission requests and returns the current position.
  /// Throws LocationServiceException if permissions are denied or location services are disabled.
  static Future<Position> getCurrentLocation() async {
    try {
      // First check using permission_handler for more reliable permission checking
      final locationPermission = await Permission.location.status;
      print('LocationService: Permission status: $locationPermission');
      
      if (!locationPermission.isGranted) {
        print('LocationService: Requesting permission...');
        final status = await Permission.location.request();
        print('LocationService: New permission status: $status');
        
        if (status.isDenied) {
          throw LocationServiceException(
            'Location permission denied. Please enable location access in Settings > Apps > AssureFix > Permissions.',
            LocationErrorType.permissionDenied,
          );
        }
        
        if (status.isPermanentlyDenied) {
          throw LocationServiceException(
            'Location permissions are permanently denied. Please go to Settings > Apps > AssureFix > Permissions and enable location access.',
            LocationErrorType.permissionDeniedForever,
          );
        }
      }
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('LocationService: Service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        throw LocationServiceException(
          'Location services are disabled. Please enable GPS/Location services in your device settings.',
          LocationErrorType.serviceDisabled,
        );
      }

      // Double-check location permission with Geolocator
      LocationPermission permission = await Geolocator.checkPermission();
      print('LocationService: Geolocator permission: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationServiceException(
            'Location permission denied. Please grant location access to share your location.',
            LocationErrorType.permissionDenied,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationServiceException(
          'Location permissions are permanently denied. Please enable location access in your device settings.',
          LocationErrorType.permissionDeniedForever,
        );
      }

      // Get current position with high accuracy and timeout
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } on LocationServiceException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
        throw LocationServiceException(
          'Location request timed out. Please try again.',
          LocationErrorType.timeout,
        );
      } else {
        throw LocationServiceException(
          'Failed to get current location. Please try again.',
          LocationErrorType.locationUnavailable,
        );
      }
    }
  }

  /// Convert geographic coordinates to a human-readable address
  /// 
  /// Uses reverse geocoding to get address information from latitude and longitude.
  /// Returns a formatted address string or coordinates if geocoding fails.
  /// Gracefully handles geocoding failures by returning coordinates.
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Build address string from available components
        List<String> addressParts = [];
        
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        if (addressParts.isNotEmpty) {
          return addressParts.join(', ');
        }
      }
      
      // Fallback to coordinates if no address found
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      // Gracefully handle geocoding failures by returning coordinates
      // This is not a critical error, so we don't throw an exception
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Open the specified location in the device's default maps application
  /// 
  /// Uses multiple URL schemes to ensure compatibility with different map applications.
  /// Throws LocationServiceException if no maps application can be opened.
  static Future<void> openInMaps(double latitude, double longitude) async {
    print('LocationService: Opening maps for coordinates: $latitude, $longitude');
    
    // Create a simple Google Maps web URL that always works
    final webUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    
    try {
      // First try the most compatible approach - web URL
      print('LocationService: Trying web URL: $webUrl');
      final uri = Uri.parse(webUrl);
      
      final canLaunch = await canLaunchUrl(uri);
      print('LocationService: Can launch web URL: $canLaunch');
      
      if (canLaunch) {
        final success = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('LocationService: Web URL launch success: $success');
        
        if (success) {
          print('LocationService: Successfully opened web maps');
          return;
        }
      }
      
      // If external launch failed, try in-app browser
      print('LocationService: Trying in-app browser');
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      print('LocationService: Opened in in-app browser');
      return;
      
    } catch (e) {
      print('LocationService: Web URL failed: $e');
    }
    
    // If web approach failed, try geo URI
    try {
      print('LocationService: Trying geo URI');
      final geoUri = Uri.parse('geo:$latitude,$longitude');
      
      final canLaunchGeo = await canLaunchUrl(geoUri);
      print('LocationService: Can launch geo URI: $canLaunchGeo');
      
      if (canLaunchGeo) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        print('LocationService: Successfully opened with geo URI');
        return;
      }
    } catch (e) {
      print('LocationService: Geo URI failed: $e');
    }
    
    // Final fallback - show coordinates in a snackbar
    throw LocationServiceException(
      'Location: $latitude, $longitude\nCopy these coordinates to your maps app.',
      LocationErrorType.mapsUnavailable,
    );
  }

  /// Check if location permissions are granted
  /// 
  /// Returns true if location permissions are granted, false otherwise.
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  /// 
  /// Returns true if permissions are granted after the request, false otherwise.
  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }
}
