# How to Apply Glass Theme to All Screens

## Quick Start

The glass theme has been implemented with reusable components. Follow these steps to update any screen:

### Step 1: Add Imports

At the top of your screen file, add:

```dart
import '../../utils/theme.dart';
import '../../widgets/glass_widgets.dart';
```

### Step 2: Replace Components

Use this find-and-replace guide:

#### Scaffold → GlassScaffold

**Before:**
```dart
return Scaffold(
  appBar: AppBar(
    title: Text('Title'),
  ),
  body: YourContent(),
);
```

**After:**
```dart
return GlassScaffold(
  title: 'Title',
  body: YourContent(),
);
```

#### Card → GlassCard

**Before:**
```dart
Card(
  elevation: 2,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Content(),
  ),
)
```

**After:**
```dart
GlassCard(
  child: Content(),
)
```

#### TextFormField → GlassTextField

**Before:**
```dart
TextFormField(
  controller: _controller,
  decoration: InputDecoration(
    labelText: 'Label',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
  ),
  validator: (value) => ...,
)
```

**After:**
```dart
GlassTextField(
  controller: _controller,
  labelText: 'Label',
  prefixIcon: Icons.person,
  validator: (value) => ...,
)
```

#### ElevatedButton → GlassButton

**Before:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Submit'),
)
```

**After:**
```dart
GlassButton(
  text: 'Submit',
  icon: Icons.check, // optional
  onPressed: () {},
  isLoading: false, // optional
)
```

#### DropdownButtonFormField → GlassDropdown

**Before:**
```dart
DropdownButtonFormField<String>(
  value: _selectedValue,
  decoration: InputDecoration(
    labelText: 'Select',
    prefixIcon: Icon(Icons.category),
  ),
  items: [...],
  onChanged: (value) {},
)
```

**After:**
```dart
GlassDropdown<String>(
  labelText: 'Select',
  value: _selectedValue,
  prefixIcon: Icons.category,
  items: [...],
  onChanged: (value) {},
)
```

#### RadioListTile → GlassRadioOption

**Before:**
```dart
RadioListTile<String>(
  title: Text('Option'),
  subtitle: Text('Description'),
  value: 'option',
  groupValue: _selected,
  onChanged: (value) {},
)
```

**After:**
```dart
GlassRadioOption<String>(
  title: 'Option',
  subtitle: 'Description',
  value: 'option',
  groupValue: _selected,
  onChanged: (value) {},
)
```

## Screen-Specific Patterns

### Login/Signup Screens

```dart
return GradientBackground(
  child: Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo and title
              SizedBox(height: 40),
              Icon(...), // Your logo
              Text('App Name'),
              SizedBox(height: 48),
              
              // Form fields
              GlassTextField(
                controller: _emailController,
                labelText: 'Email',
                prefixIcon: Icons.email,
              ),
              SizedBox(height: 16),
              GlassTextField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 24),
              
              // Submit button
              GlassButton(
                text: 'Login',
                icon: Icons.login,
                onPressed: _login,
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
```

### Dashboard Screens

```dart
return GlassScaffold(
  title: 'Dashboard',
  body: GridView.count(
    crossAxisCount: 2,
    padding: EdgeInsets.all(16),
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    children: [
      GlassOptionCard(
        icon: Icons.add_business,
        title: 'Post Service',
        subtitle: 'Add new service',
        onTap: () => Navigator.push(...),
      ),
      GlassOptionCard(
        icon: Icons.list_alt,
        title: 'My Services',
        subtitle: 'Manage services',
        onTap: () => Navigator.push(...),
      ),
      // More options...
    ],
  ),
);
```

### Form Screens

```dart
return GlassScaffold(
  title: 'Create Service',
  body: SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      child: Column(
        children: [
          GlassFormCard(
            title: 'Service Details',
            children: [
              GlassTextField(
                controller: _nameController,
                labelText: 'Service Name',
                prefixIcon: Icons.business,
                validator: (value) => ...,
              ),
              SizedBox(height: 16),
              GlassTextField(
                controller: _descriptionController,
                labelText: 'Description',
                prefixIcon: Icons.description,
                maxLines: 4,
              ),
            ],
          ),
          SizedBox(height: 16),
          
          GlassFormCard(
            title: 'Pricing',
            children: [
              GlassDropdown<String>(
                labelText: 'Price Type',
                value: _priceType,
                prefixIcon: Icons.attach_money,
                items: [
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                  DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                ],
                onChanged: (value) => setState(() => _priceType = value!),
              ),
              SizedBox(height: 16),
              GlassTextField(
                controller: _priceController,
                labelText: 'Price',
                prefixIcon: Icons.money,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              text: 'Create Service',
              icon: Icons.check,
              onPressed: _createService,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    ),
  ),
);
```

### List Screens

```dart
return GlassScaffold(
  title: 'My Services',
  body: ListView.builder(
    padding: EdgeInsets.all(16),
    itemCount: services.length,
    itemBuilder: (context, index) {
      final service = services[index];
      return GlassCard(
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryBlue,
            child: Icon(Icons.business, color: Colors.white),
          ),
          title: Text(
            service.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(service.category),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.primaryBlue,
            size: 16,
          ),
          onTap: () => Navigator.push(...),
        ),
      );
    },
  ),
);
```

### Settings Screens

```dart
return GlassScaffold(
  title: 'Settings',
  body: ListView(
    padding: EdgeInsets.all(16),
    children: [
      GlassOptionCard(
        icon: Icons.person,
        title: 'Edit Profile',
        subtitle: 'Update your information',
        onTap: () => Navigator.push(...),
      ),
      SizedBox(height: 12),
      GlassOptionCard(
        icon: Icons.lock,
        title: 'Change Password',
        subtitle: 'Update your password',
        onTap: () => Navigator.push(...),
      ),
      SizedBox(height: 12),
      GlassOptionCard(
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'Manage notifications',
        onTap: () => Navigator.push(...),
      ),
      SizedBox(height: 12),
      GlassOptionCard(
        icon: Icons.privacy_tip,
        title: 'Privacy',
        subtitle: 'Privacy settings',
        onTap: () => Navigator.push(...),
      ),
    ],
  ),
);
```

### Tab Bar Screens

For screens with tabs (like manage bookings), you need a custom approach:

```dart
return GradientBackground(
  child: Scaffold(
    backgroundColor: Colors.transparent,
    appBar: GlassAppBar(
      title: 'Manage Bookings',
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: [
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
          Tab(text: 'Cancelled'),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        _buildBookingsList('active'),
        _buildBookingsList('completed'),
        _buildBookingsList('cancelled'),
      ],
    ),
  ),
);
```

## Color Usage

Always use theme constants instead of hardcoded colors:

```dart
// ✅ Good
color: AppTheme.primaryBlue
color: AppTheme.accentBlue
color: AppTheme.lightBlue

// ❌ Bad
color: Color(0xFF1565C0)
color: Colors.blue
```

## Common Mistakes to Avoid

1. **Don't nest too many glass elements** - Max 2-3 levels
2. **Don't forget imports** - Both theme.dart and glass_widgets.dart
3. **Don't hardcode colors** - Use AppTheme constants
4. **Don't remove validators** - Transfer all validation logic
5. **Don't forget loading states** - Use isLoading parameter in GlassButton

## Testing Checklist

After updating a screen:

- [ ] No compilation errors
- [ ] All text is readable
- [ ] Glass effects are visible
- [ ] Buttons work correctly
- [ ] Forms validate properly
- [ ] Navigation works
- [ ] Loading states display correctly
- [ ] Colors match the blue/white theme

## Priority Order

Update screens in this order:

1. **Auth screens** (login, signup) - Most visible to new users
2. **Dashboard screens** - Main navigation hubs
3. **Service screens** - Core functionality
4. **Booking screens** - Core functionality
5. **Profile screens** - User management
6. **Settings screens** - Configuration
7. **Admin screens** - Internal tools

## Example: Complete Before/After

### Before
```dart
import 'package:flutter/material.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### After
```dart
import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/glass_widgets.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'My Screen',
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GlassFormCard(
              title: 'Information',
              children: [
                GlassTextField(
                  labelText: 'Name',
                  prefixIcon: Icons.person,
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                text: 'Submit',
                icon: Icons.check,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Need Help?

- Check `GLASS_THEME_IMPLEMENTATION_GUIDE.md` for detailed component documentation
- Check `GLASS_THEME_UPDATE_SUMMARY.md` for progress tracking
- Look at completed screens for examples:
  - `lib/screens/admin/send_notification_screen.dart`
  - `lib/screens/auth/login_screen.dart`

## Automated Update Script (Optional)

For bulk updates, you can use find-and-replace in your IDE:

1. Find: `Scaffold\(\s*appBar: AppBar\(\s*title: (?:const )?Text\('([^']+)'\),?\s*\),`
   Replace: `GlassScaffold(\n  title: '$1',`

2. Find: `Card\(\s*(?:elevation: \d+,)?\s*child:`
   Replace: `GlassCard(\n  child:`

3. Find: `TextFormField\(`
   Replace: `GlassTextField(`

4. Find: `ElevatedButton\(\s*onPressed: ([^,]+),\s*child: (?:const )?Text\('([^']+)'\),?\s*\)`
   Replace: `GlassButton(\n  text: '$2',\n  onPressed: $1,\n)`

**Note:** Always review automated changes carefully!
