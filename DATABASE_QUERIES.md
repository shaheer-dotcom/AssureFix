# Database Queries Reference

## 📊 Database Schema Overview

### Collections:
1. **users** - User accounts and profiles
2. **services** - Services posted by providers
3. **bookings** - Service bookings
4. **reports** - User reports
5. **ratings** - User ratings and reviews
6. **admins** - Admin accounts
7. **bannedcredentials** - Blacklisted credentials
8. **chats** - Chat conversations
9. **messages** - Chat messages

---

## 🔍 Common Queries

### User Queries

#### Get All Users
```javascript
User.find({ isEmailVerified: true })
  .select('-password -emailOTP -otpExpiry')
  .sort({ createdAt: -1 })
```

#### Get User by Email
```javascript
User.findOne({ email: 'user@example.com' })
```

#### Get User with Profile
```javascript
User.findById(userId)
  .select('-password -emailOTP -otpExpiry')
```

#### Count Users by Type
```javascript
// Total users
User.countDocuments({ isEmailVerified: true })

// Customers
User.countDocuments({ 
  'profile.userType': 'customer', 
  isEmailVerified: true 
})

// Providers
User.countDocuments({ 
  'profile.userType': 'service_provider', 
  isEmailVerified: true 
})

// Banned users
User.countDocuments({ isBanned: true })
```

#### Search Users
```javascript
User.find({
  isEmailVerified: true,
  $or: [
    { email: { $regex: searchTerm, $options: 'i' } },
    { 'profile.name': { $regex: searchTerm, $options: 'i' } },
    { 'profile.phoneNumber': { $regex: searchTerm, $options: 'i' } }
  ]
})
```

#### Ban User
```javascript
// Update user
User.findByIdAndUpdate(userId, {
  isBanned: true,
  isActive: false,
  banReason: reason,
  bannedAt: new Date()
})

// Add to banned credentials
BannedCredential.insertMany([
  { email: user.email, bannedUserId: userId, reason },
  { phoneNumber: user.profile.phoneNumber, bannedUserId: userId, reason },
  { cnic: user.profile.cnic, bannedUserId: userId, reason }
])
```

---

### Service Queries

#### Get All Services
```javascript
Service.find()
  .populate('providerId', 'profile.name email')
  .sort({ createdAt: -1 })
```

#### Get Services by Provider
```javascript
Service.find({ providerId: userId })
  .sort({ createdAt: -1 })
```

#### Search Services
```javascript
Service.find({
  $or: [
    { serviceName: { $regex: searchTerm, $options: 'i' } },
    { description: { $regex: searchTerm, $options: 'i' } }
  ],
  category: categoryFilter, // optional
  area: locationFilter, // optional
  isActive: true
})
```

#### Count Services
```javascript
Service.countDocuments()
```

---

### Booking Queries

#### Get All Bookings
```javascript
Booking.find()
  .populate('customerId', 'profile.name email')
  .populate('providerId', 'profile.name email')
  .populate('serviceId', 'serviceName')
  .sort({ createdAt: -1 })
```

#### Get User's Bookings as Customer
```javascript
Booking.find({ customerId: userId })
  .populate('serviceId', 'serviceName')
  .populate('providerId', 'profile.name')
  .sort({ createdAt: -1 })
```

#### Get User's Bookings as Provider
```javascript
Booking.find({ providerId: userId })
  .populate('serviceId', 'serviceName')
  .populate('customerId', 'profile.name')
  .sort({ createdAt: -1 })
```

#### Count Bookings
```javascript
Booking.countDocuments()
```

#### Count Bookings by Status
```javascript
Booking.countDocuments({ status: 'pending' })
Booking.countDocuments({ status: 'confirmed' })
Booking.countDocuments({ status: 'completed' })
```

---

### Report Queries

#### Get All Reports
```javascript
Report.find()
  .populate('reportedBy', 'profile.name email')
  .populate('reportedUser', 'profile.name email')
  .populate('relatedBooking')
  .populate('relatedService', 'serviceName')
  .sort({ createdAt: -1 })
```

#### Get Reports by Status
```javascript
Report.find({ status: 'pending' })
  .populate('reportedBy', 'profile.name email')
  .populate('reportedUser', 'profile.name email')
```

#### Get Reports Made by User
```javascript
Report.find({ reportedBy: userId })
  .populate('reportedUser', 'profile.name email')
  .sort({ createdAt: -1 })
```

#### Get Reports Against User
```javascript
Report.find({ reportedUser: userId })
  .populate('reportedBy', 'profile.name email')
  .sort({ createdAt: -1 })
```

#### Count Pending Reports
```javascript
Report.countDocuments({ status: 'pending' })
```

#### Update Report Status
```javascript
Report.findByIdAndUpdate(reportId, {
  status: 'resolved', // or 'under_review', 'dismissed'
  resolvedBy: adminId,
  resolvedAt: new Date(),
  adminNotes: 'Notes here'
})
```

---

### Rating Queries

#### Get User's Ratings
```javascript
// As customer
Rating.find({ 
  ratedUser: userId,
  ratingType: 'customer_rating'
})

// As provider
Rating.find({ 
  ratedUser: userId,
  ratingType: 'service_provider_rating'
})
```

