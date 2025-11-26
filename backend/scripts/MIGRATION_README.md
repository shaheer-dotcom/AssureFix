# Area Tags Migration Guide

## Overview
This migration converts the Service model from using single `area` and `areaCovered` string fields to using an `areaTags` array field for better search functionality and user experience.

## What Changed

### Backend Changes
1. **Service Model** (`backend/models/Service.js`)
   - Removed: `area` (String) and `areaCovered` (String) fields
   - Added: `areaTags` (Array of Strings) field
   - Updated indexes to use `areaTags` instead of `area`

2. **Service Routes** (`backend/routes/services.js`)
   - Updated POST `/api/services` to accept `areaTags` array
   - Updated GET `/api/services` search logic to use `$elemMatch` for area tag matching
   - Search now matches services where at least one area tag matches the location query

### Frontend Changes
1. **Service Model** (`frontend/lib/models/service.dart`)
   - Changed from `area` and `areaCovered` strings to `areaTags` array
   - Added backward compatibility getters for `area` and `areaCovered`
   - Updated JSON parsing to handle both new array format and legacy string format

2. **UI Components**
   - **Post Service Screen**: Already had tag input, updated to send `areaTags` array
   - **Edit Service Screen**: Added tag input with bubbles (matching post service screen)
   - **Search Services Screen**: Updated to display area tags as bubbles (max 3 shown)
   - **Service Detail Screen**: Updated to display all area tags as bubbles
   - **Manage Services Screen**: Updated to display area tags as bubbles (max 3 shown)

## Running the Migration

### Prerequisites
- Backup your database before running the migration
- Ensure MongoDB connection is configured in `.env`

### Steps

1. **Run the migration script**:
   ```bash
   cd backend
   node scripts/migrate-area-tags.js
   ```

2. **What the script does**:
   - Finds all services with `area` or `areaCovered` fields
   - Splits the string values by newlines, commas, or periods
   - Creates unique array of area tags
   - Updates each service with `areaTags` array
   - Removes old `area` and `areaCovered` fields

3. **Verify the migration**:
   - Check the console output for migration statistics
   - Verify services in MongoDB have `areaTags` array
   - Test service creation and search in the application

## Example Data Transformation

**Before:**
```json
{
  "name": "Plumbing Service",
  "area": "Gulshan\nDHA\nClifton",
  "areaCovered": "Gulshan\nDHA\nClifton"
}
```

**After:**
```json
{
  "name": "Plumbing Service",
  "areaTags": ["Gulshan", "DHA", "Clifton"]
}
```

## Search Behavior

### Old Behavior
- Searched using regex on `area` or `areaCovered` strings
- Matched partial strings anywhere in the field

### New Behavior
- Searches using `$elemMatch` on `areaTags` array
- Matches if ANY tag contains the search term (case-insensitive)
- More efficient with proper indexing

### Example Search Queries

**Search for "Gulshan":**
- Matches services with tags: ["Gulshan", "DHA"]
- Matches services with tags: ["Gulshan-e-Iqbal", "Karachi"]
- Does NOT match services with tags: ["DHA", "Clifton"]

## UI Features

### Tag Input
- Type area name and press Enter to create a tag
- Tags appear as removable bubbles
- Click X on bubble to remove a tag
- At least one tag is required

### Tag Display
- Service cards show up to 3 tags as bubbles
- Additional tags shown as "+N" indicator
- Detail view shows all tags
- Tags have location icon and blue styling

## Rollback

If you need to rollback:

1. Restore database from backup
2. Revert code changes:
   ```bash
   git revert <commit-hash>
   ```

## Testing Checklist

- [ ] Migration script runs without errors
- [ ] All existing services have `areaTags` array
- [ ] Can create new service with multiple area tags
- [ ] Can edit service and modify area tags
- [ ] Search by area finds correct services
- [ ] Service cards display area tags as bubbles
- [ ] Service detail shows all area tags
- [ ] Manage services screen shows area tags

## Notes

- The frontend Service model maintains backward compatibility
- Old API responses with `area` field will be parsed into `areaTags`
- New services must use `areaTags` array format
- Search is case-insensitive and matches partial tag names
