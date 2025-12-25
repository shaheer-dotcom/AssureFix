const mongoose = require('mongoose');
require('dotenv').config();

async function viewDatabase() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const db = mongoose.connection.db;
    const collections = await db.listCollections().toArray();

    console.log('📊 Database:', db.databaseName);
    console.log('📁 Collections:', collections.length, '\n');

    for (const collection of collections) {
      const count = await db.collection(collection.name).countDocuments();
      console.log(`  - ${collection.name}: ${count} documents`);
    }

    console.log('\n💡 To view data in a collection, use MongoDB Compass or:');
    console.log('   mongosh');
    console.log('   use servicehub');
    console.log('   db.users.find().pretty()');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

viewDatabase();
