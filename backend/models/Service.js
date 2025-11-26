const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema({
  providerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  serviceName: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true,
    trim: true
  },
  category: {
    type: String,
    required: true,
    enum: [
      'Home Services',
      'Beauty & Wellness', 
      'Automotive',
      'Electronics',
      'Education',
      'Health & Fitness',
      'Business Services',
      'Event Services',
      'Cleaning Services',
      'Repair & Maintenance',
      'Delivery Services',
      'Other'
    ]
  },
  areaTags: [{
    type: String,
    required: true,
    trim: true
  }],
  price: {
    type: Number,
    required: true,
    min: 100 // Minimum ₹100
  },
  pricePerHour: {
    type: Number,
    required: true,
    min: 100 // Minimum ₹100 per hour
  },
  priceType: {
    type: String,
    enum: ['fixed', 'hourly'],
    default: 'fixed'
  },
  isActive: {
    type: Boolean,
    default: true
  },
  // Service statistics
  totalBookings: {
    type: Number,
    default: 0
  },
  completedBookings: {
    type: Number,
    default: 0
  },
  // Service images (for future use)
  images: [{
    type: String // File paths
  }],
  // Service tags for better search
  tags: [{
    type: String,
    trim: true
  }]
}, {
  timestamps: true
});

// Index for better search performance
serviceSchema.index({ 
  name: 'text', 
  description: 'text', 
  category: 1
});

serviceSchema.index({ providerId: 1 });
serviceSchema.index({ areaTags: 1 }); // Index for area tag search
serviceSchema.index({ category: 1, areaTags: 1 });
serviceSchema.index({ isActive: 1 });

module.exports = mongoose.model('Service', serviceSchema);