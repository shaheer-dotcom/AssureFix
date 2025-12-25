const request = require('supertest');
const express = require('express');

// Mock models and middleware
jest.mock('../../models/Chat');
jest.mock('../../middleware/auth');

const Chat = require('../../models/Chat');
const auth = require('../../middleware/auth');
const chatRouter = require('../../routes/chat');

// Create Express app for testing
const app = express();
app.use(express.json());
app.use('/api/chat', chatRouter);

describe('Chat Routes - Message Validation', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    
    // Mock auth middleware
    auth.mockImplementation((req, res, next) => {
      req.user = { _id: 'user123' };
      next();
    });
  });

  describe('POST /api/chat/:id/messages', () => {
    it('should prevent message sending when chat is closed', async () => {
      const mockChat = {
        _id: 'chat123',
        participants: ['user123', 'user456'],
        status: 'closed',
        closedReason: 'completed',
        messages: []
      };

      Chat.findById = jest.fn().mockResolvedValue(mockChat);

      const response = await request(app)
        .post('/api/chat/chat123/messages')
        .send({
          messageType: 'text',
          content: { text: 'Hello' }
        })
        .expect(400);

      expect(response.body.message).toContain('Cannot send messages');
      expect(response.body.chatStatus).toBe('closed');
      expect(response.body.closedReason).toBe('completed');
    });

    it('should allow message sending when chat is active', async () => {
      const mockChat = {
        _id: 'chat123',
        participants: ['user123', 'user456'],
        status: 'active',
        messages: [],
        lastMessage: new Date(),
        save: jest.fn().mockResolvedValue(true),
        populate: jest.fn().mockResolvedValue({
          messages: [{
            senderId: { _id: 'user123', profile: { name: 'User' } },
            messageType: 'text',
            content: { text: 'Hello' },
            timestamp: new Date()
          }]
        })
      };

      mockChat.messages.push = jest.fn();

      Chat.findById = jest.fn().mockResolvedValue(mockChat);

      const response = await request(app)
        .post('/api/chat/chat123/messages')
        .send({
          messageType: 'text',
          content: { text: 'Hello' }
        })
        .expect(200);

      expect(mockChat.messages.push).toHaveBeenCalled();
      expect(mockChat.save).toHaveBeenCalled();
    });

    it('should validate image message has imageUrl', async () => {
      const mockChat = {
        _id: 'chat123',
        participants: ['user123', 'user456'],
        status: 'active'
      };

      Chat.findById = jest.fn().mockResolvedValue(mockChat);

      const response = await request(app)
        .post('/api/chat/chat123/messages')
        .send({
          messageType: 'image',
          content: { text: 'Image without URL' }
        })
        .expect(400);

      expect(response.body.message).toContain('Image URL is required');
    });

    it('should reject if user is not a participant', async () => {
      const mockChat = {
        _id: 'chat123',
        participants: ['user456', 'user789'],
        status: 'active'
      };

      Chat.findById = jest.fn().mockResolvedValue(mockChat);

      const response = await request(app)
        .post('/api/chat/chat123/messages')
        .send({
          messageType: 'text',
          content: { text: 'Hello' }
        })
        .expect(403);

      expect(response.body.message).toBe('Access denied');
    });
  });

  describe('POST /api/chat/:id/reopen', () => {
    it('should reopen closed chat with new booking', async () => {
      const mockChat = {
        _id: 'chat123',
        participants: ['user123', 'user456'],
        status: 'closed',
        closedAt: new Date(),
        closedReason: 'completed',
        save: jest.fn().mockResolvedValue(true)
      };

      Chat.findById = jest.fn().mockResolvedValue(mockChat);

      const response = await request(app)
        .post('/api/chat/chat123/reopen')
        .send({ bookingId: 'newbooking123' })
        .expect(200);

      expect(mockChat.status).toBe('active');
      expect(mockChat.bookingId).toBe('newbooking123');
      expect(mockChat.closedAt).toBeNull();
      expect(mockChat.closedReason).toBeNull();
      expect(mockChat.save).toHaveBeenCalled();
    });
  });

  describe('PATCH /api/chat/:id/read', () => {
    it('should mark messages as read and set timestamps', async () => {
      const message1 = {
        senderId: { toString: () => 'user456' },
        isRead: false,
        readAt: null,
        deliveredAt: null
      };
      
      const message2 = {
        senderId: { toString: () => 'user456' },
        isRead: false,
        readAt: null,
        deliveredAt: null
      };

      const mockChat = {
        _id: 'chat123',
        participants: [
          { toString: () => 'user123' },
          { toString: () => 'user456' }
        ],
        messages: [message1, message2],
        save: jest.fn().mockResolvedValue(true)
      };

      Chat.findById = jest.fn().mockResolvedValue(mockChat);

      const response = await request(app)
        .patch('/api/chat/chat123/read')
        .expect(200);

      expect(response.body.updatedCount).toBe(2);
      expect(mockChat.save).toHaveBeenCalled();
    });
  });
});
