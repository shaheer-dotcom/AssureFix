import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _bookingUpdates = true;
  bool _serviceReminders = true;
  bool _promotionalOffers = false;
  bool _newMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Notifications
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('General Notifications'),
                  subtitle: Text('Control how you receive notifications'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive notifications on your device'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                    _saveSettings();
                  },
                ),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive notifications via email'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                    _saveSettings();
                  },
                ),
                SwitchListTile(
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Receive notifications via SMS'),
                  value: _smsNotifications,
                  onChanged: (value) {
                    setState(() {
                      _smsNotifications = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Service Notifications
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.work),
                  title: Text('Service Notifications'),
                  subtitle: Text('Notifications about your bookings and services'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Booking Updates'),
                  subtitle: const Text('Status changes for your bookings'),
                  value: _bookingUpdates,
                  onChanged: (value) {
                    setState(() {
                      _bookingUpdates = value;
                    });
                    _saveSettings();
                  },
                ),
                SwitchListTile(
                  title: const Text('Service Reminders'),
                  subtitle: const Text('Reminders about upcoming services'),
                  value: _serviceReminders,
                  onChanged: (value) {
                    setState(() {
                      _serviceReminders = value;
                    });
                    _saveSettings();
                  },
                ),
                SwitchListTile(
                  title: const Text('New Messages'),
                  subtitle: const Text('Notifications for new chat messages'),
                  value: _newMessages,
                  onChanged: (value) {
                    setState(() {
                      _newMessages = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Marketing Notifications
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.local_offer),
                  title: Text('Marketing'),
                  subtitle: Text('Promotional content and offers'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Promotional Offers'),
                  subtitle: const Text('Special deals and discounts'),
                  value: _promotionalOffers,
                  onChanged: (value) {
                    setState(() {
                      _promotionalOffers = value;
                    });
                    _saveSettings();
                  },
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
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Here you would typically save to SharedPreferences or send to API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}