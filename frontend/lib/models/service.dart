class Service {
  final String id;
  final String providerId;
  final String name;
  final String serviceName;
  final String description;
  final String category;
  final List<String> areaTags;
  final double price;
  final double pricePerHour;
  final String priceType; // 'fixed' or 'hourly'
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? providerInfo; // Provider details

  Service({
    required this.id,
    required this.providerId,
    required this.name,
    required this.serviceName,
    required this.description,
    required this.category,
    required this.areaTags,
    required this.price,
    required this.pricePerHour,
    required this.priceType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.providerInfo,
  });

  // Backward compatibility getter for area
  String get area => areaTags.isNotEmpty ? areaTags.join(', ') : '';
  
  // Backward compatibility getter for areaCovered
  String get areaCovered => area;

  String get providerName {
    if (providerInfo != null && providerInfo!['profile'] != null) {
      return providerInfo!['profile']['name'] ?? 'Service Provider';
    }
    return 'Service Provider';
  }

  String get providerPhone {
    if (providerInfo != null && providerInfo!['profile'] != null) {
      return providerInfo!['profile']['phoneNumber'] ?? '';
    }
    return '';
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    try {
      // Handle providerId which might be a string or an object
      String providerId = '';
      Map<String, dynamic>? providerInfo;
      
      if (json['providerId'] != null) {
        if (json['providerId'] is String) {
          providerId = json['providerId'];
        } else if (json['providerId'] is Map) {
          providerInfo = Map<String, dynamic>.from(json['providerId'] as Map);
          providerId = providerInfo['_id']?.toString() ?? '';
        } else {
          providerId = json['providerId'].toString();
        }
      }

      // Parse areaTags - handle both array and legacy string formats
      List<String> areaTags = [];
      if (json['areaTags'] != null && json['areaTags'] is List) {
        areaTags = (json['areaTags'] as List).map((e) => e.toString()).toList();
      } else if (json['area'] != null) {
        // Backward compatibility: parse old area field
        final areaStr = json['area'].toString();
        areaTags = areaStr.split(RegExp(r'[\n,.]')).map((a) => a.trim()).where((a) => a.isNotEmpty).toList();
      }

      return Service(
        id: json['_id']?.toString() ?? '',
        providerId: providerId,
        name: json['name']?.toString() ?? '',
        serviceName: json['serviceName']?.toString() ?? json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        areaTags: areaTags,
        price: _parseDouble(json['price']),
        pricePerHour: _parseDouble(json['pricePerHour'] ?? json['price']),
        priceType: json['priceType']?.toString() ?? 'fixed',
        isActive: json['isActive'] == true,
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
        providerInfo: providerInfo,
      );
    } catch (e) {
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'providerId': providerId,
      'name': name,
      'serviceName': serviceName,
      'description': description,
      'category': category,
      'areaTags': areaTags,
      'price': price,
      'pricePerHour': pricePerHour,
      'priceType': priceType,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayPrice {
    if (priceType == 'hourly') {
      return '₹${pricePerHour.toStringAsFixed(0)}/hour';
    } else {
      return '₹${price.toStringAsFixed(0)}';
    }
  }
}