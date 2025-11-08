const express = require('express');
const { body, validationResult } = require('express-validator');
const Report = require('../models/Report');
const auth = require('../middleware/auth');

const router = express.Router();

// Create a report
router.post('/', auth, [
  body('reportedUserId').notEmpty(),
  body('reportType').isIn(['inappropriate_behavior', 'fraud', 'poor_service', 'harassment', 'fake_profile', 'other']),
  body('description').notEmpty().trim().isLength({ max: 1000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      reportedUserId,
      reportType,
      description,
      relatedBooking,
      relatedService
    } = req.body;

    // Check if user is trying to report themselves
    if (reportedUserId === req.user._id.toString()) {
      return res.status(400).json({ message: 'You cannot report yourself' });
    }

    // Check if user has already reported this user for the same booking/service
    if (relatedBooking) {
      const existingReport = await Report.findOne({
        reportedBy: req.user._id,
        reportedUser: reportedUserId,
        relatedBooking
      });

      if (existingReport) {
        return res.status(400).json({ message: 'You have already reported this user for this booking' });
      }
    }

    const report = new Report({
      reportedBy: req.user._id,
      reportedUser: reportedUserId,
      reportType,
      description,
      relatedBooking,
      relatedService
    });

    await report.save();
    await report.populate([
      { path: 'reportedUser', select: 'profile.name email' },
      { path: 'relatedBooking' },
      { path: 'relatedService', select: 'serviceName' }
    ]);

    res.status(201).json({
      message: 'Report submitted successfully',
      report
    });
  } catch (error) {
    console.error('Create report error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get user's reports
router.get('/my-reports', auth, async (req, res) => {
  try {
    const reports = await Report.find({ reportedBy: req.user._id })
      .populate('reportedUser', 'profile.name email')
      .populate('relatedBooking')
      .populate('relatedService', 'serviceName')
      .sort({ createdAt: -1 });

    res.json(reports);
  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
