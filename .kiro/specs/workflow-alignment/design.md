# Design Document

## Overview

The AssureFix application is a service booking platform that connects customers with service providers. The system consists of a Flutter mobile/web frontend, Node.js/Express backend, and MongoDB database. The design focuses on role-based workflows, real-time messaging, comprehensive booking management, and admin oversight.

### Key Design Principles

1. **Role-Based Access Control**: Separate workflows for customers, service providers, and admins
2. **Progressive Profile Creation**: Users select roles after email verification
3. **Tag-Based Service Discovery**: Services matched by name tags and area tags
4. **Real-Time Communication**: WhatsApp-style messaging with notifications
5. **Booking State Management**: Clear status transitions with time-based constraints
6. **Media Management**: Support for profile pictures, banners, documents, and chat media

## Architecture

### System Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│                 │         │                  │         │                 │
│  Flutter App    │◄───────►│  Express API     │◄───────►│    MongoDB      │
│  (Mobile/Web)   │         │  (Node.js)       │         │    Database     │
│                 │         │                  │         │                 │
└─────────────────┘         └──────────────────┘         └─────────────────┘
        │                            │
        │                            │
        ▼                            ▼
┌─────────────────┐         ┌──────────────────┐
│                 │         │                  │
│  Local Storage  │         │  Email Service   │
│  (Auth Tokens)  │         │  (Nodemailer)    │
│                 │         │                  │
└─────────────────┘         └──────────────────┘
```

### Technology Stack

**Frontend:**
- Flutter/Dart for cross-platform development
- Provider for state management
- HTTP package for API communication
- Image picker for media uploads
- Shared preferences for local storage

**Backend:**
- Node.js with Express framework
- MongoDB with Mongoose ODM
- JWT for authentication
- Multer for file uploads
- Nodemailer for email notifications

**Infrastructure:**
- File system storage for uploaded media
- JWT-based stateless authentication
- RESTful API design

## Components and Interfaces

### 1. Authentication Flow

#### Registration Process

```
User Opens App
    ↓
Login/Signup Screen
    ↓
[New User] → Signup Form (Email + Password)
    ↓
Send OTP to Email
    ↓
OTP Verification Screen
    ↓
[Valid OTP] → Role Selection Screen
    ↓
Profile Creation Form (Role-Specific Fields)
    ↓
Home Screen (Role-Specific)
```

#### API Endpoints

- `POST /api/auth/send-otp` - Send OTP to email
- `POST /api/auth/verify-otp` - Verify OTP and create user
- `POST /api/auth/resend-otp` - Resend OTP
- `POST /api/auth/login` - Login with email/password
- `GET /api/auth/me` - Get current user profile

#### Enhanced User Model

```javascript
{
  email: String (unique, required),
  password: String (hashed, required),
  isEmailVerified: Boolean,
  emailOTP: String,
  otpExpiry: Date,
  
  profile: {
    name: String,
    phoneNumber: String,
    cnic: String,
    userType: Enum['customer', 'service_provider'],
    profilePicture: String (file path),
    bannerImage: String (file path), // Service provider only
    cnicDocument: String (file path),
    shopDocument: String (file path) // Service provider only
  },
  
  customerRating: {
    average: Number (0-5),
    count: Number,
    totalStars: Number
  },
  
  serviceProviderRating: {
    average: Number (0-5),
    count: Number,
    totalStars: Number
  },
  
  isActive: Boolean,
  isBanned: Boolean,
  banReason: String,
  bannedAt: Date,
  
  blockedUsers: [ObjectId], // Users blocked by this user
  reportedUsers: [ObjectId], // Users reported by this user
  
  timestamps: true
}
```

### 2. Profile Management

#### Profile Creation Screens

**Service Provider Fields:**
- Profile Picture (image upload)
- Banner Image (image upload)
- Name (text input)
- Phone Number (text input)
- Email (auto-filled, read-only)
- CNIC Picture (image upload)
- Shop Documents (image upload, optional)

**Customer Fields:**
- Profile Picture (image upload)
- Name (text input)
- Phone Number (text input)
- Email (auto-filled, read-only)
- CNIC Picture (image upload)

#### API Endpoints

- `POST /api/profile/create` - Create user profile with role
- `PUT /api/profile/update` - Update profile information
- `POST /api/profile/upload-picture` - Upload profile picture
- `POST /api/profile/upload-banner` - Upload banner image
- `POST /api/profile/upload-document` - Upload CNIC/shop documents
- `GET /api/profile/:userId` - Get user profile by ID

### 3. Service Management (Service Provider)

#### Enhanced Service Model

```javascript
{
  providerId: ObjectId (ref: User),
  name: String (service tag for matching),
  description: String,
  areaTags: [String], // Multiple area tags as bubbles
  pricePerHour: Number,
  
  // Service statistics
  totalBookings: Number,
  completedBookings: Number,
  
  // Ratings specific to this service
  serviceRating: {
    average: Number (0-5),
    count: Number,
    totalStars: Number
  },
  
  isActive: Boolean,
  images: [String], // Service images
  
  timestamps: true
}
```

#### Service Posting Flow

```
Service Provider → "Post a service" Card
    ↓
