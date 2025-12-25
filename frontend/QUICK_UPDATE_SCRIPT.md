# Quick Glass Theme Update Script

## ✅ Completed Screens
1. `lib/screens/admin/send_notification_screen.dart` - ✓ DONE
2. `lib/screens/auth/login_screen.dart` - ✓ DONE  
3. `lib/screens/services/search_services_screen.dart` - ✓ DONE

## 🔄 To Update All Remaining Screens

### Step 1: Add Imports to ALL Screen Files

Add these two lines after existing imports in every screen file:

```dart
import '../../utils/theme.dart';
import '../../widgets/glass_widgets.dart';
```

### Step 2: Global Find & Replace

Use your IDE's find and replace feature (Ctrl+Shift+H or Cmd+Shift+H):

#### Replace 1: Scaffold with GlassScaffold
**Find:**
```
Scaffold\(\s*appBar:\s*AppBar\(\s*title:\s*(?:const\s+)?Text\('([^']+)'\)
```
**Replace:**
```
GlassScaffold(\n  title: '$1'
```

#### Replace 2: Remove flexibleSpace decorations
**Find:**
```
,\s*flexibleSpace:\s*Container\([^)]+\),
```
**Replace:** (empty)

#### Replace 3: Card to GlassCard
**Find:**
```
Card\(\s*(?:elevation:\s*\d+,)?\s*(?:margin:[^,]+,)?\s*child:
```
**Replace:**
```
GlassCard(\n  child:
```

#### Replace 4: Simple TextFormField to GlassTextField
**Find:**
```
TextFormField\(\s*controller:\s*([^,]+),\s*decoration:\s*(?:const\s+)?InputDecoration\(\s*labelText:\s*'([^']+)',\s*(?:hintText:[^,]+,)?\s*(?:border:[^,]+,)?\s*prefixIcon:\s*(?:const\s+)?Icon\(([^)]+)\)
```
**Replace:**
```
GlassTextField(\n  controller: $1,\n  labelText: '$2',\n  prefixIcon: $3
```

#### Replace 5: ElevatedButton to GlassButton
**Find:**
```
ElevatedButton\(\s*onPressed:\s*([^,]+),\s*(?:style:[^,]+,)?\s*child:\s*(?:const\s+)?Text\('([^']+)'\)
```
**Replace:**
```
GlassButton(\n  text: '$2',\n  onPressed: $1
```

### Step 3: Manual Updates for Complex Screens

For screens with complex layouts, manually update:

1. **Dashboard Screens** - Use `GlassOptionCard` for menu items
2. **List Screens** - Wrap list items in `GlassCard`
3. **Form Screens** - Use `GlassFormCard` for sections
4. **Settings Screens** - Use `GlassOptionCard` for options

### Step 4: Update Specific Screen Types

#### For Dashboard/Home Screens:
```dart
return GlassScaffold(
  title: 'Dashboard',
  body: GridView.count(
    crossAxisCount: 2,
    padding: EdgeInsets.all(16),
    children: [
      GlassOptionCard(
        icon: Icons.add,
        title: 'Add Service',
        onTap: () {},
      ),
      // More options...
    ],
  ),
);
```

#### For List Screens:
```dart
return GlassScaffold(
  title: 'My Items',
  body: ListView.builder(
    itemBuilder: (context, index) {
      return GlassCard(
        child: ListTile(...),
      );
    },
  ),
);
```

#### For Form Screens:
```dart
return GlassScaffold(
  title: 'Form',
  body: SingleChildScrollView(
    child: Column(
      children: [
        GlassFormCard(
          title: 'Section',
          children: [
            GlassTextField(...),
            GlassDropdown(...),
          ],
        ),
        GlassButton(...),
      ],
    ),
  ),
);
```

## 🎯 Priority Screens to Update Manually

