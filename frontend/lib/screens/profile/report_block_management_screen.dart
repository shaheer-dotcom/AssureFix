import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../widgets/confirmation_dialog.dart';
import 'user_profile_view_screen.dart';

class ReportBlockManagementScreen extends StatefulWidget {
  const ReportBlockManagementScreen({super.key});

  @override
  State<ReportBlockManagementScreen> createState() =>
      _ReportBlockManagementScreenState();
}

class _ReportBlockManagementScreenState
    extends State<ReportBlockManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _reportedUsers = [];
  List<dynamic> _blockedUsers = [];
  bool _isLoadingReports = true;
  bool _isLoadingBlocked = true;
  String? _reportsError;
  String? _blockedError;

  String get _baseUrl {
    return ApiConfig.baseUrlWithoutApi;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReportedUsers();
    _loadBlockedUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReportedUsers() async {
    setState(() {
      _isLoadingReports = true;
      _reportsError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/reports/my-reports'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _reportedUsers = data is List ? data : [];
            _isLoadingReports = false;
          });
        } else {
          setState(() {
            _reportsError = 'Failed to load reports';
            _isLoadingReports = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _reportsError = 'Error: $e';
        _isLoadingReports = false;
      });
    }
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoadingBlocked = true;
      _blockedError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/users/blocked'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _blockedUsers = data['blockedUsers'] ?? [];
            _isLoadingBlocked = false;
          });
        } else {
          setState(() {
            _blockedError = 'Failed to load blocked users';
            _isLoadingBlocked = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _blockedError = 'Error: $e';
        _isLoadingBlocked = false;
      });
    }
  }

  Future<void> _unblockUser(String userId, String userName) async {
    final confirmed = await ConfirmationDialog.unblockUser(context, userName);

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token == null) {
          throw Exception('Not authenticated');
        }

        final response = await http.delete(
          Uri.parse('$_baseUrl/api/users/block/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User unblocked successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadBlockedUsers();
          }
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to unblock user');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewUserProfile(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileViewScreen(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report & Block'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Reported Users'),
            Tab(text: 'Blocked Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportedUsersTab(),
          _buildBlockedUsersTab(),
        ],
      ),
    );
  }

  Widget _buildReportedUsersTab() {
    if (_isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reportsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(_reportsError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReportedUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reportedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No reported users',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Users you report will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReportedUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reportedUsers.length,
        itemBuilder: (context, index) {
          final report = _reportedUsers[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final reportedUser = report['reportedUser'] ?? {};
    final userName = reportedUser['profile']?['name'] ?? 'Unknown User';
    final userId = reportedUser['_id'] ?? '';
    final reportType = report['reportType'] ?? 'other';
    final description = report['description'] ?? '';
    final status = report['status'] ?? 'pending';
    final createdAt = report['createdAt'] ?? '';

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'under_review':
        statusColor = Colors.blue;
        statusIcon = Icons.rate_review;
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'dismissed':
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewUserProfile(userId, userName),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1565C0),
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatReportType(reportType),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Reported ${_formatDate(createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedUsersTab() {
    if (_isLoadingBlocked) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_blockedError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(_blockedError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBlockedUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No blocked users',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Users you block will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final user = _blockedUsers[index];
          return _buildBlockedUserCard(user);
        },
      ),
    );
  }

  Widget _buildBlockedUserCard(Map<String, dynamic> user) {
    final userName = user['profile']?['name'] ?? 'Unknown User';
    final userId = user['_id'] ?? '';
    final userType = user['profile']?['userType'] ?? 'customer';
    final email = user['email'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1565C0),
              child: Text(
                userName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userType == 'service_provider'
                        ? 'Service Provider'
                        : 'Customer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _unblockUser(userId, userName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Unblock'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _viewUserProfile(userId, userName),
                  child: const Text('View Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatReportType(String type) {
    switch (type) {
      case 'inappropriate_behavior':
        return 'Inappropriate Behavior';
      case 'fraud':
        return 'Fraud';
      case 'poor_service':
        return 'Poor Service';
      case 'harassment':
        return 'Harassment';
      case 'fake_profile':
        return 'Fake Profile';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'just now';
          }
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
