class RideModel {
  final String id;
  final String driverName;
  final String driverPhone;
  final String pickupLocation;
  final String destination;
  final double fare;
  final int etaMinutes;
  final String status; // e.g. Requested, Arriving, Completed

  const RideModel({
    required this.id,
    required this.driverName,
    required this.driverPhone,
    required this.pickupLocation,
    required this.destination,
    required this.fare,
    required this.etaMinutes,
    required this.status,
  });

  RideModel copyWith({
    String? id,
    String? driverName,
    String? driverPhone,
    String? pickupLocation,
    String? destination,
    double? fare,
    int? etaMinutes,
    String? status,
  }) {
    return RideModel(
      id: id ?? this.id,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destination: destination ?? this.destination,
      fare: fare ?? this.fare,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'pickupLocation': pickupLocation,
      'destination': destination,
      'fare': fare,
      'etaMinutes': etaMinutes,
      'status': status,
    };
  }

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String,
      driverName: json['driverName'] as String,
      driverPhone: json['driverPhone'] as String,
      pickupLocation: json['pickupLocation'] as String,
      destination: json['destination'] as String,
      fare: (json['fare'] as num).toDouble(),
      etaMinutes: json['etaMinutes'] as int,
      status: json['status'] as String,
    );
  }
}
