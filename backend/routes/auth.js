const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const auth = require('../middleware/auth');
const emailService = require('../services/emailService');

const router = express.Router();

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

// Send OTP for signup
router.post('/send-otp', async (req, res) => {
  try {
    const { email } = req.body;

    // Validation
    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    // Check if user already exists and is verified
    const existingUser = await User.findOne({ email });
    if (existingUser && existingUser.isEmailVerified) {
      return res.status(400).json({ message: 'User already exists with this email' });
    }

    // Generate OTP
    const otp = emailService.generateOTP();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // If user exists but not verified, update OTP
    if (existingUser && !existingUser.isEmailVerified) {
      existingUser.emailOTP = otp;
      existingUser.otpExpiry = otpExpiry;
      await existingUser.save();
    } else {
      // Create temporary user record for OTP
      const tempUser = new User({
        email,
        password: 'temp', // Will be updated during verification
        emailOTP: otp,
        otpExpiry: otpExpiry,
        isEmailVerified: false
      });
      await tempUser.save();
    }

    // Send OTP email
    await emailService.sendOTPEmail(email, otp);

    console.log('OTP sent successfully to:', email);

    res.json({
      message: 'Verification code sent to your email',
      email: email
    });
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ message: 'Failed to send verification code' });
  }
});

// Verify OTP and complete signup
router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp, password } = req.body;

    // Validation
    if (!email || !otp || !password) {
      return res.status(400).json({ message: 'Email, OTP, and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters' });
    }

    // Find user with email and OTP
    const user = await User.findOne({ 
      email, 
      emailOTP: otp,
      otpExpiry: { $gt: new Date() }
    });

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired verification code' });
    }

    // Update user with password and verify email
    user.password = password;
    user.isEmailVerified = true;
    user.emailOTP = null;
    user.otpExpiry = null;
    await user.save();

    // Generate token
    const token = generateToken(user._id);

    // Send welcome email
    try {
      await emailService.sendWelcomeEmail(email, 'User');
    } catch (emailError) {
      console.error('Welcome email failed:', emailError);
      // Continue even if welcome email fails
    }

    console.log('User verified and created successfully:', user.email);

    res.status(201).json({
      message: 'Account created successfully',
      token,
      user: user.toJSON()
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ message: 'Server error during verification' });
  }
});

// Resend OTP
router.post('/resend-otp', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    // Find unverified user
    const user = await User.findOne({ 
      email, 
      isEmailVerified: false 
    });

    if (!user) {
      return res.status(400).json({ message: 'No pending verification found for this email' });
    }

    // Generate new OTP
    const otp = emailService.generateOTP();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    user.emailOTP = otp;
    user.otpExpiry = otpExpiry;
    await user.save();

    // Send OTP email
    await emailService.sendOTPEmail(email, otp);

    console.log('OTP resent successfully to:', email);

    res.json({
      message: 'New verification code sent to your email'
    });
  } catch (error) {
    console.error('Resend OTP error:', error);
    res.status(500).json({ message: 'Failed to resend verification code' });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid email or password' });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid email or password' });
    }

    // Check if user is active and email is verified
    if (!user.isActive) {
      return res.status(400).json({ message: 'Account is deactivated' });
    }

    if (!user.isEmailVerified) {
      return res.status(400).json({ message: 'Please verify your email before logging in' });
    }

    // Generate token
    const token = generateToken(user._id);

    console.log('User logged in successfully:', user.email);

    res.json({
      message: 'Login successful',
      token,
      user: user.toJSON()
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error during login' });
  }
});

// Get current user
router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(user.toJSON());
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;