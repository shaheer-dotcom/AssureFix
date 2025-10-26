const nodemailer = require('nodemailer');

// Check if email credentials are properly configured
const isEmailConfigured = process.env.EMAIL_USER && 
                          process.env.EMAIL_PASS && 
                          process.env.EMAIL_USER !== 'your_actual_gmail@gmail.com' &&
                          process.env.EMAIL_PASS !== 'your_gmail_app_password';

let transporter = null;

if (isEmailConfigured) {
  transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });
} else {
  console.log('⚠️  Email not configured. Using test mode.');
  console.log('📧 To enable email, update these in .env file:');
  console.log('   EMAIL_USER=your_actual_gmail@gmail.com');
  console.log('   EMAIL_PASS=your_gmail_app_password');
  console.log('📝 Get Gmail App Password: https://support.google.com/accounts/answer/185833');
}

const sendOTP = async (email, otp) => {
  if (!isEmailConfigured || !transporter) {
    throw new Error('Email service not configured. Please check your Gmail credentials in .env file.');
  }

  const mailOptions = {
    from: `"ServiceHub" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'ServiceHub - Email Verification OTP',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h1 style="color: #2E7D32; margin: 0;">ServiceHub</h1>
          <p style="color: #666; margin: 5px 0;">Professional Service Marketplace</p>
        </div>
        
        <div style="background: linear-gradient(135deg, #2E7D32, #4CAF50); padding: 30px; border-radius: 10px; text-align: center; margin: 20px 0;">
          <h2 style="color: white; margin: 0 0 10px 0;">Email Verification</h2>
          <p style="color: white; margin: 0;">Your verification code is:</p>
        </div>
        
        <div style="background-color: #f8f9fa; padding: 30px; text-align: center; margin: 20px 0; border-radius: 10px; border: 2px dashed #2E7D32;">
          <h1 style="color: #2E7D32; font-size: 36px; margin: 0; letter-spacing: 5px; font-family: monospace;">${otp}</h1>
        </div>
        
        <div style="background-color: #fff3cd; padding: 15px; border-radius: 5px; border-left: 4px solid #ffc107; margin: 20px 0;">
          <p style="margin: 0; color: #856404;"><strong>⏰ Important:</strong> This OTP will expire in 10 minutes.</p>
        </div>
        
        <p style="color: #666; font-size: 14px; text-align: center;">
          If you didn't request this verification, please ignore this email.<br>
          This is an automated message, please do not reply.
        </p>
        
        <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
          <p style="color: #999; font-size: 12px; margin: 0;">
            © 2024 ServiceHub. All rights reserved.
          </p>
        </div>
      </div>
    `
  };

  await transporter.sendMail(mailOptions);
  console.log(`✅ OTP email sent successfully to: ${email}`);
};

module.exports = { sendOTP };