const mongoose = require('mongoose');

const callSchema = new mongoose.Schema({
  callerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  receiverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  conversationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Chat'
  },
  status: {
    type: String,
    enum: ['initiated', 'ringing', 'active', 'ended', 'rejected', 'missed'],
    default: 'initiated'
  },
  startTime: {
    type: Date,
    default: Date.now
  },
  endTime: {
    type: Date
  },
  duration: {
    type: Number,
    default: 0
  },
  agoraChannelName: {
    type: String
  },
  agoraToken: {
    type: String
  }
}, {
  timestamps: true
});

// Add indexes for performance optimization
callSchema.index({ callerId: 1 });
callSchema.index({ receiverId: 1 });
callSchema.index({ conversationId: 1 });
callSchema.index({ status: 1 });
callSchema.index({ startTime: -1 });

module.exports = mongoose.model('Call', callSchema);
