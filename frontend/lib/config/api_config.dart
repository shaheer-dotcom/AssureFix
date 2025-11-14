class ApiConfig {
  // Get base URL from environment or use default
  // In production, set this via build configuration or environment variables
  static String get baseUrl {
    // Check for environment variable (set via --dart-define or .env)
    const String envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Default to localhost for development
    // In production, this should be overridden
    return 'http://localhost:5000/api';
  }
  
  // Get full API URL
  static String get apiUrl => baseUrl;
  
  // Check if running in production mode
  static bool get isProduction {
    const bool isProd = bool.fromEnvironment('dart.vm.product');
    return isProd;
  }
}



