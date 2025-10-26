import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile/profile_setup_screen.dart';
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

void main() {
  runApp(const ServiceHubApp());
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
          return const ProfileSetupScreen();
        }

        return const MainNavigation();
      },
    );
  }
}