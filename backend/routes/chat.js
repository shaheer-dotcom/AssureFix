const express = require('express');
const { body, validationResult } = require('express-validator');
const multer = require('multer');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs');
const Chat = require('../models/Chat');
const auth = require('../middleware/auth');

const router = express.Router();

// Create uploads directory for chat images if it doesn't exist
const chatUploadsDir = path.join(__dirname, '../uploads/chat-images');
if (!fs.existsSync(chatUploadsDir)) {
  fs.mkdirSync(chatUploadsDir, { recursive: true });
}

// Configure multer for chat image uploads
const storage = multer.memoryStorage(); // Store in memory for compression

const imageFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const allowedMimeTypes = /image\/(jpeg|jpg|png|gif|webp)/;
  
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedMimeTypes.test(file.mimetype);

  if (mimetype || extname) {
    return cb(null, true);
  } else {
    cb(new Error('Only image files (JPG, JPEG, PNG, GIF, WEBP) are allowed'));
  }
};

const chatImageUpload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit before compression
  },
  fileFilter: imageFilter
});

// Create or get existing chat (DEPRECATED - chats are now created automatically with bookings)
// This endpoint is kept for backward compatibility but requires a bookingId
router.post('/create', auth, [
  body('serviceId').notEmpty(),
  body('providerId').notEmpty(),
  body('bookingId').optional()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { serviceId, providerId, bookingId } = req.body;
    const customerId = req.user._id;

    // Prevent chat creation without a booking
    if (!bookingId) {
      return res.status(400).json({ 
        message: 'Cannot create chat without an active booking. Please book the service first.',
        requiresBooking: true
      });
    }

    // Verify the booking exists and belongs to the user
    const Booking = require('../models/Booking');
    const booking = await Booking.findById(bookingId);
    
    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Verify user is either customer or provider in the booking
    const isCustomer = booking.customerId.toString() === customerId.toString();
    const isProvider = booking.providerId.toString() === providerId.toString();
    
    if (!isCustomer && !isProvider) {
      return res.status(403).json({ message: 'You are not authorized to create this chat' });
    }

    // Check if chat already exists for this booking
    let chat = await Chat.findOne({
      bookingId: bookingId
    }).populate('participants', 'profile.name profile.profilePicture');

    if (!chat) {
      // Create new chat linked to the booking
      chat = new Chat({
        serviceId,
        participants: [customerId, providerId],
        bookingId: bookingId,
        status: booking.status === 'confirmed' ? 'active' : 'pending'
      });
      await chat.save();
      await chat.populate('participants', 'profile.name profile.profilePicture');
    }

    res.json(chat);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get user's chats
router.get('/my-chats', auth, async (req, res) => {
  try {
    const chats = await Chat.find({
      participants: req.user._id
    })
    .populate('participants', 'profile.name profile.profilePicture')
    .populate('serviceId', 'serviceName areaCovered')
    .sort({ lastMessage: -1 });

    // Include messages in the response
    const chatsWithMessages = chats.map(chat => {
      const chatObj = chat.toObject();
      // Ensure messages array exists
      if (!chatObj.messages) {
        chatObj.messages = [];
      }
      return chatObj;
    });

    res.json(chatsWithMessages);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get chat by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const chat = await Chat.findById(req.params.id)
      .populate('participants', 'profile.name profile.profilePicture')
      .populate('serviceId', 'serviceName areaCovered pricePerHour')
      .populate('messages.senderId', 'profile.name profile.profilePicture');

    if (!chat) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    // Check if user is participant
    const isParticipant = chat.participants.some(
      participant => participant._id.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    res.json(chat);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Upload chat image
router.post('/:id/upload-image', auth, chatImageUpload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No image file uploaded' });
    }

    const chatId = req.params.id;

    // Verify user is participant in the chat
    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    const isParticipant = chat.participants.some(
      participant => participant.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const filename = `chat-image-${uniqueSuffix}.jpg`;
    const filepath = path.join(chatUploadsDir, filename);

    // Compress and save image using sharp
    await sharp(req.file.buffer)
      .resize(1200, 1200, {
        fit: 'inside',
        withoutEnlargement: true
      })
      .jpeg({ quality: 85 })
      .toFile(filepath);

    const imageUrl = `/uploads/chat-images/${filename}`;

    res.json({
      message: 'Image uploaded successfully',
      imageUrl: imageUrl,
      originalName: req.file.originalname
    });
  } catch (error) {
    console.error('Chat image upload error:', error);
    res.status(500).json({ message: 'Server error during image upload' });
  }
});

// Send message
router.post('/:id/messages', auth, [
  body('messageType').isIn(['text', 'voice', 'image', 'location', 'booking_request']),
  body('content').exists()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { messageType, content } = req.body;
    const chatId = req.params.id;

    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    // Check if user is participant
    const isParticipant = chat.participants.some(
      participant => participant.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Check if either user has blocked the other
    const User = require('../models/User');
    const currentUser = await User.findById(req.user._id);
    const otherParticipantId = chat.participants.find(
      p => p.toString() !== req.user._id.toString()
    );
    const otherUser = await User.findById(otherParticipantId);

    // Check if current user blocked the other user
    if (currentUser.blockedUsers.some(id => id.toString() === otherParticipantId.toString())) {
      return res.status(403).json({ 
        message: 'You have blocked this user. Unblock them to send messages.',
        blocked: true,
        blockedBy: 'you'
      });
    }

    // Check if other user blocked the current user
    if (otherUser.blockedUsers.some(id => id.toString() === req.user._id.toString())) {
      return res.status(403).json({ 
        message: 'You cannot send messages to this user.',
        blocked: true,
        blockedBy: 'them'
      });
    }

    // Check if chat has an associated booking
    if (!chat.bookingId) {
      return res.status(400).json({ 
        message: 'This chat is not associated with any booking. Please book the service first.',
        requiresBooking: true
      });
    }

    // Check if chat is closed (booking completed or cancelled)
    if (chat.status === 'closed') {
      const reason = chat.closedReason === 'completed' 
        ? 'The booking has been completed' 
        : 'The booking has been cancelled';
      return res.status(400).json({ 
        message: `Cannot send messages. ${reason}.`,
        chatStatus: 'closed',
        closedReason: chat.closedReason
      });
    }

    // Validate message content based on type
    if (messageType === 'image' && !content.imageUrl) {
      return res.status(400).json({ message: 'Image URL is required for image messages' });
    }

    const message = {
      senderId: req.user._id,
      messageType,
      content,
      timestamp: new Date()
    };

    chat.messages.push(message);
    chat.lastMessage = new Date();
    
    // Activate chat if it was pending
    if (chat.status === 'pending') {
      chat.status = 'active';
    }

    await chat.save();

    // Populate sender information before returning
    await chat.populate('messages.senderId', 'profile.name profile.profilePicture');
    
    // Return the newly created message with populated sender data
    const populatedMessage = chat.messages[chat.messages.length - 1];

    res.json(populatedMessage);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get chat status
router.get('/:id/status', auth, async (req, res) => {
  try {
    const chat = await Chat.findById(req.params.id)
      .populate('bookingId', 'status');

    if (!chat) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    // Check if user is participant
    const isParticipant = chat.participants.some(
      participant => participant.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    res.json({
      chatStatus: chat.status,
      closedAt: chat.closedAt,
      closedReason: chat.closedReason,
      bookingStatus: chat.bookingId ? chat.bookingId.status : null
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Reopen chat for repeat bookings
router.post('/:id/reopen', auth, [
  body('bookingId').notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { bookingId } = req.body;
    const chatId = req.params.id;

    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    // Check if user is participant
    const isParticipant = chat.participants.some(
      participant => participant.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    // Reopen conversation and update status to active
    chat.status = 'active';
    chat.bookingId = bookingId;
    chat.closedAt = null;
    chat.closedReason = null;
    chat.lastMessage = new Date();

    await chat.save();

    res.json({ 
      message: 'Chat reopened successfully',
      chat: chat
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Mark messages as delivered
router.patch('/:id/delivered', auth, async (req, res) => {
  try {
    const chat = await Chat.findById(req.params.id);
    if (!chat) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    // Check if user is participant
    const isParticipant = chat.participants.some(
      participant => participant.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    const now = new Date();
    let updatedCount = 0;

    // Mark all undelivered messages from other participants as delivered
    chat.messages.forEach(message => {
      if (message.senderId.toString() !== req.user._id.toString() && !message.deliveredAt) {
        message.deliveredAt = now;
        updatedCount++;
      }
    });

    if (updatedCount > 0) {
      await chat.save();
    }

    res.json({ 
      message: 'Messages marked as delivered',
      updatedCount: updatedCount
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Mark messages as read
router.patch('/:id/read', auth, async (req, res) => {
  try {
    const chat = await Chat.findById(req.params.id);
    if (!chat) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    // Check if user is participant
    const isParticipant = chat.participants.some(
      participant => participant.toString() === req.user._id.toString()
    );

    if (!isParticipant) {
      return res.status(403).json({ message: 'Access denied' });
    }

    const now = new Date();
    let updatedCount = 0;

    // Mark all unread messages from other participants as read
    chat.messages.forEach(message => {
      if (message.senderId.toString() !== req.user._id.toString()) {
        if (!message.isRead) {
          message.isRead = true;
          updatedCount++;
        }
        if (!message.readAt) {
          message.readAt = now;
        }
        // Ensure deliveredAt is set if not already
        if (!message.deliveredAt) {
          message.deliveredAt = now;
        }
      }
    });

    if (updatedCount > 0) {
      await chat.save();
    }

    res.json({ 
      message: 'Messages marked as read',
      updatedCount: updatedCount
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;