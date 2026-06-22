class BookingModel {
  final String id;
  final String serviceName;
  final DateTime bookingDate;
  final String status; // e.g. Confirmed, Pending, Cancelled
  final double amount;
  final String details;

  const BookingModel({
    required this.id,
    required this.serviceName,
    required this.bookingDate,
    required this.status,
    required this.amount,
    required this.details,
  });

  BookingModel copyWith({
    String? id,
    String? serviceName,
    DateTime? bookingDate,
    String? status,
    double? amount,
    String? details,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status,
      'amount': amount,
      'details': details,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      details: json['details'] as String,
    );
  }
}
