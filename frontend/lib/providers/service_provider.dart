import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class ServiceProvider with ChangeNotifier {
  List<Service> _services = [];
  List<Service> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<Service> get services => _services;
  List<Service> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> createService(Map<String, dynamic> serviceData) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.createService(serviceData);
      final service = Service.fromJson(response);
      _services.add(service);
      setLoading(false);
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      // Clean up the error message
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      setError(errorMessage);
      setLoading(false);
      return false;
    }
  }

  Future<void> loadUserServices() async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.getUserServices();
      _services = response.map((json) => Service.fromJson(json)).toList();
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  Future<void> searchServices(String serviceName, String area) async {
    setLoading(true);
    setError(null);
    
    try {
      final response = await ApiService.searchServices(query: serviceName, location: area);
      _searchResults = response.map((json) => Service.fromJson(json)).toList();
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  Future<bool> toggleServiceStatus(String serviceId) async {
    setLoading(true);
    setError(null);
    
    try {
      await ApiService.toggleServiceStatus(serviceId);
      // Reload services to get updated data
      await loadUserServices();
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    setLoading(true);
    setError(null);
    
    try {
      await ApiService.deleteService(serviceId);
      // Remove from local list
      _services.removeWhere((service) => service.id == serviceId);
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  int get activeServicesCount => _services.where((service) => service.isActive).length;
  int get totalServicesCount => _services.length;
}