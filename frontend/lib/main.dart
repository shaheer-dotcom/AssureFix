import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/api_config.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/messages_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/splash/animated_loading_screen.dart';
import 'screens/services/create_service_screen.dart';
import 'screens/services/manage_services_screen.dart';
import 'screens/services/search_services_screen.dart';
import 'screens/services/post_service_screen.dart';
import 'screens/services/service_history_screen.dart';
import 'screens/bookings/manage_bookings_screen.dart';
import 'screens/bookings/booking_history_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/support/help_support_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/report_block_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to fetch API config from backend
  await _fetchApiConfig();
  
  // Add error handling for uncaught errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  
  runApp(const ServiceHubApp());
}

/// Fetch API configuration from backend
/// Falls back to defaults if backend is not available
Future<void> _fetchApiConfig() async {
  // First, try to load saved API URL from preferences
  await ApiConfig.loadFromPreferences();
  
  // If we have a saved URL, try to verify it works
  final savedUrl = await ApiConfig.getSavedApiUrl();
  if (savedUrl != null) {
    try {
      final baseUrl = savedUrl.replaceAll('/api', '');
      final configUrl = '$baseUrl/api/config';
      final response = await http.get(
        Uri.parse(configUrl),
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apiUrl = data['apiUrl'] as String?;
        final baseUrlFromServer = data['baseUrl'] as String?;
        
        if (apiUrl != null && baseUrlFromServer != null) {
          await ApiConfig.setApiUrl(apiUrl, baseUrlFromServer);
          debugPrint('✅ API config loaded from saved preferences: $apiUrl');
          return;
        }
      }
    } catch (e) {
      debugPrint('⚠️  Saved API URL not reachable, trying alternatives...');
    }
  }
  
  // Try to auto-discover backend by trying multiple URLs
  final urlsToTry = <String>[];
  
  if (kIsWeb) {
    urlsToTry.add('http://localhost:5000/api/config');
  } else {
    // For mobile: try localhost (emulator), then network IPs
    urlsToTry.add('http://localhost:5000/api/config');
    urlsToTry.add('http://10.0.2.2:5000/api/config'); // Android emulator
    
    // Try common network IPs (most common first)
    urlsToTry.add('http://192.168.0.101:5000/api/config');
    urlsToTry.add('http://192.168.0.100:5000/api/config');
    urlsToTry.add('http://192.168.1.100:5000/api/config');
    urlsToTry.add('http://192.168.1.101:5000/api/config');
    urlsToTry.add('http://192.168.100.7:5000/api/config');
    urlsToTry.add('http://192.168.100.100:5000/api/config');
  }
  
  // Try each URL
  for (final configUrl in urlsToTry) {
    try {
      final response = await http.get(
        Uri.parse(configUrl),
      ).timeout(const Duration(seconds: 2));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apiUrl = data['apiUrl'] as String?;
        final baseUrl = data['baseUrl'] as String?;
        
        if (apiUrl != null && baseUrl != null) {
          await ApiConfig.setApiUrl(apiUrl, baseUrl);
          debugPrint('✅ API config loaded from backend: $apiUrl');
          return;
        }
      }
    } catch (e) {
      // Try next URL
      continue;
    }
  }
  
  // If we get here, use defaults (already set in ApiConfig)
  debugPrint('ℹ️  Using default API config (backend config not available)');
  debugPrint('ℹ️  Current API URL: ${ApiConfig.baseUrl}');
  debugPrint('ℹ️  You can configure it in Settings > API Configuration');
}

class ServiceHubApp extends StatelessWidget {
  const ServiceHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider.value(value: ConversationProvider()),
        ChangeNotifierProvider(create: (_) => MessagesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AssureFix',
            theme: themeProvider.currentTheme,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/create-service': (context) => const CreateServiceScreen(),
              '/manage-services': (context) => const ManageServicesScreen(),
              '/search-services': (context) => const SearchServicesScreen(),
              '/post-service': (context) => const PostServiceScreen(),
              '/service-history': (context) => const ServiceHistoryScreen(),
              '/manage-bookings': (context) => const ManageBookingsScreen(),
              '/booking-history': (context) => const BookingHistoryScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/help-support': (context) => const HelpSupportScreen(),
              '/report-block': (context) => const ReportBlockManagementScreen(),
              '/notifications': (context) => const NotificationsScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  _checkAuthStatus() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await authProvider.checkAuthStatus();
      await themeProvider.loadTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const AnimatedLoadingScreen();
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        if (!authProvider.hasProfile) {
          return const RoleSelectionScreen();
        }

        return const MainNavigation();
      },
    );
  }
}