const request = require('supertest');
const express = require('express');

// Mock models and middleware
jest.mock('../../models/Call');
jest.mock('../../models/User');
jest.mock('../../models/Chat');
jest.mock('../../middleware/auth');
jest.mock('../../utils/agoraToken');
jest.mock('../../services/notificationService');

const Call = require('../../models/Call');
const User = require('../../models/User');
const Chat = require('../../models/Chat');
const auth = require('../../middleware/auth');
const { generateAgoraToken, generateChannelName } = require('../../utils/agoraToken');
const callsRouter = require('../../routes/calls');

// Create Express app for testing
const app = express();
app.use(express.json());
app.use('/api/calls', callsRouter);

describe('Integration: Voice Call Flow', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    
    // Mock auth middl