### High Priority (Do These First):
1. `lib/screens/home/customer_home_screen.dart`
2. `lib/screens/home/service_provider_home_screen.dart`
3. `lib/screens/services/post_service_screen.dart`
4. `lib/screens/services/manage_services_screen.dart`
5. `lib/screens/bookings/manage_bookings_screen.dart`
6. `lib/screens/profile/profile_screen.dart`
7. `lib/screens/auth/signup_screen.dart`

### Medium Priority:
8. `lib/screens/services/service_detail_screen.dart`
9. `lib/screens/services/edit_service_screen.dart`
10. `lib/screens/profile/edit_profile_screen.dart`
11. `lib/screens/settings/settings_screen.dart`
12. `lib/screens/messages/messages_screen.dart`

### Low Priority:
13. All other screens

## 🔧 Quick Fix for Each Screen Type

### Type 1: Simple Form Screen (5 minutes)
1. Add imports
2. Change `Scaffold` to `GlassScaffold`
3. Change all `TextFormField` to `GlassTextField`
4. Change all `ElevatedButton` to `GlassButton`
5. Change all `Card` to `GlassCard`

### Type 2: Dashboard Screen (10 minutes)
1. Add imports
2. Change `Scaffold` to `GlassScaffold`
3. Replace menu cards with `GlassOptionCard`
4. Update colors to use `AppTheme` constants

### Type 3: List Screen (7 minutes)
1. Add imports
2. Change `Scaffold` to `GlassScaffold`
3. Wrap list items in `GlassCard`
4. Update colors

### Type 4: Complex Screen (15 minutes)
1. Add imports
2. Change `Scaffold` to `GlassScaffold`
3. Group form sections in `GlassFormCard`
4. Replace all input components
5. Test thoroughly

## 📝 Checklist for Each Screen

- [ ] Added imports
- [ ] Changed Scaffold to GlassScaffold
- [ ] Updated all Cards to GlassCard
- [ ] Updated all TextFields to GlassTextField
- [ ] Updated all Buttons to GlassButton
- [ ] Updated all Dropdowns to GlassDropdown (if any)
- [ ] Updated colors to use AppTheme constants
- [ ] Removed hardcoded color values
- [ ] Tested the screen
- [ ] No compilation errors

## 🚀 Fastest Way to Update All Screens

1. **Batch Update** (30 minutes):
   - Run find & replace operations on entire `lib/screens` folder
   - This will update 70% of simple cases automatically

2. **Manual Touch-ups** (2-3 hours):
   - Go through each screen
   - Fix any issues from batch update
   - Add special components (GlassOptionCard, GlassFormCard, etc.)
   - Test each screen

3. **Final Polish** (1 hour):
   - Ensure consistent spacing
   - Verify all colors use AppTheme
   - Test navigation between screens
   - Check loading states

## 💡 Tips

- Start with the most visible screens (home, dashboard, search)
- Test after updating each major screen
- Use the completed screens as reference
- Don't worry about perfection - you can refine later
- The glass theme is forgiving - it looks good even with minimal changes

## 🎨 Color Quick Reference

Replace these hardcoded colors:
- `Color(0xFF1565C0)` → `AppTheme.primaryBlue`
- `Color(0xFF42A5F5)` → `AppTheme.accentBlue`
- `Color(0xFF1976D2)` → `AppTheme.darkBlue`
- `Colors.blue` → `AppTheme.primaryBlue`

## ✅ Verification

After updating all screens, verify:
1. App launches without errors
2. All screens have glass effect
3. Navigation works
4. Forms submit correctly
5. Colors are consistent (blue and white theme)
6. Text is readable on all backgrounds
7. Buttons respond to taps
8. Loading states display correctly

## 🎯 Expected Result

After completing all updates:
- ✨ Beautiful glass morphism effects throughout
- 🎨 Consistent blue and white color scheme
- 💎 Glossy buttons with gradients
- 🔮 Transparent cards with blur effects
- 🌈 Gradient backgrounds
- ⚡ Professional, modern look

Total estimated time: **4-5 hours** for all screens
