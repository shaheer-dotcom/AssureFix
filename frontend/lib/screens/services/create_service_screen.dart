import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/service_provider.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'Home Services';
  final List<String> _areas = [];
  String _currentInput = '';
  final FocusNode _areaFocusNode = FocusNode();
  final List<String> _categories = [
    'Home Services',
    'Beauty & Wellness',
    'Automotive',
    'Electronics',
    'Education',
    'Health & Fitness',
    'Business Services',
    'Event Services',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _areaController.addListener(_updateAreas);
  }

  @override
  void dispose() {
    _areaController.removeListener(_updateAreas);
    _areaFocusNode.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateAreas() {
    setState(() {
      _currentInput = _areaController.text;
    });
  }

  void _onTextChanged(String value) {
    setState(() {
      _currentInput = value;
    });
  }

  void _onSubmitted(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty && trimmedValue.length >= 2) {
      // Sanitize the input to remove any problematic characters
      final sanitizedValue = trimmedValue.replaceAll(RegExp(r'[^\w\s\-\.]'), '');
      if (sanitizedValue.isNotEmpty) {
        setState(() {
          _areas.add(sanitizedValue);
          _currentInput = '';
          _areaController.clear();
        });
      }
    }
  }

  void _addCurrentInput() {
    final trimmedValue = _currentInput.trim();
    if (trimmedValue.isNotEmpty && trimmedValue.length >= 2) {
      // Sanitize the input to remove any problematic characters
      final sanitizedValue = trimmedValue.replaceAll(RegExp(r'[^\w\s\-\.]'), '');
      if (sanitizedValue.isNotEmpty) {
        setState(() {
          _areas.add(sanitizedValue);
          _currentInput = '';
          _areaController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Service'),
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Service Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                      hintText: 'e.g., House Cleaning, Plumbing, etc.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a service name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
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

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe your service in detail...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Service Area
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAreaInputField(),
                      const SizedBox(height: 8),
                      

                      
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Example: Type "Gulshan" then press Enter, type "DHA" then press Enter\nCustomers can find you by searching any of these areas',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      hintText: 'Enter price in Rupees',
                      border: OutlineInputBorder(),
                      prefixText: '₹ ',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (serviceProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        serviceProvider.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),

                  // Submit Button
                  ElevatedButton(
                    onPressed: serviceProvider.isLoading ? null : _submitService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: serviceProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Create Service',
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
        },
      ),
    );
  }

  void _submitService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Add current input to areas if not empty
    if (_currentInput.trim().isNotEmpty) {
      _addCurrentInput();
    }

    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a service name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a service description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ensure we have at least one area
    if (_areas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one service area'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final allAreas = _areas.join('\n');
    
    // Validate price
    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final serviceData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'area': allAreas,
      'price': price,
    };

    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final success = await serviceProvider.createService(serviceData);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildAreaTag(String area) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 12,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 3),
          Text(
            area,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 3),
          GestureDetector(
            onTap: () => _removeArea(area),
            child: Icon(
              Icons.close,
              size: 12,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _removeArea(String area) {
    setState(() {
      _areas.remove(area);
    });
  }

  Widget _buildAreaInputField() {
    return FormField<List<String>>(
      validator: (value) {
        if (_areas.isEmpty && _currentInput.trim().isEmpty) {
          return 'Please enter at least one service area';
        }
        final allAreas = [..._areas];
        if (_currentInput.trim().isNotEmpty) {
          allAreas.add(_currentInput.trim());
        }
        if (allAreas.any((area) => area.length < 2)) {
          return 'Each area must be at least 2 characters long';
        }
        return null;
      },
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: state.hasError ? Colors.red : Colors.grey.shade400,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Container(
                    padding: const EdgeInsets.only(left: 12, top: 8, right: 12),
                    child: Text(
                      'Service Areas',
                      style: TextStyle(
                        fontSize: 12,
                        color: state.hasError ? Colors.red : Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  
                  // Content area with inline tags and input
                  GestureDetector(
                    onTap: () => _areaFocusNode.requestFocus(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Display existing tags
                                ..._areas.map((area) => _buildAreaTag(area)),
                                
                                // Inline text input
                                IntrinsicWidth(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 100),
                                    child: TextField(
                                      controller: _areaController,
                                      focusNode: _areaFocusNode,
                                      onChanged: _onTextChanged,
                                      onSubmitted: _onSubmitted,
                                      decoration: InputDecoration(
                                        hintText: _areas.isEmpty && _currentInput.isEmpty
                                            ? 'Type area name and press Enter'
                                            : '',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withValues(alpha: 0.4),
                                          fontSize: 16,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Helper text
                  Container(
                    padding: const EdgeInsets.only(left: 44, right: 12, bottom: 8),
                    child: Text(
                      'Press Enter to convert text to tag',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}