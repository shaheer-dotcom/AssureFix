const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  messageType: {
    type: String,
    enum: ['text', 'voice', 'location', 'booking_request'],
    default: 'text'
  },
  content: {
    text: String,
    voiceUrl: String,
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
  messages: [messageSchema],
  status: {
    type: String,
    enum: ['pending', 'active', 'closed'],
    default: 'pending'
  },
  lastMessage: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Chat', chatSchema);