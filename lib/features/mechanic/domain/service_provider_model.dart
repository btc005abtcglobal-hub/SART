class ServiceProviderModel {
  final String id;
  final String name;
  final String type; // e.g. Mechanic, Service Center, Electrician
  final double rating;
  final String location;
  final bool isAvailable;

  const ServiceProviderModel({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.location,
    required this.isAvailable,
  });

  ServiceProviderModel copyWith({
    String? id,
    String? name,
    String? type,
    double? rating,
    String? location,
    bool? isAvailable,
  }) {
    return ServiceProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'rating': rating,
      'location': location,
      'isAvailable': isAvailable,
    };
  }

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      rating: (json['rating'] as num).toDouble(),
      location: json['location'] as String,
      isAvailable: json['isAvailable'] as bool,
    );
  }
}
