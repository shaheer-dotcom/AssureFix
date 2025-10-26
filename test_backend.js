const axios = require('axios');

async function testBackend() {
  try {
    console.log('Testing backend on port 5000...');
    
    // Test basic endpoint
    const response = await axios.get('http://localhost:5000/api/services/search?serviceName=test&area=karachi');
    console.log('✅ Backend is responding');
    console.log('Response:', response.data);
    
  } catch (error) {
    console.error('❌ Backend test failed:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    } else {
      console.error('Error:', error.message);
    }
  }
}

testBackend();