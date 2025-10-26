import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using AssureFix, you accept and agree to be bound by the terms and provision of this agreement.',
            ),

            _buildSection(
              '2. Service Description',
              'AssureFix is a platform that connects service providers with customers seeking various home and professional services. We facilitate bookings and communications but do not directly provide the services.',
            ),

            _buildSection(
              '3. User Responsibilities',
              '• Provide accurate and truthful information\n'
              '• Maintain the confidentiality of your account\n'
              '• Use the service in compliance with applicable laws\n'
              '• Respect other users and service providers\n'
              '• Pay for services as agreed',
            ),

            _buildSection(
              '4. Service Provider Responsibilities',
              '• Provide services as described and agreed\n'
              '• Maintain professional standards\n'
              '• Respond to customer inquiries promptly\n'
              '• Complete services in a timely manner\n'
              '• Maintain necessary licenses and insurance',
            ),

            _buildSection(
              '5. Payment Terms',
              'Payments are processed through our secure payment system. Service providers are responsible for setting their prices. AssureFix may charge a service fee for facilitating transactions.',
            ),

            _buildSection(
              '6. Cancellation Policy',
              'Bookings can be cancelled up to 3 hours before the scheduled service time. Cancellations made within 3 hours may be subject to cancellation fees.',
            ),

            _buildSection(
              '7. Limitation of Liability',
              'AssureFix acts as an intermediary platform. We are not liable for the quality, safety, or legality of services provided by third-party service providers.',
            ),

            _buildSection(
              '8. Privacy Policy',
              'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.',
            ),

            _buildSection(
              '9. Modifications',
              'We reserve the right to modify these terms at any time. Users will be notified of significant changes via email or app notifications.',
            ),

            _buildSection(
              '10. Contact Information',
              'For questions about these Terms of Service, please contact us at:\n\n'
              'Email: support@assurefix.com\n'
              'Phone: +1 (555) 123-4567\n'
              'Address: 123 Service Street, Tech City, TC 12345',
            ),

            const SizedBox(height: 32),

            // Accept Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terms accepted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('I Accept These Terms'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}