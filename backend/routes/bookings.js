const express = require('express');
const { body, validationResult } = require('express-validator');
const Booking = require('../models/Booking');
const Service = require('../models/Service');
const User = require('../models/User');
const Chat = require('../models/Chat');
const auth = require('../middleware/auth');
const {
  notifyBookingCreated,
  notifyBookingAccepted,
  notifyBookingCompleted,
  notifyBookingCompletionConfirmation,
  notifyBookingCancelled
} = require('../services/notificationService');

const router = express.Router();

// Create a new booking
router.post('/', auth, [
  body('serviceId').notEmpty(),
  body('bookingType').optional().isIn(['immediate', 'reservation']),
  body('customerDetails.name').notEmpty().trim(),
  body('customerDetails.phoneNumber').notEmpty().trim(),
  body('customerDetails.exactAddress').notEmpty().trim(),
  body('reservationDate').optional().isISO8601(),
  body('hoursBooked').isInt({ min: 1 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      serviceId,
      bookingType = 'reservation',
      customerDetails,
      reservationDate,
      hoursBooked
    } = req.body;

    // Get service details
    const service = await Service.findById(serviceId);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    // Calculate total amount - use pricePerHour if available, otherwise use price
    const pricePerHour = service.pricePerHour || service.price || 0;
    if (pricePerHour === 0) {
      return res.status(400).json({ 
        message: 'Service price not configured properly' 
      });
    }
    const totalAmount = pricePerHour * hoursBooked;

    // Validate based on booking type
    let finalReservationDate;
    
    if (bookingType === 'immediate') {
      // For immediate bookings, set reservation date to now
      finalReservationDate = new Date();
    } else {
      // For reservation bookings, validate the date
      if (!reservationDate) {
        return res.status(400).json({ 
          message: 'Reservation date is required for reservation bookings' 
        });
      }

      const reservationTime = new Date(reservationDate);
      const now = new Date();
      const timeDiff = reservationTime.getTime() - now.getTime();
      const hoursDiff = timeDiff / (1000 * 3600);

      if (hoursDiff < 3) {
        return res.status(400).json({ 
          message: 'Reservation must be at least 3 hours in the future' 
        });
      }
      
      finalReservationDate = reservationTime;
    }

    // Ensure reservationDate is always set
    if (!finalReservationDate) {
      return res.status(400).json({ 
        message: 'Reservation date could not be determined' 
      });
    }

    const booking = new Booking({
      customerId: req.user._id,
      serviceId,
      providerId: service.providerId,
      bookingType,
      customerDetails,
      reservationDate: finalReservationDate,
      hoursBooked,
      totalAmount
    });

    await booking.save();
    await booking.populate(['serviceId', 'providerId', 'customerId']);

    // Update service booking count
    service.totalBookings += 1;
    await service.save();

    // Find or create ONE conversation per customer-provider pair
    let conversation;
    try {
      // Look for ANY existing conversation between these two users (regardless of service or booking)
      conversation = await Chat.findOne({
        participants: { $all: [req.user._id, service.providerId] }
      }).sort({ createdAt: -1 });

      if (conversation) {
        // Reuse existing conversation
        console.log('Reusing existing conversation:', conversation._id);
        
        // Reopen if it was closed
        if (conversation.status === 'closed') {
          conversation.status = 'pending';
          conversation.closedAt = null;
          conversation.closedReason = null;
        }
        
        // Update to link to the new booking
        conversation.bookingId = booking._id;
        conversation.serviceId = serviceId; // Update service reference
        await conversation.save();
      } else {
        // Create new conversation only if none exists between these users
        console.log('Creating new conversation for customer-provider pair');
        conversation = new Chat({
          participants: [req.user._id, service.providerId],
          serviceId: serviceId,
          bookingId: booking._id,
          status: 'pending'
        });
        await conversation.save();
      }

      // Link conversation to booking
      booking.conversationId = conversation._id;
      await booking.save();
    } catch (chatError) {
      console.error('Error creating/updating conversation:', chatError);
      // Continue without conversation - booking is still created
      // The conversation can be created later if needed
    }

    // Send notification to provider
    const customer = await User.findById(req.user._id);
    await notifyBookingCreated(booking, service, customer);

    res.status(201).json(booking);
  } catch (error) {
    console.error('Booking creation error:', error);
    console.error('Error details:', {
      name: error.name,
      message: error.message,
      stack: error.stack
    });
    
    // Return more detailed error message
    let errorMessage = 'Server error';
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const validationErrors = Object.values(error.errors).map(err => err.message);
      errorMessage = `Validation error: ${validationErrors.join(', ')}`;
    } else if (error.message) {
      errorMessage = error.message;
    }
    
    res.status(500).json({ 
      message: errorMessage,
      ...(process.env.NODE_ENV !== 'production' && { 
        error: error.message, 
        name: error.name,
        details: error.errors 
      })
    });
  }
});

