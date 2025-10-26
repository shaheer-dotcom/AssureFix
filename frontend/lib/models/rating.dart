class Rating {
  final String id;
  final String ratedBy;
  final String ratedUser;
  final String ratingType; // 'customer' or 'service_provider'
  final int stars;
  final String comment;
  final String? relatedBooking;
  final String? relatedService;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.ratedBy,
    required this.ratedUser,
    required this.ratingType,
    required this.stars,
    required this.comment,
    this.relatedBooking,
    this.relatedService,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id'] ?? '',
      ratedBy: json['ratedBy'] ?? '',
      ratedUser: json['ratedUser'] ?? '',
      ratingType: json['ratingType'] ?? 'customer',
      stars: json['stars'] ?? 0,
      comment: json['comment'] ?? '',
      relatedBooking: json['relatedBooking'],
      relatedService: json['relatedService'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ratedBy': ratedBy,
      'ratedUser': ratedUser,
      'ratingType': ratingType,
      'stars': stars,
      'comment': comment,
      'relatedBooking': relatedBooking,
      'relatedService': relatedService,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}