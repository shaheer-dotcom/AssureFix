import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
            
            _buildFAQItem(
              'How do I book a service?',
              'You can browse services on the home screen, select a service provider, and book directly through the app.',
            ),
            _buildFAQItem(
              'How do I become a service provider?',
              'Sign up as a service provider during registration, complete your profile, and start posting your services.',
            ),
            _buildFAQItem(
              'How do I cancel a booking?',
              'Go to your booking history, find the booking, and tap cancel. Note that cancellation policies may apply.',
            ),
            _buildFAQItem(
              'How do I rate a service?',
              'After service completion, you\'ll receive a notification to rate and review the service provider.',
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