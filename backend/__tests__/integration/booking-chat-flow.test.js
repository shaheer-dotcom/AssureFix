const request = require('supertest');
const express = require('express');

// Mock models and middleware
jest.mock('../../models/Booking');
jest.mock('../../models/Service');
jest.mock('../../models/User');
jest.mock('../../models/Chat');
jest.mock('../../middleware/auth');
jest.mock('../../services/notificationService');

const Booking = require('../../models/Booking');
const Service = require('../../models/Service');
const User = require('../../models/User');
const Chat = require('../../models/Chat');
const auth = require('../../middleware/auth');
const bookingsRouter = require('../../routes/bookings');
const chatRouter = require('../../routes/chat');

// Create Express app for testing
const app = express();
app.use(express.json());
app.use('/api/bookings', bookingsRouter);
app.use('/api/chat', chatRouter);

describe('Integration: Booking to Chat Flow', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    
    // Mock auth middleware
    auth.mockImplementation((req, res, next) => {
      req.user = { _id: 'customer123' };
      next();
    });
  });

  test('Complete flow: Create booking -> Accept -> Send message -> Complete -> Close chat', async () => {
    // Step 1: Create booking
    const mockService = {
      _id: 'service123',
      serviceName: 'House Cleaning',
      pricePerHour: 50,
      providerId: 'provider123',
      totalBookings: 0,
      save: jest.fn().mockResolvedValue(true)
    };

    const mockBooking = {
      _id: 'booking123',
      customerId: 'customer123',
      providerId: 'provider123',
      serviceId: 'service123',
      status: 'pending',
      hoursBooked: 3,
      totalAmount: 150,
      reservationDate: new Date(Date.now() + 4 * 60 * 60 * 1000), // 4 hours from now
      customerDetails: {
        name: 'John Doe',
        phoneNumber: '+1234567890',
        exactAddress: '123 Main St'
      },
      save: jest.fn().mockResolvedValue(true),
      populate: jest.fn().mockResolvedValue({
        _id: 'booking123',
        serviceId: mockService,
        providerId: { _id: 'provider123', profile: { name: 'Provider' } },
        customerId: { _id: 'customer123', profile: { name: 'Customer' } }
      })
    };

    const mockChat = {
      _id: 'chat123',
      participants: ['customer123', 'provider123'],
      serviceId: 'service123',
      bookingId: 'booking123',
      status: 'pending',
      messages: [],
      save: jest.fn().mockResolvedValue(true)
    };

    Service.findById = jest.fn().mockResolvedValue(mockService);
    Booking.mockImplementation(() => mockBooking);
    Chat.findOne = jest.fn().mockResolvedValue(null);
    Chat.mockImplementation(() => mockChat);

    // Create booking
    const createResponse = await request(app)
      .post('/api/bookings')
      .send({
        serviceId: 'service123',
        customerDetails: mockBooking.customerDetails,
        reservationDate: mockBooking.reservationDate.toISOString(),
        hoursBooked: 3
      })
      .expect(201);

    expect(mockChat.status).toBe('pending');
    expect(mockBooking.conversationId).toBe('chat123');

    // Step 2: Provider accepts booking
    auth.mockImplementation((req, res, next) => {
      req.user = { _id: 'provider123' };
      next();
    });

    mockBooking.providerId = { toString: () => 'provider123' };
    Booking.findById = jest.fn().mockResolvedValue(mockBooking);
    Chat.findById = jest.fn().mockResolvedValue(mockChat);

    await request(app)
      .patch('/api/bookings/booking123/accept')
      .expect(200);

    expect(mockBooking.status).toBe('confirmed');
    expect(mockChat.status).toBe('active');

    // Step 3: Send message in active chat
    mockChat.participants = [
      { toString: () => 'customer123' },
      { toString: () => 'provider123' }
    ];
    mockChat.messages.push = jest.fn();
    mockChat.populate = jest.fn().mockResolvedValue({
      messages: [{
        senderId: { _id: 'customer123', profile: { name: 'Customer' } },
        messageType: 'text',
        content: { text: 'Hello' },
        timestamp: new Date()
      }]
    });

    auth.mockImplementation((req, res, next) => {
      req.user = { _id: 'customer123' };
      next();
    });

    await request(app)
      .post('/api/chat/chat123/messages')
      .send({
        messageType: 'text',
        content: { text: 'Hello' }
      })
      .expect(200);

    expect(mockChat.messages.push).toHaveBeenCalled();

    // Step 4: Complete booking
    mockBooking.customerId = { toString: () => 'customer123' };
    Chat.findByIdAndUpdate = jest.fn().mockResolvedValue({
      _id: 'chat123',
      status: 'closed',
      closedAt: expect.any(Date),
      closedReason: 'completed'
    });

    await request(app)
      .patch('/api/bookings/booking123/complete')
      .expect(200);

    expect(mockBooking.status).toBe('completed');
    expect(Chat.findByIdAndUpdate).toHaveBeenCalledWith(
      'chat123',
      expect.objectContaining({
        status: 'closed',
        closedReason: 'completed'
      })
    );

    // Step 5: Verify message sending is blocked in closed chat
    mockChat.status = 'closed';
    mockChat.closedReason = 'completed';

    const blockedResponse = await request(app)
      .post('/api/chat/chat123/messages')
      .send({
        messageType: 'text',
        content: { text: 'This should fail' }
      })
      .expect(400);

    expect(blockedResponse.body.chatStatus).toBe('closed');
  });

  test('Chat reopening flow: Complete booking -> Create new booking -> Reopen chat', async () => {
    const mockChat = {
      _id: 'chat123',
      participants: [
        { toString: () => 'customer123' },
        { toString: () => 'provider123' }
      ],
      status: 'closed',
      closedAt: new Date(),
      closedReason: 'completed',
      bookingId: 'oldbooking123',
      save: jest.fn().mockResolvedValue(true)
    };

    Chat.findById = jest.fn().mockResolvedValue(mockChat);

    auth.mockImplementation((req, res, next) => {
      req.user = { _id: 'customer123' };
      next();
    });

    const response = await request(app)
      .post('/api/chat/chat123/reopen')
      .send({ bookingId: 'newbooking123' })
      .expect(200);

    expect(mockChat.status).toBe('active');
    expect(mockChat.bookingId).toBe('newbooking123');
    expect(mockChat.closedAt).toBeNull();
    expect(mockChat.closedReason).toBeNull();
    expect(response.body.message).toContain('reopened');
  });
});
