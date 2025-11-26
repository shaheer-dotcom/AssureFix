const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/assurefix', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'Connection error:'));
db.once('open', async () => {
  console.log('Connected to MongoDB');
  
  try {
    const servicesCollection = db.collection('services');
    
    // Find all services that have area or areaCovered fields
    const services = await servicesCollection.find({
      $or: [
        { area: { $exists: true } },
        { areaCovered: { $exists: true } }
      ]
    }).toArray();
    
    console.log(`Found ${services.length} services to migrate`);
    
    let migratedCount = 0;
    
    for (const service of services) {
      const areaTags = [];
      
      // Process area field
      if (service.area) {
        const areas = service.area.split(/[\n,.]/).map(a => a.trim()).filter(a => a.length > 0);
        areaTags.push(...areas);
      }
      
      // Process areaCovered field if different from area
      if (service.areaCovered && service.areaCovered !== service.area) {
        const coveredAreas = service.areaCovered.split(/[\n,.]/).map(a => a.trim()).filter(a => a.length > 0);
        areaTags.push(...coveredAreas);
      }
      
      // Remove duplicates
      const uniqueAreaTags = [...new Set(areaTags)];
      
      if (uniqueAreaTags.length > 0) {
        // Update the service with areaTags and remove old fields
        await servicesCollection.updateOne(
          { _id: service._id },
          {
            $set: { areaTags: uniqueAreaTags },
            $unset: { area: '', areaCovered: '' }
          }
        );
        
        migratedCount++;
        console.log(`Migrated service ${service._id}: ${uniqueAreaTags.join(', ')}`);
      }
    }
    
    console.log(`\nMigration complete! Migrated ${migratedCount} services.`);
    
  } catch (error) {
    console.error('Migration error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('Database connection closed');
  }
});
