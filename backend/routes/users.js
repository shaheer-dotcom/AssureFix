const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

// Create/Update user profile
router.post('/profile', auth, async (req, res) => {
  try {
    const { name, phoneNumber, userType, cnicDocument, shopDocument } = req.body;

    // Validation
    if (!name || !phoneNumber || !userType) {
      return res.status(400).json({ 
        message: 'Name, phone number, and user type are required' 
      });
    }

    if (!['customer', 'service_provider'].includes(userType)) {
      return res.status(400).json({ 
        message: 'User type must be either customer or service_provider' 
      });
    }

    // Update user profile
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.profile = {
      name: name.trim(),
      phoneNumber: phoneNumber.trim(),
      userType,
      cnicDocument: cnicDocument || null,
      shopDocument: shopDocument || null
    };

    await user.save();

    console.log('Profile created/updated for user:', user.email);

    res.json({
      message: 'Profile updated successfully',
      ...user.toJSON()
    });
  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({ message: 'Server error during profile update' });
  }
});

// Get user profile
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(user.toJSON());
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;