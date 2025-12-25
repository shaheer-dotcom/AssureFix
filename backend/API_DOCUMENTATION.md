# Enhanced Messaging System - API Documentation

## Overview

This document provides comprehensive API documentation for the Enhanced Messaging System, including all endpoints for chat, voice calls, bookings, and media handling.

## Base URL

```
http://localhost:5000/api
```

## Authentication

All endpoints require JWT authentication unless otherwise specified. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

---

## Chat Endpoints

### Create or Get Chat

Create a new chat conversation or retrieve an existing one.

**Endpoint:** `POST /chat/create`

**Authentication:** Required

**Request Body:**
```json
{
  "serviceId": "string (ObjectId)",
  "providerId": "string (ObjectId)"
}
```

**Response:** `200 OK`
```json
{
  "_id": "string",
  "serviceId": "string",
  "participants": [
    {
      "_id": "string",
      "profile": {
        "name": "string",
        "profilePicture": "string"
      }
    }
  ],
  "status": "pending",
  "messages": [],
  "createdAt": "string (ISO 8601)",
  "updatedAt": "string (ISO 8601)"
}
```

---

### Get User's Chats

Retrieve all chat conversations for the authenticated user.

**Endpoint:** `GET /chat/my-chats`

**Authentication:** Required

**Response:** `200 OK`
```json
[
  {
    "_id": "string",
    "participants": [...],
    "serviceId": {
      "serviceName": "string",
      "areaCovered": ["string"]
    },
    "messages": [...],
    "lastMessage": "string (ISO 8601)",
    "status": "active"
  }
]
```

---

### Get Chat by ID

Retrieve a specific chat conversation with all messages.

**Endpoint:** `GET /chat/:id`

**Authentication:** Required

**Parameters:**
- `id` (path) - Chat ID

**Response:** `200 OK`
```json
{
  "_id": "string",
  "participants": [...],
  "serviceId": {...},
  "messages": [
    {
      "_id": "string",
      "senderId": {
        "_id": "string",
        "profile": {
          "name": "string",
          "profilePicture": "string"
        }
      },
      "messageType": "text|voice|image|location|booking_request",
      "content": {
        "text": "string",
        "voiceUrl": "string",
        "imageUrl": "string",
        "location": {
          "latitude": "number",
          "longitude": "number",
          "address": "string"
        }
      },
      "timestamp": "string (ISO 8601)",
      "isRead": "boolean",
      "deliveredAt": "string (ISO 8601)",
      "readAt": "string (ISO 8601)"
    }
  ],
  "status": "active|pending|closed"
}
```

---

### Upload Chat Image

Upload an image to be sent in a chat message.

**Endpoint:** `POST /chat/:id/upload-image`

**Authentication:** Required

**Parameters:**
- `id` (path) - Chat ID

**Request Body:** `multipart/form-data`
- `image` (file) - Image file (JPG, PNG, GIF, WEBP, max 10MB)

**Response:** `200 OK`
```json
{
  "message": "Image uploaded successfully",
  "imageUrl": "/uploads/chat-images/chat-image-1234567890.jpg",
  "originalName": "photo.jpg"
}
```

**Error Responses:**
- `400 Bad Request` - No image file uploaded or invalid file type
- `403 Forbidden` - User is not a participant in the chat
- `404 Not Found` - Chat not found

---

### Send Message

Send a message in a chat conversation.

**Endpoint:** `POST /chat/:id/messages`

**Authentication:** Required

**Parameters:**
- `id` (path) - Chat ID

**Request Body:**
```json
{
  "messageType": "text|voice|image|location|booking_request",
  "content": {
    "text": "string (for text messages)",
    "voiceUrl": "string (for voice messages)",
    "imageUrl": "string (for image messages)",
    "location": {
      "latitude": "number",
      "longitude": "number",
      "address": "string"
    }
  }
}
```

**Response:** `200 OK`
```json
{
  "_id": "string",
  "senderId": {
    "_id": "string",
    "profile": {
      "name": "string",
      "profilePicture": "string"
    }
  },
  "messageType": "text",
  "content": {...},
  "timestamp": "string (ISO 8601)",
  "isRead": false,
  "deliveredAt": null,
  "readAt": null
}
```

**Error Responses:**
- `400 Bad Request` - Chat is closed (booking completed or cancelled)
- `403 Forbidden` - User is not a participant in the chat
- `404 Not Found` - Chat not found

---

### Get Chat Status

Check if a chat is active or closed based on booking status.

**Endpoint:** `GET /chat/:id/status`

**Authentication:** Required

**Parameters:**
- `id` (path) - Chat ID

