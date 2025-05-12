class Booking {
  final String id;
  final String userId;
  final String serviceId;
  final DateTime bookingDate;
  final DateTime createdAt;
  final String status;

  Booking({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.bookingDate,
    required this.createdAt,
    required this.status,
  });

  // Factory method to create a Booking object from a JSON map
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      serviceId: json['serviceId'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
    );
  }

  // Method to convert a Booking object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'bookingDate': bookingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}