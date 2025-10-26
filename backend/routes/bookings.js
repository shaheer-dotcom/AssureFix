const express = require('express');
const { body, validationResult } = require('express-validator');
const Booking = require('../models/Booking');
const Service = require('../models/Service');
const auth = require('../middleware/auth');

const router = express.Router();

// Create a new booking
router.post('/', auth, [
  body('serviceId').notEmpty(),
  body('customerDetails.name').notEmpty().trim(),
  body('customerDetails.phoneNumber').notEmpty().trim(),
  body('customerDetails.exactAddress').notEmpty().trim(),
  body('reservationDate').isISO8601(),
  body('hoursBooked').isInt({ min: 1 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      serviceId,
      customerDetails,
      reservationDate,
      hoursBooked
    } = req.body;

    // Get service details
    const service = await Service.findById(serviceId);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    // Calculate total amount
    const totalAmount = service.pricePerHour * hoursBooked;

    // Check if reservation is at least 3 hours in the future
    const reservationTime = new Date(reservationDate);
    const now = new Date();
    const timeDiff = reservationTime.getTime() - now.getTime();
    const hoursDiff = timeDiff / (1000 * 3600);

    if (hoursDiff < 3) {
      return res.status(400).json({ 
        message: 'Reservation must be at least 3 hours in the future' 
      });
    }

    const booking = new Booking({
      customerId: req.user._id,
      serviceId,
      providerId: service.providerId,
      customerDetails,
      reservationDate,
      hoursBooked,
      totalAmount
    });

    await booking.save();
    await booking.populate(['serviceId', 'providerId', 'customerId']);

    // Update service booking count
    service.totalBookings += 1;
    await service.save();

    res.status(201).json(booking);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
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

    booking.status = status;
    await booking.save();

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