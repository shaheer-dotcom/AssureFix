const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');

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

// Create Express app for testing
const app = express();
app.use(express.json());
app.use('/api/bookings', bookingsRouter);

describe('Booking Routes - Chat Lifecycle', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    
    // Mock auth middleware to pass through with user
    auth.mockImplementation((req, res, next) => {
      req.user = { _id: 'user123' };
      next();
    });
  });

  describe('POST /api/bookings/:id/accept', () => {
    it('should activate conversation when booking is accepted', async () => {
      const mockBooking = {
        _id: 'booking123',
        providerId: 'user123',
        customerId: 'customer123',
        serviceId: 'service123',
        status: 'pending',
        conversationId: 'chat123',
        save: jest.fn().mockResolvedValue(true),
        populate: jest.fn().mockResolvedValue({
          _id: 'booking123',
          serviceId: { _id: 'service123', serviceName: 'Test Service' },
          providerId: { _id: 'user123', profile: { name: 'Provider' } },
          customerId: { _id: 'customer123', profile: { name: 'Customer' } }
        })
      };

      const mockChat = {
        _id: 'chat123',
        status: 'pending',
        save: jest.fn().mockResolvedValue(true)
      };

      Booking.findById = jest.fn().mockResolvedValue(mockBooking);
      Chat.findById = jest.fn().mockResolvedValue(mockChat);

      const response = await request(app)
        .patch('/api/bookings/booking123/accept')
        .expect(200);

      expect(mockBooking.status).toBe('confirmed');
      expect(mockBooking.acceptedAt).toBeDefined();
      expect(mockChat.status).toBe('active');
      expect(mockChat.save).toHaveBeenCalled();
    });

    it('should create conversation if it does not exist', async () => {
      const mockBooking = {
        _id: 'booking123',
        providerId: 'user123',
        customerId: 'customer123',
        serviceId: 'service123',
        status: 'pending',
        conversationId: null,
        save: jest.fn().mockResolvedValue(true),
        populate: jest.fn().mockResolvedValue({
          _id: 'booking123',
          serviceId: { _id: 'service123', serviceName: 'Test Service' },
          providerId: { _id: 'user123', profile: { name: 'Provider' } },
          customerId: { _id: 'customer123', profile: { name: 'Customer' } }
        })
      };

      const mockNewChat = {
        _id: 'newchat123',
        status: 'active',
        save: jest.fn().mockResolvedValue(true)
      };

      Booking.findById = jest.fn().mockResolvedValue(mockBooking);
      Chat.findById = jest.fn().mockResolvedValue(null);
      Chat.mockImplementation(() => mockNewChat);

      const response = await request(app)
        .patch('/api/bookings/booking123/accept')
        .expect(200);

      expect(mockBooking.conversationId).toBe('newchat123');
      expect(mockNewChat.save).toHaveBeenCalled();
    });

    it('should reject if user is not the provider', async () => {
      const mockBooking = {
        _id: 'booking123',
        providerId: 'differentuser',
        status: 'pending'
      };

      Booking.findById = jest.fn().mockResolvedValue(mockBooking);

      const response = await request(app)
        .patch('/api/bookings/booking123/accept')
        .expect(403);

      expect(response.body.message).toContain('Only the service provider');
    });

    it('should reject if booking is not pending', async () => {
      const mockBooking = {
        _id: 'booking123',
        providerId: 'user123',
        status: 'confirmed'
      };

      Booking.findById = jest.fn().mockResolvedValue(mockBooking);

      const response = await request(app)
        .patch('/api/bookings/booking123/accept')
        .expect(400);

      expect(response.body.message).toContain('Only pending bookings');
    });
  });

  describe('POST /api/bookings/:id/complete', () => {
    it('should close conversation when booking is completed', async () => {
      const mockBooking = {
        _id: 'booking123',
        customerId: 'user123',
        providerId: 'provider123',
        serviceId: 'service123',
        status: 'confirmed',
        conversationId: 'chat123',
        save: jest.fn().mockResolvedValue(true),
        populate: jest.fn().mockResolvedValue({
          _id: 'booking123',
          serviceId: { _id: 'service123', serviceName: 'Test Service' },
          providerId: { _id: 'provider123', profile: { name: 'Provider' } },
          customerId: { _id: 'user123', profile: { name: 'Customer' } }
        })
      };

      Booking.findById = jest.fn().mockResolvedValue(mockBooking);
      Chat.findByIdAndUpdate = jest.fn().mockResolvedValue({
        _id: 'chat123',
        status: 'closed',
        closedAt: expect.any(Date),
        closedReason: 'completed'
      });

      const response = await request(app)
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
    });
  });

  describe('POST /api/bookings/:id/cancel', () => {
    it('should close conversation when booking is cancelled', async () => {
      const mockBooking = {
        _id: 'booking123',
        customerId: 'user123',
        providerId: 'provider123',
        serviceId: 'service123',
        status: 'pending',
        conversationId: 'chat123',
        canCancel: true,
        save: jest.fn().mockResolvedValue(true),
        populate: jest.fn().mockResolvedValue({
          _id: 'booking123',
          serviceId: { _id: 'service123', serviceName: 'Test Service' },
          providerId: { _id: 'provider123', profile: { name: 'Provider' } },
          customerId: { _id: 'user123', profile: { name: 'Customer' } }
        })
      };

      Booking.findById = jest.fn().mockResolvedValue(mockBooking);
      Chat.findByIdAndUpdate = jest.fn().mockResolvedValue({
        _id: 'chat123',
        status: 'closed',
        closedAt: expect.any(Date),
        closedReason: 'cancelled'
      });

      const response = await request(app)
        .patch('/api/bookings/booking123/cancel')
        .send({ cancellationReason: 'Changed plans' })
        .expect(200);

      expect(mockBooking.status).toBe('cancelled');
      expect(Chat.findByIdAndUpdate).toHaveBeenCalledWith(
        'chat123',
        expect.objectContaining({
          status: 'closed',
          closedReason: 'cancelled'
        })
      );
    });
  });
});
