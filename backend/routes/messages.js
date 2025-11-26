const express = require('express');
const { body, validationResult } = require('express-validator');
const multer = require('multer');
const path = require('path');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const Booking = require('../models/Booking');
const auth = require('../middleware/auth');
const { notifyNewMessage } = require('../services/notificationService');

const router = express.Router();

// Configure multer for media uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/messages/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'message-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  // Accept images and audio files
  if (file.mimetype.startsWith('image/') || file.mimetype.startsWith('audio/')) {
    cb(null, true);
  } else {
    cb(new Error('Only image and audio files are allowed'), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Get all user conversations
router.get('/conversations', auth, async (req, res) => {
  try {
    const User = require('../models/User');
    const currentUser = await User.findById(req.user._id).select('blockedUsers');
    
    const conversations = await Conversation.find({
      participants: req.user._id
    })
      .populate('participants', 'profile.name profile.profilePicture')
      .populate('relatedBooking', 'serviceId status')
      .populate({
        path: 'relatedBooking',
        populate: {
          path: 'serviceId',
          select: 'serviceName'
        }
      })
      .sort({ 'lastMessage.timestamp': -1 });

    // Filter out conversations with blocked users
    let filteredConversations = conversations;
    if (currentUser && currentUser.blockedUsers.length > 0) {
      const blockedUserIds = currentUser.blockedUsers.map(id => id.toString());
      filteredConversations = conversations.filter(conversation => {
        const otherParticipant = conversation.participants.find(
          p => p._id.toString() !== req.user._id.toString()
        );
        return otherParticipant && !blockedUserIds.includes(otherParticipant._id.toString());
      });
    }

    // Get unread count for each conversation
    const conversationsWithUnread = await Promise.all(
      filteredConversations.map(async (conversation) => {
        const unreadCount = await Message.countDocuments({
          conversationId: conversation._id,
          receiverId: req.user._id,
          isRead: false
        });

        return {
          ...conversation.toObject(),
          unreadCount
        };
      })
    );

    res.json(conversationsWithUnread);
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get messages in a conversation
router.get('/:conversationId', auth, async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { page = 1, limit = 50 } = req.query;

    // Verify conversation exists and user is participant
    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({ message: 'Conversation not found' });
    }

    const isParticipant = conversation.participants.some(
      participant => participant.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Get messages with pagination
    const messages = await Message.find({ conversationId })
      .populate('senderId', 'profile.name profile.profilePicture')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    // Return in chronological order
    messages.reverse();

    res.json({
      conversation,
      messages,
      page: parseInt(page),
      limit: parseInt(limit)
    });
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Send a text message
router.post('/', auth, [
  body('conversationId').notEmpty().withMessage('Conversation ID is required'),
  body('messageType').isIn(['text', 'location']).withMessage('Invalid message type'),
  body('content').if(body('messageType').equals('text')).notEmpty().withMessage('Content is required for text messages'),
  body('location.latitude').if(body('messageType').equals('location')).isFloat().withMessage('Valid latitude is required'),
  body('location.longitude').if(body('messageType').equals('location')).isFloat().withMessage('Valid longitude is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { conversationId, messageType, content, location } = req.body;

    // Verify conversation exists and user is participant
    const conversation = await Conversation.findById(conversationId)
      .populate('relatedBooking');
    
    if (!conversation) {
      return res.status(404).json({ message: 'Conversation not found' });
    }

    const isParticipant = conversation.participants.some(
      participant => participant.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Check if user has blocked or been blocked by the other participant
    const User = require('../models/User');
    const currentUser = await User.findById(req.user._id).select('blockedUsers');
    const otherParticipantId = conversation.participants.find(
      p => p.toString() !== req.user._id.toString()
    );
    
    if (currentUser.blockedUsers.includes(otherParticipantId)) {
      return res.status(403).json({ message: 'Cannot send messages to blocked user' });
    }

    const otherUser = await User.findById(otherParticipantId).select('blockedUsers');
    if (otherUser && otherUser.blockedUsers.includes(req.user._id)) {
      return res.status(403).json({ message: 'Cannot send messages. You have been blocked by this user' });
    }

    // Check if conversation is active (booking status is pending or active)
    const booking = conversation.relatedBooking;
    if (!['pending', 'confirmed', 'in_progress'].includes(booking.status)) {
      return res.status(400).json({ 
        message: 'Cannot send messages. Booking is completed or cancelled.',
        isActive: false
      });
    }

    // Determine receiver
    const receiverId = conversation.participants.find(
      participant => participant.toString() !== req.user._id.toString()
    );

    // Create message
    const message = new Message({
      conversationId,
      senderId: req.user._id,
      receiverId,
      messageType,
      content: messageType === 'text' ? content : undefined,
      location: messageType === 'location' ? location : undefined
    });

    await message.save();
    await message.populate('senderId', 'profile.name profile.profilePicture');

    // Update conversation's last message
    conversation.lastMessage = {
      content: messageType === 'text' ? content : `Shared ${messageType}`,
      timestamp: message.createdAt,
      senderId: req.user._id
    };
    await conversation.save();

    // Send notification to receiver
    await notifyNewMessage(message, conversation, req.user);

    res.status(201).json(message);
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Upload media (voice notes and images)
router.post('/upload-media', auth, upload.single('media'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const { conversationId, messageType } = req.body;

    if (!conversationId || !messageType) {
      return res.status(400).json({ message: 'Conversation ID and message type are required' });
    }

    if (!['voice', 'image'].includes(messageType)) {
      return res.status(400).json({ message: 'Invalid message type for media upload' });
    }

    // Verify conversation exists and user is participant
    const conversation = await Conversation.findById(conversationId)
      .populate('relatedBooking');
    
    if (!conversation) {
      return res.status(404).json({ message: 'Conversation not found' });
    }

    const isParticipant = conversation.participants.some(
      participant => participant.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Check if user has blocked or been blocked by the other participant
    const User = require('../models/User');
    const currentUser = await User.findById(req.user._id).select('blockedUsers');
    const otherParticipantId = conversation.participants.find(
      p => p.toString() !== req.user._id.toString()
    );
    
    if (currentUser.blockedUsers.includes(otherParticipantId)) {
      return res.status(403).json({ message: 'Cannot send messages to blocked user' });
    }

    const otherUser = await User.findById(otherParticipantId).select('blockedUsers');
    if (otherUser && otherUser.blockedUsers.includes(req.user._id)) {
      return res.status(403).json({ message: 'Cannot send messages. You have been blocked by this user' });
    }

    // Check if conversation is active
    const booking = conversation.relatedBooking;
    if (!['pending', 'confirmed', 'in_progress'].includes(booking.status)) {
      return res.status(400).json({ 
        message: 'Cannot send messages. Booking is completed or cancelled.',
        isActive: false
      });
    }

    // Determine receiver
    const receiverId = conversation.participants.find(
      participant => participant.toString() !== req.user._id.toString()
    );

    // Create message with file path
    const message = new Message({
      conversationId,
      senderId: req.user._id,
      receiverId,
      messageType,
      content: req.file.path
    });

    await message.save();
    await message.populate('senderId', 'profile.name profile.profilePicture');

    // Update conversation's last message
    conversation.lastMessage = {
      content: messageType === 'voice' ? 'Voice message' : 'Image',
      timestamp: message.createdAt,
      senderId: req.user._id
    };
    await conversation.save();

    // Send notification to receiver
    await notifyNewMessage(message, conversation, req.user);

    res.status(201).json(message);
  } catch (error) {
    console.error('Error uploading media:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Mark message as read
router.patch('/:id/read', auth, async (req, res) => {
  try {
    const message = await Message.findById(req.params.id);
    
    if (!message) {
      return res.status(404).json({ message: 'Message not found' });
    }

    // Only receiver can mark message as read
    if (message.receiverId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Access denied' });
    }

    message.isRead = true;
    await message.save();

    res.json({ message: 'Message marked as read' });
  } catch (error) {
    console.error('Error marking message as read:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get unread message count
router.get('/unread-count', auth, async (req, res) => {
  try {
    const unreadCount = await Message.countDocuments({
      receiverId: req.user._id,
      isRead: false
    });

    res.json({ unreadCount });
  } catch (error) {
    console.error('Error fetching unread count:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
