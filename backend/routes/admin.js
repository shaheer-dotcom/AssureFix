const express = require('express');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const Admin = require('../models/Admin');
const User = require('../models/User');
const Service = require('../models/Service');
const Booking = require('../models/Booking');
const Report = require('../models/Report');
const BannedCredential = require('../models/BannedCredential');
const adminAuth = require('../middleware/adminAuth');

const router = express.Router();

// Generate admin JWT token
const generateAdminToken = (adminEmail) => {
  return jwt.sign({ adminEmail }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

// Admin login
router.post('/login', [
  body('email').isEmail().normalizeEmail()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email } = req.body;

    // Check if admin exists
    let admin = await Admin.findOne({ email, isActive: true });

    // If no admin exists and this is the primary admin email, create it
    if (!admin && email === process.env.PRIMARY_ADMIN_EMAIL) {
      admin = new Admin({
        email: process.env.PRIMARY_ADMIN_EMAIL,
        isActive: true
      });
      await admin.save();
      console.log('Primary admin created:', email);
    }

    if (!admin) {
      return res.status(403).json({ message: 'Access denied. Not an authorized admin.' });
    }

    const token = generateAdminToken(admin.email);

    res.json({
      message: 'Admin login successful',
      token,
      admin: {
        email: admin.email,
        createdAt: admin.createdAt
      }
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({ message: 'Server error during admin login' });
  }
});

// Add new admin (only existing admins can do this)
router.post('/add-admin', adminAuth, [
  body('email').isEmail().normalizeEmail()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email } = req.body;

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ message: 'Admin already exists with this email' });
    }

    const newAdmin = new Admin({
      email,
      addedBy: req.admin._id,
      isActive: true
    });

    await newAdmin.save();

    res.status(201).json({
      message: 'Admin added successfully',
      admin: {
        email: newAdmin.email,
        createdAt: newAdmin.createdAt
      }
    });
  } catch (error) {
    console.error('Add admin error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all admins
router.get('/admins', adminAuth, async (req, res) => {
  try {
    const admins = await Admin.find()
      .populate('addedBy', 'email')
      .sort({ createdAt: -1 });

    res.json(admins);
  } catch (error) {
    console.error('Get admins error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get dashboard statistics
router.get('/dashboard/stats', adminAuth, async (req, res) => {
  try {
    const [
      totalUsers,
      totalCustomers,
      totalProviders,
      totalServices,
      totalBookings,
      pendingReports,
      bannedUsers
    ] = await Promise.all([
      User.countDocuments({ isEmailVerified: true }),
      User.countDocuments({ 'profile.userType': 'customer', isEmailVerified: true }),
      User.countDocuments({ 'profile.userType': 'service_provider', isEmailVerified: true }),
      Service.countDocuments(),
      Booking.countDocuments(),
      Report.countDocuments({ status: 'pending' }),
      User.countDocuments({ isBanned: true })
    ]);

    res.json({
      totalUsers,
      totalCustomers,
      totalProviders,
      totalServices,
      totalBookings,
      pendingReports,
      bannedUsers
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all users with pagination and filters
router.get('/users', adminAuth, async (req, res) => {
  try {
    let { 
      page = 1, 
      limit = 20, 
      userType, 
      isBanned, 
      search 
    } = req.query;
    
    // Validate and sanitize pagination parameters
    page = Math.max(1, parseInt(page) || 1);
    limit = Math.min(100, Math.max(1, parseInt(limit) || 20)); // Max 100 items per page

    let query = { isEmailVerified: true };

    if (userType) {
      query['profile.userType'] = userType;
    }

    if (isBanned !== undefined) {
      query.isBanned = isBanned === 'true';
    }

    if (search) {
      query.$or = [
        { email: { $regex: search, $options: 'i' } },
        { 'profile.name': { $regex: search, $options: 'i' } },
        { 'profile.phoneNumber': { $regex: search, $options: 'i' } }
      ];
    }

    const users = await User.find(query)
      .select('-password -emailOTP -otpExpiry')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await User.countDocuments(query);

    res.json({
      users,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get user details with services and bookings
router.get('/users/:id', adminAuth, async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
      .select('-password -emailOTP -otpExpiry');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Get user's services if they're a provider
    const services = await Service.find({ providerId: user._id });

    // Get user's bookings (both as customer and provider)
    const bookingsAsCustomer = await Booking.find({ customerId: user._id })
      .populate('serviceId', 'serviceName')
      .populate('providerId', 'profile.name')
      .sort({ createdAt: -1 });

    const bookingsAsProvider = await Booking.find({ providerId: user._id })
      .populate('serviceId', 'serviceName')
      .populate('customerId', 'profile.name')
      .sort({ createdAt: -1 });

    // Get reports related to this user
    const reportsBy = await Report.find({ reportedBy: user._id })
      .populate('reportedUser', 'profile.name email')
      .sort({ createdAt: -1 });

    const reportsAgainst = await Report.find({ reportedUser: user._id })
      .populate('reportedBy', 'profile.name email')
      .sort({ createdAt: -1 });

    res.json({
      user,
      services,
      bookingsAsCustomer,
      bookingsAsProvider,
      reportsBy,
      reportsAgainst
    });
  } catch (error) {
    console.error('Get user details error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all reports
router.get('/reports', adminAuth, async (req, res) => {
  try {
    let { status, page = 1, limit = 20 } = req.query;
    
    // Validate and sanitize pagination parameters
    page = Math.max(1, parseInt(page) || 1);
    limit = Math.min(100, Math.max(1, parseInt(limit) || 20)); // Max 100 items per page

    let query = {};
    if (status) {
      query.status = status;
    }

    const reports = await Report.find(query)
      .populate('reportedBy', 'profile.name email')
      .populate('reportedUser', 'profile.name email')
      .populate('relatedBooking')
      .populate('relatedService', 'serviceName')
      .populate('resolvedBy', 'email')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Report.countDocuments(query);

    res.json({
      reports,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update report status
router.patch('/reports/:id', adminAuth, [
  body('status').isIn(['under_review', 'resolved', 'dismissed']),
  body('adminNotes').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { status, adminNotes } = req.body;

    const report = await Report.findById(req.params.id);
    if (!report) {
      return res.status(404).json({ message: 'Report not found' });
    }

    report.status = status;
    if (adminNotes) {
      report.adminNotes = adminNotes;
    }

    if (status === 'resolved' || status === 'dismissed') {
      report.resolvedBy = req.admin._id;
      report.resolvedAt = new Date();
    }

    await report.save();

    await report.populate([
      { path: 'reportedBy', select: 'profile.name email' },
      { path: 'reportedUser', select: 'profile.name email' },
      { path: 'resolvedBy', select: 'email' }
    ]);

    res.json(report);
  } catch (error) {
    console.error('Update report error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Alternative endpoint for updating report status (for compatibility)
router.patch('/reports/:id/status', adminAuth, [
  body('status').isIn(['under_review', 'resolved', 'dismissed']),
  body('adminNotes').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { status, adminNotes } = req.body;

    const report = await Report.findById(req.params.id);
    if (!report) {
      return res.status(404).json({ message: 'Report not found' });
    }

    report.status = status;
    if (adminNotes) {
      report.adminNotes = adminNotes;
    }

    if (status === 'resolved' || status === 'dismissed') {
      report.resolvedBy = req.admin._id;
      report.resolvedAt = new Date();
    }

    await report.save();

    await report.populate([
      { path: 'reportedBy', select: 'profile.name email' },
      { path: 'reportedUser', select: 'profile.name email' },
      { path: 'resolvedBy', select: 'email' }
    ]);

    res.json(report);
  } catch (error) {
    console.error('Update report error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Ban user
router.post('/users/:id/ban', adminAuth, [
  body('reason').notEmpty().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { reason } = req.body;

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.isBanned) {
      return res.status(400).json({ message: 'User is already banned' });
    }

    // Ban the user
    user.isBanned = true;
    user.isActive = false;
    user.banReason = reason;
    user.bannedAt = new Date();
    await user.save();

    // Add credentials to banned list
    const bannedCredentials = [];

    // Ban email
    if (user.email) {
      bannedCredentials.push({
        email: user.email,
        bannedUserId: user._id,
        reason,
        bannedBy: req.admin._id
      });
    }

    // Ban phone number
    if (user.profile?.phoneNumber) {
      bannedCredentials.push({
        phoneNumber: user.profile.phoneNumber,
        bannedUserId: user._id,
        reason,
        bannedBy: req.admin._id
      });
    }

    // Ban CNIC
    if (user.profile?.cnic) {
      bannedCredentials.push({
        cnic: user.profile.cnic,
        bannedUserId: user._id,
        reason,
        bannedBy: req.admin._id
      });
    }

    if (bannedCredentials.length > 0) {
      await BannedCredential.insertMany(bannedCredentials);
    }

    res.json({
      message: 'User banned successfully',
      user: {
        _id: user._id,
        email: user.email,
        isBanned: user.isBanned,
        banReason: user.banReason,
        bannedAt: user.bannedAt
      }
    });
  } catch (error) {
    console.error('Ban user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Unban user
router.post('/users/:id/unban', adminAuth, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (!user.isBanned) {
      return res.status(400).json({ message: 'User is not banned' });
    }

    // Unban the user
    user.isBanned = false;
    user.isActive = true;
    user.banReason = null;
    user.bannedAt = null;
    await user.save();

    // Remove from banned credentials
    await BannedCredential.deleteMany({ bannedUserId: user._id });

    res.json({
      message: 'User unbanned successfully',
      user: {
        _id: user._id,
        email: user.email,
        isBanned: user.isBanned
      }
    });
  } catch (error) {
    console.error('Unban user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Check if credentials are banned (used during registration)
router.post('/check-banned', async (req, res) => {
  try {
    const { email, phoneNumber, cnic } = req.body;

    const bannedChecks = [];

    if (email) {
      bannedChecks.push(BannedCredential.findOne({ email }));
    }
    if (phoneNumber) {
      bannedChecks.push(BannedCredential.findOne({ phoneNumber }));
    }
    if (cnic) {
      bannedChecks.push(BannedCredential.findOne({ cnic }));
    }

    const results = await Promise.all(bannedChecks);
    const banned = results.find(result => result !== null);

    if (banned) {
      return res.status(403).json({
        isBanned: true,
        message: 'These credentials have been banned from the platform',
        reason: banned.reason
      });
    }

    res.json({ isBanned: false });
  } catch (error) {
    console.error('Check banned error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
