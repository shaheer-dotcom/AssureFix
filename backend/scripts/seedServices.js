const mongoose = require('mongoose');
const Service = require('../models/Service');
const User = require('../models/User');
require('dotenv').config();

// Demo services data
const demoServices = [
  {
    name: 'Professional House Cleaning',
    serviceName: 'House Cleaning',
    description: 'Complete house cleaning service including all rooms, kitchen, and bathrooms. We use eco-friendly products and professional equipment.',
    category: 'Cleaning Services',
    area: 'Gulshan',
    areaCovered: 'Gulshan.Block 1.Block 2.Block 3',
    price: 2500,
    pricePerHour: 500,
    priceType: 'fixed'
  },
  {
    name: 'Expert Plumbing Services',
    serviceName: 'Plumbing',
    description: 'Professional plumbing services for pipe repairs, leakage fixing, bathroom fittings, and emergency plumbing issues.',
    category: 'Home Services',
    area: 'DHA',
    areaCovered: 'DHA.Phase 1.Phase 2.Phase 3.Phase 4',
    price: 800,
    pricePerHour: 800,
    priceType: 'hourly'
  },
  {
    name: 'Electrical Repair & Installation',
    serviceName: 'Electrician',
    description: 'Licensed electrician for wiring, fan installation, light fixtures, electrical repairs, and safety inspections.',
    category: 'Home Services',
    area: 'Clifton',
    areaCovered: 'Clifton.Block 1.Block 2.Block 3.Block 4.Block 5',
    price: 1000,
    pricePerHour: 1000,
    priceType: 'hourly'
  },
  {
    name: 'AC Repair & Maintenance',
    serviceName: 'AC Service',
    description: 'Air conditioning repair, maintenance, gas filling, and installation services for all brands.',
    category: 'Home Services',
    area: 'Nazimabad',
    areaCovered: 'Nazimabad.Block 1.Block 2.Block 3.Block 4',
    price: 1500,
    pricePerHour: 1200,
    priceType: 'fixed'
  },
  {
    name: 'Car Wash & Detailing',
    serviceName: 'Car Wash',
    description: 'Professional car washing and detailing service at your doorstep. Interior and exterior cleaning included.',
    category: 'Automotive',
    area: 'Karachi',
    areaCovered: 'Karachi.Saddar.Clifton.DHA.Gulshan',
    price: 1200,
    pricePerHour: 600,
    priceType: 'fixed'
  },
  {
    name: 'Mobile Phone Repair',
    serviceName: 'Phone Repair',
    description: 'Expert mobile phone repair services for all brands. Screen replacement, battery change, software issues.',
    category: 'Electronics',
    area: 'Saddar',
    areaCovered: 'Saddar.Empress Market.Burns Road',
    price: 500,
    pricePerHour: 500,
    priceType: 'fixed'
  },
  {
    name: 'Home Tutoring - Mathematics',
    serviceName: 'Math Tutor',
    description: 'Experienced mathematics teacher for home tutoring. All levels from primary to intermediate.',
    category: 'Education',
    area: 'Gulshan',
    areaCovered: 'Gulshan.Block 13.Block 14.Block 15',
    price: 3000,
    pricePerHour: 1000,
    priceType: 'hourly'
  },
  {
    name: 'Ladies Hair Salon at Home',
    serviceName: 'Hair Salon',
    description: 'Professional ladies hair salon services at home. Haircut, styling, coloring, and treatments.',
    category: 'Beauty & Wellness',
    area: 'DHA',
    areaCovered: 'DHA.Phase 1.Phase 2.Phase 5.Phase 6',
    price: 2000,
    pricePerHour: 800,
    priceType: 'fixed'
  },
  {
    name: 'Laptop Repair & Upgrade',
    serviceName: 'Laptop Repair',
    description: 'Professional laptop repair services. Hardware issues, software installation, virus removal, and upgrades.',
    category: 'Electronics',
    area: 'Clifton',
    areaCovered: 'Clifton.Block 2.Block 4.Block 7.Block 8',
    price: 1500,
    pricePerHour: 1000,
    priceType: 'hourly'
  },
  {
    name: 'Carpenter Services',
    serviceName: 'Carpentry',
    description: 'Skilled carpenter for furniture repair, custom furniture making, door/window installation and repairs.',
    category: 'Home Services',
    area: 'North Nazimabad',
    areaCovered: 'North Nazimabad.Block A.Block B.Block C.Block D',
    price: 1200,
    pricePerHour: 800,
    priceType: 'hourly'
  },
  {
    name: 'Painting Services',
    serviceName: 'House Painting',
    description: 'Professional house painting services for interior and exterior. Quality paints and experienced painters.',
    category: 'Home Services',
    area: 'Gulshan',
    areaCovered: 'Gulshan.Block 1.Block 2.Block 3.Block 4.Block 5',
    price: 5000,
    pricePerHour: 600,
    priceType: 'fixed'
  },
  {
    name: 'Fitness Trainer at Home',
    serviceName: 'Personal Trainer',
    description: 'Certified fitness trainer for home workouts. Weight loss, muscle building, and general fitness programs.',
    category: 'Health & Fitness',
    area: 'DHA',
    areaCovered: 'DHA.Phase 1.Phase 2.Phase 3.Phase 4.Phase 5',
    price: 4000,
    pricePerHour: 1500,
    priceType: 'hourly'
  }
];

async function seedServices() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/assurefix');
    console.log('Connected to MongoDB');

    // Find or create a demo user to assign services to
    let demoUser = await User.findOne({ email: 'demo@provider.com' });
    
    if (!demoUser) {
      demoUser = new User({
        email: 'demo@provider.com',
        password: 'password123', // This will be hashed automatically
        profile: {
          name: 'Demo Service Provider',
          phoneNumber: '+92 300 1234567',
          userType: 'service_provider'
        },
        isEmailVerified: true
      });
      await demoUser.save();
      console.log('Created demo user');
    }

    // Clear existing demo services
    await Service.deleteMany({ providerId: demoUser._id });
    console.log('Cleared existing demo services');

    // Create demo services
    const services = demoServices.map(serviceData => ({
      ...serviceData,
      providerId: demoUser._id,
      isActive: true
    }));

    await Service.insertMany(services);
    console.log(`✅ Successfully added ${services.length} demo services to the database!`);

    // Display summary
    console.log('\n📋 Demo Services Added:');
    services.forEach((service, index) => {
      console.log(`${index + 1}. ${service.name} - ${service.area} (₹${service.price})`);
    });

    console.log('\n🔍 You can now test searching for:');
    console.log('- Service names: plumbing, cleaning, electrician, etc.');
    console.log('- Areas: Gulshan, DHA, Clifton, Nazimabad, etc.');
    console.log('- Categories: Home Services, Electronics, Education, etc.');

  } catch (error) {
    console.error('❌ Error seeding services:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
  }
}

// Run the seed function
seedServices();