const mongoose = require('mongoose');
const Chat = require('../models/Chat');
require('dotenv').config();

async function cleanupDuplicateChats() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');
    console.log('Starting duplicate chat cleanup...\n');

    // Find all chats
    const allChats = await Chat.find({}).sort({ createdAt: -1 });
    console.log(`Total chats in database: ${allChats.length}`);

    // Group chats by participant pairs
    const chatGroups = {};
    
    for (const chat of allChats) {
      // Create a unique key for this participant pair
      const participants = chat.participants.map(p => p.toString()).sort();
      const key = participants.join('-');
      
      if (!chatGroups[key]) {
        chatGroups[key] = [];
      }
      chatGroups[key].push(chat);
    }

    // Find groups with duplicates
    let totalDuplicates = 0;
    let groupsWithDuplicates = 0;

    for (const [key, chats] of Object.entries(chatGroups)) {
      if (chats.length > 1) {
        groupsWithDuplicates++;
        const duplicateCount = chats.length - 1;
        totalDuplicates += duplicateCount;

        console.log(`\nFound ${chats.length} chats for participant pair:`);
        console.log(`Participants: ${key}`);
        
        // Sort by creation date (newest first)
        chats.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        
        // Keep the most recent chat
        const keepChat = chats[0];
        console.log(`  ✓ Keeping: ${keepChat._id} (created: ${keepChat.createdAt})`);
        
        // Delete the rest
        for (let i = 1; i < chats.length; i++) {
          const deleteChat = chats[i];
          console.log(`  ✗ Deleting: ${deleteChat._id} (created: ${deleteChat.createdAt})`);
          await Chat.findByIdAndDelete(deleteChat._id);
        }
      }
    }

    console.log('\n' + '='.repeat(50));
    console.log('Cleanup Summary:');
    console.log('='.repeat(50));
    console.log(`Total chats before: ${allChats.length}`);
    console.log(`Duplicate groups found: ${groupsWithDuplicates}`);
    console.log(`Duplicate chats removed: ${totalDuplicates}`);
    console.log(`Total chats after: ${allChats.length - totalDuplicates}`);
    console.log('='.repeat(50));
    console.log('\n✅ Cleanup complete!');

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during cleanup:', error);
    await mongoose.connection.close();
    process.exit(1);
  }
}

// Run the cleanup
cleanupDuplicateChats();
