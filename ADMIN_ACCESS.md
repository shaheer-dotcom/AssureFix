# Admin Portal Access Guide

## 🔐 How to Access Admin Portal

The admin portal is currently **API-based**. You can access it using API calls with tools like:
- Postman
- Insomnia
- cURL (command line)
- Or build a custom admin web interface

---

## 📝 Step 1: Admin Login

### Using cURL (Command Line):

```bash
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"shaheer13113@gmail.com\"}"
```

### Using Postman:

1. **Method:** POST
2. **URL:** `http://localhost:5000/api/admin/login`
3. **Headers:** 
   - `Content-Type: application/json`
4. **Body (raw JSON):**
```json
{
  "email": "shaheer13113@gmail.com"
}
```

### Response:
```json
{
  "message": "Admin login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "admin": {
    "email": "shaheer13113@gmail.com",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**Copy the `token` value** - you'll need it for all admin operations!

---

## 📊 Step 2: Use Admin Features

### Get Dashboard Statistics

```bash
curl -X GET http://localhost:5000/api/admin/dashboard/stats \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**Response:**
```json
{
  "totalUsers": 10,
  "totalCustomers": 6,
  "totalProviders": 4,
  "totalServices": 15,
  "totalBookings": 25,
  "pendingReports": 2,
  "bannedUsers": 0
}
```

---

### View All Users

```bash
curl -X GET "http://localhost:5000/api/admin/users?page=1&limit=20" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**With filters:**
```bash
# Search for users
curl -X GET "http://localhost:5000/api/admin/users?search=john" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"

# Filter by user type
curl -X GET "http://localhost:5000/api/admin/users?userType=service_provider" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"

# Filter banned users
curl -X GET "http://localhost:5000/api/admin/users?isBanned=true" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

### View User Details

```bash
curl -X GET http://localhost:5000/api/admin/users/USER_ID_HERE \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

**Response includes:**
- User profile
- All services posted
- All bookings (as customer and provider)
- Reports made by user
- Reports against user

---

### View All Reports

```bash
# All reports
curl -X GET http://localhost:5000/api/admin/reports \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"

# Pending reports only
curl -X GET "http://localhost:5000/api/admin/reports?status=pending" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

### Update Report Status

```bash
curl -X PATCH http://localhost:5000/api/admin/reports/REPORT_ID \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "resolved",
    "adminNotes": "Issue investigated and resolved"
  }'
```

**Status options:** `under_review`, `resolved`, `dismissed`

---

### Ban a User

```bash
curl -X POST http://localhost:5000/api/admin/users/USER_ID/ban \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Fraudulent activity"
  }'
```

**This will:**
- Ban the user account
- Blacklist their email
- Blacklist their phone number
- Blacklist their CNIC
- Prevent future registrations with these credentials

---

### Unban a User

```bash
curl -X POST http://localhost:5000/api/admin/users/USER_ID/unban \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

### Add New Admin

```bash
curl -X POST http://localhost:5000/api/admin/add-admin \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newadmin@example.com"
  }'
```

---

### View All Admins

```bash
curl -X GET http://localhost:5000/api/admin/admins \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

---

## 🎨 Building a Custom Admin UI (Optional)

You can build a Flutter web admin panel with these features:

### Recommended Structure:

```
admin_panel/
├── lib/
│   ├── screens/
│   │   ├── admin_login_screen.dart
│   │   ├── admin_dashboard_screen.dart
│   │   ├── users_management_screen.dart
│   │   ├── reports_management_screen.dart
│   │   └── admin_settings_screen.dart
│   ├── services/
│   │   └── admin_api_service.dart
│   └── main.dart
```

### Quick Admin UI Example:

```dart
// admin_api_service.dart
class AdminApiService {
  static const String baseUrl = 'http://localhost:5000/api/admin';
  static String? _adminToken;

  static Future<void> login(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _adminToken = data['token'];
    }
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/stats'),
      headers: {'Authorization': 'Bearer $_adminToken'},
    );
    return json.decode(response.body);
  }
  
  // Add more methods...
}
```

---

## 🔧 Testing Admin Features

### 1. Test Admin Login
```bash
curl -X POST http://localhost:5000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email": "shaheer13113@gmail.com"}'
```

### 2. Save the Token
Copy the token from the response

### 3. Test Dashboard
```bash
curl -X GET http://localhost:5000/api/admin/dashboard/stats \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 4. Test User Management
```bash
# List users
curl -X GET http://localhost:5000/api/admin/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📱 Quick Postman Collection

Import this into Postman:

```json
{
  "info": {
    "name": "AssureFix Admin API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Admin Login",
      "request": {
        "method": "POST",
        "header": [{"key": "Content-Type", "value": "application/json"}],
        "body": {
          "mode": "raw",
          "raw": "{\"email\": \"shaheer13113@gmail.com\"}"
        },
        "url": "http://localhost:5000/api/admin/login"
      }
    },
    {
      "name": "Dashboard Stats",
      "request": {
        "method": "GET",
        "header": [{"key": "Authorization", "value": "Bearer {{adminToken}}"}],
        "url": "http://localhost:5000/api/admin/dashboard/stats"
      }
    },
    {
      "name": "Get All Users",
      "request": {
        "method": "GET",
        "header": [{"key": "Authorization", "value": "Bearer {{adminToken}}"}],
        "url": "http://localhost:5000/api/admin/users"
      }
    }
  ]
}
```

---

## 🚀 Quick Start

1. **Start Backend:**
   ```bash
   cd backend
   npm start
   ```

2. **Login as Admin:**
   ```bash
   curl -X POST http://localhost:5000/api/admin/login \
     -H "Content-Type: application/json" \
     -d '{"email": "shaheer13113@gmail.com"}'
   ```

3. **Copy Token**

4. **Use Admin Features:**
   Replace `YOUR_TOKEN` with your actual token in all requests

---

## 📞 Support

**Admin Email:** shaheer13113@gmail.com

**Documentation:**
- ADMIN_SETUP_GUIDE.md - Complete setup
- QUICK_REFERENCE.md - Quick commands
- IMPLEMENTATION_SUMMARY.md - Technical details

---

**Your admin portal is ready to use via API!** 🎉

For a visual interface, consider building a Flutter web admin panel or using Postman for now.