**Response:** `200 OK`
```json
{
  "chatStatus": "active|pending|closed",
  "closedAt": "string (ISO 8601) or null",
  "closedReason": "completed|cancelled or null",
  "bookingStatus": "pending|confirmed|in_progress|completed|cancelled or null"
}
```

---

### Reopen Chat

Reopen a closed chat for a repeat booking.

**Endpoint:** `POST /chat/:id/reopen`

**Authentication:** Required

**Parameters:**
- `id` (path) - Chat ID

**Request Body:**
```json
{
  "bookingId": "string (ObjectId)"
}
```

**Response:** `200 OK`
```json
{
  "message": "Chat reopened successfully",
  "chat": {...}
}
```

---

### Mark Messages as Delivered

Mark all undelivered messages as delivered.

**Endpoint:** `PATCH /chat/:id/delivered`

**Authentication:** Required

**Parameters:**
- `id` (path) - Chat ID

**Response:** `200 OK`
```json
{
  "message": "Messages marked as delivered",
  "updatedCount": 5
}
```

---

### Mark Messages as Read

Mark all unread messages as read.

**Endpoint:** `PATCH /chat/:id/read`

**Authentication:** Required

**Parameters:**
- `id` (path) - Chat ID

**Response:** `200 OK`
```json
{
  "message": "Messages marked as read",
  "updatedCount": 3
}
```

---

## Voice Call Endpoints

### Initiate Call

Start a voice call with another user.

**Endpoint:** `POST /calls/initiate`

**Authentication:** Required

**Request Body:**
```json
{
  "receiverId": "string (ObjectId)",
  "conversationId": "string (ObjectId, optional)"
}
```

