const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

// Create user profile (POST - initial creation)
router.post('/profile', auth, async (req, res) => {
  try {
    const { name, phoneNumber, userType, profilePicture, bannerImage, cnicDocument, shopDocument } = req.body;

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
      profilePicture: profilePicture || null,
      bannerImage: bannerImage || null,
      cnicDocument: cnicDocument || null,
      shopDocument: shopDocument || null
    };

    await user.save();

    console.log('Profile created for user:', user.email);

    res.json({
      message: 'Profile created successfully',
      ...user.toJSON()
    });
  } catch (error) {
    console.error('Profile creation error:', error);
    res.status(500).json({ message: 'Server error during profile creation' });
  }
});

// Update user profile (PUT - update existing profile)
router.put('/profile', auth, async (req, res) => {
  try {
    const { name, phoneNumber, profilePicture, bannerImage, cnicDocument, shopDocument } = req.body;

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (!user.profile) {
      return res.status(400).json({ message: 'Profile not found. Please create a profile first.' });
    }

    // Update only provided fields
    if (name) user.profile.name = name.trim();
    if (phoneNumber) user.profile.phoneNumber = phoneNumber.trim();
    if (profilePicture !== undefined) user.profile.profilePicture = profilePicture;
    if (bannerImage !== undefined) user.profile.bannerImage = bannerImage;
    if (cnicDocument !== undefined) user.profile.cnicDocument = cnicDocument;
    if (shopDocument !== undefined) user.profile.shopDocument = shopDocument;

    await user.save();

    console.log('Profile updated for user:', user.email);

    res.json({
      message: 'Profile updated successfully',
      ...user.toJSON()
    });
  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({ message: 'Server error during profile update' });
  }
});

// Get current user profile
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

// Get user profile by ID (public view)
router.get('/profile/:userId', auth, async (req, res) => {
  try {
    const user = await User.findById(req.params.userId)
      .select('-password -emailOTP -otpExpiry -blockedUsers -reportedUsers');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.isBanned) {
      return res.status(403).json({ message: 'This user account is banned' });
    }

    // Return public profile information
    res.json({
      _id: user._id,
      email: user.email,
      profile: user.profile,
      customerRating: user.customerRating,
      serviceProviderRating: user.serviceProviderRating,
      isActive: user.isActive,
      createdAt: user.createdAt
    });
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Block a user
router.post('/block/:userId', auth, async (req, res) => {
  try {
    const userIdToBlock = req.params.userId;
    
    // Check if user is trying to block themselves
    if (userIdToBlock === req.user._id.toString()) {
      return res.status(400).json({ message: 'You cannot block yourself' });
    }

    // Check if the user to block exists
    const userToBlock = await User.findById(userIdToBlock);
    if (!userToBlock) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Get current user
    const currentUser = await User.findById(req.user._id);
    
    // Check if already blocked
    if (currentUser.blockedUsers.includes(userIdToBlock)) {
      return res.status(400).json({ message: 'User is already blocked' });
    }

    // Add to blocked users
    currentUser.blockedUsers.push(userIdToBlock);
    await currentUser.save();

    console.log(`User ${currentUser.email} blocked user ${userToBlock.email}`);

    res.json({
      message: 'User blocked successfully',
      blockedUserId: userIdToBlock
    });
  } catch (error) {
    console.error('Block user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Unblock a user
router.delete('/block/:userId', auth, async (req, res) => {
  try {
    const userIdToUnblock = req.params.userId;
    
    // Get current user
    const currentUser = await User.findById(req.user._id);
    
    // Check if user is blocked
    if (!currentUser.blockedUsers.includes(userIdToUnblock)) {
      return res.status(400).json({ message: 'User is not blocked' });
    }

    // Remove from blocked users
    currentUser.blockedUsers = currentUser.blockedUsers.filter(
      id => id.toString() !== userIdToUnblock
    );
    await currentUser.save();

    console.log(`User ${currentUser.email} unblocked user ${userIdToUnblock}`);

    res.json({
      message: 'User unblocked successfully',
      unblockedUserId: userIdToUnblock
    });
  } catch (error) {
    console.error('Unblock user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get blocked users list
router.get('/blocked', auth, async (req, res) => {
  try {
    const currentUser = await User.findById(req.user._id)
      .populate('blockedUsers', 'profile.name profile.userType email customerRating serviceProviderRating');
    
    res.json({
      blockedUsers: currentUser.blockedUsers
    });
  } catch (error) {
    console.error('Get blocked users error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;