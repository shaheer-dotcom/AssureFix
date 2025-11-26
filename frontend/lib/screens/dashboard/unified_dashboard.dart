import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../home/service_provider_home_screen.dart';
import '../home/customer_home_screen.dart';

class UnifiedDashboard extends StatefulWidget {
  const UnifiedDashboard({super.key});

  @override
  State<UnifiedDashboard> createState() => _UnifiedDashboardState();
}

class _UnifiedDashboardState extends State<UnifiedDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadUserServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ServiceProvider>(
      builder: (context, authProvider, serviceProvider, child) {
        final user = authProvider.user;
        final isProvider = user?.profile?.userType == 'service_provider';
        
        // Use dedicated home screens based on user type
        if (isProvider) {
          return const ServiceProviderHomeScreen();
        } else {
          return const CustomerHomeScreen();
        }
      },
    );
  }
}
