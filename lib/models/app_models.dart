// Model classes for the application

// User model
class UserModel {
  final String uid;
  final String email;
  final String username;
  final String userType; // 'customer' or 'admin'
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool profileComplete;
  final String phoneNumber;
  final String address;
  final String city;
  final String profileImageUrl;
  final String fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
    required this.profileComplete,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.profileImageUrl,
    required this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      userType: json['userType'] ?? 'customer',
      createdAt: json['createdAt'] != null
          ? (json['createdAt']).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt']).toDate()
          : DateTime.now(),
      profileComplete: json['profileComplete'] ?? false,
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      fcmToken: json['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'userType': userType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'profileComplete': profileComplete,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'profileImageUrl': profileImageUrl,
      'fcmToken': fcmToken,
    };
  }
}

// Service model
class ServiceModel {
  final String id;
  final String serviceType;
  final String description;
  final double baseCost;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.serviceType,
    required this.description,
    required this.baseCost,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json, String docId) {
    return ServiceModel(
      id: docId,
      serviceType: json['serviceType'] ?? '',
      description: json['description'] ?? '',
      baseCost: (json['baseCost'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt']).toDate()
          : DateTime.now(),
    );
  }
}

// Booking model
class BookingModel {
  final String id;
  final String userId;
  final String serviceType;
  final String serviceDescription;
  final DateTime bookingDate;
  final String address;
  final String city;
  final String phoneNumber;
  final double estimatedCost;
  final String status; // pending, assigned, completed, cancelled
  final String? assignedEmployeeId;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.serviceDescription,
    required this.bookingDate,
    required this.address,
    required this.city,
    required this.phoneNumber,
    required this.estimatedCost,
    required this.status,
    this.assignedEmployeeId,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json, String docId) {
    return BookingModel(
      id: docId,
      userId: json['userId'] ?? '',
      serviceType: json['serviceType'] ?? '',
      serviceDescription: json['serviceDescription'] ?? '',
      bookingDate: json['bookingDate'] != null
          ? (json['bookingDate']).toDate()
          : DateTime.now(),
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      assignedEmployeeId: json['assignedEmployeeId'],
      cancellationReason: json['cancellationReason'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt']).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt']).toDate()
          : DateTime.now(),
    );
  }
}

// Employee model
class EmployeeModel {
  final String id;
  final String name;
  final String serviceType;
  final String phone;
  final String email;
  final bool isActive;
  final bool isAvailable;
  final String? currentBookingId;
  final DateTime createdAt;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.phone,
    required this.email,
    required this.isActive,
    required this.isAvailable,
    this.currentBookingId,
    required this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json, String docId) {
    return EmployeeModel(
      id: docId,
      name: json['name'] ?? '',
      serviceType: json['serviceType'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      isActive: json['isActive'] ?? true,
      isAvailable: json['isAvailable'] ?? true,
      currentBookingId: json['currentBookingId'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt']).toDate()
          : DateTime.now(),
    );
  }
}

// Notification model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String notificationType;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.notificationType,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(
      Map<String, dynamic> json, String docId) {
    return NotificationModel(
      id: docId,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      notificationType: json['notificationType'] ?? '',
      data: json['data'] ?? {},
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt']).toDate()
          : DateTime.now(),
    );
  }
}
