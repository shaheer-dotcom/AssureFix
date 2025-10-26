const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  serviceId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
    required: true
  },
  providerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  customerDetails: {
    name: {
      type: String,
      required: true
    },
    phoneNumber: {
      type: String,
      required: true
    },
    exactAddress: {
      type: String,
      required: true
    }
  },
  reservationDate: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'],
    default: 'pending'
  },
  totalAmount: {
    type: Number,
    required: true
  },
  hoursBooked: {
    type: Number,
    required: true,
    default: 1
  },
  cancellationReason: String,
  cancelledBy: {
    type: String,
    enum: ['customer', 'provider']
  },
  canCancel: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Middleware to check if booking can be cancelled (3 hours before reservation)
bookingSchema.pre('save', function (next) {
  const now = new Date();
  const reservationTime = new Date(this.reservationDate);
  const timeDiff = reservationTime.getTime() - now.getTime();
  const hoursDiff = timeDiff / (1000 * 3600);

  this.canCancel = hoursDiff > 3;
  next();
});

module.exports = mongoose.model('Booking', bookingSchema);