Service Form:
  - Name (tag input)
  - Description (textarea)
  - Area Tags (tag input with bubbles)
  - Price Per Hour (number input)
    ↓
"Post Service" Button
    ↓
Service Stored & Searchable
```

#### API Endpoints

- `POST /api/services` - Create new service
- `GET /api/services/my-services` - Get provider's services
- `GET /api/services/:id` - Get service details
- `PUT /api/services/:id` - Update service
- `DELETE /api/services/:id` - Delete service
- `GET /api/services/:id/ratings` - Get service ratings and reviews

### 4. Service Discovery (Customer)

#### Search Flow

```
Customer → "Search A service" Card
    ↓
Search Form:
  - Service Name Tag (tag input)
  - Area Location Tag (tag input)
    ↓
"Find Services" Button
    ↓
Match Logic:
  - Service name matches input tag
  - At least ONE area tag matches
    ↓
Display Results (List of Service Cards)
```

#### Search API

- `GET /api/services/search?name=<tag>&area=<tag>` - Search services with tag matching

#### Service Card Display

**Thumbnail View:**
- Service Name
- Provider Name
- Area Tags (as bubbles)
- Provider Rating (stars)
- Price Per Hour

**Detail View:**
- All thumbnail info
- Description
- Service-specific ratings
- Customer reviews
- "Book Service" button
- "Message" button

### 5. Booking Management

#### Enhanced Booking Model

```javascript
{
  customerId: ObjectId (ref: User),
  serviceId: ObjectId (ref: Service),
  providerId: ObjectId (ref: User),
  
  customerDetails: {
    name: String,
    phoneNumber: String,
    completeAddress: String
  },
  
  bookingDate: Date,
  bookingTime: String,
  
  status: Enum['pending', 'active', 'completed', 'cancelled'],
  
  totalAmount: Number,
  
  cancellationReason: String,
  cancelledBy: Enum['customer', 'provider'],
  
  // Ratings after completion
  customerRating: {
    stars: Number (1-5),
    review: String
  },
  providerRating: {
    stars: Number (1-5),
    review: String
  },
  
  timestamps: true
}
```

#### Booking Status Flow

```
Customer Books Service
    ↓
Status: 'pending' (notification sent to provider)
    ↓
Provider Accepts
    ↓
Status: 'active'
    ↓
[Either Party] → Mark as Completed
    ↓
Rating Popup Appears
    ↓
Submit Rating & Review
    ↓
