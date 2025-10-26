const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Rating schema for both customer and service provider ratings
const ratingSchema = new mongoose.Schema({
  average: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  count: {
    type: Number,
    default: 0
  },
  totalStars: {
    type: Number,
    default: 0
  }
}, { _id: false });

const userProfileSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  phoneNumber: {
    type: String,
    required: true,
    trim: true
  },
  userType: {
    type: String,
    enum: ['customer', 'service_provider'],
    required: true
  },
  cnicDocument: {
    type: String, // File path (optional)
    default: null
  },
  shopDocument: {
    type: String, // File path (optional)
    default: null
  }
}, { _id: false });

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  profile: {
    type: userProfileSchema,
    default: null
  },
  // Separate ratings for different roles
  customerRating: {
    type: ratingSchema,
    default: () => ({ average: 0, count: 0, totalStars: 0 })
  },
  serviceProviderRating: {
    type: ratingSchema,
    default: () => ({ average: 0, count: 0, totalStars: 0 })
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isEmailVerified: {
    type: Boolean,
    default: false
  },
  emailOTP: {
    type: String,
    default: null
  },
  otpExpiry: {
    type: Date,
    default: null
  }
}, {
  timestamps: true
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Remove password from JSON output
userSchema.methods.toJSON = function() {
  const userObject = this.toObject();
  delete userObject.password;
  return userObject;
};

module.exports = mongoose.model('User', userSchema);