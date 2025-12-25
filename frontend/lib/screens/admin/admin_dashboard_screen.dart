import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import 'users_management_screen.dart';
import 'reports_management_screen.dart';
import 'send_notification_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String adminToken;
  final String adminEmail;

  const AdminDashboardScreen({
    super.key,
    required this.adminToken,
    required this.adminEmail,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  String get _baseUrl {
    return ApiConfig.baseUrlWithoutApi;
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/dashboard/stats'),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _stats = json.decode(response.body);
        });
      } else {
        setState(() {
          _error = 'Failed to load dashboard stats';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text(widget.adminEmail),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboardStats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                                  SizedBox(width: 12),
                                  Text(
                                    'Welcome, Admin!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Manage your AssureFix platform',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Statistics Cards
                      const Text(
                        'Platform Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_stats != null) ..._buildStatsCards(),
                      
                      const SizedBox(height: 32),
                      
                      // Management Options
                      const Text(
                        'Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildManagementCards(),
                    ],
                  ),
                ),
    );
  }

  void _navigateToScreen(String title) {
    switch (title) {
      case 'Users':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UsersManagementScreen(
              adminToken: widget.adminToken,
            ),
          ),
        );
        break;
      case 'Reports':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportsManagementScreen(
              adminToken: widget.adminToken,
            ),
          ),
        );
        break;
      case 'Services':
      case 'Bookings':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title management coming soon!'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
    }
  }

  List<Widget> _buildStatsCards() {
    final stats = [
      {
        'title': 'Users',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': 'Services',
        'icon': Icons.build,
        'color': Colors.purple,
      },
      {
        'title': 'Bookings',
        'icon': Icons.calendar_today,
        'color': Colors.teal,
      },
      {
        'title': 'Reports',
        'icon': Icons.report_problem,
        'color': Colors.red,
      },
    ];

    return [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _navigateToScreen(stat['title'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      size: 40,
                      color: stat['color'] as Color,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stat['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildManagementCards() {
    final managementOptions = [
      {
        'title': 'User Management',
        'subtitle': 'View, ban, and manage users',
        'icon': Icons.people_outline,
        'color': Colors.blue,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UsersManagementScreen(
                  adminToken: widget.adminToken,
                ),
              ),
            ),
      },
      {
        'title': 'Reports Management',
        'subtitle': 'Review and resolve user reports',
        'icon': Icons.report_outlined,
        'color': Colors.red,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportsManagementScreen(
                  adminToken: widget.adminToken,
                ),
              ),
            ),
      },
      {
        'title': 'Send Notifications',
        'subtitle': 'Send messages to users',
        'icon': Icons.notifications_active_outlined,
        'color': Colors.orange,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SendNotificationScreen(
                  adminToken: widget.adminToken,
                ),
              ),
            ),
      },
    ];

    return Column(
      children: managementOptions.map((option) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (option['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                option['icon'] as IconData,
                color: option['color'] as Color,
                size: 24,
              ),
            ),
            title: Text(
              option['title'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                option['subtitle'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
            onTap: option['onTap'] as VoidCallback,
          ),
        );
      }).toList(),
    );
  }
}
