const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  reportedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  reportedUser: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  reportType: {
    type: String,
    enum: ['inappropriate_behavior', 'fraud', 'poor_service', 'harassment', 'fake_profile', 'other'],
    required: true
  },
  description: {
    type: String,
    required: true,
    trim: true,
    maxlength: 1000
  },
  relatedBooking: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking',
    default: null
  },
  relatedService: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
    default: null
  },
  status: {
    type: String,
    enum: ['pending', 'under_review', 'resolved', 'dismissed'],
    default: 'pending'
  },
  adminNotes: {
    type: String,
    default: ''
  },
  resolvedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Admin',
    default: null
  },
  resolvedAt: {
    type: Date,
    default: null
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Report', reportSchema);
