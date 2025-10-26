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
    return Booking(
      id: json['_id'] ?? '',
      customerId: json['customerId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      providerId: json['providerId'] ?? '',
      customerDetails: CustomerDetails.fromJson(json['customerDetails'] ?? {}),
      reservationDate: DateTime.parse(json['reservationDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      hoursBooked: json['hoursBooked'] ?? 1,
      cancellationReason: json['cancellationReason'],
      cancelledBy: json['cancelledBy'],
      canCancel: json['canCancel'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
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
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      exactAddress: json['exactAddress'] ?? '',
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