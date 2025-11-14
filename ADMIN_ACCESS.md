# Admin Panel Access Guide

## 🎯 Quick Access - In-App Admin Panel

**The easiest way to test the admin panel is directly in the app!**

### Steps to Access:

1. **Open the AssureFix app** on your device/emulator
2. **Navigate to the Profile tab** (bottom navigation bar)
3. **Scroll to the bottom** - you'll see a green "Admin Panel Access" button
4. **Tap the button** to open the admin login screen
5. **Enter the admin email** (pre-filled: `shaheer13113@gmail.com`)
6. **Tap "Login as Admin"**

You'll be taken to the Admin Dashboard with full access to:
- 📊 Platform statistics
- 👥 User management
- 📝 Reports management

---

## 🔐 Admin Credentials

**Admin Email:** `shaheer13113@gmail.com`

---

## 📱 Admin Panel Features

### Dashboard
- **Total Users** - View all registered users
- **Customers & Providers** - Breakdown by user type
- **Services** - Total services posted
- **Bookings** - All bookings on the platform
- **Pending Reports** - Reports awaiting review
- **Banned Users** - Currently banned accounts

### User Management
- View all users with search functionality
- Filter by user type (customer/provider)
- Filter by ban status (active/banned)
- Ban users with reason
- Unban users
- View detailed user profiles

### Reports Management
- View all user reports
- Filter by status (pending, under review, resolved, dismissed)
- Update report status
- View report details and descriptions
- Take action on reports

---

## 🔧 API Access (Alternative Method)

### Admin Login

**Using cURL:**
```bash
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"shaheer13113@gmail.com\"}"
```

**Using Postman:**
- **Method:** POST
- **URL:** `http://localhost:5000/api/admin/login`
- **Headers:** `Content-Type: application/json`
- **Body:**
```json
{
  "email": "shaheer13113@gmail.com"
}
```

**Response:**
```json
{
  "message": "Admin login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "admin": {
    "email": "shaheer13113@gmail.com"
  }
}
```

---

## 📊 Available Admin Endpoints

### Dashboard Statistics
```
GET http://localhost:5000/api/admin/dashboard/stats
Authorization: Bearer YOUR_TOKEN
```

### User Management

**Get All Users:**
```
GET http://localhost:5000/api/admin/users?page=1&limit=10
Authorization: Bearer YOUR_TOKEN
```

Query Parameters:
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 10)
- `search` - Search by name, email, or phone
- `userType` - Filter by 'customer' or 'service_provider'
- `isBanned` - Filter by ban status ('true' or 'false')

**Get User Details:**
```
GET http://localhost:5000/api/admin/users/:userId
Authorization: Bearer YOUR_TOKEN
```

**Ban User:**
```
POST http://localhost:5000/api/admin/users/:userId/ban
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "reason": "Violation of terms of service"
}
```

**Unban User:**
```
POST http://localhost:5000/api/admin/users/:userId/unban
Authorization: Bearer YOUR_TOKEN
```

### Reports Management

**Get All Reports:**
```
GET http://localhost:5000/api/admin/reports?page=1&limit=10
Authorization: Bearer YOUR_TOKEN
```

Query Parameters:
- `page` - Page number
- `limit` - Items per page
- `status` - Filter by status ('pending', 'under_review', 'resolved', 'dismissed')

**Update Report Status:**
```
PATCH http://localhost:5000/api/admin/reports/:reportId/status
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "status": "resolved"
}
```

Valid statuses: `pending`, `under_review`, `resolved`, `dismissed`

---

## 🚀 Testing the Admin Panel

### Method 1: In-App (Recommended)

1. **Start the backend server:**
   ```bash
   cd backend
   npm start
   ```

2. **Run the Flutter app:**
   ```bash
   cd frontend
   flutter run
   ```

3. **Access admin panel:**
   - Open app → Profile tab → "Admin Panel Access" button
   - Login with admin email
   - Explore the dashboard and features

### Method 2: API Testing

1. **Start backend server**
2. **Use Postman/Thunder Client**
3. **Login to get token**
4. **Test endpoints with token**

---

## 🔒 Security Notes

- Admin email is hardcoded in `backend/middleware/adminAuth.js`
- To add more admins, update the `ADMIN_EMAILS` array
- Admin tokens expire after 7 days
- All admin routes are JWT protected

---

## ⚠️ Common Issues

### "Unauthorized access"
- Verify you're using the correct admin email
- Check token validity

### "Connection error" (In-App)
- Ensure backend is running on port 5000
- Android emulator uses `10.0.2.2:5000` for localhost
- iOS simulator may need your computer's IP address

### "Failed to load" errors
- Verify backend server is running
- Check MongoDB connection
- Ensure admin routes are configured

---

## 📞 Support

**Admin Email:** shaheer13113@gmail.com

**Related Documentation:**
- ADMIN_SETUP_GUIDE.md - Complete setup
- QUICK_REFERENCE.md - Quick commands
- IMPLEMENTATION_SUMMARY.md - Technical details

---

**Your admin panel is ready! Access it directly in the app.** 🎉
