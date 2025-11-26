import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 32,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We\'re Here to Help',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get in touch with our support team',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contact Information
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Phone Support
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.phone,
                    color: Colors.green.shade700,
                  ),
                ),
                title: const Text('Phone Support'),
                subtitle: const Text('+92 300 1234567'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _makePhoneCall('+923001234567'),
                      icon: const Icon(Icons.call),
                      tooltip: 'Call',
                    ),
                    IconButton(
                      onPressed: () => _copyToClipboard(context, '+92 300 1234567'),
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Email Support
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.email,
                    color: Colors.blue.shade700,
                  ),
                ),
                title: const Text('Email Support'),
                subtitle: const Text('support@assurefix.com'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _sendEmail('support@assurefix.com'),
                      icon: const Icon(Icons.send),
                      tooltip: 'Send Email',
                    ),
                    IconButton(
                      onPressed: () => _copyToClipboard(context, 'support@assurefix.com'),
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // WhatsApp Support
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chat,
                    color: Colors.green.shade700,
                  ),
                ),
                title: const Text('WhatsApp Support'),
                subtitle: const Text('+92 300 1234567'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _openWhatsApp('+923001234567'),
                      icon: const Icon(Icons.chat_bubble),
                      tooltip: 'WhatsApp',
                    ),
                    IconButton(
                      onPressed: () => _copyToClipboard(context, '+92 300 1234567'),
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Support Hours
            const Text(
              'Support Hours',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Monday - Friday',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        const Text('9:00 AM - 6:00 PM'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Saturday',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        const Text('10:00 AM - 4:00 PM'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Sunday',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        const Text('Closed'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final isProvider = authProvider.user?.profile?.userType == 'service_provider';
                
                if (isProvider) {
                  return Column(
                    children: [
                      _buildFAQItem(
                        'How do I post a service?',
                        'Go to your home screen, tap "Post a service", fill in the service details including name, description, price, and area tags, then submit.',
                      ),
                      _buildFAQItem(
                        'How do I manage my bookings?',
                        'Tap "Manage Bookings" from your home screen to view all active, completed, and cancelled bookings.',
                      ),
                      _buildFAQItem(
                        'How do I complete a booking?',
                        'Once the service is done, tap "Mark as Completed" on the booking card, then rate the customer.',
                      ),
                      _buildFAQItem(
                        'How do I edit my services?',
                        'Go to "Manage Services" from your home screen, find the service you want to edit, and tap the edit icon.',
                      ),
                      _buildFAQItem(
                        'How do customers find my services?',
                        'Customers can search for services by name and area tags. Make sure to add relevant area tags to your services.',
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildFAQItem(
                        'How do I book a service?',
                        'Search for services using the search screen, select a service provider, review the details, and tap "Book This Service".',
                      ),
                      _buildFAQItem(
                        'How do I search for services?',
                        'Use the "Search A service" option from your home screen. Add service name tags and area tags to find relevant services.',
                      ),
                      _buildFAQItem(
                        'How do I cancel a booking?',
                        'Go to "Manage Bookings", find your booking in the Active tab, and tap "Cancel". Confirm the cancellation.',
                      ),
                      _buildFAQItem(
                        'How do I rate a service provider?',
                        'After the service is completed, tap "Completed" on the booking card, then rate the provider with stars and an optional review.',
                      ),
                      _buildFAQItem(
                        'How do I contact a service provider?',
                        'On the service detail screen, tap the "Message" button to start a conversation with the provider.',
                      ),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Common FAQs
            const Text(
              'General Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildFAQItem(
              'How do I change my password?',
              'Go to Settings > Change Password. Enter your new password and verify it with the OTP sent to your email.',
            ),
            _buildFAQItem(
              'How do I report a user?',
              'Tap "Report and block" from your home screen, select the user, and provide details about the issue.',
            ),
            _buildFAQItem(
              'Is my data secure?',
              'Yes, we use industry-standard encryption and security measures to protect your data. Read our Privacy Policy for more details.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=AssureFix Support Request',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $text to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}