import '../domain/search_result_model.dart';
import '../../../routes/routes.dart';

class SearchService {
  final List<SearchResultModel> _mockDatabase = const [
    // Rides
    SearchResultModel(
      id: 's-001',
      title: 'Premium Airport Ride',
      subtitle: 'Instant luxury taxi to terminal 2',
      category: 'Rides',
      route: AppRoutes.rides,
    ),
    SearchResultModel(
      id: 's-002',
      title: 'Daily Commute pooling',
      subtitle: 'Shared ride pools to downtown',
      category: 'Rides',
      route: AppRoutes.rides,
    ),
    // Rentals
    SearchResultModel(
      id: 's-003',
      title: 'Tata Nexon EV Rental',
      subtitle: 'Rent electric sedans hourly',
      category: 'Rentals',
      route: AppRoutes.rental,
    ),
    SearchResultModel(
      id: 's-004',
      title: 'SUV Weekend Rental',
      subtitle: '4x4 utilities for offroad trips',
      category: 'Rentals',
      route: AppRoutes.rental,
    ),
    // Drivers
    SearchResultModel(
      id: 's-005',
      title: 'Personal Chauffeur',
      subtitle: 'Hire driver for executive events',
      category: 'Drivers',
      route: AppRoutes.driversOnDemand,
    ),
    // Parking
    SearchResultModel(
      id: 's-006',
      title: 'Downtown Shared Parking',
      subtitle: 'Reserve parking spots in block 4',
      category: 'Parking',
      route: AppRoutes.sharedParking,
    ),
    // Travel Guide
    SearchResultModel(
      id: 's-007',
      title: 'Pacific Highway Guide',
      subtitle: 'Scenic routes, motels, and maps',
      category: 'Travel Guide',
      route: AppRoutes.travelGuide,
    ),
    // Bookings
    SearchResultModel(
      id: 's-008',
      title: 'Toll Ticket Booking',
      subtitle: 'Prepay highway toll passes',
      category: 'Bookings',
      route: AppRoutes.booking,
    ),
    // Mechanics
    SearchResultModel(
      id: 's-009',
      title: 'Emergency Mobile Mechanic',
      subtitle: '24/7 flat tire & engine jumpstarts',
      category: 'Mechanics',
      route: AppRoutes.mechanic,
    ),
    SearchResultModel(
      id: 's-010',
      title: 'Periodic Vehicle Tuning',
      subtitle: 'Certified maintenance center services',
      category: 'Mechanics',
      route: AppRoutes.serviceCenter,
    ),
    // Accessories
    SearchResultModel(
      id: 's-011',
      title: 'Premium Styling Trim Cover',
      subtitle: 'Real Carbon steering wheels',
      category: 'Accessories',
      route: AppRoutes.accessoriesPoint,
    ),
  ];

  List<SearchResultModel> search(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _mockDatabase.where((item) {
      return item.title.toLowerCase().contains(lowerQuery) ||
             item.subtitle.toLowerCase().contains(lowerQuery) ||
             item.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    
    // Extract unique matching titles or categories as suggestions
    return _mockDatabase
        .where((item) => item.title.toLowerCase().contains(lowerQuery) || item.category.toLowerCase().contains(lowerQuery))
        .map((item) => item.title)
        .take(5)
        .toList();
  }
}
