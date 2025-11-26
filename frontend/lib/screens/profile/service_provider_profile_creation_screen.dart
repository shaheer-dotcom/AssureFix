import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../main_navigation.dart';

class ServiceProviderProfileCreationScreen extends StatefulWidget {
  const ServiceProviderProfileCreationScreen({super.key});

  @override
  State<ServiceProviderProfileCreationScreen> createState() =>
      _ServiceProviderProfileCreationScreenState();
}

class _ServiceProviderProfileCreationScreenState
    extends State<ServiceProviderProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  XFile? _profilePicture;
  XFile? _bannerImage;
  XFile? _cnicDocument;
  XFile? _shopDocument;

  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Auto-fill email from authenticated user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _emailController.text = authProvider.user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider Profile'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome message
                  const Text(
                    'Complete Your Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set up your service provider profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Picture Upload
                  _buildCircularImageUploadSection(
                    title: 'Profile Picture *',
                    subtitle: 'Upload your profile photo',
                    icon: Icons.person,
                    image: _profilePicture,
                    onTap: () => _pickImage('profile'),
                  ),
                  const SizedBox(height: 20),

                  // Banner Image Upload
                  _buildBannerUploadSection(
                    title: 'Banner Image *',
                    subtitle: 'Upload a banner for your profile',
                    icon: Icons.image,
                    image: _bannerImage,
                    onTap: () => _pickImage('banner'),
                  ),
                  const SizedBox(height: 24),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone number field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.trim().length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field (read-only)
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CNIC Document Upload (Optional)
                  _buildDocumentUploadSection(
                    title: 'CNIC Picture (Optional)',
                    subtitle: 'Upload your CNIC document',
                    icon: Icons.credit_card,
                    document: _cnicDocument,
                    onTap: () => _pickImage('cnic'),
                    isOptional: true,
                  ),
                  const SizedBox(height: 16),

                  // Shop Document Upload (Optional)
                  _buildDocumentUploadSection(
                    title: 'Shop Documents (Optional)',
                    subtitle: 'Business license or registration',
                    icon: Icons.store,
                    document: _shopDocument,
                    onTap: () => _pickImage('shop'),
                    isOptional: true,
                  ),
                  const SizedBox(height: 32),

                  // Error message
                  if (authProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Create Profile button
                  ElevatedButton(
                    onPressed: (authProvider.isLoading || _isUploading)
                        ? null
                        : _createProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: (authProvider.isLoading || _isUploading)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Create Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Logout option
                  TextButton(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false)
                          .logout();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircularImageUploadSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required XFile? image,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
              border: Border.all(
                color: image != null ? Colors.green : Colors.grey.shade300,
                width: 3,
              ),
            ),
            child: image != null
                ? ClipOval(
                    child: kIsWeb
                        ? FutureBuilder<Uint8List>(
                            future: image.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          )
                        : Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerUploadSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required XFile? image,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: image != null ? Colors.green : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? FutureBuilder<Uint8List>(
                            future: image.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          )
                        : Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to upload',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required XFile? document,
    required VoidCallback onTap,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: document != null ? Colors.green : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: document != null ? Colors.green : Colors.grey,
            ),
            title: Text(
              document != null ? 'Document uploaded' : subtitle,
              style: TextStyle(
                color: document != null ? Colors.green : Colors.grey.shade700,
              ),
            ),
            subtitle: Text(
              isOptional ? 'Optional' : 'Required',
              style: TextStyle(
                fontSize: 12,
                color: isOptional ? Colors.grey : Colors.red.shade300,
              ),
            ),
            trailing: document != null
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cloud_upload_outlined),
            onTap: onTap,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(String type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Store XFile directly (works on all platforms)
        setState(() {
          switch (type) {
            case 'profile':
              _profilePicture = pickedFile;
              break;
            case 'banner':
              _bannerImage = pickedFile;
              break;
            case 'cnic':
              _cnicDocument = pickedFile;
              break;
            case 'shop':
              _shopDocument = pickedFile;
              break;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required images
    if (_profilePicture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a profile picture'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_bannerImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a banner image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload all files
      final String profilePicturePath =
          await ApiService.uploadFile(_profilePicture!, 'profilePicture');
      final String bannerImagePath =
          await ApiService.uploadFile(_bannerImage!, 'bannerImage');
      
      // Upload CNIC if provided (optional)
      String? cnicPath;
      if (_cnicDocument != null) {
        cnicPath = await ApiService.uploadFile(_cnicDocument!, 'cnicDocument');
      }

      String? shopPath;
      if (_shopDocument != null) {
        shopPath = await ApiService.uploadFile(_shopDocument!, 'shopDocument');
      }

      // Create profile data
      final profileData = {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'userType': 'service_provider',
        'profilePicture': profilePicturePath,
        'bannerImage': bannerImagePath,
        if (cnicPath != null) 'cnicDocument': cnicPath,
        if (shopPath != null) 'shopDocument': shopPath,
      };

      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.createProfile(profileData);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to service provider home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
