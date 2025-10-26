class UserRating {
  final double average;
  final int count;
  final int totalStars;

  UserRating({
    required this.average,
    required this.count,
    required this.totalStars,
  });

  factory UserRating.fromJson(Map<String, dynamic> json) {
    return UserRating(
      average: (json['average'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
      totalStars: json['totalStars'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'count': count,
      'totalStars': totalStars,
    };
  }
}

class User {
  final String id;
  final String email;
  final UserProfile? profile;
  final UserRating customerRating;
  final UserRating serviceProviderRating;

  User({
    required this.id,
    required this.email,
    this.profile,
    required this.customerRating,
    required this.serviceProviderRating,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      profile: json['profile'] != null 
          ? UserProfile.fromJson(json['profile']) 
          : null,
      customerRating: json['customerRating'] != null
          ? UserRating.fromJson(json['customerRating'])
          : UserRating(average: 0, count: 0, totalStars: 0),
      serviceProviderRating: json['serviceProviderRating'] != null
          ? UserRating.fromJson(json['serviceProviderRating'])
          : UserRating(average: 0, count: 0, totalStars: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'profile': profile?.toJson(),
      'customerRating': customerRating.toJson(),
      'serviceProviderRating': serviceProviderRating.toJson(),
    };
  }
}

class UserProfile {
  final String name;
  final String phoneNumber;
  final String userType; // 'customer' or 'service_provider'
  final String? cnicDocument;
  final String? shopDocument;

  UserProfile({
    required this.name,
    required this.phoneNumber,
    required this.userType,
    this.cnicDocument,
    this.shopDocument,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userType: json['userType'] ?? 'customer',
      cnicDocument: json['cnicDocument'],
      shopDocument: json['shopDocument'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'cnicDocument': cnicDocument,
      'shopDocument': shopDocument,
    };
  }
}