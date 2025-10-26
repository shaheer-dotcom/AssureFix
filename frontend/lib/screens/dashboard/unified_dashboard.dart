import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';

class UnifiedDashboard extends StatefulWidget {
  const UnifiedDashboard({super.key});

  @override
  State<UnifiedDashboard> createState() => _UnifiedDashboardState();
}

class _UnifiedDashboardState extends State<UnifiedDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadUserServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ServiceProvider>(
      builder: (context, authProvider, serviceProvider, child) {
        final user = authProvider.user;
        final isProvider = user?.profile?.userType == 'service_provider';
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(user, isProvider),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Role-based action cards
              ..._buildActionCards(isProvider),
              
              const SizedBox(height: 32),

              // Stats Section
              Text(
                isProvider ? 'Your Performance' : 'Your Activity',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Role-based stats
              ..._buildStatsCards(user, serviceProvider, isProvider),
              
              const SizedBox(height: 32),

              // Recent Activity
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildRecentActivity(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(user, bool isProvider) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isProvider ? 'Service Provider Dashboard' : 'Dashboard',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome, ${user?.profile?.name ?? (isProvider ? 'Provider' : 'Customer')}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isProvider 
                ? 'Manage your services and bookings'
                : 'Find and book services easily',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionCards(bool isProvider) {
    if (isProvider) {
      // Provider action cards
      return [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_business,
                title: 'Post Service',
                subtitle: 'Add new service',
                color: const Color(0xFF1565C0),
                onTap: () => Navigator.pushNamed(context, '/post-service'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.business_center,
                title: 'Manage Services',
                subtitle: 'Edit your services',
                color: const Color(0xFF42A5F5),
                onTap: () => Navigator.pushNamed(context, '/manage-services'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'Service History',
                subtitle: 'View past services',
                color: const Color(0xFF2196F3),
                onTap: () => Navigator.pushNamed(context, '/service-history'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'View performance',
                color: const Color(0xFF64B5F6),
                onTap: () {
                  _showAnalyticsDialog(context);
                },
              ),
            ),
          ],
        ),
      ];
    } else {
      // Customer action cards
      return [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.search,
                title: 'Find Services',
                subtitle: 'Browse available services',
                color: const Color(0xFF1565C0),
                onTap: () => Navigator.pushNamed(context, '/search-services'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.manage_accounts,
                title: 'Manage Bookings',
                subtitle: 'Track active bookings',
                color: const Color(0xFF42A5F5),
                onTap: () => Navigator.pushNamed(context, '/manage-bookings'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'Booking History',
                subtitle: 'View past bookings',
                color: const Color(0xFF2196F3),
                onTap: () => Navigator.pushNamed(context, '/booking-history'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.local_offer,
                title: 'Offers',
                subtitle: 'Special deals',
                color: const Color(0xFF64B5F6),
                onTap: () {
                  _showOffersDialog(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_business,
                title: 'Post Service',
                subtitle: 'Offer your services',
                color: const Color(0xFF4CAF50),
                onTap: () => Navigator.pushNamed(context, '/post-service'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.business_center,
                title: 'Manage Services',
                subtitle: 'Edit your services',
                color: const Color(0xFF9C27B0),
                onTap: () => Navigator.pushNamed(context, '/manage-services'),
              ),
            ),
          ],
        ),
      ];
    }
  }

  List<Widget> _buildStatsCards(user, serviceProvider, bool isProvider) {
    if (isProvider) {
      // Provider stats
      return [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                title: 'Service Rating',
                value: user?.serviceProviderRating.average.toStringAsFixed(1) ?? '0.0',
                subtitle: 'From customers (${user?.serviceProviderRating.count ?? 0})',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.rate_review,
                title: 'Customer Rating',
                value: user?.customerRating.average.toStringAsFixed(1) ?? '0.0',
                subtitle: 'As customer (${user?.customerRating.count ?? 0})',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.work,
                title: 'Active Services',
                value: serviceProvider.activeServicesCount.toString(),
                subtitle: 'Currently active',
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'Total Services',
                value: serviceProvider.totalServicesCount.toString(),
                subtitle: 'All time',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ];
    } else {
      // Customer stats
      return [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                title: 'Customer Rating',
                value: user?.customerRating.average.toStringAsFixed(1) ?? '0.0',
                subtitle: 'From providers (${user?.customerRating.count ?? 0})',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.rate_review,
                title: 'Given Ratings',
                value: user?.serviceProviderRating.average.toStringAsFixed(1) ?? '0.0',
                subtitle: 'To providers (${user?.serviceProviderRating.count ?? 0})',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.book_online,
                title: 'Total Bookings',
                value: '0',
                subtitle: 'All time',
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.savings,
                title: 'Money Saved',
                value: '₹0',
                subtitle: 'With offers',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ];
    }
  }

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No Recent Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your recent bookings and activities will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics Overview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnalyticsRow('Total Bookings', '12'),
            _buildAnalyticsRow('Completed Services', '8'),
            _buildAnalyticsRow('Average Rating', '4.5'),
            _buildAnalyticsRow('Revenue This Month', '₹15,000'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showOffersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Special Offers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOfferCard('New Customer Discount', '20% off your first booking'),
            const SizedBox(height: 8),
            _buildOfferCard('Referral Bonus', 'Get ₹100 for each referral'),
            const SizedBox(height: 8),
            _buildOfferCard('Weekend Special', '15% off weekend services'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
}