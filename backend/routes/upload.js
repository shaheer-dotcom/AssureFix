const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const auth = require('../middleware/auth');

const router = express.Router();

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + extension);
  }
});

const fileFilter = (req, file, cb) => {
  // Allow only specific file types
  const allowedTypes = /jpeg|jpg|png|pdf/;
  const allowedMimeTypes = /image\/(jpeg|jpg|png)|application\/pdf/;
  
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedMimeTypes.test(file.mimetype);

  console.log('File upload attempt:', {
    originalname: file.originalname,
    mimetype: file.mimetype,
    extension: path.extname(file.originalname).toLowerCase(),
    extnameValid: extname,
    mimetypeValid: mimetype
  });

  // Accept if either extension or mimetype is valid (for web compatibility)
  if (mimetype || extname) {
    return cb(null, true);
  } else {
    cb(new Error('Only PDF, JPG, JPEG, and PNG files are allowed'));
  }
};

// Image-only file filter for profile pictures and banners
const imageFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png/;
  const allowedMimeTypes = /image\/(jpeg|jpg|png)/;
  
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedMimeTypes.test(file.mimetype);

  console.log('Image upload attempt:', {
    originalname: file.originalname,
    mimetype: file.mimetype,
    extension: path.extname(file.originalname).toLowerCase(),
    extnameValid: extname,
    mimetypeValid: mimetype
  });

  // Accept if either extension or mimetype is valid (for web compatibility)
  if (mimetype || extname) {
    return cb(null, true);
  } else {
    cb(new Error('Only JPG, JPEG, and PNG image files are allowed'));
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: fileFilter
});

// Multer configuration for images only (profile pictures and banners)
const imageUpload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: imageFilter
});

// General file upload endpoint - accepts any field name
router.post('/', auth, upload.any(), (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const file = req.files[0]; // Get the first file
    const filePath = `/uploads/${file.filename}`;
    
    console.log('File uploaded successfully:', file.filename);

    res.json({
      message: 'File uploaded successfully',
      filePath: filePath,
      originalName: file.originalname,
      size: file.size
    });
  } catch (error) {
    console.error('File upload error:', error);
    res.status(500).json({ message: 'Server error during file upload' });
  }
});

// Profile picture upload endpoint
router.post('/profile-picture', auth, imageUpload.single('profilePicture'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No profile picture uploaded' });
    }

    const filePath = `/uploads/${req.file.filename}`;
    
    console.log('Profile picture uploaded successfully:', req.file.filename);

    res.json({
      message: 'Profile picture uploaded successfully',
      filePath: filePath,
      originalName: req.file.originalname,
      size: req.file.size
    });
  } catch (error) {
    console.error('Profile picture upload error:', error);
    res.status(500).json({ message: 'Server error during profile picture upload' });
  }
});

// Banner image upload endpoint
router.post('/banner', auth, imageUpload.single('banner'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No banner image uploaded' });
    }

    const filePath = `/uploads/${req.file.filename}`;
    
    console.log('Banner image uploaded successfully:', req.file.filename);

    res.json({
      message: 'Banner image uploaded successfully',
      filePath: filePath,
      originalName: req.file.originalname,
      size: req.file.size
    });
  } catch (error) {
    console.error('Banner image upload error:', error);
    res.status(500).json({ message: 'Server error during banner image upload' });
  }
});

// Handle multer errors
router.use((error, req, res, next) => {
  console.error('Upload error:', error);
  
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ message: 'File size too large. Maximum 5MB allowed.' });
    }
    return res.status(400).json({ message: `Upload error: ${error.message}` });
  }
  
  if (error.message === 'Only PDF, JPG, JPEG, and PNG files are allowed' || 
      error.message === 'Only JPG, JPEG, and PNG image files are allowed') {
    return res.status(400).json({ message: error.message });
  }

  res.status(500).json({ message: `Server error during file upload: ${error.message}` });
});

module.exports = router;