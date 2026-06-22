class SearchResultModel {
  final String id;
  final String title;
  final String subtitle;
  final String category; // e.g. Ride, Driver, Parking, Mechanic, Accessory
  final String route;

  const SearchResultModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.route,
  });

  SearchResultModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    String? route,
  }) {
    return SearchResultModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      route: route ?? this.route,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'route': route,
    };
  }

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      category: json['category'] as String,
      route: json['route'] as String,
    );
  }
}
