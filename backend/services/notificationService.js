const Notification = require('../models/Notification');

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
 * Create notification when a booking is created
 * @param {Object} booking - Booking object
 * @param {Object} service - Service object
 * @param {Object} customer - Customer user object
 */
const notifyBookingCreated = async (booking, service, customer) => {
  try {
    await createNotification({
      userId: booking.providerId,
      type: 'booking',
      title: 'New Booking Request',
      message: `${customer.profile.name} has booked your service "${service.serviceName}" for ${new Date(booking.reservationDate).toLocaleDateString()}`,
      relatedBooking: booking._id,
      actionUrl: `/bookings/${booking._id}`
    });
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

module.exports = {
  createNotification,
  notifyBookingCreated,
  notifyBookingAccepted,
  notifyBookingCompleted,
  notifyBookingCancelled,
  notifyNewMessage
};