// Get user's bookings
router.get('/my-bookings', auth, async (req, res) => {
  try {
    const { status, page = 1, limit = 10 } = req.query;

    let query = {
      $or: [
        { customerId: req.user._id },
        { providerId: req.user._id }
      ]
    };

    if (status) {
      query.status = status;
    }

    const bookings = await Booking.find(query)
      .populate('serviceId', 'serviceName areaCovered pricePerHour')
      .populate('providerId', 'profile.name profile.phoneNumber')
      .populate('customerId', 'profile.name profile.phoneNumber')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    res.json(bookings);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get booking by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('serviceId')
      .populate('providerId', 'profile.name profile.phoneNumber profile.address')
      .populate('customerId', 'profile.name profile.phoneNumber');

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Check if user is involved in this booking
    if (booking.customerId._id.toString() !== req.user._id.toString() &&
        booking.providerId._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Access denied' });
    }

    res.json(booking);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Accept booking (provider only)
router.patch('/:id/accept', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Check if user is the provider
    if (booking.providerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only the service provider can accept this booking' });
    }

    // Check if booking is in pending status
    if (booking.status !== 'pending') {
      return res.status(400).json({ message: 'Only pending bookings can be accepted' });
    }

    // Update booking status to confirmed
    booking.status = 'confirmed';
    booking.acceptedAt = new Date();
    await booking.save();

    // Populate booking data for notifications
    await booking.populate(['serviceId', 'providerId', 'customerId']);

    // Activate or create conversation when booking is accepted
    let conversation = await Chat.findById(booking.conversationId);
    
    if (conversation) {
      conversation.status = 'active';
      await conversation.save();
    } else {
      // Create conversation if it doesn't exist
      conversation = new Chat({
        participants: [booking.customerId._id, booking.providerId._id],
        serviceId: booking.serviceId._id,
        bookingId: booking._id,
        status: 'active'
      });
      await conversation.save();
      
      // Link conversation to booking
      booking.conversationId = conversation._id;
      await booking.save();
    }

    // Update the provider's original notification to show accepted status FIRST
    const Notification = require('../models/Notification');
    await Notification.updateMany(
      { 
        relatedBooking: booking._id,
        userId: booking.providerId,
        type: 'booking'
      },
      { 
        $set: { 
          'bookingData.status': 'confirmed',
          title: 'Booking Accepted',
          message: `You accepted the booking for "${booking.serviceId.serviceName}" with ${booking.customerId.profile.name}`
        }
      }
    );

    // Send notification to customer about acceptance
    await notifyBookingAccepted(booking, booking.serviceId, booking.providerId);

    res.json(booking);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Reject/Decline booking (provider only)
router.patch('/:id/reject', auth, async (req, res) => {
  try {
    const { rejectionReason } = req.body;

    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Check if user is the provider
    if (booking.providerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only the service provider can reject this booking' });
    }

    // Check if booking is in pending status
    if (booking.status !== 'pending') {
      return res.status(400).json({ message: 'Only pending bookings can be rejected' });
    }

    // Update booking status to cancelled
    booking.status = 'cancelled';
    booking.cancellationReason = rejectionReason || 'Rejected by service provider';
    booking.cancelledBy = 'provider';
    await booking.save();

    // Populate booking data for notifications
    await booking.populate(['serviceId', 'providerId', 'customerId']);

    // Close conversation when booking is rejected - do not activate it
    if (booking.conversationId) {
      await Chat.findByIdAndUpdate(booking.conversationId, {
        status: 'closed',
        closedAt: new Date(),
        closedReason: 'cancelled'
      });
    }

    // Update the provider's original notification to show rejected status FIRST
    const Notification = require('../models/Notification');
    await Notification.updateMany(
      { 
        relatedBooking: booking._id,
        userId: booking.providerId,
        type: 'booking'
      },
      { 
        $set: { 
          'bookingData.status': 'cancelled',
          title: 'Booking Declined',
          message: `You declined the booking for "${booking.serviceId.serviceName}" from ${booking.customerId.profile.name}`
        }
      }
    );

    // Send notification to customer about rejection
    await notifyBookingCancelled(booking, booking.serviceId, booking.customerId, booking.providerId, 'provider');

    res.json(booking);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Initiate booking completion (first party marks as complete)
router.patch('/:id/initiate-completion', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Check if user is involved in this booking
    const isCustomer = booking.customerId.toString() === req.user._id.toString();
    const isProvider = booking.providerId.toString() === req.user._id.toString();

    if (!isCustomer && !isProvider) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Check if booking can be completed
    if (!['confirmed', 'in_progress'].includes(booking.status)) {
      return res.status(400).json({ message: 'Only confirmed or in-progress bookings can be completed' });
    }

    // Check if already initiated
    if (booking.completionInitiatedBy) {
      return res.status(400).json({ message: 'Completion already initiated. Waiting for confirmation.' });
    }

    // Mark completion as initiated
    const initiatedBy = isCustomer ? 'customer' : 'provider';
    booking.completionInitiatedBy = initiatedBy;
    booking.completionInitiatedAt = new Date();
    await booking.save();

    // Populate booking data for notifications
    await booking.populate(['serviceId', 'providerId', 'customerId']);

    // Send confirmation request notification to the other party
    await notifyBookingCompletionConfirmation(
      booking, 
      booking.serviceId, 
      booking.customerId, 
      booking.providerId, 
      initiatedBy
    );

    res.json({
      message: 'Completion initiated. Waiting for confirmation from the other party.',
      booking
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Confirm booking completion (second party confirms)
router.patch('/:id/confirm-completion', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Check if user is involved in this booking
    const isCustomer = booking.customerId.toString() === req.user._id.toString();
    const isProvider = booking.providerId.toString() === req.user._id.toString();

    if (!isCustomer && !isProvider) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Check if completion was initiated
    if (!booking.completionInitiatedBy) {
      return res.status(400).json({ message: 'Completion must be initiated first' });
    }

    // Check if the confirming party is different from the initiating party
    const confirmingBy = isCustomer ? 'customer' : 'provider';
    if (booking.completionInitiatedBy === confirmingBy) {
      return res.status(400).json({ message: 'You already initiated completion. Waiting for the other party to confirm.' });
    }

    // Mark completion as confirmed and update status to completed
    booking.completionConfirmedBy = confirmingBy;
    booking.completionConfirmedAt = new Date();
    booking.status = 'completed';
    await booking.save();

    // Populate booking data for notifications
    await booking.populate(['serviceId', 'providerId', 'customerId']);

    // Close conversation when booking is completed
    if (booking.conversationId) {
      await Chat.findByIdAndUpdate(booking.conversationId, {
        status: 'closed',
        closedAt: new Date(),
        closedReason: 'completed'
      });
    }

    // Send notifications to both parties to rate each other
    await notifyBookingCompleted(booking, booking.serviceId, booking.customerId, booking.providerId);

    res.json({
      message: 'Booking completed successfully. Please rate your experience.',
      booking
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Legacy complete endpoint (for backward compatibility - now initiates completion)
router.patch('/:id/complete', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Check if user is involved in this booking
    const isCustomer = booking.customerId.toString() === req.user._id.toString();
    const isProvider = booking.providerId.toString() === req.user._id.toString();

    if (!isCustomer && !isProvider) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Check if booking can be completed
    if (!['confirmed', 'in_progress'].includes(booking.status)) {
      return res.status(400).json({ message: 'Only confirmed or in-progress bookings can be completed' });
    }

    // If completion not initiated, initiate it
    if (!booking.completionInitiatedBy) {
      const initiatedBy = isCustomer ? 'customer' : 'provider';
      booking.completionInitiatedBy = initiatedBy;
      booking.completionInitiatedAt = new Date();
      await booking.save();

      // Populate booking data for notifications
      await booking.populate(['serviceId', 'providerId', 'customerId']);

      // Send confirmation request notification to the other party
      await notifyBookingCompletionConfirmation(
        booking, 
        booking.serviceId, 
        booking.customerId, 
        booking.providerId, 
        initiatedBy
      );

      return res.json({
        message: 'Completion initiated. Waiting for confirmation from the other party.',
        booking,
        requiresConfirmation: true
      });
    }

    // If already initiated by the other party, confirm it
    const confirmingBy = isCustomer ? 'customer' : 'provider';
    if (booking.completionInitiatedBy !== confirmingBy) {
      booking.completionConfirmedBy = confirmingBy;
      booking.completionConfirmedAt = new Date();
      booking.status = 'completed';
      await booking.save();

      // Populate booking data for notifications
      await booking.populate(['serviceId', 'providerId', 'customerId']);

      // Close conversation when booking is completed
      if (booking.conversationId) {
        await Chat.findByIdAndUpdate(booking.conversationId, {
          status: 'closed',
          closedAt: new Date(),
          closedReason: 'completed'
        });
      }

      // Send notifications to both parties to rate each other
      await notifyBookingCompleted(booking, booking.serviceId, booking.customerId, booking.providerId);

      return res.json({
        message: 'Booking completed successfully. Please rate your experience.',
        booking,
        requiresConfirmation: false
      });
    }

    // If same party tries to complete again
    return res.status(400).json({ 
      message: 'You already initiated completion. Waiting for the other party to confirm.',
      booking
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Cancel booking
router.patch('/:id/cancel', auth, [
  body('cancellationReason').optional().trim()
], async (req, res) => {
  try {
    const { cancellationReason } = req.body;

    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Check if user is involved in this booking
    const isCustomer = booking.customerId.toString() === req.user._id.toString();
    const isProvider = booking.providerId.toString() === req.user._id.toString();

    if (!isCustomer && !isProvider) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Check if booking can be cancelled
    if (!booking.canCancel) {
      return res.status(400).json({ 
        message: 'Cannot cancel booking less than 3 hours before reservation' 
      });
    }

    if (['completed', 'cancelled'].includes(booking.status)) {
      return res.status(400).json({ message: 'Booking is already completed or cancelled' });
    }

    // Update booking status to cancelled
    booking.status = 'cancelled';
    booking.cancellationReason = cancellationReason;
    booking.cancelledBy = isCustomer ? 'customer' : 'provider';
    await booking.save();

    // Populate booking data for notifications
    await booking.populate(['serviceId', 'providerId', 'customerId']);

    // Close conversation when booking is cancelled
    if (booking.conversationId) {
      await Chat.findByIdAndUpdate(booking.conversationId, {
        status: 'closed',
        closedAt: new Date(),
        closedReason: 'cancelled'
      });
    }

    // Send notifications
    await notifyBookingCancelled(booking, booking.serviceId, booking.customerId, booking.providerId, booking.cancelledBy);

    res.json(booking);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update booking status
router.patch('/:id/status', auth, [
  body('status').isIn(['confirmed', 'in_progress', 'completed', 'cancelled'])
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { status, cancellationReason } = req.body;

    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Check permissions
    const isCustomer = booking.customerId.toString() === req.user._id.toString();
    const isProvider = booking.providerId.toString() === req.user._id.toString();

    if (!isCustomer && !isProvider) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Validate status transitions
    if (status === 'cancelled') {
      if (!booking.canCancel) {
        return res.status(400).json({ 
          message: 'Cannot cancel booking less than 3 hours before reservation' 
        });
      }
      booking.cancellationReason = cancellationReason;
      booking.cancelledBy = isCustomer ? 'customer' : 'provider';
    }

    const previousStatus = booking.status;
    booking.status = status;
    await booking.save();

    // Populate booking data for notifications
    await booking.populate(['serviceId', 'providerId', 'customerId']);
    const service = booking.serviceId;
    const provider = booking.providerId;
    const customer = booking.customerId;

    // Close conversation when booking is completed or cancelled
    if (status === 'completed' || status === 'cancelled') {
      if (booking.conversationId) {
        await Chat.findByIdAndUpdate(booking.conversationId, {
          status: 'closed',
          closedAt: new Date(),
          closedReason: status === 'completed' ? 'completed' : 'cancelled'
        });
      }
    }

    // Send notifications based on status change
    if (status === 'confirmed' && previousStatus === 'pending') {
      await notifyBookingAccepted(booking, service, provider);
    } else if (status === 'completed') {
      await notifyBookingCompleted(booking, service, customer, provider);
    } else if (status === 'cancelled') {
      const cancelledBy = booking.cancelledBy;
      await notifyBookingCancelled(booking, service, customer, provider, cancelledBy);
    }

    res.json(booking);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update booking details (customer only)
router.put('/:id', auth, [
  body('customerDetails.name').optional().notEmpty().trim(),
  body('customerDetails.phoneNumber').optional().notEmpty().trim(),
  body('customerDetails.exactAddress').optional().notEmpty().trim(),
  body('reservationDate').optional().isISO8601(),
  body('hoursBooked').optional().isInt({ min: 1 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Only customer can update booking details
    if (booking.customerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only customer can update booking details' });
    }

    // Cannot update if booking is confirmed or completed
    if (['confirmed', 'completed', 'cancelled'].includes(booking.status)) {
      return res.status(400).json({ message: 'Cannot update confirmed, completed, or cancelled bookings' });
    }

    // Check 3-hour rule for new reservation date
    if (req.body.reservationDate) {
      const reservationTime = new Date(req.body.reservationDate);
      const now = new Date();
      const timeDiff = reservationTime.getTime() - now.getTime();
      const hoursDiff = timeDiff / (1000 * 3600);

      if (hoursDiff < 3) {
        return res.status(400).json({ 
          message: 'Reservation must be at least 3 hours in the future' 
        });
      }
    }

    // Update total amount if hours changed
    if (req.body.hoursBooked) {
      const service = await Service.findById(booking.serviceId);
      booking.totalAmount = service.pricePerHour * req.body.hoursBooked;
    }

    Object.assign(booking, req.body);
    await booking.save();

    res.json(booking);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;