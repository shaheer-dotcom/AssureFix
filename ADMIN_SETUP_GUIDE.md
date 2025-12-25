# AssureFix Admin Portal Setup Guide

## 🎯 Overview

This guide will help you set up the complete AssureFix application with:
1. **Admin Portal** - Full admin dashboard with user management
2. **Real Email OTP Verification** - Gmail SMTP integration
3. **Fixed Messaging System** - WhatsApp-style conversations
4. **Fixed Booking Management** - Complete booking tracking
5. **Report System** - User reporting and moderation

---

## 📋 Prerequisites

- Node.js (v16+)
- MongoDB (local or cloud)
- Flutter SDK (3.0+)
- Gmail account for sending emails

---

## 🔧 Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the `backend` directory:

```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/servicehub
JWT_SECRET=your_super_secret_jwt_key_here_change_this

# Email Configuration (Gmail)
EMAIL_USER=shaheer13113@gmail.com
EMAIL_PASS=your_gmail_app_password_here

# Admin Configuration
PRIMARY_ADMIN_EMAIL=shaheer13113@gmail.com

# Frontend URL
FRONTEND_URL=http://localhost:8082
```

### 3. Set Up Gmail App Password

**Important:** You need to create a Gmail App Password (not your regular password):

1. Go to your Google Account: https://myaccount.google.com/
2. Select **Security**
3. Under "Signing in to Google," select **2-Step Verification** (enable if not already)
4. At the bottom, select **App passwords**
5. Select **Mail** and **Other (Custom name)**
6. Name it "AssureFix" and click **Generate**
7. Copy the 16-character password
8. Paste it in your `.env` file as `EMAIL_PASS`

### 4. Start the Backend Server

```bash
npm start
```

The server will run on `http://localhost:5000`

---

## 📱 Frontend Setup

### 1. Install Dependencies

```bash
cd frontend
flutter pub get
```

### 2. Run the Flutter App

```bash
flutter run -d chrome --web-port=8082
```

The app will run on `http://localhost:8082`

---

## 👨‍💼 Admin Portal Access

### 1. Access Admin Portal

The admin portal is accessible through a separate admin login endpoint.

**Admin Login URL:** `http://localhost:5000/api/admin/login`

### 2. First Time Admin Login

On first login with your primary admin email (`shaheer13113@gmail.com`), the system will automatically create your admin account.

**API Request:**
```bash
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email": "shaheer13113@gmail.com"}'
```

**Response:**
```json
{
  "message": "Admin login successful",
  "token": "your_admin_jwt_token",
  "admin": {
    "email": "shaheer13113@gmail.com",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### 3. Admin Features

Once logged in as admin, you can:

#### **Dashboard Statistics**
```bash
GET /api/admin/dashboard/stats
Authorization: Bearer {admin_token}
```

Returns:
- Total users
- Total customers
- Total service providers
- Total services
- Total bookings
- Pending reports
- Banned users

#### **View All Users**
```bash
GET /api/admin/users?page=1&limit=20&userType=customer&search=john
Authorization: Bearer {admin_token}
```

#### **View User Details**
```bash
GET /api/admin/users/{userId}
Authorization: Bearer {admin_token}
```

Returns complete user profile with:
- User information
- All services posted
- Bookings as customer
- Bookings as provider
- Reports made by user
- Reports against user

#### **Ban a User**
```bash
POST /api/admin/users/{userId}/ban
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "reason": "Fraudulent activity"
}
```

This will:
- Ban the user account
- Add email, phone, and CNIC to banned list
- Prevent future registrations with these credentials

#### **Unban a User**
```bash
POST /api/admin/users/{userId}/unban
Authorization: Bearer {admin_token}
```

#### **View All Reports**
```bash
GET /api/admin/reports?status=pending&page=1&limit=20
Authorization: Bearer {admin_token}
```

#### **Update Report Status**
```bash
PATCH /api/admin/reports/{reportId}
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "status": "resolved",
  "adminNotes": "Issue resolved after investigation"
}
```

#### **Add New Admin**
```bash
POST /api/admin/add-admin
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "email": "newadmin@example.com"
}
```

---

## 📧 Email OTP Verification

### How It Works

1. User enters email during registration
2. System sends 6-digit OTP to email
3. OTP expires in 10 minutes
4. User enters OTP to verify and complete registration

### Testing Email OTP

1. **Register a new user:**
```bash
POST /api/auth/send-otp
Content-Type: application/json

{
  "email": "test@example.com"
}
```

2. **Check your email** for the OTP code

3. **Verify OTP:**
```bash
POST /api/auth/verify-otp
Content-Type: application/json

{
  "email": "test@example.com",
  "otp": "123456",
  "password": "password123"
}
```

4. **Resend OTP if needed:**
```bash
POST /api/auth/resend-otp
Content-Type: application/json

