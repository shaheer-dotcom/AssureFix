import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final bool _profileVisibility = true;
  bool _showPhoneNumber = false;
  bool _showEmail = false;
  bool _allowDirectMessages = true;
  bool _shareLocationData = true;
  bool _analyticsData = false;
  String _profileVisibilityLevel = 'Public';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Privacy
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile Privacy'),
                  subtitle:
                      Text('Control who can see your profile information'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Profile Visibility'),
                  subtitle: Text('Currently: $_profileVisibilityLevel'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showProfileVisibilityDialog,
                ),
                SwitchListTile(
                  title: const Text('Show Phone Number'),
                  subtitle: const Text('Display phone number on your profile'),
                  value: _showPhoneNumber,
                  onChanged: (value) {
                    setState(() {
                      _showPhoneNumber = value;
                    });
                    _saveSettings();
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Email Address'),
                  subtitle: const Text('Display email address on your profile'),
                  value: _showEmail,
                  onChanged: (value) {
                    setState(() {
                      _showEmail = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Communication Privacy
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Communication'),
                  subtitle: Text('Control how others can contact you'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Allow Direct Messages'),
                  subtitle: const Text('Let other users send you messages'),
                  value: _allowDirectMessages,
                  onChanged: (value) {
                    setState(() {
                      _allowDirectMessages = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Data Privacy
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Data Privacy'),
                  subtitle: Text('Control how your data is used'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Share Location Data'),
                  subtitle: const Text('Help improve location-based services'),
                  value: _shareLocationData,
                  onChanged: (value) {
                    setState(() {
                      _shareLocationData = value;
                    });
                    _saveSettings();
                  },
                ),
                SwitchListTile(
                  title: const Text('Analytics Data'),
                  subtitle:
                      const Text('Help improve the app with usage analytics'),
                  value: _analyticsData,
                  onChanged: (value) {
                    setState(() {
                      _analyticsData = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Data Management
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.folder),
                  title: Text('Data Management'),
                  subtitle: Text('Manage your personal data'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Download My Data'),
                  subtitle: const Text('Get a copy of your data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _downloadData,
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Delete Account'),
                  subtitle: const Text('Permanently delete your account'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Privacy Settings'),
          ),
        ],
      ),
    );
  }

  void _showProfileVisibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Visibility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Public'),
              subtitle: const Text('Anyone can see your profile'),
              value: 'Public',
              groupValue: _profileVisibilityLevel,
              onChanged: (value) {
                setState(() {
                  _profileVisibilityLevel = value!;
                });
                Navigator.pop(context);
                _saveSettings();
              },
            ),
            RadioListTile<String>(
              title: const Text('Customers Only'),
              subtitle: const Text('Only customers can see your profile'),
              value: 'Customers Only',
              groupValue: _profileVisibilityLevel,
              onChanged: (value) {
                setState(() {
                  _profileVisibilityLevel = value!;
                });
                Navigator.pop(context);
                _saveSettings();
              },
            ),
            RadioListTile<String>(
              title: const Text('Private'),
              subtitle: const Text('Only you can see your profile'),
              value: 'Private',
              groupValue: _profileVisibilityLevel,
              onChanged: (value) {
                setState(() {
                  _profileVisibilityLevel = value!;
                });
                Navigator.pop(context);
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Data'),
        content: const Text(
            'Your data will be prepared and sent to your email address within 24 hours.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download request submitted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Here you would typically save to SharedPreferences or send to API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
