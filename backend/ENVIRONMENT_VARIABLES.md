# Environment Variables Documentation

## Overview

This document provides comprehensive documentation for all environment variables used in the Enhanced Messaging System backend.

## Configuration File

Environment variables are stored in the `.env` file in the backend root directory. This file should **never** be committed to version control.

### Creating the .env File

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Update the values with your actual configuration

3. Ensure `.env` is listed in `.gitignore`

---

## Required Variables

### Server Configuration

#### `PORT`
- **Description:** Port number for the Express server
- **Type:** Number
- **Default:** 5000
- **Example:** `PORT=5000`
- **Required:** Yes
- **Notes:** Choose a port that's not in use by other services

---

### Database Configuration

#### `MONGODB_URI`
- **Description:** MongoDB connection string
- **Type:** String (URI)
- **Default:** None
- **Example:** 
  - Local: `MONGODB_URI=mongodb://localhost:27017/servicehub`
  - Atlas: `MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/servicehub?retryWrites=true&w=majority`
- **Required:** Yes
- **Notes:** 
  - For production, use MongoDB Atlas or a managed MongoDB service
  - Ensure the database name is appropriate for your environment
  - Include authentication credentials if required
  - Use connection pooling for better performance

---

### Authentication Configuration

#### `JWT_SECRET`
- **Description:** Secret key for signing JWT tokens
- **Type:** String
- **Default:** None
- **Example:** `JWT_SECRET=your_super_secret_jwt_key_min_32_characters_long`
- **Required:** Yes
- **Security Requirements:**
  - Minimum 32 characters
  - Use a cryptographically secure random string
  - Different for each environment (dev, staging, production)
  - Never share or commit to version control
- **Generation:** 
  ```bash
  node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
  ```

---

### Email Configuration (Gmail SMTP)

#### `EMAIL_USER`
- **Description:** Gmail email address for sending emails
- **Type:** String (Email)
- **Default:** None
- **Example:** `EMAIL_USER=your-email@gmail.com`
- **Required:** Yes (for email features)
- **Notes:** 
  - Must be a valid Gmail account
  - 2-factor authentication must be enabled
  - App password must be generated (see `EMAIL_PASS`)

#### `EMAIL_PASS`
- **Description:** Gmail app password (not your regular password)
- **Type:** String
- **Default:** None
- **Example:** `EMAIL_PASS=abcd efgh ijkl mnop`
- **Required:** Yes (for email features)
- **Setup Instructions:**
  1. Enable 2-factor authentication on your Gmail account
  2. Go to Google Account → Security → 2-Step Verification → App passwords
  3. Generate a new app password for "Mail"
  4. Copy the 16-character password (with spaces)
  5. Use this password in the `EMAIL_PASS` variable
- **Notes:**
  - This is NOT your regular Gmail password
  - Keep this secret and secure
  - Gmail has sending limits: 500 emails/day for free accounts

---

### Admin Configuration

#### `PRIMARY_ADMIN_EMAIL`
- **Description:** Email address of the primary administrator
- **Type:** String (Email)
- **Default:** None
- **Example:** `PRIMARY_ADMIN_EMAIL=admin@assurefix.com`
- **Required:** Yes
- **Notes:**
  - This user will have full admin privileges
  - Used for initial admin account creation
  - Can add additional admins through the admin panel

---

### Frontend Configuration

#### `FRONTEND_URL`
- **Description:** URL of the frontend application
- **Type:** String (URL)
- **Default:** None
- **Example:** 
  - Development: `FRONTEND_URL=http://localhost:8082`
  - Production: `FRONTEND_URL=https://assurefix.com`
- **Required:** Yes
- **Notes:**
  - Used for CORS configuration
  - Used in email templates for links
  - Must match the actual frontend URL

---

### Cloud Storage Configuration (Optional)

#### `CLOUDINARY_CLOUD_NAME`
- **Description:** Cloudinary cloud name
- **Type:** String
- **Default:** None
- **Example:** `CLOUDINARY_CLOUD_NAME=your-cloud-name`
- **Required:** No (optional for cloud storage)
- **Notes:**
  - Required only if using Cloudinary for image storage
  - Alternative: Use local file storage

#### `CLOUDINARY_API_KEY`
- **Description:** Cloudinary API key
- **Type:** String
- **Default:** None
- **Example:** `CLOUDINARY_API_KEY=123456789012345`
- **Required:** No (optional for cloud storage)
- **Notes:** Found in Cloudinary dashboard

#### `CLOUDINARY_API_SECRET`
- **Description:** Cloudinary API secret
- **Type:** String
- **Default:** None
- **Example:** `CLOUDINARY_API_SECRET=abcdefghijklmnopqrstuvwxyz`
- **Required:** No (optional for cloud storage)
- **Notes:** Keep this secret and secure

---

### Voice Call Configuration (Agora)

