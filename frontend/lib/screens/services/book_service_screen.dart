import 'package:flutter/material.dart';

import 'search_services_screen.dart';
import '../profile/profile_screen.dart';

class BookServiceScreen extends StatelessWidget {
  const BookServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service booking options
            _buildOptionCard(
              context,
              'Book Service',
              'Search and book professional services',
              Icons.search,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchServicesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              'Manage Bookings',
              'View and manage your bookings',
              Icons.book_online,
              () {
                Navigator.pushNamed(context, '/manage-bookings');
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              'View History',
              'See completed and cancelled bookings',
              Icons.history,
              () {
                Navigator.pushNamed(context, '/booking-history');
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              'Messages',
              'Chat with service providers',
              Icons.message,
              () {
                Navigator.pushNamed(context, '/messages');
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              'Profile',
              'View and edit your profile',
              Icons.person,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          size: 32,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
