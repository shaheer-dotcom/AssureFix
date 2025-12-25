# Glass Effect Theme Implementation Guide

## Overview
This guide explains how to apply the blue and white glass effect theme across all screens in the app.

## Theme Components

### 1. Colors (AppTheme in `lib/utils/theme.dart`)
- **Primary Blue**: `#1E88E5` - Main brand color
- **Light Blue**: `#64B5F6` - Lighter accent
- **Dark Blue**: `#1565C0` - Darker shade
- **Accent Blue**: `#42A5F5` - Secondary accent
- **Glass effects**: Semi-transparent whites and blues

### 2. Reusable Glass Widgets

#### GlassScaffold
Replaces standard `Scaffold` with gradient background and glass app bar.

```dart
return GlassScaffold(
  title: 'Screen Title',
  body: YourContent(),
  actions: [/* app bar actions */],
);
```

#### GlassAppBar
Glossy app bar with gradient and blur effect.

```dart
appBar: GlassAppBar(
  title: 'Title',
  actions: [IconButton(...)],
),
```

#### GlassCard
Card with glass morphism effect for content containers.

```dart
GlassCard(
  child: Column(
    children: [/* your content */],
  ),
)
```

#### GlassButton
Glossy button with gradient and shadow.

```dart
GlassButton(
  text: 'Submit',
  icon: Icons.check,
  onPressed: () {},
  isLoading: false,
)
```

#### GlassTextField
Input field with glass effect.

```dart
GlassTextField(
  controller: controller,
  labelText: 'Label',
  prefixIcon: Icons.person,
  validator: (value) => /* validation */,
)
```

#### GlassFormCard
Card specifically for form sections.

```dart
GlassFormCard(
  title: 'Section Title',
  children: [
    GlassTextField(...),
    SizedBox(height: 16),
    GlassButton(...),
  ],
)
```

#### GlassOptionCard
Card for menu options with icon.

```dart
GlassOptionCard(
  icon: Icons.settings,
  title: 'Settings',
  subtitle: 'Configure app',
  onTap: () {},
)
```

#### GlassRadioOption
Radio button with glass effect.

```dart
GlassRadioOption<String>(
  title: 'Option 1',
  subtitle: 'Description',
  value: 'option1',
  groupValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

#### GlassDropdown
Dropdown with glass effect.

```dart
GlassDropdown<String>(
  labelText: 'Select',
  value: selectedValue,
  prefixIcon: Icons.category,
  items: [/* DropdownMenuItem widgets */],
  onChanged: (value) {},
)
```

#### GlassSearchBar
Search field with glass effect.

```dart
GlassSearchBar(
  controller: searchController,
  hintText: 'Search...',
  onChanged: (value) {},
)
```

#### GlassListTile
List item with glass effect.

```dart
GlassListTile(
  leading: Icon(Icons.person),
  title: 'Title',
  subtitle: 'Subtitle',
  trailing: Icon(Icons.arrow_forward),
  onTap: () {},
)
```

#### GlassContainer
Generic container with glass effect.

```dart
GlassContainer(
  padding: EdgeInsets.all(16),
  child: YourWidget(),
)
```

#### GradientBackground
Gradient background for screens.

```dart
return GradientBackground(
  child: Scaffold(
    backgroundColor: Colors.transparent,
    body: YourContent(),
  ),
);
```

## Implementation Steps for Each Screen

### Step 1: Import Required Files
```dart
import '../../utils/theme.dart';
import '../../widgets/glass_widgets.dart';
```

### Step 2: Replace Scaffold
```dart
// Before
return Scaffold(
  appBar: AppBar(title: Text('Title')),
  body: Content(),
);

// After
return GlassScaffold(
  title: 'Title',
  body: Content(),
);
```

### Step 3: Replace Cards
```dart
// Before
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Content(),
  ),
)

// After
GlassCard(
  child: Content(),
)
```

### Step 4: Replace TextFields
```dart
// Before
TextFormField(
  controller: controller,
  decoration: InputDecoration(
    labelText: 'Label',
    prefixIcon: Icon(Icons.person),
  ),
)

// After
GlassTextField(
  controller: controller,
  labelText: 'Label',
  prefixIcon: Icons.person,
)
```

### Step 5: Replace Buttons
```dart
// Before
ElevatedButton(
  onPressed: () {},
  child: Text('Submit'),
)

// After
GlassButton(
  text: 'Submit',
  onPressed: () {},
)
```

### Step 6: Replace Radio Buttons
```dart
// Before
RadioListTile<String>(
  title: Text('Option'),
  value: 'option',
  groupValue: selected,
  onChanged: (value) {},
)

