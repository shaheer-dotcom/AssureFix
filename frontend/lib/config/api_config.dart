import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Configuration: Set these values based on your environment
  // Option 1: Use environment variable (recommended for production)
  //   Run with: flutter run --dart-define=API_BASE_URL=https://your-app.onrender.com/api
  //   Build with: flutter build apk --dart-define=API_BASE_URL=https://your-app.onrender.com/api
  // Option 2: Set production URL below (for easy switching)
  // Option 3: Configure in app settings (Settings > API Configuration)
  // Option 4: Modify the values below directly
  
  // ============================================
  // PRODUCTION CONFIGURATION
  // ============================================
  // Set your production API URL here (e.g., from Render, Railway, Fly.io)
  // Leave empty to use environment variable or defaults
  // Example: 'https://assurefix-backend.onrender.com/api'
  static const String _productionApiUrl = '';
  
  // ============================================
  // DEVELOPMENT CONFIGURATION
  // ============================================
  // Your computer's local network IP address (for mobile testing)
  // Change this to your actual network IP when testing on mobile devices
  // Common IPs: 192.168.0.101, 192.168.1.100, 192.168.100.7
  static const String _localNetworkIp = '192.168.0.101';
  static const String _port = '5000';
  
  // SharedPreferences key
  static const String _prefsApiUrlKey = 'api_base_url';
  static const String _prefsBaseUrlKey = 'api_base_url_without_api';
  
  // Cached API URL (set during initialization)
  static String? _cachedApiUrl;
  static String? _cachedBaseUrl;
  
  // Load API URL from SharedPreferences
  static Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedApiUrl = prefs.getString(_prefsApiUrlKey);
      final savedBaseUrl = prefs.getString(_prefsBaseUrlKey);
      
      if (savedApiUrl != null && savedBaseUrl != null) {
        _cachedApiUrl = savedApiUrl;
        _cachedBaseUrl = savedBaseUrl;
      }
    } catch (e) {
      // Silently fail, use defaults
    }
  }
  
  // Save API URL to SharedPreferences
  static Future<void> saveToPreferences(String apiUrl, String baseUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsApiUrlKey, apiUrl);
      await prefs.setString(_prefsBaseUrlKey, baseUrl);
      _cachedApiUrl = apiUrl;
      _cachedBaseUrl = baseUrl;
    } catch (e) {
      // Silently fail
    }
  }
  
  // Get saved API URL from preferences (without loading cache)
  static Future<String?> getSavedApiUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsApiUrlKey);
    } catch (e) {
      return null;
    }
  }

  // Get base URL from environment, cache, or use smart defaults
  static String get baseUrl {
    // 1. Check for environment variable (highest priority - for production builds)
    const String envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // 2. Use production URL if set and in production mode
    if (_productionApiUrl.isNotEmpty && isProduction) {
      return _productionApiUrl;
    }

    // 3. Use cached URL if available (set from backend config endpoint)
    if (_cachedApiUrl != null) {
      return _cachedApiUrl!;
    }

    // 4. Smart defaults based on platform (development)
    if (kIsWeb) {
      // Web: Always use localhost
      return 'http://localhost:$_port/api';
    } else {
      // Mobile/Desktop: Use network IP for device testing
      // Change _localNetworkIp above to match your network IP
      return 'http://$_localNetworkIp:$_port/api';
    }
  }

  // Get full API URL
  static String get apiUrl => baseUrl;

  // Get base URL without /api suffix (for file uploads and direct endpoints)
  static String get baseUrlWithoutApi {
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }
    
    const String envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      final url = envUrl;
      if (url.endsWith('/api')) {
        return url.substring(0, url.length - 4);
      }
      return url;
    }
    
    // Use production URL if set and in production mode
    if (_productionApiUrl.isNotEmpty && isProduction) {
      if (_productionApiUrl.endsWith('/api')) {
        return _productionApiUrl.substring(0, _productionApiUrl.length - 4);
      }
      return _productionApiUrl;
    }
    
    if (kIsWeb) {
      return 'http://localhost:$_port';
    } else {
      return 'http://$_localNetworkIp:$_port';
    }
  }

  // Set API URL from backend config (called during app initialization)
  static Future<void> setApiUrl(String apiUrl, String baseUrl) async {
    _cachedApiUrl = apiUrl;
    _cachedBaseUrl = baseUrl;
    await saveToPreferences(apiUrl, baseUrl);
  }

  // Clear cached URLs (useful for testing or reconfiguration)
  static Future<void> clearCache() async {
    _cachedApiUrl = null;
    _cachedBaseUrl = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsApiUrlKey);
      await prefs.remove(_prefsBaseUrlKey);
    } catch (e) {
      // Silently fail
    }
  }

  // Check if running in production mode
  static bool get isProduction {
    const bool isProd = bool.fromEnvironment('dart.vm.product');
    return isProd;
  }
}
