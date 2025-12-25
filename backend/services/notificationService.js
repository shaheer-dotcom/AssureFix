const Notification = require('../models/Notification');

/**
 * Create booking notification payload structure
 * @param {Object} booking - Booking object
 * @param {Object} service - Service object
 * @param {Object} customer - Customer user object
 * @returns {Object} Notification payload with booking details and action buttons
 */
const createBookingNotificationPayload = (booking, service, customer) => {
  const reservationDate = new Date(booking.reservationDate);
  const dateStr = reservationDate.toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });
  const timeStr = reservationDate.toLocaleTimeString('en-US', { 
    hour: '2-digit', 
    minute: '2-digit' 
  });

  return {
    title: booking.bookingType === 'immediate' ? 'New Immediate Booking Request' : 'New Booking Request',
    body: `${customer.profile.name} has requested your service "${service.serviceName}"${booking.bookingType === 'immediate' ? ' (IMMEDIATE)' : ''}`,
    data: {
      type: 'booking_request',
      bookingId: booking._id.toString(),
      serviceId: service._id.toString(),
      customerId: customer._id.toString(),
      serviceName: service.serviceName,
      customerName: customer.profile.name,
      customerPhone: booking.customerDetails.phoneNumber,
      customerAddress: booking.customerDetails.exactAddress,
      reservationDate: booking.reservationDate.toISOString(),
      reservationDateFormatted: dateStr,
      reservationTime: timeStr,
      hoursBooked: booking.hoursBooked,
      totalAmount: booking.totalAmount,
      bookingType: booking.bookingType || 'reservation',
      actions: [
        {
          action: 'accept',
          title: 'Accept',
          icon: 'check',
          color: '#4CAF50'
        },
        {
          action: 'decline',
          title: 'Decline',
          icon: 'close',
          color: '#F44336'
        }
      ]
    },
    priority: 'high',
    sound: 'default'
  };
};

/**
 * Send push notification to user
 * @param {String} userId - User ID to send notification to
 * @param {Object} payload - Notification payload
 * @returns {Promise<Boolean>} Success status
 */
const sendPushNotification = async (userId, payload) => {
  try {
    // TODO: Implement actual push notification sending using FCM/Expo
    // This is a placeholder that logs the notification
    // In production, this would use Firebase Cloud Messaging or Expo Push Notifications
    
    console.log('Push notification would be sent to user:', userId);
    console.log('Notification payload:', JSON.stringify(payload, null, 2));
    
    // For now, return true to indicate the notification was "sent"
    // In production, this would return the actual FCM/Expo response
    return true;
  } catch (error) {
    console.error('Error sending push notification:', error);
    // Don't throw error - notification failure shouldn't break the flow
    return false;
  }
};

/**
 * Create a notification for a user
 * @param {Object} notificationData - Notification data
 * @param {String} notificationData.userId - User ID to send notification to
 * @param {String} notificationData.type - Type of notification (booking, message, admin, update)
 * @param {String} notificationData.title - Notification title
 * @param {String} notificationData.message - Notification message
 * @param {String} notificationData.relatedBooking - Related booking ID (optional)
 * @param {String} notificationData.relatedMessage - Related message ID (optional)
 * @param {String} notificationData.actionUrl - Action URL (optional)
 * @returns {Promise<Notification>} Created notification
 */
const createNotification = async (notificationData) => {
  try {
    const notification = new Notification(notificationData);
    await notification.save();
    return notification;
  } catch (error) {
    console.error('Error creating notification:', error);
    throw error;
  }
};

/**
 * Send booking notification to service provider with action buttons
 * @param {Object} booking - Booking object
 * @param {Object} service - Service object
 * @param {Object} customer - Customer user object
 * @returns {Promise<Object>} Notification result with database and push notification status
 */
const sendBookingNotification = async (booking, service, customer) => {
  try {
    // Create notification payload with booking details and action buttons
    const payload = createBookingNotificationPayload(booking, service, customer);
    
    // Create in-app notification in database
    const notification = await createNotification({
      userId: booking.providerId,
      type: 'booking',
      title: payload.title,
      message: payload.body,
      relatedBooking: booking._id,
      actionUrl: `/bookings/${booking._id}`,
      bookingData: {
        bookingId: booking._id.toString(),
        serviceName: service.serviceName,
        customerName: customer.profile.name,
        customerPhone: booking.customerDetails.phoneNumber,
        customerAddress: booking.customerDetails.exactAddress,
        reservationDate: booking.reservationDate,
        hoursBooked: booking.hoursBooked,
        totalAmount: booking.totalAmount,
        status: booking.status,
        bookingType: booking.bookingType || 'reservation'
      }
    });
    
    // Send push notification to service provider
    const pushSent = await sendPushNotification(booking.providerId, payload);
    
    return {
      success: true,
      notification,
      pushNotificationSent: pushSent
    };
  } catch (error) {
    console.error('Error sending booking notification:', error);
    // Return partial success if database notification was created but push failed
    return {
      success: false,
      error: error.message
    };
  }
};

