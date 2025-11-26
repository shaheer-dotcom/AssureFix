const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');
const emailService = require('../services/emailService');

const router = express.Router();

// Request password change OTP
router.post('/change-password-request', auth, async (req, res) => {
  try {
    const { newPassword } = req.body;

    // Validation
    if (!newPassword) {
      return res.status(400).json({ message: 'New password is required' });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters' });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Generate OTP
    const otp = emailService.generateOTP();
    const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Store OTP and new password temporarily
    user.emailOTP = otp;
    user.otpExpiry = otpExpiry;
    user.pendingPassword = newPassword; // Temporary field to store new password
    await user.save();

    // Send OTP email
    try {
      await emailService.sendOTPEmail(user.email, otp);
      console.log('✅ Password change OTP sent to:', user.email);
    } catch (emailError) {
      console.error('⚠️  Email sending failed:', emailError);
      // Continue even if email fails - OTP is saved
    }

    res.json({
      message: 'Verification code sent to your email',
      email: user.email
    });
  } catch (error) {
    console.error('Password change request error:', error);
    res.status(500).json({ message: 'Failed to process password change request' });
  }
});

// Verify OTP and change password
router.post('/change-password-verify', auth, async (req, res) => {
  try {
    const { otp } = req.body;

    // Validation
    if (!otp) {
      return res.status(400).json({ message: 'OTP is required' });
    }

    // Find user with valid OTP
    const user = await User.findOne({
      _id: req.user._id,
      emailOTP: otp,
      otpExpiry: { $gt: new Date() }
    });

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired verification code' });
    }

    if (!user.pendingPassword) {
      return res.status(400).json({ message: 'No pending password change found' });
    }

    // Update password
    user.password = user.pendingPassword;
    user.emailOTP = null;
    user.otpExpiry = null;
    user.pendingPassword = null;
    await user.save();

    console.log('✅ Password changed successfully for:', user.email);

    res.json({
      message: 'Password changed successfully'
    });
  } catch (error) {
    console.error('Password change verify error:', error);
    res.status(500).json({ message: 'Failed to change password' });
  }
});

// Get FAQs by role (public endpoint)
router.get('/faqs', async (req, res) => {
  try {
    const { role } = req.query;
    
    // Determine user role from query parameter or default to customer
    const userRole = role || 'customer';

    // Define FAQs based on role
    const customerFAQs = [
      {
        id: 1,
        question: 'How do I book a service?',
        answer: 'Search for services using the search screen, select a service provider, review the details, and tap "Book This Service".',
        category: 'Booking'
      },
      {
        id: 2,
        question: 'How do I search for services?',
        answer: 'Use the "Search A service" option from your home screen. Add service name tags and area tags to find relevant services.',
        category: 'Search'
      },
      {
        id: 3,
        question: 'How do I cancel a booking?',
        answer: 'Go to "Manage Bookings", find your booking in the Active tab, and tap "Cancel". Confirm the cancellation.',
        category: 'Booking'
      },
      {
        id: 4,
        question: 'How do I rate a service provider?',
        answer: 'After the service is completed, tap "Completed" on the booking card, then rate the provider with stars and an optional review.',
        category: 'Rating'
      },
      {
        id: 5,
        question: 'How do I contact a service provider?',
        answer: 'On the service detail screen, tap the "Message" button to start a conversation with the provider.',
        category: 'Messaging'
      },
      {
        id: 6,
        question: 'How do I change my password?',
        answer: 'Go to Settings > Change Password. Enter your new password and verify it with the OTP sent to your email.',
        category: 'Account'
      },
      {
        id: 7,
        question: 'How do I report a user?',
        answer: 'Tap "Report and block" from your home screen, select the user, and provide details about the issue.',
        category: 'Safety'
      },
      {
        id: 8,
        question: 'Is my data secure?',
        answer: 'Yes, we use industry-standard encryption and security measures to protect your data. Read our Privacy Policy for more details.',
        category: 'Security'
      }
    ];

    const providerFAQs = [
      {
        id: 1,
        question: 'How do I post a service?',
        answer: 'Go to your home screen, tap "Post a service", fill in the service details including name, description, price, and area tags, then submit.',
        category: 'Services'
      },
      {
        id: 2,
        question: 'How do I manage my bookings?',
        answer: 'Tap "Manage Bookings" from your home screen to view all active, completed, and cancelled bookings.',
        category: 'Booking'
      },
      {
        id: 3,
        question: 'How do I complete a booking?',
        answer: 'Once the service is done, tap "Mark as Completed" on the booking card, then rate the customer.',
        category: 'Booking'
      },
      {
        id: 4,
        question: 'How do I edit my services?',
        answer: 'Go to "Manage Services" from your home screen, find the service you want to edit, and tap the edit icon.',
        category: 'Services'
      },
      {
        id: 5,
        question: 'How do customers find my services?',
        answer: 'Customers can search for services by name and area tags. Make sure to add relevant area tags to your services.',
        category: 'Services'
      },
      {
        id: 6,
        question: 'How do I change my password?',
        answer: 'Go to Settings > Change Password. Enter your new password and verify it with the OTP sent to your email.',
        category: 'Account'
      },
      {
        id: 7,
        question: 'How do I report a user?',
        answer: 'Tap "Report and block" from your home screen, select the user, and provide details about the issue.',
        category: 'Safety'
      },
      {
        id: 8,
        question: 'Is my data secure?',
        answer: 'Yes, we use industry-standard encryption and security measures to protect your data. Read our Privacy Policy for more details.',
        category: 'Security'
      }
    ];

    const faqs = userRole === 'service_provider' ? providerFAQs : customerFAQs;

    res.json({
      role: userRole,
      faqs: faqs
    });
  } catch (error) {
    console.error('Get FAQs error:', error);
    res.status(500).json({ message: 'Failed to fetch FAQs' });
  }
});

module.exports = router;
