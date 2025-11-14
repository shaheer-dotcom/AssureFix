const mongoose = require('mongoose');
require('dotenv').config();

const User = require('../models/User');
const Service = require('../models/Service');
const Chat = require('../models/Chat');

async function viewChats() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/servicehub');
    console.log('✅ Connected to MongoDB\n');

    const chats = await Chat.find()
      .populate('participants', 'profile.name email')
      .populate('serviceId', 'serviceName');

    console.log(`Found ${chats.length} chats\n`);
    console.log('='.repeat(80));

    chats.forEach((chat, index) => {
      console.log(`\nChat ${index + 1}:`);
      console.log(`ID: ${chat._id}`);
      console.log(`Service: ${chat.serviceId?.serviceName || 'Unknown'}`);
      console.log(`Participants:`);
      chat.participants.forEach(p => {
        console.log(`  - ${p.profile?.name || 'Unknown'} (${p.email})`);
      });
      console.log(`Messages: ${chat.messages.length}`);
      console.log(`Last Message: ${chat.lastMessage}`);
      
      if (chat.messages.length > 0) {
        console.log(`\nMessages:`);
        chat.messages.forEach((msg, i) => {
          console.log(`  ${i + 1}. [${msg.messageType}] ${msg.content.text || JSON.stringify(msg.content)}`);
          console.log(`     Time: ${msg.timestamp}`);
          console.log(`     Read: ${msg.isRead}`);
        });
      }
      console.log('='.repeat(80));
    });

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    await mongoose.connection.close();
    process.exit(1);
  }
}

viewChats();
