/**
 * Environment Variables Validation Script
 * 
 * This script validates that all required environment variables are set
 * and meet the necessary security and format requirements.
 * 
 * Usage: node scripts/validateEnv.js
 */

require('dotenv').config();

const requiredVars = {
  PORT: { type: 'number', required: true },
  MONGODB_URI: { type: 'string', required: true },
  JWT_SECRET: { type: 'string', required: true, minLength: 32 },
  EMAIL_USER: { type: 'email', required: true },
  EMAIL_PASS: { type: 'string', required: true },
  PRIMARY_ADMIN_EMAIL: { type: 'email', required: true },
  FRONTEND_URL: { type: 'url', required: true },
  AGORA_APP_ID: { type: 'string', required: true },
  AGORA_APP_CERTIFICATE: { type: 'string', required: true }
};

const optionalVars = {
  CLOUDINARY_CLOUD_NAME: { type: 'string', required: false },
  CLOUDINARY_API_KEY: { type: 'string', required: false },
  CLOUDINARY_API_SECRET: { type: 'string', required: false },
  LOG_LEVEL: { type: 'string', required: false },
  LOG_FILE: { type: 'string', required: false },
  RATE_LIMIT_WINDOW_MS: { type: 'number', required: false },
  RATE_LIMIT_MAX_REQUESTS: { type: 'number', required: false },
  MAX_FILE_SIZE: { type: 'number', required: false },
  UPLOAD_DIR: { type: 'string', required: false },
  SESSION_SECRET: { type: 'string', required: false }
};

let errors = [];
let warnings = [];

console.log('='.repeat(60));
console.log('Environment Variables Validation');
console.log('='.repeat(60));
console.log('');

/**
 * Validate a single environment variable
 */
function validateVar(varName, config, value) {
  // Check if required variable is missing
  if (config.required && !value) {
    errors.push(`${varName} is required but not set`);
    return;
  }

  // Skip validation if optional and not set
  if (!config.required && !value) {
    return;
  }

  // Type validation
  switch (config.type) {
    case 'number':
      if (isNaN(value)) {
        errors.push(`${varName} must be a number (got: ${value})`);
      }
      break;

    case 'email':
      if (!value.includes('@') || !value.includes('.')) {
        errors.push(`${varName} must be a valid email address`);
      }
      break;

    case 'url':
      if (!value.startsWith('http://') && !value.startsWith('https://')) {
        errors.push(`${varName} must be a valid URL (must start with http:// or https://)`);
      }
      break;

    case 'string':
      if (typeof value !== 'string') {
        errors.push(`${varName} must be a string`);
      }
      break;
  }

  // Length validation
  if (config.minLength && value.length < config.minLength) {
    errors.push(`${varName} must be at least ${config.minLength} characters (got: ${value.length})`);
  }

  // Security warnings
  if (varName === 'JWT_SECRET') {
    if (value.includes('your_') || value.includes('example') || value.includes('test')) {
      warnings.push(`${varName} appears to be a placeholder value - use a secure random string`);
    }
  }

  if (varName === 'AGORA_APP_ID' || varName === 'AGORA_APP_CERTIFICATE') {
    if (value.includes('your_') || value.includes('example') || value.includes('test')) {
      warnings.push(`${varName} appears to be a placeholder value - use actual Agora credentials`);
    }
  }

  if (varName === 'MONGODB_URI') {
    if (value.includes('localhost') && process.env.NODE_ENV === 'production') {
      warnings.push(`${varName} is using localhost in production environment`);
    }
  }
}

// Validate required variables
console.log('Checking required variables...\n');
Object.entries(requiredVars).forEach(([varName, config]) => {
  const value = process.env[varName];
  const status = value ? '✓' : '✗';
  console.log(`  ${status} ${varName}`);
  validateVar(varName, config, value);
});

// Validate optional variables
console.log('\nChecking optional variables...\n');
Object.entries(optionalVars).forEach(([varName, config]) => {
  const value = process.env[varName];
  const status = value ? '✓' : '-';
  console.log(`  ${status} ${varName}${value ? '' : ' (not set)'}`);
  if (value) {
    validateVar(varName, config, value);
  }
});

// Display results
console.log('\n' + '='.repeat(60));
console.log('Validation Results');
console.log('='.repeat(60));
console.log('');

if (errors.length > 0) {
  console.log('ERRORS:\n');
  errors.forEach(error => {
    console.log(`  ✗ ${error}`);
  });
  console.log('');
}

if (warnings.length > 0) {
  console.log('WARNINGS:\n');
  warnings.forEach(warning => {
    console.log(`  ⚠ ${warning}`);
  });
  console.log('');
}

if (errors.length === 0 && warnings.length === 0) {
  console.log('✓ All environment variables are valid!\n');
  console.log('Your environment is properly configured.\n');
} else if (errors.length === 0) {
  console.log('✓ All required variables are valid\n');
  console.log(`⚠ ${warnings.length} warning(s) found - please review\n`);
} else {
  console.log(`✗ ${errors.length} error(s) found\n`);
  console.log('Please fix the errors above before starting the application.\n');
  console.log('See ENVIRONMENT_VARIABLES.md for detailed configuration guide.\n');
}

console.log('='.repeat(60));
console.log('');

// Exit with appropriate code
if (errors.length > 0) {
  process.exit(1);
} else {
  process.exit(0);
}
