const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('../models/User');
const Service = require('../models/Service');
const Booking = require('../models/Booking');
const Report = require('../models/Report');
const Rating = require('../models/Rating');
const Admin = require('../models/Admin');

async function viewDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/servicehub');
    console.log('✅ Connected to MongoDB\n');

    // Get counts
    const userCount = await User.countDocuments();
    const serviceCount = await Service.countDocuments();
    const bookingCount = await Booking.countDocuments();
    const reportCount = await Report.countDocuments();
    const ratingCount = await Rating.countDocuments();
    const adminCount = await Admin.countDocuments();

    console.log('📊 DATABASE OVERVIEW');
    console.log('='.repeat(50));
    console.log(`Users:     ${userCount}`);
    console.log(`Services:  ${serviceCount}`);
    console.log(`Bookings:  ${bookingCount}`);
    console.log(`Reports:   ${reportCount}`);
    console.log(`Ratings:   ${ratingCount}`);
    console.log(`Admins:    ${adminCount}`);
    console.log('='.repeat(50));
    console.log();

    // Show Users
    console.log('👥 USERS');
    console.log('='.repeat(50));
    const users = await User.find().select('-password -emailOTP -otpExpiry');
    users.forEach((user, index) => {
      console.log(`\n${index + 1}. ${user.profile?.name || 'No Name'}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Type: ${user.profile?.userType || 'N/A'}`);
      console.log(`   Phone: ${user.profile?.phoneNumber || 'N/A'}`);
      console.log(`   Verified: ${user.isEmailVerified ? 'Yes' : 'No'}`);
      console.log(`   Banned: ${user.isBanned ? 'Yes' : 'No'}`);
      console.log(`   Customer Rating: ${user.customerRating?.average || 0} (${user.customerRating?.count || 0} reviews)`);
      if (user.profile?.userType === 'service_provider') {
        console.log(`   Provider Rating: ${user.serviceProviderRating?.average || 0} (${user.serviceProviderRating?.count || 0} reviews)`);
      }
    });
    console.log('\n' + '='.repeat(50));
    console.log();

    // Show Services
    console.log('🔧 SERVICES');
    console.log('='.repeat(50));
    const services = await Service.find().populate('providerId', 'profile.name email');
    services.forEach((service, index) => {
      console.log(`\n${index + 1}. ${service.serviceName}`);
      console.log(`   Provider: ${service.providerId?.profile?.name || 'Unknown'}`);
      console.log(`   Category: ${service.category}`);
      console.log(`   Price: $${service.price}`);
      console.log(`   Area: ${service.area}`);
      console.log(`   Active: ${service.isActive ? 'Yes' : 'No'}`);
    });
    console.log('\n' + '='.repeat(50));
    console.log();

    // Show Bookings
    console.log('📅 BOOKINGS');
    console.log('='.repeat(50));
    const bookings = await Booking.find()
      .populate('customerId', 'profile.name email')
      .populate('providerId', 'profile.name email')
      .populate('serviceId', 'serviceName');
    bookings.forEach((booking, index) => {
      console.log(`\n${index + 1}. Booking #${booking._id.toString().slice(-6)}`);
      console.log(`   Service: ${booking.serviceId?.serviceName || 'Unknown'}`);
      console.log(`   Customer: ${booking.customerId?.profile?.name || 'Unknown'}`);
      console.log(`   Provider: ${booking.providerId?.profile?.name || 'Unknown'}`);
      console.log(`   Status: ${booking.status}`);
      console.log(`   Amount: $${booking.totalAmount}`);
      console.log(`   Date: ${new Date(booking.reservationDate).toLocaleDateString()}`);
    });
    console.log('\n' + '='.repeat(50));
    console.log();

    // Show Reports
    console.log('📝 REPORTS');
    console.log('='.repeat(50));
    const reports = await Report.find()
      .populate('reportedBy', 'profile.name email')
      .populate('reportedUser', 'profile.name email');
    if (reports.length === 0) {
      console.log('No reports found');
    } else {
      reports.forEach((report, index) => {
        console.log(`\n${index + 1}. Report #${report._id.toString().slice(-6)}`);
        console.log(`   Type: ${report.reportType}`);
        console.log(`   Reporter: ${report.reportedBy?.profile?.name || 'Unknown'}`);
        console.log(`   Reported User: ${report.reportedUser?.profile?.name || 'Unknown'}`);
        console.log(`   Status: ${report.status}`);
        console.log(`   Description: ${report.description}`);
        console.log(`   Date: ${new Date(report.createdAt).toLocaleDateString()}`);
      });
    }
    console.log('\n' + '='.repeat(50));
    console.log();

    // Show Ratings
    console.log('⭐ RATINGS');
    console.log('='.repeat(50));
    const ratings = await Rating.find()
      .populate('ratedBy', 'profile.name')
      .populate('ratedUser', 'profile.name');
    if (ratings.length === 0) {
      console.log('No ratings found');
    } else {
      ratings.forEach((rating, index) => {
        console.log(`\n${index + 1}. Rating #${rating._id.toString().slice(-6)}`);
        console.log(`   From: ${rating.ratedBy?.profile?.name || 'Unknown'}`);
        console.log(`   To: ${rating.ratedUser?.profile?.name || 'Unknown'}`);
        console.log(`   Type: ${rating.ratingType}`);
        console.log(`   Stars: ${rating.rating}/5`);
        console.log(`   Comment: ${rating.comment || 'No comment'}`);
      });
    }
    console.log('\n' + '='.repeat(50));
    console.log();

    // Show Admins
    console.log('👨‍💼 ADMINS');
    console.log('='.repeat(50));
    const admins = await Admin.find();
    admins.forEach((admin, index) => {
      console.log(`${index + 1}. ${admin.email}`);
      console.log(`   Active: ${admin.isActive ? 'Yes' : 'No'}`);
      console.log(`   Created: ${new Date(admin.createdAt).toLocaleDateString()}`);
    });
    console.log('\n' + '='.repeat(50));

    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    await mongoose.connection.close();
    process.exit(1);
  }
}

viewDatabase();
