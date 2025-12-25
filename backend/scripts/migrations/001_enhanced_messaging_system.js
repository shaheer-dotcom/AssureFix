/**
 * Migration: Enhanced Messaging System
 * Version: 001
 * Date: December 3, 2025
 * 
 * This migration adds new fields and indexes required for the Enhanced Messaging System:
 * - Chat model enhancements (bookingId, closedAt, closedReason)
 * - Message schema enhancements (imageUrl, deliveredAt, readAt)
 * - Booking model enhancements (conversationId, notificationSent, acceptedAt)
 * - New Call collection
 * - Database indexes for performance
 */

const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Chat = require('../../models/Chat');
const Booking = require('../../models/Booking');
const Call = require('../../models/Call');

/**
 * Run migration
 */
async function up() {
  console.log('Starting migration: Enhanced Messaging System...\n');

  try {
    // Connect to database
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✓ Connected to MongoDB\n');

    // Step 1: Update Chat collection
    console.log('Step 1: Updating Chat collection...');
    const chatUpdateResult = await Chat.updateMany(
      {
        $or: [
          { bookingId: { $exists: false } },
          { closedAt: { $exists: false } },
          { closedReason: { $exists: false } }
        ]
      },
      {
        $set: {
          bookingId: null,
          closedAt: null,
          closedReason: null
        }
      }
    );
    console.log(`  ✓ Updated ${chatUpdateResult.modifiedCount} chat documents`);

    // Step 2: Update Message schema within Chat documents
    console.log('\nStep 2: Updating Message schema in Chat documents...');
    const chats = await Chat.find({});
    let messageUpdateCount = 0;

    for (const chat of chats) {
      let modified = false;
      
      for (const message of chat.messages) {
        if (!message.deliveredAt) {
          message.deliveredAt = null;
          modified = true;
        }
        if (!message.readAt) {
          message.readAt = null;
          modified = true;
        }
        // Note: imageUrl is part of content object, handled by schema
      }

      if (modified) {
        await chat.save();
        messageUpdateCount++;
      }
    }
    console.log(`  ✓ Updated messages in ${messageUpdateCount} chat documents`);

    // Step 3: Update Booking collection
    console.log('\nStep 3: Updating Booking collection...');
    const bookingUpdateResult = await Booking.updateMany(
      {
        $or: [
          { conversationId: { $exists: false } },
          { notificationSent: { $exists: false } },
          { acceptedAt: { $exists: false } }
        ]
      },
      {
        $set: {
          conversationId: null,
          notificationSent: false,
          acceptedAt: null
        }
      }
    );
    console.log(`  ✓ Updated ${bookingUpdateResult.modifiedCount} booking documents`);

    // Step 4: Create indexes for Chat collection
    console.log('\nStep 4: Creating indexes for Chat collection...');
    await Chat.collection.createIndex({ participants: 1 });
    console.log('  ✓ Created index on Chat.participants');
    
    await Chat.collection.createIndex({ bookingId: 1 });
    console.log('  ✓ Created index on Chat.bookingId');
    
    await Chat.collection.createIndex({ lastMessage: -1 });
    console.log('  ✓ Created index on Chat.lastMessage (descending)');
    
    await Chat.collection.createIndex({ serviceId: 1, participants: 1 });
    console.log('  ✓ Created compound index on Chat.serviceId and Chat.participants');

    // Step 5: Create indexes for Booking collection
    console.log('\nStep 5: Creating indexes for Booking collection...');
    await Booking.collection.createIndex({ customerId: 1 });
    console.log('  ✓ Created index on Booking.customerId');
    
    await Booking.collection.createIndex({ providerId: 1 });
    console.log('  ✓ Created index on Booking.providerId');
    
    await Booking.collection.createIndex({ status: 1 });
    console.log('  ✓ Created index on Booking.status');
    
    await Booking.collection.createIndex({ reservationDate: 1 });
    console.log('  ✓ Created index on Booking.reservationDate');
    
    await Booking.collection.createIndex({ conversationId: 1 });
    console.log('  ✓ Created index on Booking.conversationId');

    // Step 6: Create Call collection and indexes
    console.log('\nStep 6: Setting up Call collection...');
    
    // Ensure Call collection exists
    const collections = await mongoose.connection.db.listCollections().toArray();
    const callCollectionExists = collections.some(col => col.name === 'calls');
    
    if (!callCollectionExists) {
      await mongoose.connection.db.createCollection('calls');
      console.log('  ✓ Created Call collection');
    } else {
      console.log('  ✓ Call collection already exists');
    }

    // Create indexes for Call collection
    await Call.collection.createIndex({ callerId: 1 });
    console.log('  ✓ Created index on Call.callerId');
    
    await Call.collection.createIndex({ receiverId: 1 });
    console.log('  ✓ Created index on Call.receiverId');
    
    await Call.collection.createIndex({ startTime: -1 });
    console.log('  ✓ Created index on Call.startTime (descending)');
    
    await Call.collection.createIndex({ status: 1 });
    console.log('  ✓ Created index on Call.status');
    
    await Call.collection.createIndex({ conversationId: 1 });
    console.log('  ✓ Created index on Call.conversationId');

    // Step 7: Verify indexes
    console.log('\nStep 7: Verifying indexes...');
    const chatIndexes = await Chat.collection.indexes();
    console.log(`  ✓ Chat collection has ${chatIndexes.length} indexes`);
    
    const bookingIndexes = await Booking.collection.indexes();
    console.log(`  ✓ Booking collection has ${bookingIndexes.length} indexes`);
    
    const callIndexes = await Call.collection.indexes();
    console.log(`  ✓ Call collection has ${callIndexes.length} indexes`);

    console.log('\n✓ Migration completed successfully!\n');

    // Print summary
    console.log('=== Migration Summary ===');
    console.log(`Chat documents updated: ${chatUpdateResult.modifiedCount}`);
    console.log(`Chat documents with message updates: ${messageUpdateCount}`);
    console.log(`Booking documents updated: ${bookingUpdateResult.modifiedCount}`);
    console.log(`Total indexes created: ${chatIndexes.length + bookingIndexes.length + callIndexes.length}`);
    console.log('========================\n');

  } catch (error) {
    console.error('\n✗ Migration failed:', error);
    throw error;
  } finally {
    await mongoose.connection.close();
    console.log('✓ Database connection closed');
  }
}