// After
GlassRadioOption<String>(
  title: 'Option',
  value: 'option',
  groupValue: selected,
  onChanged: (value) {},
)
```

## Screens to Update

### Authentication Screens
- [ ] `lib/screens/auth/login_screen.dart`
- [ ] `lib/screens/auth/signup_screen.dart`
- [ ] `lib/screens/auth/forgot_password_screen.dart`

### Profile Screens
- [ ] `lib/screens/profile/profile_screen.dart`
- [ ] `lib/screens/profile/edit_profile_screen.dart`
- [ ] `lib/screens/profile/profile_setup_screen.dart`
- [ ] `lib/screens/profile/customer_profile_creation_screen.dart`
- [ ] `lib/screens/profile/service_provider_profile_creation_screen.dart`
- [ ] `lib/screens/profile/user_profile_view_screen.dart`
- [ ] `lib/screens/profile/ratings_view_screen.dart`
- [ ] `lib/screens/profile/report_block_management_screen.dart`

### Service Screens
- [ ] `lib/screens/services/post_service_screen.dart`
- [ ] `lib/screens/services/manage_services_screen.dart`
- [ ] `lib/screens/services/edit_service_screen.dart`
- [ ] `lib/screens/services/create_service_screen.dart`
- [ ] `lib/screens/services/service_detail_screen.dart`
- [ ] `lib/screens/services/search_services_screen.dart`
- [ ] `lib/screens/services/service_history_screen.dart`
- [ ] `lib/screens/services/book_service_screen.dart`

### Booking Screens
- [ ] `lib/screens/bookings/manage_bookings_screen.dart`
- [ ] `lib/screens/bookings/booking_detail_screen.dart`
- [ ] `lib/screens/bookings/booking_history_screen.dart`

### Message Screens
- [ ] `lib/screens/messages/messages_screen.dart`
- [ ] `lib/screens/messages/enhanced_messages_screen.dart`
- [ ] `lib/screens/messages/whatsapp_chat_screen.dart`
- [ ] `lib/screens/messages/new_message_screen.dart`

### Dashboard & Home
- [ ] `lib/screens/home/home_screen.dart`
- [ ] `lib/screens/dashboard/customer_dashboard.dart`
- [ ] `lib/screens/dashboard/service_provider_dashboard.dart`

### Settings Screens
- [ ] `lib/screens/settings/settings_screen.dart`
- [ ] `lib/screens/settings/change_password_screen.dart`
- [ ] `lib/screens/settings/notification_settings_screen.dart`
- [ ] `lib/screens/settings/privacy_settings_screen.dart`
- [ ] `lib/screens/settings/privacy_policy_screen.dart`
- [ ] `lib/screens/settings/terms_screen.dart`

### Admin Screens
- [x] `lib/screens/admin/send_notification_screen.dart` ✓ COMPLETED
- [ ] `lib/screens/admin/admin_login_screen.dart`
- [ ] `lib/screens/admin/admin_dashboard.dart`

### Other Screens
- [ ] `lib/screens/notifications/notifications_screen.dart`
- [ ] `lib/screens/support/help_support_screen.dart`
- [ ] `lib/screens/splash/animated_loading_screen.dart`
- [ ] `lib/screens/main_navigation.dart`

## Color Usage Guidelines

### Backgrounds
- Use `GradientBackground` for full-screen gradients
- Light blue (#E3F2FD) to white gradient

### Cards & Containers
- Use `GlassCard` or `GlassContainer`
- Semi-transparent white with blur effect
- Subtle blue shadows

### Buttons
- Primary actions: Blue gradient (#1E88E5 to #42A5F5)
- Secondary actions: Outlined with blue border
- Destructive actions: Red gradient

### Text
- Primary text: Black87 (rgba(0,0,0,0.87))
- Secondary text: Grey600
- On blue backgrounds: White

### Icons
- Primary: Blue (#1E88E5)
- On colored backgrounds: White
- Inactive: Grey400

## Best Practices

1. **Consistency**: Use the same glass widgets across all screens
2. **Spacing**: Maintain consistent padding (16px standard, 8px compact)
3. **Shadows**: Let the glass widgets handle shadows automatically
4. **Gradients**: Use the predefined gradients from AppTheme
5. **Accessibility**: Ensure sufficient contrast for text readability
6. **Performance**: Avoid excessive blur effects on low-end devices

## Testing Checklist

- [ ] All screens use GlassScaffold or GradientBackground
- [ ] All cards use GlassCard
- [ ] All buttons use GlassButton
- [ ] All text fields use GlassTextField
- [ ] All forms use GlassFormCard
- [ ] Color scheme is consistent (blue and white)
- [ ] Glass effects are visible and attractive
- [ ] Text is readable on all backgrounds
- [ ] Shadows and blur effects work properly
- [ ] App performs well on different devices

## Example: Complete Screen Implementation

```dart
import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/glass_widgets.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedOption = 'option1';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Example Screen',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Form section
              GlassFormCard(
                title: 'User Information',
                children: [
                  GlassTextField(
                    controller: _nameController,
                    labelText: 'Name',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  GlassRadioOption<String>(
                    title: 'Option 1',
                    value: 'option1',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() => _selectedOption = value!);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Options section
              GlassOptionCard(
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'Configure preferences',
                onTap: () {
                  // Navigate to settings
                },
              ),
              const SizedBox(height: 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  text: 'Submit',
                  icon: Icons.check,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle submission
                    }
                  },
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
```

## Notes

- The glass effect works best with the gradient background
- Avoid nesting too many glass elements (max 2-3 levels)
- Test on both light and dark mode if applicable
- Ensure touch targets are at least 48x48 pixels
- Use semantic labels for accessibility