{
  "email": "test@example.com"
}
```

---

## 💬 Messaging System

### Features

- WhatsApp-style conversation list
- Real-time message updates
- Unread message counts
- Last message preview
- Time ago format (e.g., "2 hours ago")

### How It Works

1. **Conversations are created** when users book services or start chats
2. **Messages are stored** in the database with timestamps
3. **Conversations list** shows all active chats sorted by last message
4. **Click on conversation** to open chat screen

### Testing Messaging

1. Book a service as a customer
2. Go to Messages screen
3. You'll see the conversation with the service provider
4. Click to open and send messages

---

## 📅 Booking Management

### Features

- View all bookings (as customer and provider)
- Filter by status: Pending, Confirmed, In Progress, Completed
- Cancel bookings (with 3-hour rule)
- Update booking status

### Booking Statuses

- **Pending**: Newly created booking
- **Confirmed**: Provider confirmed the booking
- **In Progress**: Service is being provided
- **Completed**: Service completed
- **Cancelled**: Booking cancelled by customer or provider

### Testing Bookings

1. Search for a service
2. Book the service with date/time
3. Go to "Manage Bookings"
4. View booking in "Pending" tab
5. Provider can confirm/reject
6. Track status changes

---

## 🚨 Report System

### User Reporting

Users can report other users for:
- Inappropriate behavior
- Fraud
- Poor service
- Harassment
- Fake profile
- Other

### Report Flow

1. **User submits report** with description
2. **Report appears in admin dashboard** as "Pending"
3. **Admin reviews** and updates status
4. **Admin can ban user** if necessary
5. **Report marked as resolved/dismissed**

### Testing Reports

**As User:**
```bash
POST /api/reports
Authorization: Bearer {user_token}
Content-Type: application/json

{
  "reportedUserId": "user_id_to_report",
  "reportType": "fraud",
  "description": "This user is scamming customers",
  "relatedBooking": "booking_id_optional"
}
```

**As Admin:**
```bash
GET /api/admin/reports?status=pending
Authorization: Bearer {admin_token}
```

---

## 🔒 Security Features

### Banned Credentials

When a user is banned:
- Email is blacklisted
- Phone number is blacklisted
- CNIC is blacklisted

Future registration attempts with these credentials will be rejected.

### Check Banned Credentials

```bash
POST /api/admin/check-banned
Content-Type: application/json

{
  "email": "test@example.com",
  "phoneNumber": "+1234567890",
  "cnic": "12345-1234567-1"
}
```

---

## 🎨 Admin Portal UI (Coming Soon)

A Flutter web admin dashboard is recommended for easier management. For now, use API endpoints with tools like:

- **Postman** - API testing
- **Insomnia** - API client
- **cURL** - Command line
- **Custom admin panel** - Build with Flutter/React

---

## 📊 Database Collections

### Users
- User accounts with profiles
- Customer and service provider types
- Ban status and reasons

### Services
- Service listings
- Provider information
- Pricing and availability

### Bookings
- Customer bookings
- Provider bookings
- Status tracking

### Chats
- Conversations between users
- Messages with timestamps
- Read status

### Reports
- User reports
- Admin notes
- Resolution status

### BannedCredentials
- Blacklisted emails
- Blacklisted phone numbers
- Blacklisted CNICs

### Admins
- Admin accounts
- Added by tracking

---

## 🐛 Troubleshooting

### Email Not Sending

1. Check Gmail App Password is correct
2. Verify 2-Step Verification is enabled
3. Check console logs for email errors
4. Test with a different email service if needed

### Bookings Not Showing

1. Ensure user is logged in
2. Check API token is valid
3. Verify bookings exist in database
4. Check console for API errors

### Messages Not Loading

1. Refresh the messages screen
2. Check network connection
3. Verify chat exists in database
4. Check API endpoint is accessible

### Admin Login Failed

1. Verify PRIMARY_ADMIN_EMAIL in .env
2. Check JWT_SECRET is set
3. Ensure MongoDB is running
4. Check server logs for errors

---

## 📞 Support

For issues or questions:
- Check server logs: `backend/` console
- Check Flutter logs: Flutter console
- Review API responses in browser DevTools
- Contact: shaheer13113@gmail.com

---

## ✅ Checklist

- [ ] MongoDB running
- [ ] Backend .env configured
- [ ] Gmail App Password set up
- [ ] Backend server started
- [ ] Flutter dependencies installed
- [ ] Flutter app running
- [ ] Admin login tested
- [ ] Email OTP tested
- [ ] Messaging tested
- [ ] Bookings tested
- [ ] Reports tested

---

**🎉 Your AssureFix application is now fully configured with admin portal, real email verification, fixed messaging, and complete booking management!**
