# ServiceHub Setup Guide

## Prerequisites

### Backend Requirements
- Node.js (v16 or higher)
- MongoDB (local or cloud instance)
- Gmail account for OTP emails

### Frontend Requirements
- Flutter SDK (v3.0 or higher)
- Android Studio / VS Code
- Android/iOS device or emulator

## Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create environment file**
   ```bash
   copy .env.example .env
   ```

4. **Configure environment variables in .env**
   ```
   PORT=5000
   MONGODB_URI=mongodb://localhost:27017/servicehub
   JWT_SECRET=your_super_secret_jwt_key_here
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USER=your_email@gmail.com
   EMAIL_PASS=your_gmail_app_password
   ```

5. **Create uploads directory**
   ```bash
   mkdir uploads
   ```

6. **Start MongoDB** (if using local installation)
   ```bash
   mongod
   ```

7. **Start the server**
   ```bash
   npm run dev
   ```

## Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API endpoint** (if needed)
   - Open `lib/services/api_service.dart`
   - Update `baseUrl` to match your backend URL

4. **Run the app**
   ```bash
   flutter run
   ```

## Gmail App Password Setup

1. Enable 2-Factor Authentication on your Gmail account
2. Go to Google Account settings
3. Navigate to Security > 2-Step Verification > App passwords
4. Generate an app password for "Mail"
5. Use this password in the `EMAIL_PASS` environment variable

## MongoDB Setup Options

### Option 1: Local MongoDB
1. Download and install MongoDB Community Server
2. Start MongoDB service
3. Use connection string: `mongodb://localhost:27017/servicehub`

### Option 2: MongoDB Atlas (Cloud)
1. Create account at mongodb.com/atlas
2. Create a new cluster
3. Get connection string and update `MONGODB_URI`

## Testing the Application

1. **Backend API Testing**
   - Server should be running on http://localhost:5000
   - Test registration endpoint: POST /api/auth/register

2. **Frontend Testing**
   - App should connect to backend automatically
   - Test user registration and OTP verification

## Common Issues

### Backend Issues
- **Port already in use**: Change PORT in .env file
- **MongoDB connection failed**: Check MongoDB service is running
- **Email not sending**: Verify Gmail app password setup

### Frontend Issues
- **Network error**: Check backend URL in api_service.dart
- **Build errors**: Run `flutter clean` then `flutter pub get`
- **Permission errors**: Enable internet permission in Android manifest

## Project Structure

```
serviceHub/
├── backend/
│   ├── models/          # Database models
│   ├── routes/          # API routes
│   ├── middleware/      # Authentication middleware
│   ├── utils/           # Helper functions
│   └── uploads/         # File uploads directory
├── frontend/
│   ├── lib/
│   │   ├── models/      # Data models
│   │   ├── providers/   # State management
│   │   ├── screens/     # UI screens
│   │   ├── services/    # API services
│   │   └── utils/       # Utilities
│   └── assets/          # Images and icons
└── docs/               # Documentation
```

## Next Steps

After successful setup:
1. Create user accounts and test authentication
2. Set up user profiles (service provider/customer)
3. Test service posting and booking functionality
4. Implement real-time chat features
5. Add payment integration (future enhancement)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review error logs in terminal/console
3. Ensure all dependencies are properly installed