/**
 * Create notification when a booking is created
 * @param {Object} booking - Booking object
 * @param {Object} service - Service object
 * @param {Object} customer - Customer user object
 */
const notifyBookingCreated = async (booking, service, customer) => {
  try {
    await sendBookingNotification(booking, service, customer);
  } catch (error) {
    console.error('Error creating booking notification:', error);
  }
};

/**
 * Create notification when a booking is accepted/confirmed
 * @param {Object} booking - Booking object
 * @param {Object} service - Service object
 * @param {Object} provider - Provider user object
 */
const notifyBookingAccepted = async (booking, service, provider) => {
  try {
    await createNotification({
      userId: booking.customerId,
      type: 'booking',
      title: 'Booking Confirmed',
      message: `${provider.profile.name} has confirmed your booking for "${service.serviceName}" on ${new Date(booking.reservationDate).toLocaleDateString()}`,
      relatedBooking: booking._id,
      actionUrl: `/bookings/${booking._id}`
    });
  } catch (error) {
    console.error('Error creating booking accepted notification:', error);
  }
};

/**
 * Create notifications when a booking is completed
 * @param {Object} booking - Booking object
 * @param {Object} service - Service object
 * @param {Object} customer - Customer user object
 * @param {Object} provider - Provider user object
 */
const notifyBookingCompleted = async (booking, service, customer, provider) => {
  try {
    // Notify customer
    await createNotification({
      userId: booking.customerId,
      type: 'booking',
      title: 'Booking Completed',
      message: `Your booking for "${service.serviceName}" with ${provider.profile.name} has been completed. Please rate your experience.`,
      relatedBooking: booking._id,
      actionUrl: `/bookings/${booking._id}/rate`
    });

    // Notify provider
    await createNotification({
      userId: booking.providerId,
      type: 'booking',
      title: 'Booking Completed',
      message: `Your booking for "${service.serviceName}" with ${customer.profile.name} has been completed. Please rate your experience.`,
      relatedBooking: booking._id,
      actionUrl: `/bookings/${booking._id}/rate`
    });
  } catch (error) {
    console.error('Error creating booking completed notifications:', error);
  }
};

/**
 * Create notification when one party initiates booking completion
 * @param {Object} booking - Booking object
 * @param {Object} service - Service object
 * @param {Object} customer - Customer user object
 * @param {Object} provider - Provider user object
 * @param {String} initiatedBy - Who initiated completion (customer or provider)
 */
const notifyBookingCompletionConfirmation = async (booking, service, customer, provider, initiatedBy) => {
  try {
    const recipientId = initiatedBy === 'customer' ? booking.providerId : booking.customerId;
    const initiatorName = initiatedBy === 'customer' ? customer.profile.name : provider.profile.name;
    const recipientName = initiatedBy === 'customer' ? provider.profile.name : customer.profile.name;

    await createNotification({
      userId: recipientId,
      type: 'booking_completion_confirmation',
      title: 'Confirm Booking Completion',
      message: `${initiatorName} has marked the booking for "${service.serviceName}" as completed. Please confirm if the service was completed.`,
      relatedBooking: booking._id,
      actionUrl: `/bookings/${booking._id}/confirm-completion`,
      bookingData: {
        bookingId: booking._id.toString(),
        serviceName: service.serviceName,
        customerName: customer.profile.name,
        providerName: provider.profile.name,
        customerAddress: booking.customerDetails.exactAddress,
        customerPhone: booking.customerDetails.phoneNumber,
        reservationDate: booking.reservationDate,
        hoursBooked: booking.hoursBooked,
        totalAmount: booking.totalAmount,
        status: booking.status,
        initiatedBy: initiatedBy
      }
    });
  } catch (error) {
    console.error('Error creating booking completion confirmation notification:', error);
  }
};