Status: 'completed'
```

#### Booking Management Features

**Customer Capabilities:**
- View active, completed, cancelled bookings (separate tabs)
- Edit active bookings (date, time, address, name, phone)
- Cancel active bookings
- Mark as completed (triggers rating)
- Cannot edit/cancel completed or cancelled bookings

**Service Provider Capabilities:**
- View active, completed, cancelled bookings (separate tabs)
- Mark active bookings as completed (triggers rating)
- Cannot cancel or edit bookings
- View booking notifications

#### API Endpoints

- `POST /api/bookings` - Create booking
- `GET /api/bookings/my-bookings?status=<status>` - Get user's bookings
- `GET /api/bookings/:id` - Get booking details
- `PUT /api/bookings/:id` - Update booking (customer only)
- `PATCH /api/bookings/:id/status` - Update booking status
- `POST /api/bookings/:id/complete` - Mark as completed and rate

### 6. Messaging System

#### Message Model

```javascript
{
  conversationId: ObjectId (ref: Conversation),
  senderId: ObjectId (ref: User),
  receiverId: ObjectId (ref: User),
  
  messageType: Enum['text', 'voice', 'image', 'location'],
  
  content: String, // Text message or file path
  
  location: {
    latitude: Number,
    longitude: Number
  },
  
  isRead: Boolean,
  
  timestamps: true
}
```

#### Conversation Model

```javascript
{
  participants: [ObjectId], // [customerId, providerId]
  relatedBooking: ObjectId (ref: Booking),
  
  lastMessage: {
    content: String,
    timestamp: Date,
    senderId: ObjectId
  },
  
  isActive: Boolean, // Based on booking status
  
  timestamps: true
}
```

#### Messaging Rules

1. **Conversation Creation**: Automatically created when booking is made
2. **Active Messaging**: Only allowed when booking status is 'pending' or 'active'
3. **Read-Only Mode**: When booking is 'completed' or 'cancelled', show messages but disable sending
4. **Notifications**: Real-time notifications when messages are sent/received
5. **Media Support**: Text, voice notes, images, location sharing

#### API Endpoints

- `GET /api/messages/conversations` - Get all user conversations
- `GET /api/messages/:conversationId` - Get messages in conversation
- `POST /api/messages` - Send message
- `POST /api/messages/upload-media` - Upload voice note or image
- `PATCH /api/messages/:id/read` - Mark message as read
- `GET /api/messages/unread-count` - Get unread message count

### 7. Rating and Review System

#### Rating Model

```javascript
{
  ratedBy: ObjectId (ref: User),
  ratedUser: ObjectId (ref: User),
  ratingType: Enum['customer', 'service_provider'],
  
  stars: Number (1-5),
  review: String (max 500 chars),
  
  relatedBooking: ObjectId (ref: Booking),
  relatedService: ObjectId (ref: Service),
  
  timestamps: true
}
```

#### Rating Flow

```
Booking Marked as Completed
    ↓
Rating Popup Appears
    ↓
User Selects Stars (1-5)
    ↓
User Writes Review (optional)
    ↓
Submit Rating
    ↓
Update User's Average Rating
    ↓
