import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
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
              '1. Information We Collect',
              'We collect information you provide directly to us, such as:\n\n'
              '• Personal information (name, email, phone number)\n'
              '• Profile information and preferences\n'
              '• Service booking and payment information\n'
              '• Communications and messages\n'
              '• Location data (with your permission)',
            ),

            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Provide and improve our services\n'
              '• Process bookings and payments\n'
              '• Communicate with you about services\n'
              '• Send notifications and updates\n'
              '• Ensure platform safety and security\n'
              '• Comply with legal obligations',
            ),

            _buildSection(
              '3. Information Sharing',
              'We may share your information with:\n\n'
              '• Service providers (to fulfill bookings)\n'
              '• Payment processors (for transactions)\n'
              '• Legal authorities (when required by law)\n'
              '• Service providers (with your consent)\n\n'
              'We do not sell your personal information to third parties.',
            ),

            _buildSection(
              '4. Data Security',
              'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes:\n\n'
              '• Encryption of sensitive data\n'
              '• Secure server infrastructure\n'
              '• Regular security audits\n'
              '• Access controls and authentication',
            ),

            _buildSection(
              '5. Your Rights',
              'You have the right to:\n\n'
              '• Access your personal information\n'
              '• Correct inaccurate information\n'
              '• Delete your account and data\n'
              '• Opt-out of marketing communications\n'
              '• Data portability\n'
              '• Withdraw consent',
            ),

            _buildSection(
              '6. Cookies and Tracking',
              'We use cookies and similar technologies to:\n\n'
              '• Remember your preferences\n'
              '• Analyze app usage\n'
              '• Improve user experience\n'
              '• Provide personalized content\n\n'
              'You can control cookie settings in your browser.',
            ),

            _buildSection(
              '7. Data Retention',
              'We retain your information for as long as necessary to provide services and comply with legal obligations. You can request deletion of your account and data at any time.',
            ),

            _buildSection(
              '8. Children\'s Privacy',
              'Our service is not intended for children under 13. We do not knowingly collect personal information from children under 13.',
            ),

            _buildSection(
              '9. Changes to Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any material changes via email or app notification.',
            ),

            _buildSection(
              '10. Contact Us',
              'If you have questions about this Privacy Policy, please contact us:\n\n'
              'Email: privacy@assurefix.com\n'
              'Phone: +1 (555) 123-4567\n'
              'Address: 123 Service Street, Tech City, TC 12345',
            ),

            const SizedBox(height: 32),

            // Acknowledge Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy acknowledged'),
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
                child: const Text('I Understand'),
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