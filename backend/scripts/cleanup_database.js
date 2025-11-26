const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Service = require('../models/Service');
const Booking = require('../models/Booking');
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

async function cleanupDatabase() {
  try {
    console.log('🔌 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    console.log('🗑️  Starting database cleanup...\n');

    // Delete all services
    const servicesDeleted = await Service.deleteMany({});
    console.log(`✓ Deleted ${servicesDeleted.deletedCount} services`);

    // Delete all bookings
    const bookingsDeleted = await Booking.deleteMany({});
    console.log(`✓ Deleted ${bookingsDeleted.deletedCount} bookings`);

    // Delete all conversations
    const conversationsDeleted = await Conversation.deleteMany({});
    console.log(`✓ Deleted ${conversationsDeleted.deletedCount} conversations`);

    // Delete all messages
    const messagesDeleted = await Message.deleteMany({});
    console.log(`✓ Deleted ${messagesDeleted.deletedCount} messages`);

    console.log('\n✅ Database cleanup completed successfully!');
    console.log('\nSummary:');
    console.log(`  - Services: ${servicesDeleted.deletedCount} deleted`);
    console.log(`  - Bookings: ${bookingsDeleted.deletedCount} deleted`);
    console.log(`  - Conversations: ${conversationsDeleted.deletedCount} deleted`);
    console.log(`  - Messages: ${messagesDeleted.deletedCount} deleted`);
    console.log('\nNote: User accounts and ratings were preserved.');

  } catch (error) {
    console.error('❌ Error during cleanup:', error.message);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
    process.exit(0);
  }
}

// Run cleanup
cleanupDatabase();
