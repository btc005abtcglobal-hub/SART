import 'package:flutter/material.dart';
import '../screens/main_scaffold.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/notifications/presentation/notification_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/rides/presentation/rides_screen.dart';
import '../features/carrier/presentation/carrier_screen.dart';
import '../features/rental/presentation/rental_screen.dart';
import '../features/shared_parking/presentation/parking_screen.dart';
import '../features/travel_guide/presentation/travel_screen.dart';
import '../features/booking/presentation/booking_screen.dart';
import '../features/community/presentation/community_screen.dart';
import '../features/drivers_on_demand/presentation/drivers_screen.dart';
import '../features/auto_news/presentation/news_screen.dart';
import '../features/mechanic/presentation/mechanic_screen.dart';
import '../features/service_center/presentation/service_center_screen.dart';
import '../features/accessories/presentation/accessories_screen.dart';
import '../features/vehicle_tracker/presentation/garage_screen.dart';
import '../features/smart_upgrade/presentation/upgrade_screen.dart';
import '../features/sos/presentation/sos_screen.dart';

class AppRoutes {
  static const String initial = '/';
  
  // Core Actions
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String explore = '/explore';
  static const String sos = '/sos';
  
  // Home Services
  static const String rides = '/rides';
  static const String carrier = '/carrier';
  static const String rental = '/rental';
  static const String community = '/community';
  static const String driversOnDemand = '/drivers_on_demand';
  static const String sharedParking = '/shared_parking';
  static const String travelGuide = '/travel_guide';
  static const String booking = '/booking';
  static const String findMyVehicle = '/find_my_vehicle';
  static const String autoNews = '/auto_news';

  // Store Services
  static const String smartUpgrade = '/smart_upgrade';
  static const String mechanic = '/mechanic';
  static const String serviceCenter = '/service_center';
  static const String accessoriesPoint = '/accessories_point';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => const MainScaffold());
      
      // Core Actions
      case search:
        return _buildAnimatedRoute(const SearchScreen(), settings);
      case notifications:
        return _buildAnimatedRoute(const NotificationScreen(), settings);
      case explore:
        return _buildAnimatedRoute(const ExploreScreen(), settings);
      case sos:
        return _buildAnimatedRoute(const SosScreen(), settings);
      
      // Home Services
      case rides:
        return _buildAnimatedRoute(const RidesScreen(), settings);
      case carrier:
        return _buildAnimatedRoute(const CarrierScreen(), settings);
      case rental:
        return _buildAnimatedRoute(const RentalScreen(), settings);
      case community:
        return _buildAnimatedRoute(const CommunityScreen(), settings);
      case driversOnDemand:
        return _buildAnimatedRoute(const DriversScreen(), settings);
      case sharedParking:
        return _buildAnimatedRoute(const ParkingScreen(), settings);
      case travelGuide:
        return _buildAnimatedRoute(const TravelScreen(), settings);
      case booking:
        return _buildAnimatedRoute(const BookingScreen(), settings);
      case findMyVehicle:
        return _buildAnimatedRoute(const GarageScreen(), settings);
      case autoNews:
        return _buildAnimatedRoute(const NewsScreen(), settings);

      // Store Services
      case smartUpgrade:
        return _buildAnimatedRoute(const UpgradeScreen(), settings);
      case mechanic:
        return _buildAnimatedRoute(const MechanicScreen(), settings);
      case serviceCenter:
        return _buildAnimatedRoute(const ServiceCenterScreen(), settings);
      case accessoriesPoint:
        return _buildAnimatedRoute(const AccessoriesScreen(), settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _buildAnimatedRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.3); // Slide up slightly from bottom
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
