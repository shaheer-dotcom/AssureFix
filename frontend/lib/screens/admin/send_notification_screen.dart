import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/theme.dart';
import '../../widgets/glass_widgets.dart';

class SendNotificationScreen extends StatefulWidget {
  final String adminToken;

  const SendNotificationScreen({
    super.key,
    required this.adminToken,
  });

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _notificationType = 'broadcast'; // 'broadcast' or 'individual'
  String _targetAudience = 'all'; // 'all', 'customers', 'providers'
  String? _selectedUserId;
  String? _selectedUserName;
  
  bool _isLoading = false;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  String get _baseUrl {
    return kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/users?search=$query&limit=10'),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['users'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_notificationType == 'individual' && _selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String endpoint;
      Map<String, dynamic> body;

      if (_notificationType == 'individual') {
        endpoint = '$_baseUrl/api/admin/notifications/send';
        body = {
          'userId': _selectedUserId,
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
        };
      } else {
        endpoint = '$_baseUrl/api/admin/notifications/broadcast';
        body = {
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          'targetAudience': _targetAudience,
        };
      }

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          final data = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _notificationType == 'individual'
                    ? 'Notification sent successfully'
                    : 'Broadcast sent to ${data['recipientCount']} users',
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear form
          _titleController.clear();
          _messageController.clear();
          setState(() {
            _selectedUserId = null;
            _selectedUserName = null;
            _searchResults = [];
          });
        }
      } else {
        final error = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['message'] ?? 'Failed to send notification'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Send Notification',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Type Selection
              GlassFormCard(
                title: 'Notification Type',
                children: [
                  GlassRadioOption<String>(
                    title: 'Broadcast',
                    subtitle: 'Send to multiple users',
                    value: 'broadcast',
                    groupValue: _notificationType,
                    onChanged: (value) {
                      setState(() {
                        _notificationType = value!;
                        _selectedUserId = null;
                        _selectedUserName = null;
                        _searchResults = [];
                      });
                    },
                  ),
                  GlassRadioOption<String>(
                    title: 'Individual',
                    subtitle: 'Send to one user',
                    value: 'individual',
                    groupValue: _notificationType,
                    onChanged: (value) {
                      setState(() {
                        _notificationType = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Target Audience (for broadcast)
              if (_notificationType == 'broadcast') ...[
                GlassFormCard(
                  title: 'Target Audience',
                  children: [
                    GlassDropdown<String>(
                      labelText: 'Select Audience',
                      value: _targetAudience,
                      prefixIcon: Icons.people,
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Users'),
                        ),
                        DropdownMenuItem(
                          value: 'customers',
                          child: Text('All Customers'),
                        ),
                        DropdownMenuItem(
                          value: 'providers',
                          child: Text('All Service Providers'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _targetAudience = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // User Selection (for individual)
              if (_notificationType == 'individual') ...[
                GlassFormCard(
                  title: 'Select User',
                  children: [
                    // Selected user display
                    if (_selectedUserId != null) ...[
                      GlassContainer(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedUserName ?? 'User selected',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() {
                                  _selectedUserId = null;
                                  _selectedUserName = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Search field
                    GlassTextField(
                      hintText: 'Search by name, email, or phone',
                      prefixIcon: Icons.search,
                      onChanged: _searchUsers,
                    ),
                    
                    // Search results
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      )
                    else if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: EdgeInsets.zero,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final user = _searchResults[index];
                              final profile = user['profile'] ?? {};
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryBlue,
                                  child: Text(
                                    (profile['name'] ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  profile['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${user['email']}\n${profile['userType'] ?? 'N/A'}',
                                ),
                                isThreeLine: true,
                                onTap: () {
                                  setState(() {
                                    _selectedUserId = user['_id'];
                                    _selectedUserName = 
                                        '${profile['name']} (${user['email']})';
                                    _searchResults = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Notification Content
              GlassFormCard(
                title: 'Notification Content',
                children: [
                  // Title field
                  GlassTextField(
                    controller: _titleController,
                    labelText: 'Title',
                    prefixIcon: Icons.title,
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Message field
                  GlassTextField(
                    controller: _messageController,
                    labelText: 'Message',
                    prefixIcon: Icons.message,
                    maxLines: 5,
                    maxLength: 500,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Send button
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  text: 'Send Notification',
                  icon: Icons.send,
                  onPressed: _sendNotification,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