**Response:** `201 Created`
```json
{
  "message": "Call initiated successfully",
  "call": {
    "_id": "string",
    "callerId": {
      "_id": "string",
      "profile": {
        "name": "string",
        "profilePicture": "string"
      }
    },
    "receiverId": "string",
    "status": "initiated",
    "channelName": "string",
    "token": "string (Agora token)",
    "startTime": "string (ISO 8601)"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Receiver ID required or trying to call yourself
- `403 Forbidden` - Not a participant in the conversation
- `404 Not Found` - Receiver or conversation not found

---

### Accept Call

Accept an incoming voice call.

**Endpoint:** `POST /calls/:callId/accept`

**Authentication:** Required

**Parameters:**
- `callId` (path) - Call ID

**Response:** `200 OK`
```json
{
  "message": "Call accepted successfully",
  "call": {
    "_id": "string",
    "callerId": "string",
    "receiverId": "string",
    "status": "active",
    "channelName": "string",
    "token": "string (Agora token for receiver)",
    "startTime": "string (ISO 8601)"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Call cannot be accepted (wrong status)
- `403 Forbidden` - Not authorized to accept this call
- `404 Not Found` - Call not found

---

### Reject Call

Reject an incoming voice call.

**Endpoint:** `POST /calls/:callId/reject`

**Authentication:** Required

**Parameters:**
- `callId` (path) - Call ID

**Response:** `200 OK`
```json
{
  "message": "Call rejected successfully",
  "call": {
    "_id": "string",
    "status": "rejected",
    "endTime": "string (ISO 8601)"
  }
}
```

---

### End Call

End an active voice call.

**Endpoint:** `POST /calls/:callId/end`

**Authentication:** Required

**Parameters:**
- `callId` (path) - Call ID

**Response:** `200 OK`
```json
{
  "message": "Call ended successfully",
  "call": {
    "_id": "string",
    "status": "ended",
    "endTime": "string (ISO 8601)",
    "duration": 125
  }
}
```

**Note:** Duration is in seconds.

---

### Get Agora Token

Get an Agora token for joining a call channel.

**Endpoint:** `GET /calls/token`

**Authentication:** Required

**Query Parameters:**
- `channelName` (required) - Agora channel name
- `uid` (optional) - User ID (defaults to 0)

**Response:** `200 OK`
```json
{
  "token": "string (Agora token)",
  "channelName": "string",
  "uid": 0
}
```

---

### Get Call History

Retrieve call history for the authenticated user.

**Endpoint:** `GET /calls/history`

**Authentication:** Required

**Query Parameters:**
- `limit` (optional) - Number of calls to return (default: 50)
- `skip` (optional) - Number of calls to skip (default: 0)

**Response:** `200 OK`
```json
{
  "calls": [
    {
      "_id": "string",
      "callerId": {
        "_id": "string",
        "profile": {
          "name": "string",
          "profilePicture": "string"
        }
      },
      "receiverId": {...},
      "status": "ended",
      "startTime": "string (ISO 8601)",
      "endTime": "string (ISO 8601)",
      "duration": 125
    }
  ],
  "count": 10
}
```

---

## Booking Endpoints

### Create Booking

Create a new service booking.

**Endpoint:** `POST /bookings`

**Authentication:** Required

**Request Body:**
```json
{
  "serviceId": "string (ObjectId)",
  "customerDetails": {
    "name": "string",
    "phoneNumber": "string",
    "exactAddress": "string"
  },
  "reservationDate": "string (ISO 8601)",
  "hoursBooked": "number (min: 1)"
}
```

**Response:** `201 Created`
```json
{
  "_id": "string",
  "customerId": "string",
  "serviceId": {...},
  "providerId": {...},
  "customerDetails": {...},
  "reservationDate": "string (ISO 8601)",
  "hoursBooked": 3,
  "totalAmount": 150,
  "status": "pending",
  "conversationId": "string",
  "createdAt": "string (ISO 8601)"
}
```

**Error Responses:**
- `400 Bad Request` - Reservation must be at least 3 hours in the future
- `404 Not Found` - Service not found

**Notes:**
- Automatically creates or reopens a conversation
- Sends notification to service provider
- Updates service booking count

---

### Get User's Bookings

Retrieve all bookings for the authenticated user (as customer or provider).

**Endpoint:** `GET /bookings/my-bookings`

**Authentication:** Required

**Query Parameters:**
- `status` (optional) - Filter by status (pending, confirmed, in_progress, completed, cancelled)
- `page` (optional) - Page number (default: 1)
- `limit` (optional) - Items per page (default: 10)

**Response:** `200 OK`
```json
[
  {
    "_id": "string",
    "customerId": {...},
    "serviceId": {...},
    "providerId": {...},
    "customerDetails": {...},
    "reservationDate": "string (ISO 8601)",
    "hoursBooked": 3,
    "totalAmount": 150,
    "status": "confirmed",
    "createdAt": "string (ISO 8601)"
  }
]
```

---

### Get Booking by ID

Retrieve a specific booking.

**Endpoint:** `GET /bookings/:id`

**Authentication:** Required

**Parameters:**
- `id` (path) - Booking ID

**Response:** `200 OK`
```json
{
  "_id": "string",
  "customerId": {...},
  "serviceId": {...},
  "providerId": {...},
  "customerDetails": {...},
  "reservationDate": "string (ISO 8601)",
  "hoursBooked": 3,
  "totalAmount": 150,
  "status": "confirmed",
  "conversationId": "string",
  "acceptedAt": "string (ISO 8601)",
  "createdAt": "string (ISO 8601)"
}
```

---

### Accept Booking

Accept a pending booking (provider only).

**Endpoint:** `PATCH /bookings/:id/accept`

**Authentication:** Required

**Parameters:**
- `id` (path) - Booking ID

**Response:** `200 OK`
```json
{
  "_id": "string",
  "status": "confirmed",
  "acceptedAt": "string (ISO 8601)",
  ...
}
```

**Error Responses:**
- `400 Bad Request` - Only pending bookings can be accepted
- `403 Forbidden` - Only the service provider can accept this booking
- `404 Not Found` - Booking not found

**Notes:**
- Activates the conversation
- Sends notification to customer

---

### Complete Booking

Mark a booking as completed.

**Endpoint:** `PATCH /bookings/:id/complete`

**Authentication:** Required

**Parameters:**
- `id` (path) - Booking ID

**Response:** `200 OK`
```json
{
  "_id": "string",
  "status": "completed",
  ...
}
```

**Error Responses:**
- `400 Bad Request` - Only confirmed or in-progress bookings can be completed
- `403 Forbidden` - Access denied
- `404 Not Found` - Booking not found

**Notes:**
- Closes the conversation with reason "completed"
- Sends notifications to both parties

---

### Cancel Booking

Cancel a booking.

**Endpoint:** `PATCH /bookings/:id/cancel`

**Authentication:** Required

**Parameters:**
- `id` (path) - Booking ID

**Request Body:**
```json
{
  "cancellationReason": "string (optional)"
}
```

**Response:** `200 OK`
```json
{
  "_id": "string",
  "status": "cancelled",
  "cancellationReason": "string",
  "cancelledBy": "customer|provider",
  ...
}
```

**Error Responses:**
- `400 Bad Request` - Cannot cancel less than 3 hours before reservation
- `403 Forbidden` - Access denied
- `404 Not Found` - Booking not found

**Notes:**
- Closes the conversation with reason "cancelled"
- Sends notifications to both parties
- 3-hour cancellation rule applies

---

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "message": "Error description",
  "errors": [
    {
      "field": "fieldName",
      "message": "Validation error message"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "message": "No token provided" | "Invalid token"
}
```

### 403 Forbidden
```json
{
  "message": "Access denied"
}
```

### 404 Not Found
```json
{
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "message": "Server error",
  "error": "Error details (in development mode)"
}
```

---

## Rate Limiting

API endpoints are rate-limited to prevent abuse. Current limits:
- 100 requests per 15 minutes per IP address
- 1000 requests per hour per authenticated user

---

## WebSocket Events

The messaging system uses Socket.IO for real-time updates.

### Connection

```javascript
const socket = io('http://localhost:5000', {
  auth: {
    token: 'your_jwt_token'
  }
});
```

### Events

#### Client → Server

- `join_chat` - Join a chat room
  ```javascript
  socket.emit('join_chat', { chatId: 'chat_id' });
  ```

- `send_message` - Send a message (alternative to REST API)
  ```javascript
  socket.emit('send_message', {
    chatId: 'chat_id',
    messageType: 'text',
    content: { text: 'Hello' }
  });
  ```

#### Server → Client

- `new_message` - Receive a new message
  ```javascript
  socket.on('new_message', (message) => {
    console.log('New message:', message);
  });
  ```

- `message_delivered` - Message delivery confirmation
  ```javascript
  socket.on('message_delivered', (data) => {
    console.log('Message delivered:', data.messageId);
  });
  ```

- `message_read` - Message read confirmation
  ```javascript
  socket.on('message_read', (data) => {
    console.log('Messages read:', data.chatId);
  });
  ```

- `incoming_call` - Receive incoming call notification
  ```javascript
  socket.on('incoming_call', (call) => {
    console.log('Incoming call from:', call.callerId);
  });
  ```

---

## Data Models

### Chat Model

```javascript
{
  _id: ObjectId,
  participants: [ObjectId], // User IDs
  serviceId: ObjectId,
  bookingId: ObjectId,
  messages: [Message],
  status: 'pending' | 'active' | 'closed',
  lastMessage: Date,
  closedAt: Date,
  closedReason: 'completed' | 'cancelled',
  createdAt: Date,
  updatedAt: Date
}
```

### Message Schema

```javascript
{
  _id: ObjectId,
  senderId: ObjectId,
  messageType: 'text' | 'voice' | 'image' | 'location' | 'booking_request',
  content: {
    text: String,
    voiceUrl: String,
    imageUrl: String,
    location: {
      latitude: Number,
      longitude: Number,
      address: String
    }
  },
  timestamp: Date,
  isRead: Boolean,
  deliveredAt: Date,
  readAt: Date
}
```

### Call Model

```javascript
{
  _id: ObjectId,
  callerId: ObjectId,
  receiverId: ObjectId,
  conversationId: ObjectId,
  status: 'initiated' | 'ringing' | 'active' | 'ended' | 'rejected' | 'missed',
  startTime: Date,
  endTime: Date,
  duration: Number, // seconds
  agoraChannelName: String,
  agoraToken: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Booking Model

```javascript
{
  _id: ObjectId,
  customerId: ObjectId,
  serviceId: ObjectId,
  providerId: ObjectId,
  customerDetails: {
    name: String,
    phoneNumber: String,
    exactAddress: String
  },
  reservationDate: Date,
  hoursBooked: Number,
  totalAmount: Number,
  status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled',
  conversationId: ObjectId,
  notificationSent: Boolean,
  acceptedAt: Date,
  cancellationReason: String,
  cancelledBy: 'customer' | 'provider',
  createdAt: Date,
  updatedAt: Date
}
```

---

## Testing

### Using cURL

#### Create a chat
```bash
curl -X POST http://localhost:5000/api/chat/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"serviceId":"SERVICE_ID","providerId":"PROVIDER_ID"}'
```

#### Send a message
```bash
curl -X POST http://localhost:5000/api/chat/CHAT_ID/messages \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"messageType":"text","content":{"text":"Hello"}}'
```

#### Initiate a call
```bash
curl -X POST http://localhost:5000/api/calls/initiate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"receiverId":"RECEIVER_ID"}'
```

### Using Postman

Import the provided Postman collection (if available) or create requests manually using the endpoints documented above.

---

## Changelog

### Version 2.0 (Enhanced Messaging System)

**Added:**
- Voice call functionality with Agora SDK integration
- Image upload and sharing in chat
- Message delivery and read status tracking
- Booking-based chat lifecycle management
- Chat reopening for repeat bookings
- Call history endpoint
- Enhanced notification system

**Changed:**
- Chat model now includes bookingId, closedAt, closedReason
- Message schema includes imageUrl, deliveredAt, readAt
- Booking model includes conversationId, notificationSent, acceptedAt

**Fixed:**
- Chat status validation when sending messages
- Profile picture population in chat endpoints
- Conversation activation on booking acceptance

---

## Support

For API support and questions:
- Create an issue in the GitHub repository
- Contact: support@assurefix.com

---

**Last Updated:** December 3, 2025
