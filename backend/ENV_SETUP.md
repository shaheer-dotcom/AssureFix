# Environment Variables Setup

Create a `.env` file in the `backend` directory with the following variables:

## 📋 Development Configuration

```env
# Server Configuration
NODE_ENV=development
PORT=5000

# API URL Configuration (for frontend)
# Use localhost when running frontend on same machine
# Use network IP (e.g., 192.168.100.7) when testing on mobile devices
# Examples:
#   API_URL=http://localhost:5000/api
#   API_URL=http://192.168.100.7:5000/api
API_URL=http://localhost:5000/api

# Database
MONGODB_URI=mongodb://localhost:27017/servicehub
# For MongoDB Atlas: mongodb+srv://username:password@cluster.mongodb.net/servicehub

# JWT Secret (MUST be at least 32 characters in production)
# Generate a strong secret: openssl rand -base64 32
JWT_SECRET=your_super_secret_jwt_key_here_change_this_in_production_min_32_chars

# CORS Configuration (comma-separated list of allowed origins)
# Example: ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
ALLOWED_ORIGINS=

# Email Configuration (for OTP and notifications)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_gmail_app_password

# Frontend URL (for email links)
FRONTEND_URL=http://localhost:8080

# Admin Configuration
PRIMARY_ADMIN_EMAIL=admin@yourdomain.com
```

## 🚀 Production Configuration

For production deployment, use these settings:

```env
# Server Configuration
NODE_ENV=production
PORT=10000  # Render uses 10000, Railway/Fly.io auto-assign

# API URL Configuration
# Set this to your deployed backend URL (e.g., from Render, Railway, Fly.io)
# Examples:
#   API_URL=https://assurefix-backend.onrender.com/api
#   API_URL=https://assurefix-backend.up.railway.app/api
#   API_URL=https://assurefix-backend.fly.dev/api
API_URL=https://your-backend-url.onrender.com/api

# Database (MongoDB Atlas recommended)
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/assurefix?retryWrites=true&w=majority

# JWT Secret (MUST be at least 32 characters)
# Generate: openssl rand -base64 32 (or use online generator)
JWT_SECRET=your_very_long_production_secret_at_least_32_characters_long

# CORS Configuration (comma-separated, no spaces)
ALLOWED_ORIGINS=https://your-frontend.com,https://www.your-frontend.com

# Email Configuration (Gmail SMTP)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_gmail_app_password  # Use App Password, not regular password

# Frontend URL
FRONTEND_URL=https://your-frontend.com

# Admin Configuration
PRIMARY_ADMIN_EMAIL=admin@yourdomain.com
```

## 📚 Deployment Guide

For detailed instructions on deploying to free hosting services (Render, Railway, Fly.io), see:
**[../DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md)**

## ✅ Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Use a strong `JWT_SECRET` (at least 32 characters)
- [ ] Set `ALLOWED_ORIGINS` to your production domain(s)
- [ ] Use MongoDB Atlas or a secure database connection
- [ ] Configure proper email service credentials
- [ ] Set `FRONTEND_URL` to your production frontend URL
- [ ] Set `PRIMARY_ADMIN_EMAIL` to your admin email
- [ ] Set `API_URL` to your deployed backend URL
- [ ] Test all API endpoints after deployment
- [ ] Update frontend to use production API URL

## 🔐 Security Notes

1. **JWT Secret**: Never commit your production JWT secret to Git. Use environment variables in your hosting platform.

2. **MongoDB Atlas**: 
   - Enable network access restrictions
   - Use strong database passwords
   - Enable authentication

3. **Gmail App Password**:
   - Enable 2-Step Verification
   - Generate App Password (not regular password)
   - Use App Password in `EMAIL_PASS`

4. **CORS**: Only allow your actual frontend domains in `ALLOWED_ORIGINS`

## 🆘 Troubleshooting

- **Connection Issues**: Check MongoDB Atlas network access settings
- **CORS Errors**: Verify `ALLOWED_ORIGINS` includes your frontend URL
- **Email Not Sending**: Verify Gmail App Password is correct
- **API Not Found**: Check `API_URL` matches your deployed backend URL



