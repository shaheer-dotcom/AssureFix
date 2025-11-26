import 'package:flutter/material.dart';
import '../../models/service.dart';
import '../../services/api_service.dart';

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
  final _areaController = TextEditingController();
  late final TextEditingController _priceController;
  
  late String _selectedCategory;
  late String _selectedPriceType;
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
    _priceController = TextEditingController(text: widget.service.price.toString());
    _selectedCategory = widget.service.category;
    _selectedPriceType = widget.service.priceType;
    
    // Parse existing area tags from service
    if (widget.service.area.isNotEmpty) {
      _areas.addAll(
        widget.service.area.split(RegExp(r'[\n,.]')).map((a) => a.trim()).where((a) => a.isNotEmpty)
      );
    }
    
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

            // Service Area with Tag Bubbles
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Add current input to areas if not empty
    if (_currentInput.trim().isNotEmpty) {
      _addCurrentInput();
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

    // TODO: Implement API call to update service
    // final serviceData = {
    //   'name': _nameController.text.trim(),
    //   'serviceName': _nameController.text.trim(),
    //   'description': _descriptionController.text.trim(),
    //   'category': _selectedCategory,
    //   'areaTags': _areas, // Send as array
    //   'price': double.parse(_priceController.text),
    //   'pricePerHour': double.parse(_priceController.text),
    //   'priceType': _selectedPriceType,
    // };

    final serviceData = {
      'name': _nameController.text.trim(),
      'serviceName': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'areaTags': _areas,
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

      // Update service via API
      await ApiService.updateService(widget.service.id, serviceData);
      
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
        Navigator.pop(context, true); // Return true to indicate success
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