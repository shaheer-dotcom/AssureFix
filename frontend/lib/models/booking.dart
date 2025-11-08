class Booking {
  final String id;
  final String customerId;
  final String serviceId;
  final String providerId;
  final CustomerDetails customerDetails;
  final DateTime reservationDate;
  final String status;
  final double totalAmount;
  final int hoursBooked;
  final String? cancellationReason;
  final String? cancelledBy;
  final bool canCancel;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.providerId,
    required this.customerDetails,
    required this.reservationDate,
    required this.status,
    required this.totalAmount,
    required this.hoursBooked,
    this.cancellationReason,
    this.cancelledBy,
    required this.canCancel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Helper function to extract ID from string or object
    String extractId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) return value['_id']?.toString() ?? '';
      return value.toString();
    }

    return Booking(
      id: json['_id']?.toString() ?? '',
      customerId: extractId(json['customerId']),
      serviceId: extractId(json['serviceId']),
      providerId: extractId(json['providerId']),
      customerDetails: CustomerDetails.fromJson(
        json['customerDetails'] is Map 
            ? Map<String, dynamic>.from(json['customerDetails'] as Map)
            : {}
      ),
      reservationDate: DateTime.parse(
        json['reservationDate'] ?? DateTime.now().toIso8601String()
      ),
      status: json['status']?.toString() ?? 'pending',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      hoursBooked: (json['hoursBooked'] ?? 1) is int 
          ? json['hoursBooked'] 
          : int.tryParse(json['hoursBooked'].toString()) ?? 1,
      cancellationReason: json['cancellationReason']?.toString(),
      cancelledBy: json['cancelledBy']?.toString(),
      canCancel: json['canCancel'] == true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String()
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String()
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerId': customerId,
      'serviceId': serviceId,
      'providerId': providerId,
      'customerDetails': customerDetails.toJson(),
      'reservationDate': reservationDate.toIso8601String(),
      'status': status,
      'totalAmount': totalAmount,
      'hoursBooked': hoursBooked,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'canCancel': canCancel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CustomerDetails {
  final String name;
  final String phoneNumber;
  final String exactAddress;

  CustomerDetails({
    required this.name,
    required this.phoneNumber,
    required this.exactAddress,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      exactAddress: json['exactAddress']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'exactAddress': exactAddress,
    };
  }
}