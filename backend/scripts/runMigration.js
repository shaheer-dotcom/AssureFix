/**
 * Migration Runner Script
 * 
 * This script helps run database migrations in order.
 * Usage: node scripts/runMigration.js [migration_number] [up|down]
 * 
 * Examples:
 *   node scripts/runMigration.js 001 up    - Run migration 001
 *   node scripts/runMigration.js 001 down  - Rollback migration 001
 *   node scripts/runMigration.js all up    - Run all pending migrations
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const MIGRATIONS_DIR = path.join(__dirname, 'migrations');

/**
 * Get all migration files
 */
function getMigrationFiles() {
  if (!fs.existsSync(MIGRATIONS_DIR)) {
    console.error('Migrations directory not found:', MIGRATIONS_DIR);
    process.exit(1);
  }

  const files = fs.readdirSync(MIGRATIONS_DIR)
    .filter(file => file.endsWith('.js'))
    .sort();

  return files;
}

/**
 * Run a specific migration
 */
function runMigration(migrationFile, direction) {
  const migrationPath = path.join(MIGRATIONS_DIR, migrationFile);
  
  console.log(`\n${'='.repeat(60)}`);
  console.log(`Running migration: ${migrationFile} (${direction})`);
  console.log('='.repeat(60));

  try {
    execSync(`node "${migrationPath}" ${direction}`, { 
      stdio: 'inherit',
      cwd: path.join(__dirname, '..')
    });
    console.log(`\n✓ Migration ${migrationFile} completed successfully`);
    return true;
  } catch (error) {
    console.error(`\n✗ Migration ${migrationFile} failed`);
    return false;
  }
}

/**
 * Main function
 */
function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.log('Usage: node runMigration.js [migration_number|all] [up|down]');
    console.log('\nExamples:');
    console.log('  node runMigration.js 001 up    - Run migration 001');
    console.log('  node runMigration.js 001 down  - Rollback migration 001');
    console.log('  node runMigration.js all up    - Run all migrations');
    console.log('\nAvailable migrations:');
    
    const migrations = getMigrationFiles();
    if (migrations.length === 0) {
      console.log('  No migrations found');
    } else {
      migrations.forEach(file => {
        console.log(`  - ${file}`);
      });
    }
    
    process.exit(1);
  }

  const [migrationArg, direction] = args;

  if (!['up', 'down'].includes(direction)) {
    console.error('Direction must be "up" or "down"');
    process.exit(1);
  }

  const migrations = getMigrationFiles();

  if (migrationArg === 'all') {
    // Run all migrations
    console.log(`\nRunning all migrations (${direction})...\n`);
    
    const migrationsToRun = direction === 'up' 
      ? migrations 
      : migrations.reverse();

    let successCount = 0;
    let failCount = 0;

    for (const migration of migrationsToRun) {
      const success = runMigration(migration, direction);
      if (success) {
        successCount++;
      } else {
        failCount++;
        console.error('\nStopping due to migration failure');
        break;
      }
    }

    console.log(`\n${'='.repeat(60)}`);
    console.log('Migration Summary');
    console.log('='.repeat(60));
    console.log(`Total migrations: ${migrations.length}`);
    console.log(`Successful: ${successCount}`);
    console.log(`Failed: ${failCount}`);
    console.log('='.repeat(60));

    process.exit(failCount > 0 ? 1 : 0);

  } else {
    // Run specific migration
    const migrationFile = migrations.find(file => file.startsWith(migrationArg));

    if (!migrationFile) {
      console.error(`Migration ${migrationArg} not found`);
      console.log('\nAvailable migrations:');
      migrations.forEach(file => {
        console.log(`  - ${file}`);
      });
      process.exit(1);
    }

    const success = runMigration(migrationFile, direction);
    process.exit(success ? 0 : 1);
  }
}

// Run main function
main();