#### Get Ratings Given by User
```javascript
Rating.find({ ratedBy: userId })
  .populate('ratedUser', 'profile.name')
  .sort({ createdAt: -1 })
```

#### Calculate Average Rating
```javascript
// This is done automatically in the User model
// customerRating.average and serviceProviderRating.average
```

#### Create Rating
```javascript
const rating = new Rating({
  ratedBy: raterId,
  ratedUser: ratedUserId,
  relatedBooking: bookingId,
  rating: 5,
  comment: 'Great service!',
  ratingType: 'service_provider_rating'
})
await rating.save()

// Update user's rating
await User.findByIdAndUpdate(ratedUserId, {
  $inc: {
    'serviceProviderRating.count': 1,
    'serviceProviderRating.totalStars': 5
  }
})
```

---

### Admin Queries

#### Get Dashboard Stats
```javascript
const stats = await Promise.all([
  User.countDocuments({ isEmailVerified: true }),
  User.countDocuments({ 'profile.userType': 'customer', isEmailVerified: true }),
  User.countDocuments({ 'profile.userType': 'service_provider', isEmailVerified: true }),
  Service.countDocuments(),
  Booking.countDocuments(),
  Report.countDocuments({ status: 'pending' }),
  User.countDocuments({ isBanned: true })
])
```

#### Get User Details for Admin
```javascript
const user = await User.findById(userId).select('-password -emailOTP -otpExpiry')
const services = await Service.find({ providerId: userId })
const bookingsAsCustomer = await Booking.find({ customerId: userId })
  .populate('serviceId', 'serviceName')
  .populate('providerId', 'profile.name')
const bookingsAsProvider = await Booking.find({ providerId: userId })
  .populate('serviceId', 'serviceName')
  .populate('customerId', 'profile.name')
const reportsBy = await Report.find({ reportedBy: userId })
  .populate('reportedUser', 'profile.name email')
const reportsAgainst = await Report.find({ reportedUser: userId })
  .populate('reportedBy', 'profile.name email')
```

---

## 🔧 Advanced Queries

### Aggregation Queries

#### Get Top Rated Providers
```javascript
User.aggregate([
  { $match: { 'profile.userType': 'service_provider' } },
  { $sort: { 'serviceProviderRating.average': -1 } },
  { $limit: 10 }
])
```

#### Get Most Booked Services
```javascript
Booking.aggregate([
  { $group: { 
    _id: '$serviceId', 
    count: { $sum: 1 } 
  }},
  { $sort: { count: -1 } },
  { $limit: 10 },
  { $lookup: {
    from: 'services',
    localField: '_id',
    foreignField: '_id',
    as: 'service'
  }}
])
```

#### Get Revenue by Provider
```javascript
Booking.aggregate([
  { $match: { status: 'completed' } },
  { $group: {
    _id: '$providerId',
    totalRevenue: { $sum: '$totalAmount' },
    bookingCount: { $sum: 1 }
  }},
  { $sort: { totalRevenue: -1 } }
])
```

---

## 📝 Query Performance Tips

1. **Use Indexes**
   - Email (unique index)
   - User type
   - Service category
   - Booking status
   - Report status

2. **Use Select to Limit Fields**
   ```javascript
   .select('profile.name email')
   ```

3. **Use Populate Wisely**
   ```javascript
   .populate('userId', 'profile.name email') // Only needed fields
   ```

4. **Use Pagination**
   ```javascript
   .limit(20).skip((page - 1) * 20)
   ```

5. **Use Lean for Read-Only**
   ```javascript
   .lean() // Returns plain JavaScript objects
   ```

---

## 🚀 Running Database Queries

### View Database Contents
```bash
cd backend
node scripts/viewDatabase.js
```

### MongoDB Shell
```bash
mongosh
use servicehub
db.users.find().pretty()
db.services.find().pretty()
db.bookings.find().pretty()
```

### Count Documents
```bash
db.users.countDocuments()
db.services.countDocuments()
db.bookings.countDocuments()
```

---

## 📊 Database Indexes

```javascript
// User indexes
userSchema.index({ email: 1 }, { unique: true })
userSchema.index({ 'profile.userType': 1 })
userSchema.index({ isBanned: 1 })

// Service indexes
serviceSchema.index({ providerId: 1 })
serviceSchema.index({ category: 1 })
serviceSchema.index({ area: 1 })
serviceSchema.index({ isActive: 1 })

// Booking indexes
bookingSchema.index({ customerId: 1 })
bookingSchema.index({ providerId: 1 })
bookingSchema.index({ status: 1 })

// Report indexes
reportSchema.index({ reportedBy: 1 })
reportSchema.index({ reportedUser: 1 })
reportSchema.index({ status: 1 })
```

---

## 🔐 Security Queries

### Check Banned Credentials
```javascript
BannedCredential.findOne({
  $or: [
    { email: userEmail },
    { phoneNumber: userPhone },
    { cnic: userCnic }
  ]
})
```

### Verify Admin
```javascript
Admin.findOne({ 
  email: adminEmail, 
  isActive: true 
})
```

---

This document covers all major database queries used in the AssureFix application.
