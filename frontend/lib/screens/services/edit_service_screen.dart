import 'package:flutter/material.dart';
import '../../models/service.dart';

class EditServiceScreen extends StatefulWidget {
  final Service service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _areaController;
  late final TextEditingController _priceController;
  
  late String _selectedCategory;
  late String _selectedPriceType;

  final List<String> _categories = [
    'Home Services',
    'Beauty & Wellness',
    'Automotive',
    'Electronics',
    'Education',
    'Health & Fitness',
    'Business Services',
    'Event Services',
    'Cleaning Services',
    'Repair & Maintenance',
    'Delivery Services',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(text: widget.service.description);
    _areaController = TextEditingController(text: widget.service.area);
    _priceController = TextEditingController(text: widget.service.price.toString());
    _selectedCategory = widget.service.category;
    _selectedPriceType = widget.service.priceType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Service Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Service Name',
                hintText: 'e.g., Home Cleaning, Plumbing',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter service name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your service in detail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter service description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Area
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'Service Area',
                hintText: 'e.g., Gulshan, DHA, Clifton',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter service area';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price Type
            DropdownButtonFormField<String>(
              initialValue: _selectedPriceType,
              decoration: const InputDecoration(
                labelText: 'Price Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: const [
                DropdownMenuItem(value: 'fixed', child: Text('Fixed Price')),
                DropdownMenuItem(value: 'hourly', child: Text('Per Hour')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriceType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _selectedPriceType == 'fixed' ? 'Price (₹)' : 'Price per Hour (₹)',
                hintText: 'Enter amount',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                final price = double.tryParse(value);
                if (price == null || price < 100) {
                  return 'Minimum price is ₹100';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Update Button
            ElevatedButton(
              onPressed: _updateService,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Update Service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateService() async {
    if (_formKey.currentState!.validate()) {
      final serviceData = {
        'name': _nameController.text.trim(),
        'serviceName': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'area': _areaController.text.trim(),
        'areaCovered': _areaController.text.trim(),
        'price': double.parse(_priceController.text),
        'pricePerHour': double.parse(_priceController.text),
        'priceType': _selectedPriceType,
      };

      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Update service (you can implement API call here)
        // For now, we'll simulate the API call
        print('Updated Service Data: $serviceData');
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        
        // Hide loading
        if (mounted) Navigator.pop(context);
        
        // Show success message and go back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Hide loading
        if (mounted) Navigator.pop(context);
        
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating service: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}