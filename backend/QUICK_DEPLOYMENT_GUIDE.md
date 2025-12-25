# Quick Deployment Guide

## Overview

This is a condensed deployment guide for the Enhanced Messaging System. For the complete checklist, see [DEPLOYMENT_CHECKLIST.md](../DEPLOYMENT_CHECKLIST.md).

---

## Prerequisites

- [ ] Node.js 16+ installed
- [ ] MongoDB database ready
- [ ] Agora account created
- [ ] Gmail SMTP configured
- [ ] Domain and SSL certificate (production)

---

## Quick Deployment Steps

### 1. Prepare Environment

```bash
# Clone repository
git clone <repository_url>
cd backend

# Install dependencies
npm install --production

# Configure environment
cp .env.example .env
nano .env  # Update with production values
```

### 2. Validate Configuration

```bash
# Validate environment variables
npm run validate:env

# Test database connection
node -e "
const mongoose = require('mongoose');
require('dotenv').config();
mongoose.connect(process.env.MONGODB_URI)
  .then(() => { console.log('✓ Database connected'); process.exit(0); })
  .catch(err => { console.error('✗ Database error:', err); process.exit(1); });
"

# Test Agora credentials
node -e "
const {generateAgoraToken} = require('./utils/agoraToken');
try {
  const token = generateAgoraToken('test', 0, 'publisher');
  console.log('✓ Agora token generated');
} catch (err) {
  console.error('✗ Agora error:', err.message);
}
"
```

### 3. Run Database Migrations

```bash
# Run all migrations
npm run migrate:up

# Verify migrations
node -e "
const mongoose = require('mongoose');
require('dotenv').config();
mongoose.connect(process.env.MONGODB_URI)
  .then(async () => {
    const collections = await mongoose.connection.db.listCollections().toArray();
    console.log('Collections:', collections.map(c => c.name).join(', '));
    process.exit(0);
  });
"
```

### 4. Run Tests

```bash
# Run all tests
npm test

# Check for security vulnerabilities
npm audit
npm audit fix
```

### 5. Deploy Application

#### Option A: PM2 (Recommended)

```bash
# Install PM2 globally
npm install -g pm2

# Start application
pm2 start server.js --name assurefix-backend

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup

# View logs
pm2 logs assurefix-backend

# Monitor
pm2 monit
```

#### Option B: Docker

```bash
# Build image
docker build -t assurefix-backend .

# Run container
docker run -d \
  --name assurefix-backend \
  -p 5000:5000 \
  --env-file .env \
  assurefix-backend

# View logs
docker logs -f assurefix-backend
```

#### Option C: Systemd Service

```bash
# Create service file
sudo nano /etc/systemd/system/assurefix-backend.service

# Add configuration (see below)

# Start service
sudo systemctl start assurefix-backend
sudo systemctl enable assurefix-backend

# View logs
sudo journalctl -u assurefix-backend -f
```

**Systemd Service Configuration:**
```ini
[Unit]
Description=AssureFix Backend API
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/assurefix/backend
Environment=NODE_ENV=production
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 6. Configure Reverse Proxy (Nginx)

```bash
# Install Nginx
sudo apt install nginx

# Create configuration
sudo nano /etc/nginx/sites-available/assurefix-api

# Add configuration (see below)

# Enable site
sudo ln -s /etc/nginx/sites-available/assurefix-api /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy to Node.js
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # WebSocket support
    location /socket.io/ {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

### 7. Setup SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d api.yourdomain.com

# Test auto-renewal
sudo certbot renew --dry-run
```

### 8. Configure Firewall

```bash
# Allow SSH
sudo ufw allow ssh

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

### 9. Setup Monitoring

```bash
# Install monitoring tools
npm install -g pm2

# Enable PM2 monitoring
pm2 install pm2-logrotate

# Configure log rotation
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7

# Setup external monitoring (optional)
# - UptimeRobot: https://uptimerobot.com/
# - Sentry: https://sentry.io/
```

### 10. Verify Deployment

```bash
# Health check
curl https://api.yourdomain.com/api/health

# Test authentication
curl -X POST https://api.yourdomain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Check logs
pm2 logs assurefix-backend --lines 50

# Monitor resources
pm2 monit
```

---

## Post-Deployment

### Backup Strategy

```bash
# Database backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/mongodb"
mkdir -p $BACKUP_DIR

mongodump --uri="$MONGODB_URI" --out="$BACKUP_DIR/$DATE"

# Keep only last 7 days
find $BACKUP_DIR -type d -mtime +7 -exec rm -rf {} +
```

**Setup cron job:**
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /path/to/backup-script.sh
```

### Monitoring Checklist

- [ ] Setup uptime monitoring (UptimeRobot, Pingdom)
- [ ] Configure error tracking (Sentry)
- [ ] Setup log aggregation (Papertrail, Loggly)
- [ ] Monitor Agora usage (Agora Console)
- [ ] Setup alerts for critical errors
- [ ] Monitor disk space
- [ ] Monitor memory usage
- [ ] Monitor API response times

### Security Checklist

- [ ] Firewall configured
- [ ] SSL certificate installed
- [ ] Environment variables secured
- [ ] Database access restricted
- [ ] Regular security updates scheduled
- [ ] Backup strategy implemented
- [ ] Rate limiting enabled
- [ ] CORS properly configured

---

## Rollback Procedure

If deployment fails:

```bash
# Stop current version
pm2 stop assurefix-backend

# Checkout previous version
git checkout <previous_version_tag>

# Install dependencies
npm install

# Rollback database (if needed)
npm run migrate:down

# Start previous version
pm2 start server.js --name assurefix-backend

# Verify
curl https://api.yourdomain.com/api/health
```

---

## Common Issues

### Issue: Port already in use

```bash
# Find process using port 5000
sudo lsof -i :5000

# Kill process
sudo kill -9 <PID>
```

### Issue: MongoDB connection fails

```bash
# Check MongoDB status
sudo systemctl status mongod

# Check connection string
echo $MONGODB_URI

# Test connection
mongosh "$MONGODB_URI"
```

### Issue: PM2 not starting on boot

```bash
# Regenerate startup script
pm2 unstartup
pm2 startup

# Save PM2 list
pm2 save
```

### Issue: Nginx 502 Bad Gateway

```bash
# Check backend is running
pm2 status

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Test backend directly
curl http://localhost:5000/api/health
```

---

## Useful Commands

```bash
# Backend
pm2 start server.js          # Start
pm2 stop assurefix-backend    # Stop
pm2 restart assurefix-backend # Restart
pm2 logs assurefix-backend    # View logs
pm2 monit                     # Monitor

# Database
npm run migrate:up            # Run migrations
npm run migrate:down          # Rollback migrations
mongodump --uri="..."         # Backup
mongorestore --uri="..."      # Restore

# Validation
npm run validate:env          # Validate environment
npm test                      # Run tests
npm audit                     # Security audit

# Nginx
sudo nginx -t                 # Test config
sudo systemctl reload nginx   # Reload
sudo systemctl restart nginx  # Restart

# SSL
sudo certbot renew            # Renew certificate
sudo certbot certificates     # List certificates
```

---

## Support

For detailed information, see:
- [DEPLOYMENT_CHECKLIST.md](../DEPLOYMENT_CHECKLIST.md) - Complete checklist
- [ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md) - Configuration guide
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - API reference
- [AGORA_SETUP_GUIDE.md](AGORA_SETUP_GUIDE.md) - Voice call setup

---

**Last Updated:** December 3, 2025
