const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema({
  // Who gave the rating
  ratedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  // Who received the rating
  ratedUser: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  // What role was the user being rated for
  ratingType: {
    type: String,
    enum: ['customer', 'service_provider'],
    required: true
  },
  // The actual rating (1-5 stars)
  stars: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  // Optional comment
  comment: {
    type: String,
    trim: true,
    maxlength: 500
  },
  // Related booking/service (optional)
  relatedBooking: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking',
    default: null
  },
  relatedService: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
    default: null
  }
}, {
  timestamps: true
});

// Ensure a user can only rate another user once per booking/service
ratingSchema.index({
  ratedBy: 1,
  ratedUser: 1,
  ratingType: 1,
  relatedBooking: 1
}, {
  unique: true,
  sparse: true
});

// Method to update user's average rating
ratingSchema.statics.updateUserRating = async function (userId, ratingType) {
  const User = mongoose.model('User');

  // Calculate new average rating
  const ratings = await this.find({
    ratedUser: userId,
    ratingType: ratingType
  });

  if (ratings.length === 0) {
    return;
  }

  const totalStars = ratings.reduce((sum, rating) => sum + rating.stars, 0);
  const average = totalStars / ratings.length;
  const count = ratings.length;

  // Update user's rating based on type
  const updateField = ratingType === 'customer' ? 'customerRating' : 'serviceProviderRating';

  await User.findByIdAndUpdate(userId, {
    [updateField]: {
      average: Math.round(average * 10) / 10, // Round to 1 decimal place
      count: count,
      totalStars: totalStars
    }
  });
};

// Post-save hook to update user rating
ratingSchema.post('save', async function () {
  await this.constructor.updateUserRating(this.ratedUser, this.ratingType);
});

// Post-remove hook to update user rating
ratingSchema.post('remove', async function () {
  await this.constructor.updateUserRating(this.ratedUser, this.ratingType);
});

module.exports = mongoose.model('Rating', ratingSchema);