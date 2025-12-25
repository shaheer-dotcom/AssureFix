import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../utils/error_handler.dart';
import '../../services/api_service.dart';
import '../profile/user_profile_view_screen.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  void _loadBookings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadUserBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList('active'),
          _buildBookingsList('completed'),
          _buildBookingsList('cancelled'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String status) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text('Error: ${bookingProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadBookings,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Get current user to determine which bookings to show
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = authProvider.user?.id ?? '';

        debugPrint('=== Filtering bookings for tab: $status ===');
        debugPrint('Current User ID: $currentUserId');
        debugPrint('Total bookings: ${bookingProvider.bookings.length}');

        final filteredBookings = status == 'active'
            ? bookingProvider.bookings.where((booking) {
                final isCustomer = booking.customerId == currentUserId;
                final hasUserRated =
                    isCustomer ? booking.customerRated : booking.providerRated;

                debugPrint(
                    'Booking ${booking.id}: status=${booking.status}, isCustomer=$isCustomer, customerRated=${booking.customerRated}, providerRated=${booking.providerRated}, hasUserRated=$hasUserRated');

                // Show in active if:
                // 1. Status is pending/confirmed/in_progress (regardless of rating)
                // 2. OR status is completed but user hasn't rated yet
                final showInActive = (booking.status == 'pending' ||
                        booking.status == 'confirmed' ||
                        booking.status == 'in_progress') ||
                    (booking.status == 'completed' && !hasUserRated);

                debugPrint('  -> Show in Active: $showInActive');
                return showInActive;
              }).toList()
            : status == 'completed'
                ? bookingProvider.bookings.where((booking) {
                    final isCustomer = booking.customerId == currentUserId;
                    final hasUserRated = isCustomer
                        ? booking.customerRated
                        : booking.providerRated;

                    debugPrint(
                        'Booking ${booking.id}: status=${booking.status}, hasUserRated=$hasUserRated');

                    // Show in completed only if user has rated
                    final showInCompleted =
                        booking.status == 'completed' && hasUserRated;
                    debugPrint('  -> Show in Completed: $showInCompleted');
                    return showInCompleted;
                  }).toList()
                : bookingProvider.bookings
                    .where((booking) => booking.status == status)
                    .toList();

        debugPrint('Filtered bookings count: ${filteredBookings.length}');

        if (filteredBookings.isEmpty) {
          return EmptyStateWidget.noBookings(
            bookingType: _getStatusTitle(status),
            onAction: status == 'active'
                ? () {
                    Navigator.pop(context);
                    // Navigate to search services
                  }
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadBookings(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return _buildBookingCard(booking);
            },
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    // Get current user info to determine if they're customer or provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id ?? '';
    final isCustomer = booking.customerId == currentUserId;

    // Determine per-user status
    final hasUserRated =
        isCustomer ? booking.customerRated : booking.providerRated;
    final userSpecificStatus = (booking.status == 'completed' && !hasUserRated)
        ? 'pending_rating' // Show as pending rating if completed but user hasn't rated
        : booking.status;

    // Determine which name to show based on user role
    String displayName;
    String displayLabel;
    if (isCustomer) {
      // Customer sees provider name
      displayName = booking.providerName ?? 'Service Provider';
      displayLabel = 'Booked from';
    } else {
      // Provider sees customer name
      displayName = booking.customerName ?? booking.customerDetails.name;
      displayLabel = 'Booked by';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName ?? 'Service',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          final otherUserId = isCustomer ? booking.providerId : booking.customerId;
                          final otherUserName = isCustomer 
                              ? (booking.providerName ?? 'Service Provider')
                              : (booking.customerName ?? 'Customer');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfileViewScreen(
                                userId: otherUserId,
                                userName: otherUserName,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$displayLabel: $displayName',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(userSpecificStatus),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusTitle(userSpecificStatus),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (booking.bookingType == 'immediate') ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_on,
                                size: 10, color: Colors.orange.shade700),
                            const SizedBox(width: 2),
                            Text(
                              'IMMEDIATE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${booking.reservationDate.day}/${booking.reservationDate.month}/${booking.reservationDate.year}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${booking.reservationDate.hour.toString().padLeft(2, '0')}:${booking.reservationDate.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.customerDetails.exactAddress,
                    style: TextStyle(color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (booking.completionInitiatedBy != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pending_actions,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isCustomer
                            ? (booking.completionInitiatedBy == 'customer'
                                ? 'You marked as complete. Waiting for provider confirmation.'
                                : 'Provider marked as complete. Please confirm and rate.')
                            : (booking.completionInitiatedBy == 'provider'
                                ? 'You marked as complete. Waiting for customer confirmation.'
                                : 'Customer marked as complete. Please confirm and rate.'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Show ratings status if booking is completed
            if (booking.status == 'completed') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    isCustomer
                        ? (booking.customerRated
                            ? 'You rated this booking'
                            : 'Rating pending')
                        : (booking.providerRated
                            ? 'You rated this booking'
                            : 'Rating pending'),
                    style: TextStyle(
                      fontSize: 12,
                      color: (isCustomer ? booking.customerRated : booking.providerRated)
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if ((isCustomer && booking.customerRated) || (!isCustomer && booking.providerRated))
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to view ratings for this booking
                        final otherUserId = isCustomer ? booking.providerId : booking.customerId;
                        final otherUserName = isCustomer 
                            ? (booking.providerName ?? 'Service Provider')
                            : (booking.customerName ?? 'Customer');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileViewScreen(
                              userId: otherUserId,
                              userName: otherUserName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 14),
                      label: const Text('View Profile'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Price and action buttons section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price row
                Row(
                  children: [
                    Text(
                      '₹${booking.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const Spacer(),
                    // Quick action buttons (Edit/Cancel)
                    if ((booking.status == 'pending' ||
                            booking.status == 'confirmed' ||
                            booking.status == 'in_progress') &&
                        booking.canCancel) ...[
                      // Only show Edit button for customers
                      if (isCustomer)
                        TextButton(
                          onPressed: () => _showEditDialog(booking),
                          child: const Text('Edit'),
                        ),
                      TextButton(
                        onPressed: () => _cancelBookingWithConfirmation(booking),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Main action buttons row
                Row(
                  children: [
                    // Show Mark Complete / Confirm & Rate button if:
                    // 1. Status is pending/confirmed/in_progress OR
                    // 2. Status is completed but user hasn't rated yet
                    if (booking.status == 'pending' ||
                        booking.status == 'confirmed' ||
                        booking.status == 'in_progress' ||
                        (booking.status == 'completed' && !hasUserRated))
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showCompletionDialog(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            (booking.status == 'completed' && !hasUserRated)
                                ? 'Rate & Complete'
                                : (booking.completionInitiatedBy != null
                                    ? 'Confirm & Rate'
                                    : 'Mark Complete'),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    
                    // Add spacing between buttons if both exist
                    if ((booking.status == 'pending' ||
                            booking.status == 'confirmed' ||
                            booking.status == 'in_progress' ||
                            (booking.status == 'completed' && !hasUserRated)) &&
                        (booking.status == 'completed' ||
                            booking.status == 'cancelled'))
                      const SizedBox(width: 8),
                    
                    // View Details button
                    if (booking.status == 'completed' ||
                        booking.status == 'cancelled')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _viewBookingDetails(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return const Color(0xFF1565C0); // Blue theme
      case 'in_progress':
        return const Color(0xFF1976D2); // Lighter blue
      case 'pending_rating':
        return const Color(
            0xFF1E88E5); // Medium blue - waiting for user to rate
      case 'completed':
        return const Color(0xFF2E7D32); // Green
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelBookingWithConfirmation(Booking booking) async {
    final confirmed = await ConfirmationDialog.cancelBooking(context);
    if (confirmed == true) {
      await _cancelBooking(booking);
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    try {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final success = await bookingProvider.cancelBooking(booking.id,
          cancellationReason: 'Cancelled by user');

      if (mounted) {
        if (success) {
          ErrorHandler.showSuccessSnackBar(
              context, 'Booking cancelled successfully');
          // Reload bookings to show updated list
          _loadBookings();
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            bookingProvider.error ?? 'Failed to cancel booking',
            onRetry: () => _cancelBooking(booking),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.getErrorMessage(e),
          onRetry: () => _cancelBooking(booking),
        );
      }
    }
  }

  void _viewBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking #${booking.id.substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${booking.customerDetails.name}'),
            Text('Phone: ${booking.customerDetails.phoneNumber}'),
            Text('Address: ${booking.customerDetails.exactAddress}'),
            Text(
                'Date: ${booking.reservationDate.day}/${booking.reservationDate.month}/${booking.reservationDate.year}'),
            Text(
                'Time: ${booking.reservationDate.hour.toString().padLeft(2, '0')}:${booking.reservationDate.minute.toString().padLeft(2, '0')}'),
            Text('Amount: ₹${booking.totalAmount.toStringAsFixed(0)}'),
            Text('Status: ${_getStatusTitle(booking.status)}'),
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

  String _getStatusTitle(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'pending_rating':
        return 'Awaiting Rating';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  void _showEditDialog(Booking booking) {
    final nameController =
        TextEditingController(text: booking.customerDetails.name);
    final phoneController =
        TextEditingController(text: booking.customerDetails.phoneNumber);
    final addressController =
        TextEditingController(text: booking.customerDetails.exactAddress);
    DateTime selectedDate = booking.reservationDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(booking.reservationDate);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Booking'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedTime = time;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _updateBooking(
                    booking,
                    nameController.text,
                    phoneController.text,
                    addressController.text,
                    selectedDate,
                    selectedTime,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateBooking(
    Booking booking,
    String name,
    String phone,
    String address,
    DateTime date,
    TimeOfDay time,
  ) async {
    try {
      // Combine date and time
      final reservationDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Prepare update data
      final updateData = {
        'customerDetails': {
          'name': name,
          'phoneNumber': phone,
          'exactAddress': address,
        },
        'reservationDate': reservationDateTime.toIso8601String(),
      };

      // Call API to update booking
      await ApiService.updateBooking(booking.id, updateData);

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Booking updated successfully',
        );

        // Reload bookings to reflect the change
        _loadBookings();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          ErrorHandler.getErrorMessage(e),
          onRetry: () =>
              _updateBooking(booking, name, phone, address, date, time),
        );
      }
    }
  }

  void _showCompletionDialog(Booking booking) {
    // Get current user info to determine if they're customer or provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id ?? '';
    final isCustomer = booking.customerId == currentUserId;

    // Check if user already rated
    if ((isCustomer && booking.customerRated) ||
        (!isCustomer && booking.providerRated)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already rated this booking'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show rating dialog directly
    _showRatingDialog(booking, isCustomer);
  }

  void _showRatingDialog(Booking booking, bool isCustomer) {
    int rating = 0;
    final reviewController = TextEditingController();
    final bool isFirstToComplete = booking.status != 'completed';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isCustomer ? 'Rate Service Provider' : 'Rate Customer'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFirstToComplete
                        ? 'Please rate your experience with the ${isCustomer ? 'service provider' : 'customer'}.'
                        : 'The ${isCustomer ? 'service provider' : 'customer'} has marked this booking as complete. Please rate your experience.',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Review (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: rating > 0
                    ? () async {
                        Navigator.pop(context);
                        await _submitRatingAndMarkComplete(
                          booking,
                          rating,
                          reviewController.text,
                          isCustomer,
                          isFirstToComplete,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
                child: Text(isFirstToComplete
                    ? 'Submit & Mark Complete'
                    : 'Submit Rating'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitRatingAndMarkComplete(
    Booking booking,
    int stars,
    String review,
    bool isCustomer,
    bool isFirstToComplete,
  ) async {
    try {
      debugPrint('=== Starting rating submission ===');
      debugPrint('Booking ID: ${booking.id}');
      debugPrint('Booking Status: ${booking.status}');
      debugPrint('Is Customer: $isCustomer');
      debugPrint('Is First To Complete: $isFirstToComplete');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submitting rating...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Determine who to rate based on current user role
      final ratedUserId = isCustomer ? booking.providerId : booking.customerId;
      final ratingType = isCustomer ? 'service_provider' : 'customer';

      debugPrint('Rating User ID: $ratedUserId');
      debugPrint('Rating Type: $ratingType');

      // Submit rating via POST /api/ratings endpoint
      final ratingData = {
        'ratedUserId': ratedUserId,
        'ratingType': ratingType,
        'stars': stars,
        'comment': review,
        'relatedBooking': booking.id,
        'relatedService': booking.serviceId,
      };

      debugPrint('Submitting rating data: $ratingData');

      // Submit rating - backend will automatically mark booking as completed
      await ApiService.createRating(ratingData);

      debugPrint('Rating submitted successfully');

      // Reload bookings to reflect the changes
      _loadBookings();

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Rating submitted successfully! Booking marked as complete.',
        );
      }
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      debugPrint('Error type: ${e.runtimeType}');

      if (mounted) {
        // Show detailed error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _submitRatingAndMarkComplete(
                  booking, stars, review, isCustomer, isFirstToComplete),
            ),
          ),
        );
      }
    }
  }
}