Update Service's Average Rating (if applicable)
```

#### Rating Display

**Profile Screen:**
- Average rating (stars)
- Total rating count
- Click to view detailed ratings

**Detailed Rating View:**
- List of individual ratings
- Reviewer name
- Stars given
- Review text
- Date

#### API Endpoints

- `POST /api/ratings` - Submit rating
- `GET /api/ratings/user/:userId?type=<customer|provider>` - Get user ratings
- `GET /api/ratings/service/:serviceId` - Get service ratings

### 8. Report and Block System

#### Report Model

```javascript
{
  reportedBy: ObjectId (ref: User),
  reportedUser: ObjectId (ref: User),
  
  reason: String,
  description: String,
  
  status: Enum['pending', 'reviewed', 'resolved'],
  
  adminNotes: String,
  reviewedBy: ObjectId (ref: User), // Admin
  reviewedAt: Date,
  
  timestamps: true
}
```

#### Block Functionality

- Stored in User model as `blockedUsers: [ObjectId]`
- Prevents messaging
- Hides user from searches
- Shows in "Report and Block" management screen

#### API Endpoints

- `POST /api/reports` - Submit report
- `POST /api/users/block/:userId` - Block user
- `DELETE /api/users/block/:userId` - Unblock user
- `GET /api/users/blocked` - Get blocked users
- `GET /api/reports/my-reports` - Get user's submitted reports

### 9. Notification System

#### Notification Model

```javascript
{
  userId: ObjectId (ref: User),
  
  type: Enum['booking', 'message', 'admin', 'update'],
  
  title: String,
  message: String,
  
  relatedBooking: ObjectId (ref: Booking),
  relatedMessage: ObjectId (ref: Message),
  
  isRead: Boolean,
  
  actionUrl: String, // Deep link to relevant screen
  
  timestamps: true
}
```

#### Notification Types

1. **Booking Notifications**:
   - New booking created (to provider)
   - Booking accepted (to customer)
   - Booking completed (to both)
   - Booking cancelled (to both)

2. **Message Notifications**:
   - New message received

3. **Admin Notifications**:
   - Messages from admin team
   - Account warnings
   - Ban notifications

4. **Update Notifications**:
   - App updates
   - Feature announcements

#### API Endpoints

- `GET /api/notifications` - Get user notifications
- `PATCH /api/notifications/:id/read` - Mark as read
- `PATCH /api/notifications/read-all` - Mark all as read
- `GET /api/notifications/unread-count` - Get unread count

### 10. Admin Portal

#### Admin Features

**User Management:**
- View all customers (separate list)
- View all service providers (separate list)
- View user details
- Ban/unban users
- View user activity

**Report Management:**
- View customer reports (separate list)
- View service provider reports (separate list)
- Review report details
- Take action on reports
- Add admin notes

**Notification Management:**
- Send notification to specific user
- Send notification to all customers
- Send notification to all service providers
- Send broadcast to all users

#### API Endpoints

- `GET /api/admin/users?type=<customer|provider>` - Get users by type
- `GET /api/admin/users/:id` - Get user details
- `PATCH /api/admin/users/:id/ban` - Ban user
- `PATCH /api/admin/users/:id/unban` - Unban user
- `GET /api/admin/reports?type=<customer|provider>` - Get reports
- `PATCH /api/admin/reports/:id/review` - Review report
- `POST /api/admin/notifications/send` - Send notification
- `POST /api/admin/notifications/broadcast` - Broadcast notification

### 11. Settings and Preferences

#### Settings Features

**Password Management:**
- Change password with email OTP verification
- Flow: Enter new password → Send OTP → Verify OTP → Update password

**Theme Management:**
- Toggle between light and dark mode
- Persist preference in local storage

**Help and Support:**
- Customer support contact details
- FAQs by role (customer/provider)
- How-to guides

#### API Endpoints

- `POST /api/settings/change-password-request` - Request password change OTP
- `POST /api/settings/change-password-verify` - Verify OTP and change password
- `GET /api/settings/faqs?role=<customer|provider>` - Get role-specific FAQs

## Data Models

### Complete Schema Overview

```
User
├── Authentication (email, password, OTP)
├── Profile (name, phone, CNIC, type, pictures)
├── Ratings (customer rating, provider rating)
├── Status (active, banned)
└── Relationships (blocked users, reported users)

Service
├── Basic Info (name, description, area tags)
├── Pricing (price per hour)
├── Provider (providerId reference)
├── Statistics (bookings, ratings)
└── Status (active/inactive)

Booking
├── Parties (customer, provider, service)
├── Details (date, time, address)
├── Status (pending, active, completed, cancelled)
├── Payment (total amount)
└── Ratings (customer rating, provider rating)

Message
├── Conversation (conversationId)
├── Parties (sender, receiver)
├── Content (type, content, media)
└── Status (read/unread)

Conversation
├── Participants (customer, provider)
├── Related Booking
├── Last Message
└── Status (active/inactive)

Rating
├── Parties (rater, rated user)
├── Rating (stars, review)
├── Type (customer/provider rating)
└── Context (booking, service)

Report
├── Parties (reporter, reported user)
├── Details (reason, description)
├── Status (pending, reviewed, resolved)
└── Admin Review (notes, reviewer)

