# AssureFix - Quick Reference Card

## 🚀 Start Commands

### Backend
```bash
cd backend
npm start
```
**Runs on:** http://localhost:5000

### Frontend
```bash
cd frontend
flutter run -d chrome --web-port=8082
```
**Runs on:** http://localhost:8082

---

## 👨‍💼 Admin Access

### Login as Admin
```bash
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email": "shaheer13113@gmail.com"}'
```

**Response:** You'll get an admin token

### Use Admin Token
```bash
curl -X GET http://localhost:5000/api/admin/dashboard/stats \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

## 📧 Email Setup (One-Time)

1. Go to: https://myaccount.google.com/security
2. Enable **2-Step Verification**
3. Go to **App passwords**
4. Create password for "AssureFix"
5. Copy 16-character password
6. Add to `backend/.env`:
```env
EMAIL_USER=shaheer13113@gmail.com
EMAIL_PASS=your_16_char_app_password
```

---

## 🔑 Environment Variables

### Required in `backend/.env`:
```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/servicehub
JWT_SECRET=your_secret_key_change_this
EMAIL_USER=shaheer13113@gmail.com
EMAIL_PASS=your_gmail_app_password
PRIMARY_ADMIN_EMAIL=shaheer13113@gmail.com
FRONTEND_URL=http://localhost:8082
```

---

## 📊 Admin API Endpoints

### Dashboard
```bash
GET /api/admin/dashboard/stats
```
Returns: Total users, bookings, services, reports, banned users

### Users
```bash
GET /api/admin/users?page=1&limit=20&search=john
GET /api/admin/users/:userId
POST /api/admin/users/:userId/ban
POST /api/admin/users/:userId/unban
```

### Reports
```bash
GET /api/admin/reports?status=pending
PATCH /api/admin/reports/:reportId
```

### Admins
```bash
POST /api/admin/add-admin
GET /api/admin/admins
```

---

## 🧪 Testing Checklist

### 1. Test Email OTP
- [ ] Register with real email
- [ ] Check inbox for OTP
- [ ] Verify OTP
- [ ] Receive welcome email

### 2. Test Messaging
- [ ] Book a service
- [ ] Go to Messages screen
- [ ] See conversation
- [ ] Send message
- [ ] See unread count

### 3. Test Bookings
- [ ] Create booking
- [ ] Go to Manage Bookings
- [ ] See in Pending tab
- [ ] Update status
- [ ] Cancel booking

### 4. Test Reports
- [ ] Submit report as user
- [ ] Login as admin
- [ ] View report
- [ ] Update status
- [ ] Add admin notes

### 5. Test Ban System
- [ ] Ban user as admin
- [ ] Try to register with banned email
- [ ] Should be rejected
- [ ] Unban user
- [ ] Can register again

---

## 🐛 Common Issues

### Email Not Sending
**Problem:** OTP emails not arriving
**Solution:**
1. Check Gmail App Password is correct
2. Verify 2-Step Verification enabled
3. Check console logs for errors
4. Try different email to test

### Messages Not Loading
**Problem:** Conversation list empty
**Solution:**
1. Refresh the screen
2. Check API token is valid
3. Verify chats exist in database
4. Check browser console for errors

### Bookings Not Showing
**Problem:** Manage Bookings screen empty
**Solution:**
1. Ensure user is logged in
2. Create a test booking first
3. Check API response in network tab
4. Verify backend is running

### Admin Login Failed
**Problem:** Can't login as admin
**Solution:**
1. Check PRIMARY_ADMIN_EMAIL in .env
2. Verify JWT_SECRET is set
3. Ensure MongoDB is running
4. Check backend console logs

---

## 📱 User Flow

### Customer Journey
1. Register → Verify Email → Complete Profile
2. Search Services → View Details
3. Book Service → Enter Details
4. Chat with Provider
5. Track Booking Status
6. Rate Service

### Provider Journey
1. Register → Verify Email → Complete Profile
2. Post Service → Add Details
3. Receive Bookings
4. Chat with Customers
5. Update Booking Status
6. Get Rated

### Admin Journey
1. Login as Admin
2. View Dashboard Stats
3. Monitor Users & Services
4. Review Reports
5. Ban Bad Actors
6. Resolve Issues

---

## 🔧 Database Quick Access

### MongoDB Shell
```bash
mongosh
use servicehub
```

### View Collections
```javascript
db.users.find().pretty()
db.bookings.find().pretty()
db.chats.find().pretty()
db.reports.find().pretty()
db.admins.find().pretty()
db.bannedcredentials.find().pretty()
```

### Count Documents
```javascript
db.users.countDocuments()
db.bookings.countDocuments()
db.reports.countDocuments({ status: 'pending' })
```

---

## 📞 Quick Support

**Email:** shaheer13113@gmail.com

**Documentation:**
- ADMIN_SETUP_GUIDE.md - Full setup guide
- IMPLEMENTATION_SUMMARY.md - Technical details
- README.md - Project overview

**Logs:**
- Backend: Check terminal running `npm start`
- Frontend: Check Flutter console
- Browser: Check DevTools console (F12)

---

## ✅ Daily Checklist

### Before Starting Work
- [ ] MongoDB running
- [ ] Backend server started
- [ ] Frontend app running
- [ ] Check for errors in console

### After Making Changes
- [ ] Test affected features
- [ ] Check console for errors
- [ ] Commit changes
- [ ] Update documentation if needed

### Before Deployment
- [ ] All tests passing
- [ ] No console errors
- [ ] Environment variables set
- [ ] Database backed up

---

## 🎯 Key Features Status

| Feature | Status | Notes |
|---------|--------|-------|
| Admin Portal | ✅ Complete | Full CRUD operations |
| Email OTP | ✅ Complete | Gmail SMTP configured |
| Messaging | ✅ Fixed | WhatsApp-style UI |
| Bookings | ✅ Fixed | Status-based filtering |
| Reports | ✅ Complete | Admin review system |
| Ban System | ✅ Complete | Credential blacklisting |
| User Auth | ✅ Complete | JWT + Email verify |
| Services | ✅ Complete | Full CRUD |
| Ratings | ✅ Complete | Dual rating system |

---

## 🚀 Production Deployment (Future)

### Backend
- Deploy to Heroku/Railway/DigitalOcean
- Use MongoDB Atlas
- Set environment variables
- Enable HTTPS

### Frontend
- Build: `flutter build web`
- Deploy to Firebase Hosting/Netlify
- Update API URLs
- Enable PWA

### Admin Panel
- Create separate admin web app
- Deploy to subdomain (admin.assurefix.com)
- Restrict access by IP if needed

---

**Keep this file handy for quick reference!** 📌
