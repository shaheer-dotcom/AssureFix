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