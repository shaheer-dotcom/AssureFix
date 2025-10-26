# AssureFix - Service Booking Platform

## ✅ **LFS Issues Completely Resolved!**

**The repository has been completely cleaned and migrated from Git LFS to regular Git files.**

- ✅ All files now contain actual content (no more LFS pointers)
- ✅ Repository is clean and ready to clone
- ✅ No LFS dependencies required
- ✅ All features are functional and the codebase is complete

**Simply clone and use:**
```bash
git clone https://github.com/shaheer-dotcom/AssureFix.git
cd AssureFix
```

🎯 **Ready to go!** All files are now regular Git files with actual content.

---

A comprehensive Flutter and Node.js application for connecting service providers with customers. AssureFix allows users to book various home and professional services with features like real-time messaging, voice notes, and comprehensive booking management.

## 🚀 Features

### 📱 **Mobile & Web App (Flutter)**
- **Service Discovery**: Search and filter services by category and location
- **Tag-based Areas**: Service providers can add multiple service areas using tag bubbles
- **Complete Booking System**: Date/time selection, customer details, and booking management
- **Real-time Messaging**: Chat with service providers including voice notes and file sharing
- **Profile Management**: Complete user profiles with photo upload capabilities
- **Settings & Privacy**: Comprehensive settings including notifications, privacy controls
- **Booking History**: Track all bookings with status updates and cancellation options

### 🔧 **Backend API (Node.js)**
- **RESTful API**: Complete API for all app functionality
- **MongoDB Integration**: Robust data storage and management
- **Authentication**: Secure user authentication and authorization
- **Real-time Features**: Socket.io integration for live messaging
- **File Upload**: Support for profile pictures and attachments
- **Booking Management**: Complete booking lifecycle management

### 🎵 **Advanced Messaging**
- **Voice Notes**: Long-press to record and send voice messages
- **File Sharing**: Photos, videos, documents, and location sharing
- **Persistent Conversations**: Messages saved across app sessions
- **Search Functionality**: Search through conversations and messages
- **Real-time Updates**: Instant message delivery and read receipts

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile and web development
- **Provider** - State management
- **HTTP** - API communication
- **Socket.io Client** - Real-time messaging

### Backend
- **Node.js** - Server runtime
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM for MongoDB
- **Socket.io** - Real-time communication
- **Multer** - File upload handling
- **JWT** - Authentication tokens

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK (3.0+)
- Node.js (16+)
- MongoDB (local or cloud)
- Git

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Configure your MongoDB connection in .env
npm start
```

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port=8082
```

### Environment Variables
Create a `.env` file in the backend directory:
```env
MONGODB_URI=mongodb://localhost:27017/assurefix
JWT_SECRET=your_jwt_secret_here
PORT=5000
```

## 🚀 Running the Application

1. **Start Backend Server**:
   ```bash
   cd backend
   npm start
   ```
   Server runs on: `http://localhost:5000`

2. **Start Frontend App**:
   ```bash
   cd frontend
   flutter run -d chrome --web-port=8082
   ```
   App runs on: `http://localhost:8082`

## 📱 App Features Overview

### User Types
- **Customers**: Book services, chat with providers, manage bookings
- **Service Providers**: Offer services, manage bookings, communicate with customers

### Core Functionality
1. **Service Management**: Create, edit, and manage service listings
2. **Booking System**: Complete booking flow with date/time selection
3. **Messaging**: Real-time chat with voice notes and file sharing
4. **Profile System**: User profiles with ratings and reviews
5. **Search & Discovery**: Find services by location and category
6. **Settings**: Comprehensive app settings and privacy controls

### Voice Notes Feature
- **Long-press** the microphone button to record
- **Release** to send the voice note
- Voice messages display with duration and play controls
- Works in all chat conversations

### Tag-based Service Areas
- Service providers can add multiple areas using tag bubbles
- Type area name and press Enter to create tags
- Easy removal by clicking the X on any tag
- Customers can search by any listed area

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/send-otp` - Send OTP for registration
- `POST /api/auth/verify-otp` - Verify OTP and register

### Services
- `GET /api/services` - Get all services (with search/filter)
- `POST /api/services` - Create new service
- `GET /api/services/my-services` - Get user's services
- `PUT /api/services/:id` - Update service
- `DELETE /api/services/:id` - Delete service

### Bookings
- `POST /api/bookings` - Create booking
- `GET /api/bookings/my-bookings` - Get user bookings
- `PATCH /api/bookings/:id/status` - Update booking status

### Users
- `GET /api/users/profile` - Get user profile
- `POST /api/users/profile` - Create/update profile

## 🎨 UI/UX Features

- **Material Design**: Clean, modern interface
- **Responsive**: Works on mobile and web
- **Dark/Light Theme**: Theme switching capability
- **Intuitive Navigation**: Easy-to-use bottom navigation
- **Real-time Updates**: Live updates for messages and bookings
- **Smooth Animations**: Polished user experience

## 🔒 Security Features

- JWT-based authentication
- Password hashing
- Input validation and sanitization
- CORS protection
- Rate limiting (can be added)
- Secure file upload handling

## 📊 Database Schema

### Users
- Profile information
- Authentication data
- Ratings and reviews
- Service provider/customer type

### Services
- Service details and pricing
- Provider information
- Categories and areas
- Availability status

### Bookings
- Customer and provider details
- Service information
- Booking status and timeline
- Cancellation policies

### Messages
- Conversation management
- Message types (text, voice, file)
- Real-time delivery status

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Contact: [your-email@example.com]

## 🎯 Future Enhancements

- [ ] Push notifications
- [ ] Payment integration
- [ ] Advanced search filters
- [ ] Service provider verification
- [ ] Multi-language support
- [ ] Mobile app store deployment
- [ ] Advanced analytics dashboard

---

**AssureFix** - Connecting trusted service providers with customers seamlessly! 🔧✨