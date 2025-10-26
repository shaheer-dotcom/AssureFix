const axios = require('axios');

const baseURL = 'http://localhost:3000/api';
let authToken = '';

async function testAPI() {
  try {
    console.log('Testing ServiceHub API...\n');

    // Test login
    console.log('1. Testing login...');
    const loginResponse = await axios.post(`${baseURL}/auth/login`, {
      email: 'murad7265@gmail.com',
      password: 'password123'
    });
    
    authToken = loginResponse.data.token;
    console.log('✅ Login successful');
    console.log('User:', loginResponse.data.user.profile.name);
    console.log('User Type:', loginResponse.data.user.profile.userType);

    // Test create service
    console.log('\n2. Testing create service...');
    const serviceData = {
      name: 'House Cleaning Service',
      area: 'Karachi',
      price: 2000,
      category: 'Home Services',
      description: 'Professional house cleaning service with experienced staff'
    };

    const createServiceResponse = await axios.post(`${baseURL}/services`, serviceData, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    
    console.log('✅ Service created successfully');
    console.log('Service ID:', createServiceResponse.data._id);
    console.log('Service Name:', createServiceResponse.data.name);

    // Test search services
    console.log('\n3. Testing search services...');
    const searchResponse = await axios.get(`${baseURL}/services/search?serviceName=cleaning&area=karachi`);
    
    console.log('✅ Search successful');
    console.log('Found services:', searchResponse.data.length);
    if (searchResponse.data.length > 0) {
      console.log('First service:', searchResponse.data[0].name);
    }

    // Test get user services
    console.log('\n4. Testing get user services...');
    const userServicesResponse = await axios.get(`${baseURL}/services/my-services`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    
    console.log('✅ User services retrieved');
    console.log('User has', userServicesResponse.data.length, 'services');

    console.log('\n🎉 All API tests passed!');

  } catch (error) {
    console.error('❌ API test failed:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Message:', error.response.data.message || error.response.data);
    } else {
      console.error('Error:', error.message);
    }
  }
}

testAPI();