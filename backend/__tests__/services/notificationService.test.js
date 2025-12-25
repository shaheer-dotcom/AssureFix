const {
  createBookingNotificationPayload,
  createCallNotificationPayload,
  sendPushNotification
} = require('../../services/notificationService');

describe('Notification Service', () => {
  describe('createBookingNotificationPayload', () => {
    it('should create valid booking notification payload with all required fields', () => {
      const booking = {
        _id: '507f1f77bcf86cd799439011',
        reservationDate: new Date('2024-12-15T10:00:00Z'),
        hoursBooked: 3,
        totalAmount: 150,
        customerDetails: {
          phoneNumber: '+1234567890',
          exactAddress: '123 Main St'
        }
      };

      const service = {
        _id: '507f1f77bcf86cd799439012',
        serviceName: 'House Cleaning'
      };

      const customer = {
        _id: '507f1f77bcf86cd799439013',
        profile: {
          name: 'John Doe'
        }
      };

      const payload = createBookingNotificationPayload(booking, service, customer);

      expect(payload).toHaveProperty('title', 'New Booking Request');
      expect(payload.body).toContain('John Doe');
      expect(payload.body).toContain('House Cleaning');
      expect(payload.data).toHaveProperty('type', 'booking_request');
      expect(payload.data).toHaveProperty('bookingId', booking._id.toString());
      expect(payload.data).toHaveProperty('serviceName', 'House Cleaning');
      expect(payload.data).toHaveProperty('customerName', 'John Doe');
      expect(payload.data).toHaveProperty('hoursBooked', 3);
      expect(payload.data).toHaveProperty('totalAmount', 150);
      expect(payload.data.actions).toHaveLength(2);
      expect(payload.data.actions[0]).toHaveProperty('action', 'accept');
      expect(payload.data.actions[1]).toHaveProperty('action', 'decline');
    });

    it('should format reservation date and time correctly', () => {
      const booking = {
        _id: '507f1f77bcf86cd799439011',
        reservationDate: new Date('2024-12-15T14:30:00Z'),
        hoursBooked: 2,
        totalAmount: 100,
        customerDetails: {
          phoneNumber: '+1234567890',
          exactAddress: '123 Main St'
        }
      };

      const service = {
        _id: '507f1f77bcf86cd799439012',
        serviceName: 'Plumbing'
      };

      const customer = {
        _id: '507f1f77bcf86cd799439013',
        profile: {
          name: 'Jane Smith'
        }
      };

      const payload = createBookingNotificationPayload(booking, service, customer);

      expect(payload.data).toHaveProperty('reservationDateFormatted');
      expect(payload.data).toHaveProperty('reservationTime');
      expect(payload.data.reservationDateFormatted).toBeTruthy();
      expect(payload.data.reservationTime).toBeTruthy();
    });
  });

  describe('createCallNotificationPayload', () => {
    it('should create valid call notification payload with all required fields', () => {
      const call = {
        _id: '507f1f77bcf86cd799439014',
        callerId: {
          _id: '507f1f77bcf86cd799439015',
          profile: {
            name: 'Alice Johnson',
            profilePicture: 'https://example.com/alice.jpg'
          }
        },
        agoraChannelName: 'channel_123',
        conversationId: '507f1f77bcf86cd799439016'
      };

      const caller = call.callerId;

      const payload = createCallNotificationPayload(call, caller);

      expect(payload).toHaveProperty('title', 'Incoming Voice Call');
      expect(payload.body).toContain('Alice Johnson');
      expect(payload.data).toHaveProperty('type', 'incoming_call');
      expect(payload.data).toHaveProperty('callId', call._id.toString());
      expect(payload.data).toHaveProperty('callerName', 'Alice Johnson');
      expect(payload.data).toHaveProperty('channelName', 'channel_123');
      expect(payload.data.actions).toHaveLength(2);
      expect(payload.data.actions[0]).toHaveProperty('action', 'accept');
      expect(payload.data.actions[1]).toHaveProperty('action', 'reject');
      expect(payload).toHaveProperty('priority', 'high');
      expect(payload).toHaveProperty('category', 'call');
    });

    it('should handle missing profile picture', () => {
      const call = {
        _id: '507f1f77bcf86cd799439014',
        callerId: {
          _id: '507f1f77bcf86cd799439015',
          profile: {
            name: 'Bob Wilson'
          }
        },
        agoraChannelName: 'channel_456',
        conversationId: null
      };

      const caller = call.callerId;

      const payload = createCallNotificationPayload(call, caller);

      expect(payload.data).toHaveProperty('callerProfilePicture', null);
      expect(payload.data).toHaveProperty('conversationId', null);
    });
  });

  describe('sendPushNotification', () => {
    it('should return true for successful notification send', async () => {
      const userId = '507f1f77bcf86cd799439017';
      const payload = {
        title: 'Test Notification',
        body: 'This is a test',
        data: { type: 'test' }
      };

      const result = await sendPushNotification(userId, payload);

      expect(result).toBe(true);
    });

    it('should return true even with null values (logs but does not throw)', async () => {
      const userId = null;
      const payload = null;

      const result = await sendPushNotification(userId, payload);

      // Current implementation logs but returns true
      expect(result).toBe(true);
    });
  });
});
