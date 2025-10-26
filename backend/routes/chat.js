const express = require('express');
const { body, validationResult } = require('express-validator');
const Chat = require('../models/Chat');
const auth = require('../middleware/auth');

const router = express.Router();

// Create or get existing chat
router.post('/create', auth, [
  body('serviceId').notEmpty(),
  body('providerId').notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { serviceId, providerId } = req.body;
    const customerId = req.user._id;

    // Check if chat already exists
    let chat = await Chat.findOne({
      serviceId,
      participants: { $all: [customerId, providerId] }
    }).populate('participants', 'profile.name profile.profilePicture');

    if (!chat) {
      // Create new chat
      chat = new Chat({
        serviceId,
        participants: [customerId, providerId],
        status: 'pending'
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

    res.json(chats);
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
      .populate('serviceId', 'serviceName areaCovered pricePerHour');

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

// Send message
router.post('/:id/messages', auth, [
  body('messageType').isIn(['text', 'voice', 'location', 'booking_request']),
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

    res.json(message);
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

    // Mark all messages from other participants as read
    chat.messages.forEach(message => {
      if (message.senderId.toString() !== req.user._id.toString()) {
        message.isRead = true;
      }
    });

    await chat.save();

    res.json({ message: 'Messages marked as read' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;