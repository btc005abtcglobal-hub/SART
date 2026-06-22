class FeatureModel {
  final String id;
  final String name;
  final bool isEnabled;
  final String category;

  const FeatureModel({
    required this.id,
    required this.name,
    required this.isEnabled,
    required this.category,
  });

  FeatureModel copyWith({
    String? id,
    String? name,
    bool? isEnabled,
    String? category,
  }) {
    return FeatureModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isEnabled': isEnabled,
      'category': category,
    };
  }

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isEnabled: json['isEnabled'] as bool,
      category: json['category'] as String,
    );
  }
}