#### `AGORA_APP_ID`
- **Description:** Agora application ID for voice calls
- **Type:** String
- **Default:** None
- **Example:** `AGORA_APP_ID=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`
- **Required:** Yes (for voice call features)
- **Setup:**
  1. Create account at https://console.agora.io/
  2. Create a new project
  3. Copy the App ID from project settings
- **Notes:**
  - Required for voice call functionality
  - Free tier: 10,000 minutes/month
  - See AGORA_SETUP_GUIDE.md for detailed setup

#### `AGORA_APP_CERTIFICATE`
- **Description:** Agora application certificate for token generation
- **Type:** String
- **Default:** None
- **Example:** `AGORA_APP_CERTIFICATE=1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p`
- **Required:** Yes (for voice call features)
- **Setup:**
  1. In Agora Console, go to project settings
  2. Enable "Primary Certificate"
  3. Copy the certificate value
- **Security:**
  - **NEVER** expose this in client-side code
  - Keep this secret and secure
  - Used only on backend for token generation

---

## Optional Variables

### Logging Configuration

#### `LOG_LEVEL`
- **Description:** Logging level for Winston logger
- **Type:** String (enum)
- **Default:** `info`
- **Options:** `error`, `warn`, `info`, `debug`, `verbose`
- **Example:** `LOG_LEVEL=debug`
- **Required:** No
- **Notes:**
  - Use `debug` or `verbose` in development
  - Use `info` or `warn` in production

#### `LOG_FILE`
- **Description:** Path to log file
- **Type:** String (Path)
- **Default:** `logs/app.log`
- **Example:** `LOG_FILE=/var/log/assurefix/app.log`
- **Required:** No
- **Notes:** Ensure the directory exists and is writable

---

### Rate Limiting Configuration

#### `RATE_LIMIT_WINDOW_MS`
- **Description:** Time window for rate limiting (milliseconds)
- **Type:** Number
- **Default:** 900000 (15 minutes)
- **Example:** `RATE_LIMIT_WINDOW_MS=900000`
- **Required:** No

#### `RATE_LIMIT_MAX_REQUESTS`
- **Description:** Maximum requests per window
- **Type:** Number
- **Default:** 100
- **Example:** `RATE_LIMIT_MAX_REQUESTS=100`
- **Required:** No

---

### Session Configuration

#### `SESSION_SECRET`
- **Description:** Secret for session encryption
- **Type:** String
- **Default:** None
- **Example:** `SESSION_SECRET=your_session_secret_key`
- **Required:** No (if using sessions)
- **Notes:** Similar security requirements as JWT_SECRET

---

### File Upload Configuration

#### `MAX_FILE_SIZE`
- **Description:** Maximum file upload size in bytes
- **Type:** Number
- **Default:** 10485760 (10MB)
- **Example:** `MAX_FILE_SIZE=10485760`
- **Required:** No

#### `UPLOAD_DIR`
- **Description:** Directory for uploaded files
- **Type:** String (Path)
- **Default:** `uploads`
- **Example:** `UPLOAD_DIR=/var/www/assurefix/uploads`
- **Required:** No
- **Notes:** Ensure directory exists and is writable

---

## Environment-Specific Configurations

### Development Environment

```env
# Server
PORT=5000

# Database
MONGODB_URI=mongodb://localhost:27017/servicehub_dev

# Authentication
JWT_SECRET=dev_jwt_secret_min_32_characters_long_12345

# Email
EMAIL_USER=dev-email@gmail.com
EMAIL_PASS=dev app password here

# Admin
PRIMARY_ADMIN_EMAIL=admin@localhost

# Frontend
FRONTEND_URL=http://localhost:8082

# Agora (use test credentials)
AGORA_APP_ID=test_app_id
AGORA_APP_CERTIFICATE=test_app_certificate

# Logging
LOG_LEVEL=debug
```

### Staging Environment

```env
# Server
PORT=5000

# Database
MONGODB_URI=mongodb+srv://user:pass@staging-cluster.mongodb.net/servicehub_staging

# Authentication
JWT_SECRET=staging_jwt_secret_different_from_dev_and_prod

# Email
EMAIL_USER=staging-email@gmail.com
EMAIL_PASS=staging app password

# Admin
PRIMARY_ADMIN_EMAIL=admin@staging.assurefix.com

# Frontend
FRONTEND_URL=https://staging.assurefix.com

# Agora
AGORA_APP_ID=staging_app_id
AGORA_APP_CERTIFICATE=staging_app_certificate

# Logging
LOG_LEVEL=info
```

### Production Environment

