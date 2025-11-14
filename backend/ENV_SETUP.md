# Environment Variables Setup

Create a `.env` file in the `backend` directory with the following variables:

```env
# Server Configuration
NODE_ENV=development
PORT=5000

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

## Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Use a strong `JWT_SECRET` (at least 32 characters)
- [ ] Set `ALLOWED_ORIGINS` to your production domain(s)
- [ ] Use MongoDB Atlas or a secure database connection
- [ ] Configure proper email service credentials
- [ ] Set `FRONTEND_URL` to your production frontend URL
- [ ] Set `PRIMARY_ADMIN_EMAIL` to your admin email



