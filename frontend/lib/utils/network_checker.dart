import 'dart:io';
import 'dart:async';

/// Utility class to check network connectivity
class NetworkChecker {
  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check connectivity before making API call
  static Future<void> ensureConnectivity() async {
    final hasConnection = await hasInternetConnection();
    if (!hasConnection) {
      throw const SocketException('No internet connection');
    }
  }
}
