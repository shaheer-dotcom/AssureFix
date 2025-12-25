import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/service_provider.dart';
import '../../models/service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/error_handler.dart';
import '../../utils/theme.dart';
import '../../widgets/glass_widgets.dart';
import 'service_detail_screen.dart';

class SearchServicesScreen extends StatefulWidget {
  const SearchServicesScreen({super.key});

  @override
  State<SearchServicesScreen> createState() => _SearchServicesScreenState();
}

class _SearchServicesScreenState extends State<SearchServicesScreen> {
  final _serviceNameController = TextEditingController();
  final _areaController = TextEditingController();
  String? _serviceNameTag;
  String? _areaTag;
  bool _showSearchForm = true;

  @override
  void dispose() {
    _serviceNameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _addServiceNameTag() {
    final tag = _serviceNameController.text.trim().toLowerCase(); // Make case-insensitive
    if (tag.isNotEmpty) {
      setState(() {
        _serviceNameTag = tag;
        _serviceNameController.clear();
      });
    }
  }

  void _removeServiceNameTag() {
    setState(() {
      _serviceNameTag = null;
    });
  }

  void _addAreaTag() {
    final tag = _areaController.text.trim().toLowerCase(); // Make case-insensitive
    if (tag.isNotEmpty) {
      setState(() {
        _areaTag = tag;
        _areaController.clear();
      });
    }
  }

  void _removeAreaTag() {
    setState(() {
      _areaTag = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Search Services',
      actions: [
        if (!_showSearchForm)
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'New Search',
            onPressed: () {
              setState(() {
                _showSearchForm = true;
                _serviceNameTag = null;
                _areaTag = null;
              });
            },
          ),
      ],
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, child) {
          return Column(
            children: [
              // Search Form - only show if _showSearchForm is true
              if (_showSearchForm)
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Service Name Field
                      GlassTextField(
                        controller: _serviceNameController,
                        labelText: 'Service Name Tag',
                        hintText: 'e.g., Plumber, Electrician',
                        prefixIcon: Icons.search,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add_circle, color: AppTheme.primaryBlue),
                          onPressed: _addServiceNameTag,
                        ),
                        onChanged: (_) {},
                      ),
                      if (_serviceNameTag != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _serviceNameTag!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _removeServiceNameTag,
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Area Field
                      GlassTextField(
                        controller: _areaController,
                        labelText: 'Area Location Tag',
                        hintText: 'e.g., Gulshan, DHA, Clifton',
                        prefixIcon: Icons.location_on,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.green.shade600),
                          onPressed: _addAreaTag,
                        ),
                        onChanged: (_) {},
                      ),
                      if (_areaTag != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green.shade600, Colors.green.shade400],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _areaTag!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _removeAreaTag,
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          text: 'Find Services',
                          icon: Icons.search,
                          onPressed: _searchServices,
                          isLoading: serviceProvider.isLoading,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Search Results
              Expanded(
                child: _buildSearchResults(serviceProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(ServiceProvider serviceProvider) {
    if (serviceProvider.isLoading) {
      return const LoadingWidget(message: 'Searching for services...');
    }

    if (serviceProvider.error != null) {
      return ErrorHandler.buildErrorWidget(
        message: serviceProvider.error!,
        onRetry: _searchServices,
      );
    }

    if (serviceProvider.searchResults.isEmpty) {
      return EmptyStateWidget.noSearchResults(
        onRetry: () {
          // Show search form again and clear tags
          setState(() {
            _showSearchForm = true;
            _serviceNameTag = null;
            _areaTag = null;
          });
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: serviceProvider.searchResults.length,
      itemBuilder: (context, index) {
        final service = serviceProvider.searchResults[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(Service service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get provider rating from providerInfo
    final providerRating = service.providerInfo?['serviceProviderRating'];
    final averageRating = providerRating?['average']?.toDouble() ?? 0.0;
    final ratingCount = providerRating?['count'] ?? 0;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: service),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${service.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          ' ($ratingCount)',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Provider name
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  service.providerName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ...service.areaTags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
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
                              tag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (service.areaTags.length > 3)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${service.areaTags.length - 3}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _searchServices() {
    // Add any text in the input fields as tags before searching
    if (_serviceNameController.text.trim().isNotEmpty) {
      _addServiceNameTag();
    }
    if (_areaController.text.trim().isNotEmpty) {
      _addAreaTag();
    }

    if (_serviceNameTag == null && _areaTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one service name or area tag'),
        ),
      );
      return;
    }

    // Hide search form after clicking Find Services
    setState(() {
      _showSearchForm = false;
    });

    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    serviceProvider.searchServices(_serviceNameTag ?? '', _areaTag ?? '');
  }
}