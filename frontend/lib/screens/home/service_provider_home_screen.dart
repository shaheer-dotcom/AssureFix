import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/booking.dart';
import '../../services/api_service.dart';
import '../../widgets/rating_widget.dart';

class ServiceProviderHomeScreen extends StatefulWidget {
  const ServiceProviderHomeScreen({super.key});

  @override
  State<ServiceProviderHomeScreen> createState() => _ServiceProviderHomeScreenState();
}

class _ServiceProviderHomeScreenState extends State<ServiceProviderHomeScreen> {
  final Map<String, String> _serviceNames = {};
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveBookings();
      _loadNotificationCount();
    });
  }

  Future<void> _loadActiveBookings() async {
    await Provider.of<BookingProvider>(context, listen: false).loadUserBookings();
    await _loadServiceNames();
  }

  Future<void> _loadNotificationCount() async {
    await Provider.of<NotificationProvider>(context, listen: false).loadUnreadCount();
  }

  Future<void> _loadServiceNames() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final activeBookings = bookingProvider.bookings
        .where((booking) => 
            booking.status == 'pending' || booking.status == 'active')
        .toList();
    
    for (var booking in activeBookings) {
      if (!_serviceNames.containsKey(booking.serviceId)) {
        try {
          final serviceData = await ApiService.getServiceById(booking.serviceId);
          if (mounted) {
            setState(() {
              _serviceNames[booking.serviceId] = serviceData['name'] ?? 'Unknown Service';
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _serviceNames[booking.serviceId] = 'Unknown Service';
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AssureFix'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationProvider.unreadCount > 99
                              ? '99+'
                              : notificationProvider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadActiveBookings,
        child: Consumer3<AuthProvider, BookingProvider, NotificationProvider>(
          builder: (context, authProvider, bookingProvider, notificationProvider, child) {
            final user = authProvider.user;
            final profile = user?.profile;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.name ?? 'Service Provider',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        icon: Icons.add_business,
                        title: 'Post a service',
                        color: const Color(0xFF1565C0),
                        onTap: () {
                          Navigator.pushNamed(context, '/post-service');
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.business_center,
                        title: 'Manage services',
                        color: const Color(0xFF42A5F5),
                        onTap: () {
                          Navigator.pushNamed(context, '/manage-services');
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.report_problem_outlined,
                        title: 'Report and block',
                        color: const Color(0xFFFF6B6B),
                        onTap: () {
                          Navigator.pushNamed(context, '/report-block');
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.calendar_today,
                        title: 'Manage Bookings',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          Navigator.pushNamed(context, '/manage-bookings');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Active Bookings Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Bookings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/manage-bookings');
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Active Bookings List
                  _buildActiveBookingsList(bookingProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF2C2C2C) 
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Theme.of(context).brightness == Brightness.dark 
              ? Border.all(color: Colors.grey.shade800) 
              : null,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.black26 
                  : Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBookingsList(BookingProvider bookingProvider) {
    if (bookingProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (bookingProvider.error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 12),
            Text(
              'Error loading bookings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              bookingProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadActiveBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Filter active bookings (pending, confirmed, or in_progress status)
    final activeBookings = bookingProvider.bookings
        .where((booking) => 
            booking.status == 'pending' || 
            booking.status == 'confirmed' || 
            booking.status == 'in_progress')
        .toList();

    if (activeBookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your active bookings will appear here',
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

    return Column(
      children: activeBookings.map((booking) {
        return _buildBookingCard(booking);
      }).toList(),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: booking.status == 'pending' 
                      ? Colors.orange.shade100 
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: booking.status == 'pending' 
                        ? Colors.orange.shade700 
                        : Colors.green.shade700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '₹${booking.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Service: ${_serviceNames[booking.serviceId] ?? 'Loading...'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person_outline, 'Customer: ${booking.customerDetails.name}'),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.phone_outlined, booking.customerDetails.phoneNumber),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.location_on_outlined, booking.customerDetails.exactAddress),
          const SizedBox(height: 4),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            '${booking.reservationDate.day}/${booking.reservationDate.month}/${booking.reservationDate.year}',
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            Icons.access_time_outlined,
            '${booking.reservationDate.hour}:${booking.reservationDate.minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showCompletionDialog(booking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Mark as Completed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Booking'),
        content: RatingInputWidget(
          title: 'Rate ${booking.customerDetails.name}',
          onSubmit: (rating, comment) async {
            await _submitRatingAndComplete(booking, rating, comment);
          },
        ),
      ),
    );
  }

  Future<void> _submitRatingAndComplete(
    Booking booking,
    int stars,
    String comment,
  ) async {
    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completing booking...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Submit rating
      // Note: Backend automatically marks booking as completed when rating is submitted
      await ApiService.createRating({
        'ratedUserId': booking.customerId,
        'ratingType': 'customer',
        'stars': stars,
        'comment': comment,
        'relatedBooking': booking.id,
        'relatedService': booking.serviceId,
      });

      // Reload bookings to reflect the changes
      await _loadActiveBookings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking completed and rating submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
