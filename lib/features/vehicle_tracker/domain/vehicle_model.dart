class VehicleModel {
  final String id;
  final String name;
  final String model;
  final String plateNumber;
  final double latitude;
  final double longitude;
  final double fuelLevel; // percentage 0.0 to 100.0
  final String status; // e.g. Parked, Driving, Active

  const VehicleModel({
    required this.id,
    required this.name,
    required this.model,
    required this.plateNumber,
    required this.latitude,
    required this.longitude,
    required this.fuelLevel,
    required this.status,
  });

  VehicleModel copyWith({
    String? id,
    String? name,
    String? model,
    String? plateNumber,
    double? latitude,
    double? longitude,
    double? fuelLevel,
    String? status,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'plateNumber': plateNumber,
      'latitude': latitude,
      'longitude': longitude,
      'fuelLevel': fuelLevel,
      'status': status,
    };
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      model: json['model'] as String,
      plateNumber: json['plateNumber'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      fuelLevel: (json['fuelLevel'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}
