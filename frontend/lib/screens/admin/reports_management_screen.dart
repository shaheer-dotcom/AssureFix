import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

class ReportsManagementScreen extends StatefulWidget {
  final String adminToken;

  const ReportsManagementScreen({
    super.key,
    required this.adminToken,
  });

  @override
  State<ReportsManagementScreen> createState() => _ReportsManagementScreenState();
}

class _ReportsManagementScreenState extends State<ReportsManagementScreen> {
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String? _error;

  String get _baseUrl {
    return ApiConfig.baseUrlWithoutApi;
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/reports'),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _reports = data['reports'];
        });
      } else {
        setState(() {
          _error = 'Failed to load reports';
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

  Future<void> _updateReportStatus(String reportId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/admin/reports/$reportId/status'),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report status updated to $status'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReports();
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update report status');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _showNotificationDialog(String userId, String userName) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Notification to $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty &&
                  messageController.text.trim().isNotEmpty) {
                await _sendNotification(
                  userId,
                  titleController.text.trim(),
                  messageController.text.trim(),
                );
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendNotification(String userId, String title, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/notifications/send'),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'title': title,
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send notification');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showBanDialog(String userId, String userName) async {
    final reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ban $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to ban this user?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Ban Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                await _banUser(userId, reasonController.text.trim());
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban User'),
          ),
        ],
      ),
    );
  }

  Future<void> _banUser(String userId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/users/$userId/ban'),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User banned successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReports(); // Refresh the reports list
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to ban user');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error banning user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Management'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
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
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReports,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _reports.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.report_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No reports found'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _reports.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final report = _reports[index];
                        final reportedUser = report['reportedUser'] ?? {};
                        final reportedUserProfile = reportedUser['profile'] ?? {};
                        final reporterProfile = (report['reporter'] ?? {})['profile'] ?? {};
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(report['status']),
                              child: const Icon(Icons.report, color: Colors.white),
                            ),
                            title: Text(
                              report['reportType']?.replaceAll('_', ' ').toUpperCase() ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reported: ${reportedUserProfile['name'] ?? 'Unknown'}'),
                                Text('By: ${reporterProfile['name'] ?? 'Unknown'}'),
                                Text('Date: ${_formatDate(report['createdAt'])}'),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(report['status']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report['status']?.toUpperCase() ?? 'UNKNOWN',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Description:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(report['description'] ?? 'No description'),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Actions:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (report['status'] != 'under_review')
                                          ElevatedButton.icon(
                                            onPressed: () => _updateReportStatus(
                                              report['_id'],
                                              'under_review',
                                            ),
                                            icon: const Icon(Icons.visibility, size: 16),
                                            label: const Text('Review'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        if (report['status'] != 'resolved')
                                          ElevatedButton.icon(
                                            onPressed: () => _updateReportStatus(
                                              report['_id'],
                                              'resolved',
                                            ),
                                            icon: const Icon(Icons.check_circle, size: 16),
                                            label: const Text('Resolve'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        if (report['status'] != 'dismissed')
                                          ElevatedButton.icon(
                                            onPressed: () => _updateReportStatus(
                                              report['_id'],
                                              'dismissed',
                                            ),
                                            icon: const Icon(Icons.cancel, size: 16),
                                            label: const Text('Dismiss'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ElevatedButton.icon(
                                          onPressed: () => _showNotificationDialog(
                                            reportedUser['_id'],
                                            reportedUserProfile['name'] ?? 'User',
                                          ),
                                          icon: const Icon(Icons.message, size: 16),
                                          label: const Text('Notify Reported'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => _showNotificationDialog(
                                            report['reportedBy']['_id'],
                                            reporterProfile['name'] ?? 'User',
                                          ),
                                          icon: const Icon(Icons.message, size: 16),
                                          label: const Text('Notify Reporter'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.purple,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => _showBanDialog(
                                            reportedUser['_id'],
                                            reportedUserProfile['name'] ?? 'User',
                                          ),
                                          icon: const Icon(Icons.block, size: 16),
                                          label: const Text('Ban User'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
