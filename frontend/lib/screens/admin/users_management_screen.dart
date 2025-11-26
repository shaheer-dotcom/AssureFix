import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/confirmation_dialog.dart';
import 'user_detail_admin_screen.dart';

class UsersManagementScreen extends StatefulWidget {
  final String adminToken;

  const UsersManagementScreen({
    super.key,
    required this.adminToken,
  });

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _error;

  String get _baseUrl {
    return kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/users'),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = data['users'];
        });
      } else {
        setState(() {
          _error = 'Failed to load users';
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

  Future<void> _banUser(String userId, String userName) async {
    // First, show confirmation dialog
    final confirmed = await _showBanConfirmationDialog(userName);
    if (confirmed != true) return;

    // Then, ask for ban reason
    final reason = await _showBanReasonDialog(userName);
    if (reason == null) return;

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
            SnackBar(
              content: Text('User $userName has been banned'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _loadUsers();
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

  Future<void> _unbanUser(String userId, String userName) async {
    // Show confirmation dialog before unbanning
    final confirmed = await _showUnbanConfirmationDialog(userName);
    if (confirmed != true) return;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/users/$userId/unban'),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User $userName has been unbanned'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error unbanning user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showBanConfirmationDialog(String userName) async {
    return ConfirmationDialog.banUser(context, userName);
  }

  Future<bool?> _showUnbanConfirmationDialog(String userName) async {
    return ConfirmationDialog.unbanUser(context, userName);
  }

  Future<String?> _showBanReasonDialog(String userName) async {
    final reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Ban Reason for $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a detailed reason for banning this user:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Ban Reason',
                hintText: 'e.g., Violation of terms of service, fraudulent activity...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 500,
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Text(
              'This reason will be visible to the user.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context, reasonController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a ban reason'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit & Ban User'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
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
                        onPressed: _loadUsers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No users found'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _users.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        final profile = user['profile'] ?? {};
                        final isBanned = user['isBanned'] == true;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isBanned 
                                  ? Colors.red.shade100 
                                  : const Color(0xFF2E7D32),
                              child: Text(
                                (profile['name'] ?? 'U')[0].toUpperCase(),
                                style: TextStyle(
                                  color: isBanned ? Colors.red : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    profile['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: isBanned 
                                          ? TextDecoration.lineThrough 
                                          : null,
                                    ),
                                  ),
                                ),
                                if (isBanned)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'BANNED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['email'] ?? ''),
                                Text(
                                  '${profile['userType'] ?? 'Unknown'} • ${profile['phoneNumber'] ?? 'No phone'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'ban':
                                    _banUser(user['_id'], profile['name'] ?? 'Unknown');
                                    break;
                                  case 'unban':
                                    _unbanUser(user['_id'], profile['name'] ?? 'Unknown');
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                if (!isBanned)
                                  const PopupMenuItem(
                                    value: 'ban',
                                    child: Row(
                                      children: [
                                        Icon(Icons.block, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Ban User', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                if (isBanned)
                                  const PopupMenuItem(
                                    value: 'unban',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle, size: 20, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Unban User', style: TextStyle(color: Colors.green)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailAdminScreen(
                                    adminToken: widget.adminToken,
                                    userId: user['_id'],
                                    userName: profile['name'] ?? 'Unknown',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
