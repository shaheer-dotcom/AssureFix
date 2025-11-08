const nodemailer = require('nodemailer');

class EmailService {
  constructor() {
    // Gmail SMTP configuration
    // You need to enable "Less secure app access" or use App Password
    this.transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });
  }

  // Generate 6-digit OTP
  generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // Send OTP email
  async sendOTPEmail(email, otp, name = 'User') {
    // Log to console for debugging
    console.log('\n=================================');
    console.log('📧 ASSUREFIX - EMAIL VERIFICATION CODE');
    console.log('=================================');
    console.log(`To: ${email}`);
    console.log(`OTP: ${otp}`);
    console.log(`Expires: 10 minutes`);
    console.log('=================================\n');

    const mailOptions = {
      from: `"AssureFix" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'AssureFix - Email Verification Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2E7D32; margin: 0;">AssureFix</h1>
            <p style="color: #666; margin: 5px 0;">Professional Service Marketplace</p>
          </div>
          
          <div style="background-color: #f8f9fa; padding: 30px; border-radius: 10px; text-align: center;">
            <h2 style="color: #333; margin-bottom: 20px;">Email Verification</h2>
            <p style="color: #666; margin-bottom: 30px;">Hello ${name},</p>
            <p style="color: #666; margin-bottom: 30px;">
              Thank you for signing up with AssureFix! Please use the verification code below to complete your registration:
            </p>
            
            <div style="background-color: #2E7D32; color: white; padding: 20px; border-radius: 8px; margin: 30px 0;">
              <h1 style="margin: 0; font-size: 32px; letter-spacing: 5px;">${otp}</h1>
            </div>
            
            <p style="color: #666; margin-bottom: 20px;">
              This code will expire in <strong>10 minutes</strong>.
            </p>
            <p style="color: #666; font-size: 14px;">
              If you didn't request this verification code, please ignore this email.
            </p>
          </div>
          
          <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 12px;">
              This is an automated email from AssureFix. Please do not reply to this email.
            </p>
          </div>
        </div>
      `
    };

    try {
      await this.transporter.sendMail(mailOptions);
      console.log(`✅ OTP email sent successfully to ${email}`);
      return true;
    } catch (error) {
      console.error('❌ Error sending OTP email:', error);
      throw new Error('Failed to send verification email');
    }
  }

  // Send welcome email after successful verification
  async sendWelcomeEmail(email, name) {
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Welcome to AssureFix!',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2E7D32; margin: 0;">ServiceHub</h1>
            <p style="color: #666; margin: 5px 0;">Professional Service Marketplace</p>
          </div>
          
          <div style="background-color: #f8f9fa; padding: 30px; border-radius: 10px;">
            <h2 style="color: #333; margin-bottom: 20px;">Welcome to AssureFix!</h2>
            <p style="color: #666; margin-bottom: 20px;">Hello ${name},</p>
            <p style="color: #666; margin-bottom: 20px;">
              Congratulations! Your email has been successfully verified and your AssureFix account is now active.
            </p>
            <p style="color: #666; margin-bottom: 20px;">
              You can now complete your profile and start connecting with trusted service providers or offer your own services.
            </p>
            <div style="text-align: center; margin: 30px 0;">
              <a href="${process.env.FRONTEND_URL || 'http://localhost:8081'}" 
                 style="background-color: #2E7D32; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
                Complete Your Profile
              </a>
            </div>
          </div>
          
          <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 12px;">
              Thank you for choosing AssureFix!
            </p>
          </div>
        </div>
      `
    };

    try {
      await this.transporter.sendMail(mailOptions);
      console.log(`Welcome email sent successfully to ${email}`);
      return true;
    } catch (error) {
      console.error('Error sending welcome email:', error);
      // Don't throw error for welcome email as it's not critical
      return false;
    }
  }
}

module.exports = new EmailService();