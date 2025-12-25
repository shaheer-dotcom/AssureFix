const express = require('express');
const Rating = require('../models/Rating');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

// Create a new rating
router.post('/', auth, async (req, res) => {
  try {
    const { ratedUserId, ratingType, stars, comment, relatedBooking, relatedService } = req.body;

    // Validation
    if (!ratedUserId || !ratingType || !stars) {
      return res.status(400).json({ 
        message: 'Rated user ID, rating type, and stars are required' 
      });
    }

    if (!['customer', 'service_provider'].includes(ratingType)) {
      return res.status(400).json({ 
        message: 'Rating type must be either customer or service_provider' 
      });
    }

    if (stars < 1 || stars > 5) {
      return res.status(400).json({ 
        message: 'Stars must be between 1 and 5' 
      });
    }

    // Check if user exists
    const ratedUser = await User.findById(ratedUserId);
    if (!ratedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Prevent self-rating
    if (req.user._id.toString() === ratedUserId) {
      return res.status(400).json({ message: 'You cannot rate yourself' });
    }

    // Check if rating already exists for this booking/service
    const existingRating = await Rating.findOne({
      ratedBy: req.user._id,
      ratedUser: ratedUserId,
      ratingType: ratingType,
      relatedBooking: relatedBooking || null
    });

    if (existingRating) {
      return res.status(400).json({ 
        message: 'You have already rated this user for this service' 
      });
    }

    // If related to a booking, verify booking exists and user is involved
    if (relatedBooking) {
      const Booking = require('../models/Booking');
      const booking = await Booking.findById(relatedBooking);
      
      if (!booking) {
        return res.status(404).json({ message: 'Booking not found' });
      }

      // Allow rating for confirmed, in_progress, or completed bookings
      // This allows users to rate when marking as complete
      if (!['confirmed', 'in_progress', 'completed'].includes(booking.status)) {
        return res.status(400).json({ message: 'Can only rate confirmed or completed bookings' });
      }

      // Verify user is involved in this booking
      const isCustomer = booking.customerId.toString() === req.user._id.toString();
      const isProvider = booking.providerId.toString() === req.user._id.toString();

      if (!isCustomer && !isProvider) {
        return res.status(403).json({ message: 'You are not involved in this booking' });
      }

      // Store other party ID before populating (in case it's an ObjectId)
      const otherPartyId = isCustomer ? booking.providerId : booking.customerId;

      // Update booking rating tracking
      if (isCustomer) {
        booking.customerRated = true;
      } else {
        booking.providerRated = true;
      }
      
      // Mark booking as completed if this is the first rating
      // This allows the other party to see it in completed tab and rate back
      if (booking.status !== 'completed') {
        booking.status = 'completed';
        
        // Populate booking data for notifications
        await booking.populate([
          { path: 'serviceId', select: 'serviceName' },
          { path: 'providerId', select: 'profile.name' },
          { path: 'customerId', select: 'profile.name' }
        ]);
        
        // Send notification to the other party that booking is completed and they can rate
        const { createNotification } = require('../services/notificationService');
        const raterName = isCustomer 
          ? (booking.customerId?.profile?.name || 'Customer')
          : (booking.providerId?.profile?.name || 'Service Provider');
        const serviceName = booking.serviceId?.serviceName || 'Service';
        
        // Use the stored ID (which is an ObjectId) or the populated object's _id
        const notificationUserId = otherPartyId._id || otherPartyId;
        
        await createNotification({
          userId: notificationUserId,
          type: 'booking',
          title: 'Booking Completed',
          message: `${raterName} has marked the booking for "${serviceName}" as completed and rated you. Please rate your experience.`,
          relatedBooking: booking._id,
          actionUrl: `/bookings/${booking._id}/rate`
        });
      }
      
      await booking.save();
    }

    // Create new rating
    const rating = new Rating({
      ratedBy: req.user._id,
      ratedUser: ratedUserId,
      ratingType,
      stars,
      comment: comment || '',
      relatedBooking: relatedBooking || null,
      relatedService: relatedService || null
    });

    await rating.save();

    // Populate the rating with user details
    await rating.populate([
      { path: 'ratedBy', select: 'profile.name email' },
      { path: 'ratedUser', select: 'profile.name email' }
    ]);

    console.log('Rating created successfully:', rating._id);

    res.status(201).json({
      message: 'Rating created successfully',
      rating: rating
    });
  } catch (error) {
    console.error('Rating creation error:', error);
    res.status(500).json({ message: 'Server error during rating creation' });
  }
});

// Get ratings for a specific user
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { type } = req.query; // 'customer' or 'service_provider'

    // Build query
    const query = { ratedUser: userId };
    if (type && ['customer', 'service_provider'].includes(type)) {
      query.ratingType = type;
    }

    const ratings = await Rating.find(query)
      .populate('ratedBy', 'profile.name email')
      .populate('ratedUser', 'profile.name email')
      .sort({ createdAt: -1 });

    // Get user's rating summary
    const user = await User.findById(userId).select('customerRating serviceProviderRating');
    
    res.json({
      ratings: ratings,
      summary: {
        customerRating: user?.customerRating || { average: 0, count: 0, totalStars: 0 },
        serviceProviderRating: user?.serviceProviderRating || { average: 0, count: 0, totalStars: 0 }
      }
    });
  } catch (error) {
    console.error('Get ratings error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get ratings given by a user
router.get('/given', auth, async (req, res) => {
  try {
    const ratings = await Rating.find({ ratedBy: req.user._id })
      .populate('ratedUser', 'profile.name email')
      .sort({ createdAt: -1 });

    res.json(ratings);
  } catch (error) {
    console.error('Get given ratings error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get ratings for a specific service
router.get('/service/:serviceId', async (req, res) => {
  try {
    const { serviceId } = req.params;
    const Service = require('../models/Service');

    // Verify service exists
    const service = await Service.findById(serviceId);
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }

    // Get all ratings for this service (service provider ratings)
    const ratings = await Rating.find({
      relatedService: serviceId,
      ratingType: 'service_provider'
    })
      .populate('ratedBy', 'profile.name profile.profilePicture')
      .populate('relatedBooking', 'reservationDate')
      .sort({ createdAt: -1 });

    // Calculate service-specific rating summary
    const totalStars = ratings.reduce((sum, rating) => sum + rating.stars, 0);
    const average = ratings.length > 0 ? totalStars / ratings.length : 0;

    res.json({
      ratings: ratings,
      summary: {
        average: Math.round(average * 10) / 10,
        count: ratings.length,
        totalStars: totalStars
      }
    });
  } catch (error) {
    console.error('Get service ratings error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update a rating
router.put('/:ratingId', auth, async (req, res) => {
  try {
    const { ratingId } = req.params;
    const { stars, comment } = req.body;

    const rating = await Rating.findById(ratingId);
    if (!rating) {
      return res.status(404).json({ message: 'Rating not found' });
    }

    // Check if user owns this rating
    if (rating.ratedBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to update this rating' });
    }

    // Update rating
    if (stars !== undefined) {
      if (stars < 1 || stars > 5) {
        return res.status(400).json({ message: 'Stars must be between 1 and 5' });
      }
      rating.stars = stars;
    }
    
    if (comment !== undefined) {
      rating.comment = comment;
    }

    await rating.save();

    await rating.populate([
      { path: 'ratedBy', select: 'profile.name email' },
      { path: 'ratedUser', select: 'profile.name email' }
    ]);

    console.log('Rating updated successfully:', rating._id);

    res.json({
      message: 'Rating updated successfully',
      rating: rating
    });
  } catch (error) {
    console.error('Rating update error:', error);
    res.status(500).json({ message: 'Server error during rating update' });
  }
});

// Delete a rating
router.delete('/:ratingId', auth, async (req, res) => {
  try {
    const { ratingId } = req.params;

    const rating = await Rating.findById(ratingId);
    if (!rating) {
      return res.status(404).json({ message: 'Rating not found' });
    }

    // Check if user owns this rating
    if (rating.ratedBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to delete this rating' });
    }

    await rating.remove();

    console.log('Rating deleted successfully:', ratingId);

    res.json({ message: 'Rating deleted successfully' });
  } catch (error) {
    console.error('Rating deletion error:', error);
    res.status(500).json({ message: 'Server error during rating deletion' });
  }
});

module.exports = router;