/**
 * Create notifications when a booking is cancelled
 * @param {Object} booking - Booking object
 * @param {Object} service - Service object
 * @param {Object} customer - Customer user object
 * @param {Object} provider - Provider user object
 * @param {String} cancelledBy - Who cancelled (customer or provider)
 */
const notifyBookingCancelled = async (booking, service, customer, provider, cancelledBy) => {
  try {
    if (cancelledBy === 'customer') {
      // Notify provider
      await createNotification({
        userId: booking.providerId,
        type: 'booking',
        title: 'Booking Cancelled',
        message: `${customer.profile.name} has cancelled the booking for "${service.serviceName}" scheduled for ${new Date(booking.reservationDate).toLocaleDateString()}`,
        relatedBooking: booking._id,
        actionUrl: `/bookings/${booking._id}`
      });
    } else {
      // Notify customer
      await createNotification({
        userId: booking.customerId,
        type: 'booking',
        title: 'Booking Cancelled',
        message: `${provider.profile.name} has cancelled your booking for "${service.serviceName}" scheduled for ${new Date(booking.reservationDate).toLocaleDateString()}`,
        relatedBooking: booking._id,
        actionUrl: `/bookings/${booking._id}`
      });
    }
  } catch (error) {
    console.error('Error creating booking cancelled notification:', error);
  }
};

/**
 * Create notification when a new message is sent
 * @param {Object} message - Message object
 * @param {Object} conversation - Conversation object
 * @param {Object} sender - Sender user object
 */
const notifyNewMessage = async (message, conversation, sender) => {
  try {
    const messagePreview = message.messageType === 'text' 
      ? message.content.substring(0, 50) 
      : `Sent a ${message.messageType}`;

    await createNotification({
      userId: message.receiverId,
      type: 'message',
      title: `New message from ${sender.profile.name}`,
      message: messagePreview,
      relatedMessage: message._id,
      actionUrl: `/messages/${conversation._id}`
    });
  } catch (error) {
    console.error('Error creating message notification:', error);
  }
};

/**
 * Create call notification payload structure
 * @param {Object} call - Call object
 * @param {Object} caller - Caller user object
 * @returns {Object} Notification payload with call details
 */
const createCallNotificationPayload = (call, caller) => {
  return {
    title: 'Incoming Voice Call',
    body: `${caller.profile.name} is calling you`,
    data: {
      type: 'incoming_call',
      callId: call._id.toString(),
      callerId: call.callerId._id ? call.callerId._id.toString() : call.callerId.toString(),
      callerName: caller.profile.name,
      callerProfilePicture: caller.profile.profilePicture || null,
      channelName: call.agoraChannelName,
      conversationId: call.conversationId ? call.conversationId.toString() : null,
      actions: [
        {
          action: 'accept',
          title: 'Accept',
          icon: 'call',
          color: '#4CAF50'
        },
        {
          action: 'reject',
          title: 'Reject',
          icon: 'call_end',
          color: '#F44336'
        }
      ]
    },
    priority: 'high',
    sound: 'default',
    category: 'call'
  };
};

/**
 * Send call notification to receiver
 * @param {Object} call - Call object
 * @param {Object} receiver - Receiver user object
 * @returns {Promise<Object>} Notification result
 */
const sendCallNotification = async (call, receiver) => {
  try {
    // Get caller information
    let caller;
    if (call.callerId.profile) {
      // Already populated
      caller = call.callerId;
    } else {
      // Need to fetch caller
      const User = require('../models/User');
      caller = await User.findById(call.callerId);
      if (!caller) {
        throw new Error('Caller not found');
      }
    }

    // Create notification payload with call details
    const payload = createCallNotificationPayload(call, caller);
    
    // Create in-app notification in database
    const notification = await createNotification({
      userId: receiver._id,
      type: 'call',
      title: payload.title,
      message: payload.body,
      actionUrl: `/calls/${call._id}`
    });
    
    // Send push notification to receiver
    const pushSent = await sendPushNotification(receiver._id, payload);
    
    return {
      success: true,
      notification,
      pushNotificationSent: pushSent
    };
  } catch (error) {
    console.error('Error sending call notification:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

module.exports = {
  createNotification,
  createBookingNotificationPayload,
  sendPushNotification,
  sendBookingNotification,
  notifyBookingCreated,
  notifyBookingAccepted,
  notifyBookingCompleted,
  notifyBookingCompletionConfirmation,
  notifyBookingCancelled,
  notifyNewMessage,
  createCallNotificationPayload,
  sendCallNotification
};
