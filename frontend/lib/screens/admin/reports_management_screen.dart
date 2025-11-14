import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    return kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report status updated to $status'),
            backgroundColor: Colors.green,
          ),
        );
        _loadReports();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