Notification
├── Recipient (userId)
├── Type (booking, message, admin, update)
├── Content (title, message)
├── Related Items (booking, message)
└── Status (read/unread)
```

## Error Handling

### Error Response Format

```javascript
{
  success: false,
  message: "Human-readable error message",
  error: "ERROR_CODE",
  details: {} // Optional additional details
}
```

### Common Error Scenarios

1. **Authentication Errors**:
   - Invalid OTP
   - Expired OTP
   - Invalid credentials
   - Banned account
   - Unverified email

2. **Authorization Errors**:
   - Accessing other user's data
   - Performing unauthorized actions
   - Admin-only endpoints

3. **Validation Errors**:
   - Missing required fields
   - Invalid data formats
   - File size/type restrictions

4. **Business Logic Errors**:
   - Booking time constraints
   - Cannot message inactive booking
   - Cannot edit completed booking
   - Service not available in area

5. **Resource Errors**:
   - User not found
   - Service not found
   - Booking not found
   - Conversation not found

### Error Handling Strategy

- **Frontend**: Display user-friendly error messages with retry options
- **Backend**: Log detailed errors, return sanitized messages to client
- **Validation**: Validate on both frontend and backend
- **Network**: Handle offline scenarios gracefully

## Testing Strategy

### Unit Testing

**Backend:**
- Model validation tests
- Authentication logic tests
- Rating calculation tests
- Search/matching algorithm tests
- Notification generation tests

**Frontend:**
- Widget tests for custom components
- Provider state management tests
- Form validation tests
- Tag input functionality tests

### Integration Testing

**API Integration:**
- Authentication flow (signup → OTP → verify → login)
- Service posting and search
- Booking creation and management
- Messaging flow
- Rating submission and calculation
- Report and block functionality

**UI Integration:**
- Navigation flows
- Form submissions
- Image uploads
- Real-time updates

### End-to-End Testing

**Critical User Journeys:**

1. **Customer Journey**:
   - Register → Verify → Select role → Create profile → Search service → Book → Message → Complete → Rate

2. **Service Provider Journey**:
   - Register → Verify → Select role → Create profile → Post service → Receive booking → Message → Complete → Rate

3. **Admin Journey**:
   - Login → View users → Ban user → Review reports → Send notifications

### Testing Tools

- **Backend**: Jest, Supertest
- **Frontend**: Flutter test framework
- **API**: Postman collections
- **E2E**: Flutter integration tests

### Test Data

- Create seed data for different user types
- Mock services in various categories and areas
- Sample bookings in different states
- Test conversations with various message types

## Performance Considerations

### Database Optimization

- Index frequently queried fields (email, service tags, area tags)
- Use pagination for list endpoints
- Implement caching for static data (FAQs, categories)
- Optimize populate queries

### File Upload Optimization

- Compress images before upload
- Set file size limits
- Use efficient file storage structure
- Implement lazy loading for images

### Real-Time Features

- Implement efficient polling for notifications
- Consider WebSocket for messaging (future enhancement)
- Batch notification updates

### Mobile Performance

- Implement infinite scroll for lists
- Cache API responses locally
- Optimize image loading
- Minimize network requests

## Security Considerations

### Authentication Security

- Hash passwords with bcrypt
- Use secure JWT tokens
- Implement token expiration
- Validate OTP expiry
- Rate limit OTP requests

### Data Protection

- Validate all user inputs
- Sanitize data before storage
- Implement CORS properly
- Use HTTPS in production
- Protect sensitive endpoints with auth middleware

### File Upload Security

- Validate file types
- Limit file sizes
- Scan for malicious content
- Store files outside web root
- Use secure file naming

### Privacy

- Don't expose sensitive user data
- Implement proper access controls
- Allow users to delete their data
- Comply with data protection regulations

## Future Enhancements

1. **Real-Time Messaging**: Implement WebSocket for instant messaging
2. **Push Notifications**: Add Firebase Cloud Messaging
3. **Payment Integration**: Add payment gateway for booking payments
4. **Service Categories**: Expand category system with subcategories
5. **Advanced Search**: Add filters for price range, ratings, availability
6. **Service Provider Verification**: Implement document verification workflow
7. **Booking Calendar**: Visual calendar for service providers
8. **Analytics Dashboard**: Detailed analytics for service providers
9. **Multi-Language Support**: Internationalization
10. **Social Features**: Share services, refer friends
