const mongoose = require('mongoose');

const bannedCredentialSchema = new mongoose.Schema({
  email: {
    type: String,
    lowercase: true,
    trim: true,
    sparse: true
  },
  phoneNumber: {
    type: String,
    trim: true,
    sparse: true
  },
  cnic: {
    type: String,
    trim: true,
    sparse: true
  },
  bannedUserId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  reason: {
    type: String,
    required: true
  },
  bannedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Admin',
    required: true
  }
}, {
  timestamps: true
});

// Indexes for quick lookup
bannedCredentialSchema.index({ email: 1 });
bannedCredentialSchema.index({ phoneNumber: 1 });
bannedCredentialSchema.index({ cnic: 1 });

module.exports = mongoose.model('BannedCredential', bannedCredentialSchema);