/**
 * Rollback migration
 */
async function down() {
  console.log('Starting rollback: Enhanced Messaging System...\n');

  try {
    // Connect to database
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✓ Connected to MongoDB\n');

    // Step 1: Remove new fields from Chat collection
    console.log('Step 1: Removing new fields from Chat collection...');
    const chatRollbackResult = await Chat.updateMany(
      {},
      {
        $unset: {
          bookingId: '',
          closedAt: '',
          closedReason: ''
        }
      }
    );
    console.log(`  ✓ Rolled back ${chatRollbackResult.modifiedCount} chat documents`);

    // Step 2: Remove new fields from Message schema
    console.log('\nStep 2: Removing new fields from Message schema...');
    const chats = await Chat.find({});
    let messageRollbackCount = 0;

    for (const chat of chats) {
      let modified = false;
      
      for (const message of chat.messages) {
        if (message.deliveredAt !== undefined) {
          message.deliveredAt = undefined;
          modified = true;
        }
        if (message.readAt !== undefined) {
          message.readAt = undefined;
          modified = true;
        }
      }

      if (modified) {
        await chat.save();
        messageRollbackCount++;
      }
    }
    console.log(`  ✓ Rolled back messages in ${messageRollbackCount} chat documents`);

    // Step 3: Remove new fields from Booking collection
    console.log('\nStep 3: Removing new fields from Booking collection...');
    const bookingRollbackResult = await Booking.updateMany(
      {},
      {
        $unset: {
          conversationId: '',
          notificationSent: '',
          acceptedAt: ''
        }
      }
    );
    console.log(`  ✓ Rolled back ${bookingRollbackResult.modifiedCount} booking documents`);

    // Step 4: Drop indexes (optional - may want to keep for performance)
    console.log('\nStep 4: Dropping new indexes...');
    try {
      await Chat.collection.dropIndex('bookingId_1');
      console.log('  ✓ Dropped index Chat.bookingId');
    } catch (e) {
      console.log('  - Index Chat.bookingId not found or already dropped');
    }

    try {
      await Booking.collection.dropIndex('conversationId_1');
      console.log('  ✓ Dropped index Booking.conversationId');
    } catch (e) {
      console.log('  - Index Booking.conversationId not found or already dropped');
    }

    // Step 5: Drop Call collection (WARNING: This deletes all call data)
    console.log('\nStep 5: Dropping Call collection...');
    const collections = await mongoose.connection.db.listCollections().toArray();
    const callCollectionExists = collections.some(col => col.name === 'calls');
    
    if (callCollectionExists) {
      await mongoose.connection.db.dropCollection('calls');
      console.log('  ✓ Dropped Call collection');
    } else {
      console.log('  - Call collection does not exist');
    }

    console.log('\n✓ Rollback completed successfully!\n');

    // Print summary
    console.log('=== Rollback Summary ===');
    console.log(`Chat documents rolled back: ${chatRollbackResult.modifiedCount}`);
    console.log(`Chat documents with message rollbacks: ${messageRollbackCount}`);
    console.log(`Booking documents rolled back: ${bookingRollbackResult.modifiedCount}`);
    console.log('Call collection dropped');
    console.log('========================\n');

  } catch (error) {
    console.error('\n✗ Rollback failed:', error);
    throw error;
  } finally {
    await mongoose.connection.close();
    console.log('✓ Database connection closed');
  }
}

// Run migration based on command line argument
const command = process.argv[2];

if (command === 'up') {
  up()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
} else if (command === 'down') {
  down()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
} else {
  console.log('Usage: node 001_enhanced_messaging_system.js [up|down]');
  console.log('  up   - Run migration');
  console.log('  down - Rollback migration');
  process.exit(1);
}
