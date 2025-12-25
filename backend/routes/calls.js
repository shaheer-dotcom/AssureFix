const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Call = require('../models/Call');
const User = require('../models/User');
const Chat = require('../models/Chat');
const { generateAgoraToken, generateChannelName } = require('../utils/agoraToken');
const { sendCallNotification } = require('../services/notificationService');

/**
 * POST /api/calls/initiate
 * Initiate a voice call
 */
router.post('/initiate', auth, async (req, res) => {
  try {
    const { receiverId, conversationId } = req.body;
    const callerId = req.user.userId;

    // Validate required fields
    if (!receiverId) {
      return res.status(400).json({ message: 'Receiver ID is required' });
    }

    // Check if receiver exists
    const receiver = await User.findById(receiverId);
    if (!receiver) {
      return res.status(404).json({ message: 'Receiver not found' });
    }

    // Check if caller is trying to call themselves
    if (callerId === receiverId) {
      return res.status(400).json({ message: 'Cannot call yourself' });
    }

    // Verify conversation exists if conversationId is provided
    if (conversationId) {
      const conversation = await Chat.findById(conversationId);
      if (!conversation) {
        return res.status(404).json({ message: 'Conversation not found' });
      }

      // Verify caller is a participant in the conversation
      const isParticipant = conversation.participants.some(
        p => p.toString() === callerId
      );
      if (!isParticipant) {
        return res.status(403).json({ message: 'You are not a participant in this conversation' });
      }
    }

    // Generate unique channel name
    const channelName = generateChannelName(callerId, receiverId);

    // Generate Agora token for caller
    const agoraToken = generateAgoraToken(channelName, 0, 'publisher');

    // Create call record
    const call = new Call({
      callerId,
      receiverId,
      conversationId: conversationId || null,
      status: 'initiated',
      agoraChannelName: channelName,
      agoraToken
    });

    await call.save();

    // Populate caller information
    await call.populate('callerId', 'profile.name profile.profilePicture');

    // Send notification to receiver
    await sendCallNotification(call, receiver);

    res.status(201).json({
      message: 'Call initiated successfully',
      call: {
        _id: call._id,
        callerId: call.callerId,
        receiverId: call.receiverId,
        status: call.status,
        channelName: call.agoraChannelName,
        token: call.agoraToken,
        startTime: call.startTime
      }
    });
  } catch (error) {
    console.error('Error initiating call:', error);
    res.status(500).json({ message: 'Failed to initiate call', error: error.message });
  }
});

/**
 * POST /api/calls/:callId/accept
 * Accept an incoming call
 */
router.post('/:callId/accept', auth, async (req, res) => {
  try {
    const { callId } = req.params;
    const userId = req.user.userId;

    // Find the call
    const call = await Call.findById(callId);
    if (!call) {
      return res.status(404).json({ message: 'Call not found' });
    }

    // Verify user is the receiver
    if (call.receiverId.toString() !== userId) {
      return res.status(403).json({ message: 'You are not authorized to accept this call' });
    }

    // Check if call is in correct state
    if (call.status !== 'initiated' && call.status !== 'ringing') {
      return res.status(400).json({ message: `Cannot accept call with status: ${call.status}` });
    }

    // Update call status
    call.status = 'active';
    await call.save();

    // Generate token for receiver
    const receiverToken = generateAgoraToken(call.agoraChannelName, 0, 'publisher');

    res.json({
      message: 'Call accepted successfully',
      call: {
        _id: call._id,
        callerId: call.callerId,
        receiverId: call.receiverId,
        status: call.status,
        channelName: call.agoraChannelName,
        token: receiverToken,
        startTime: call.startTime
      }
    });
  } catch (error) {
    console.error('Error accepting call:', error);
    res.status(500).json({ message: 'Failed to accept call', error: error.message });
  }
});

/**
 * POST /api/calls/:callId/reject
 * Reject an incoming call
 */
router.post('/:callId/reject', auth, async (req, res) => {
  try {
    const { callId } = req.params;
    const userId = req.user.userId;

    // Find the call
    const call = await Call.findById(callId);
    if (!call) {
      return res.status(404).json({ message: 'Call not found' });
    }

    // Verify user is the receiver
    if (call.receiverId.toString() !== userId) {
      return res.status(403).json({ message: 'You are not authorized to reject this call' });
    }

    // Check if call is in correct state
    if (call.status !== 'initiated' && call.status !== 'ringing') {
      return res.status(400).json({ message: `Cannot reject call with status: ${call.status}` });
    }

    // Update call status
    call.status = 'rejected';
    call.endTime = new Date();
    await call.save();

    res.json({
      message: 'Call rejected successfully',
      call: {
        _id: call._id,
        status: call.status,
        endTime: call.endTime
      }
    });
  } catch (error) {
    console.error('Error rejecting call:', error);
    res.status(500).json({ message: 'Failed to reject call', error: error.message });
  }
});

/**
 * POST /api/calls/:callId/end
 * End an active call
 */
router.post('/:callId/end', auth, async (req, res) => {
  try {
    const { callId } = req.params;
    const userId = req.user.userId;

    // Find the call
    const call = await Call.findById(callId);
    if (!call) {
      return res.status(404).json({ message: 'Call not found' });
    }

    // Verify user is either caller or receiver
    if (call.callerId.toString() !== userId && call.receiverId.toString() !== userId) {
      return res.status(403).json({ message: 'You are not authorized to end this call' });
    }

    // Check if call is already ended
    if (call.status === 'ended' || call.status === 'rejected') {
      return res.status(400).json({ message: 'Call is already ended' });
    }

    // Calculate duration if call was active
    const endTime = new Date();
    let duration = 0;
    if (call.status === 'active') {
      duration = Math.floor((endTime - call.startTime) / 1000); // Duration in seconds
    }

    // Update call status
    call.status = 'ended';
    call.endTime = endTime;
    call.duration = duration;
    await call.save();

    res.json({
      message: 'Call ended successfully',
      call: {
        _id: call._id,
        status: call.status,
        endTime: call.endTime,
        duration: call.duration
      }
    });
  } catch (error) {
    console.error('Error ending call:', error);
    res.status(500).json({ message: 'Failed to end call', error: error.message });
  }
});

/**
 * GET /api/calls/token
 * Get Agora token for joining a call
 */
router.get('/token', auth, async (req, res) => {
  try {
    const { channelName, uid } = req.query;

    // Validate required parameters
    if (!channelName) {
      return res.status(400).json({ message: 'Channel name is required' });
    }

    // Generate token
    const token = generateAgoraToken(channelName, uid || 0, 'publisher');

    res.json({
      token,
      channelName,
      uid: uid || 0
    });
  } catch (error) {
    console.error('Error generating token:', error);
    res.status(500).json({ message: 'Failed to generate token', error: error.message });
  }
});

/**
 * GET /api/calls/history
 * Get call history for the authenticated user
 */
router.get('/history', auth, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { limit = 50, skip = 0 } = req.query;

    // Find calls where user is either caller or receiver
    const calls = await Call.find({
      $or: [
        { callerId: userId },
        { receiverId: userId }
      ]
    })
      .sort({ startTime: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip))
      .populate('callerId', 'profile.name profile.profilePicture')
      .populate('receiverId', 'profile.name profile.profilePicture');

    res.json({
      calls,
      count: calls.length
    });
  } catch (error) {
    console.error('Error fetching call history:', error);
    res.status(500).json({ message: 'Failed to fetch call history', error: error.message });
  }
});

module.exports = router;
