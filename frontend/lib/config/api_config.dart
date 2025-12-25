class ApiConfig {
  // Your computer's local network IP address
  // Updated IP: 172.16.84.191 (Wi-Fi adapter)
  // IMPORTANT: Mobile devices must be on the same Wi-Fi network (172.16.84.x)
  static const String _localNetworkIp = '172.16.84.191';
  static const String _port = '5000';

  // Get base URL from environment or use default
  // In production, set this via build configuration or environment variables
  static String get baseUrl {
    // Check for environment variable (set via --dart-define or .env)
    const String envUrl =
        String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Use local network IP for mobile testing
    // Make sure:
    // 1. Your mobile is connected to the same Wi-Fi network (172.16.84.x)
    // 2. Backend server is running on this computer (172.16.84.191:5000)
    // 3. Windows Firewall allows connections on port 5000
    return 'http://$_localNetworkIp:$_port/api';
  }

  // Get full API URL
  static String get apiUrl => baseUrl;

  // Get base URL without /api suffix (for file uploads and direct endpoints)
  static String get baseUrlWithoutApi => 'http://$_localNetworkIp:$_port';

  // Check if running in production mode
  static bool get isProduction {
    const bool isProd = bool.fromEnvironment('dart.vm.product');
    return isProd;
  }
}
