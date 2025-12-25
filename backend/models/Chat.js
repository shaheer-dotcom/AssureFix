const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  messageType: {
    type: String,
    enum: ['text', 'voice', 'image', 'location', 'booking_request'],
    default: 'text'
  },
  content: {
    text: String,
    voiceUrl: String,
    imageUrl: String,
    location: {
      latitude: Number,
      longitude: Number,
      address: String
    },
    bookingData: {
      serviceId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Service'
      }
    }
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  isRead: {
    type: Boolean,
    default: false
  },
  deliveredAt: {
    type: Date
  },
  readAt: {
    type: Date
  }
});

const chatSchema = new mongoose.Schema({
  participants: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }],
  serviceId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
    required: true
  },
  bookingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking'
  },
  messages: [messageSchema],
  status: {
    type: String,
    enum: ['pending', 'active', 'closed'],
    default: 'pending'
  },
  lastMessage: {
    type: Date,
    default: Date.now
  },
  closedAt: {
    type: Date
  },
  closedReason: {
    type: String,
    enum: ['completed', 'cancelled']
  }
}, {
  timestamps: true
});

// Add indexes for performance optimization
chatSchema.index({ bookingId: 1 });
chatSchema.index({ participants: 1 });
chatSchema.index({ status: 1 });
chatSchema.index({ lastMessage: -1 });

module.exports = mongoose.model('Chat', chatSchema);