```env
# Server
PORT=5000

# Database
MONGODB_URI=mongodb+srv://user:pass@prod-cluster.mongodb.net/servicehub_prod

# Authentication
JWT_SECRET=production_jwt_secret_very_secure_and_long_random_string

# Email
EMAIL_USER=noreply@assurefix.com
EMAIL_PASS=production app password

# Admin
PRIMARY_ADMIN_EMAIL=admin@assurefix.com

# Frontend
FRONTEND_URL=https://assurefix.com

# Agora
AGORA_APP_ID=production_app_id
AGORA_APP_CERTIFICATE=production_app_certificate

# Cloudinary (optional)
CLOUDINARY_CLOUD_NAME=assurefix-prod
CLOUDINARY_API_KEY=production_api_key
CLOUDINARY_API_SECRET=production_api_secret

# Logging
LOG_LEVEL=warn
LOG_FILE=/var/log/assurefix/app.log

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

---

## Security Best Practices

### 1. Never Commit .env Files

Ensure `.env` is in `.gitignore`:
```
# .gitignore
.env
.env.local
.env.*.local
```

### 2. Use Strong Secrets

Generate cryptographically secure random strings:
```bash
# Generate JWT secret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Generate session secret
node -e "console.log(require('crypto').randomBytes(64).toString('base64'))"
```

### 3. Different Secrets Per Environment

- Never use the same JWT_SECRET in dev, staging, and production
- Use different database credentials for each environment
- Rotate secrets regularly

### 4. Restrict Access

- Limit who has access to production .env files
- Use secret management services (AWS Secrets Manager, HashiCorp Vault)
- Encrypt .env files at rest

### 5. Environment Variable Validation

The application validates required environment variables on startup:
```javascript
// In server.js
const requiredEnvVars = [
  'MONGODB_URI',
  'JWT_SECRET',
  'EMAIL_USER',
  'EMAIL_PASS',
  'AGORA_APP_ID',
  'AGORA_APP_CERTIFICATE'
];

requiredEnvVars.forEach(varName => {
  if (!process.env[varName]) {
    console.error(`Error: ${varName} is not set in environment variables`);
    process.exit(1);
  }
});
```

---

## Troubleshooting

### Issue: "Environment variable not found"

**Solution:**
1. Verify `.env` file exists in backend root directory
2. Check variable name spelling (case-sensitive)
3. Ensure no spaces around `=` sign
4. Restart the server after updating `.env`

### Issue: "Invalid MongoDB URI"

**Solution:**
1. Check connection string format
2. Verify username and password are URL-encoded
3. Test connection with MongoDB Compass or mongosh
4. Check network connectivity and firewall rules

### Issue: "JWT token invalid"

**Solution:**
1. Verify JWT_SECRET is set and consistent
2. Check token expiration time
3. Ensure secret hasn't changed (invalidates existing tokens)

### Issue: "Email sending fails"

**Solution:**
1. Verify 2FA is enabled on Gmail account
2. Check app password is correct (16 characters with spaces)
3. Test with a simple email sending script
4. Check Gmail sending limits (500/day for free accounts)

### Issue: "Agora token generation fails"

**Solution:**
1. Verify AGORA_APP_ID and AGORA_APP_CERTIFICATE are set
2. Check credentials match Agora Console
3. Ensure App Certificate is enabled in Agora Console
4. Test token generation with test script

---

## Validation Script

Create a script to validate environment variables:

```javascript
// scripts/validateEnv.js
require('dotenv').config();

const requiredVars = {
  PORT: 'number',
  MONGODB_URI: 'string',
  JWT_SECRET: 'string',
  EMAIL_USER: 'email',
  EMAIL_PASS: 'string',
  PRIMARY_ADMIN_EMAIL: 'email',
  FRONTEND_URL: 'url',
  AGORA_APP_ID: 'string',
  AGORA_APP_CERTIFICATE: 'string'
};

let errors = [];

Object.entries(requiredVars).forEach(([varName, type]) => {
  const value = process.env[varName];
  
  if (!value) {
    errors.push(`${varName} is not set`);
    return;
  }
  
  // Type validation
  if (type === 'number' && isNaN(value)) {
    errors.push(`${varName} must be a number`);
  }
  
  if (type === 'email' && !value.includes('@')) {
    errors.push(`${varName} must be a valid email`);
  }
  
  if (type === 'url' && !value.startsWith('http')) {
    errors.push(`${varName} must be a valid URL`);
  }
  
  // Security validation
  if (varName === 'JWT_SECRET' && value.length < 32) {
    errors.push(`${varName} must be at least 32 characters`);
  }
});

if (errors.length > 0) {
  console.error('Environment validation failed:\n');
  errors.forEach(error => console.error(`  ✗ ${error}`));
  process.exit(1);
} else {
  console.log('✓ All environment variables are valid');
}
```

Run validation:
```bash
node scripts/validateEnv.js
```

---

## References

- [dotenv Documentation](https://github.com/motdotla/dotenv)
- [MongoDB Connection Strings](https://docs.mongodb.com/manual/reference/connection-string/)
- [Gmail SMTP Settings](https://support.google.com/mail/answer/7126229)
- [Agora Documentation](https://docs.agora.io/)

---

**Last Updated:** December 3, 2025
