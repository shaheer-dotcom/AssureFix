const jwt = require('jsonwebtoken');
const Admin = require('../models/Admin');

const adminAuth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ message: 'No authentication token provided' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if this is an admin token
    if (!decoded.adminEmail) {
      return res.status(403).json({ message: 'Access denied. Admin privileges required.' });
    }

    const admin = await Admin.findOne({ 
      email: decoded.adminEmail,
      isActive: true 
    });

    if (!admin) {
      return res.status(403).json({ message: 'Admin access denied or account deactivated' });
    }

    req.admin = admin;
    next();
  } catch (error) {
    console.error('Admin auth error:', error);
    res.status(401).json({ message: 'Invalid or expired token' });
  }
};

module.exports = adminAuth;
