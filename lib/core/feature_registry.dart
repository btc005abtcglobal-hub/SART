import 'package:flutter/material.dart';
import '../routes/routes.dart';

class AppFeature {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final String route;
  final String description;

  const AppFeature({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.route,
    required this.description,
  });
}

class FeatureRegistry {
  // Home Dashboard Services
  static const List<AppFeature> homeServices = [
    AppFeature(
      id: 'rides',
      title: 'Rides',
      subtitle: 'Premium booking',
      icon: Icons.directions_car,
      route: AppRoutes.rides,
      description: 'Book premium and daily commute rides instantly.',
    ),
    AppFeature(
      id: 'carrier',
      title: 'Carrier',
      subtitle: 'Heavy logistics',
      icon: Icons.local_shipping,
      route: AppRoutes.carrier,
      description: 'On-demand goods delivery and logistics tracking.',
    ),
    AppFeature(
      id: 'rental',
      title: 'Rental',
      subtitle: 'Hourly drives',
      icon: Icons.key,
      route: AppRoutes.rental,
      description: 'Rent luxury and utility vehicles on hourly or daily rates.',
    ),
    AppFeature(
      id: 'community',
      title: 'Community',
      subtitle: 'Owner chat',
      icon: Icons.people_outline,
      route: AppRoutes.community,
      description: 'Connect with fellow automobile owners, join groups, and forums.',
    ),
    AppFeature(
      id: 'drivers_on_demand',
      title: 'Drivers On Demand',
      subtitle: 'Personal driver',
      icon: Icons.supervised_user_circle,
      route: AppRoutes.driversOnDemand,
      description: 'Hire verified drivers for short trips or full days.',
    ),
    AppFeature(
      id: 'shared_parking',
      title: 'Shared Parking',
      subtitle: 'Reserve spots',
      icon: Icons.local_parking,
      route: AppRoutes.sharedParking,
      description: 'Find, reserve, and share premium parking spots.',
    ),
    AppFeature(
      id: 'travel_guide',
      title: 'Travel Guide',
      subtitle: 'Explore maps',
      icon: Icons.explore_outlined,
      route: AppRoutes.travelGuide,
      description: 'Explore popular destinations and driving routes.',
    ),
    AppFeature(
      id: 'booking',
      title: 'Booking',
      subtitle: 'Manage tickets',
      icon: Icons.confirmation_number_outlined,
      route: AppRoutes.booking,
      description: 'Manage all your transport, hotel, and activity bookings.',
    ),
    AppFeature(
      id: 'find_my_vehicle',
      title: 'Find My Vehicle',
      subtitle: 'Locate and track your parked vehicle instantly',
      icon: Icons.gps_fixed,
      route: AppRoutes.findMyVehicle,
      description: 'Track and locate your vehicle status and position in real-time.',
    ),
    AppFeature(
      id: 'auto_news',
      title: 'Auto News',
      subtitle: 'Latest updates in the vehicle ecosystem',
      icon: Icons.newspaper,
      route: AppRoutes.autoNews,
      description: 'Latest updates, reviews, and trends in the automotive world.',
    ),
  ];

  // Store Services & Upgrades
  static const List<AppFeature> storeServices = [
    AppFeature(
      id: 'smart_upgrade',
      title: 'Smart Upgrade',
      subtitle: 'Best fit for your vehicle',
      icon: Icons.bolt,
      route: AppRoutes.smartUpgrade,
      description: 'Premium hardware and software enhancements for your ride.',
    ),
    AppFeature(
      id: 'mechanic',
      title: 'Mechanic',
      subtitle: 'Book direct diagnosis',
      icon: Icons.build,
      route: AppRoutes.mechanic,
      description: 'Book professional mechanics for inspections and diagnostics.',
    ),
    AppFeature(
      id: 'service_center',
      title: 'Service Center',
      subtitle: 'Scheduled maintenance',
      icon: Icons.home_repair_service,
      route: AppRoutes.serviceCenter,
      description: 'Find authorized service centers for periodic maintenance.',
    ),
    AppFeature(
      id: 'accessories_point',
      title: 'Accessories Point',
      subtitle: 'Styling & utility kit',
      icon: Icons.dashboard_customize,
      route: AppRoutes.accessoriesPoint,
      description: 'High quality vehicle styling, safety and utility products.',
    ),
  ];

  // Profile Settings - Left Column
  static const List<AppFeature> profileLeftItems = [
    AppFeature(
      id: 'documents',
      title: 'Documents',
      icon: Icons.description_outlined,
      route: '/profile/documents',
      description: 'Manage driving license, vehicle registry docs, and permits.',
    ),
    AppFeature(
      id: 'payment',
      title: 'Payment',
      icon: Icons.credit_card_outlined,
      route: '/profile/payment',
      description: 'Manage credit cards, bank accounts, and automatic top-ups.',
    ),
    AppFeature(
      id: 'translate',
      title: 'Translate',
      icon: Icons.g_translate_outlined,
      route: '/profile/translate',
      description: 'Translate communication settings.',
    ),
    AppFeature(
      id: 'language_country',
      title: 'Language & Country',
      icon: Icons.public,
      route: '/profile/language_country',
      description: 'Configure country, locale, and region specific settings.',
    ),
    AppFeature(
      id: 'help_support',
      title: 'Help & Support',
      icon: Icons.help_outline,
      route: '/profile/help_support',
      description: 'Reach our customer team, live chat, or read support forums.',
    ),
    AppFeature(
      id: 'about',
      title: 'About',
      icon: Icons.info_outline,
      route: '/profile/about',
      description: 'Super App version history, legal, and privacy policy.',
    ),
    AppFeature(
      id: 'reminder',
      title: 'Reminder',
      icon: Icons.notifications_active_outlined,
      route: '/profile/reminder',
      description: 'Manage notifications for service tasks, tolls, and maintenance.',
    ),
    AppFeature(
      id: 'feature_suggestion',
      title: 'Feature Suggestion',
      icon: Icons.lightbulb_outline,
      route: '/profile/feature_suggestion',
      description: 'Submit feedback or vote on request features.',
    ),
    AppFeature(
      id: 'ride_sharing',
      title: 'Ride Sharing',
      icon: Icons.share_location_outlined,
      route: '/profile/ride_sharing',
      description: 'Manage your rider and carrier pooling sharing status.',
    ),
  ];

  // Profile Settings - Right Column
  static const List<AppFeature> profileRightItems = [
    AppFeature(
      id: 'professional_mode',
      title: 'Professional Mode',
      icon: Icons.badge_outlined,
      route: '/profile/professional_mode',
      description: 'Toggle driver mode, track business mileage, and tax details.',
    ),
    AppFeature(
      id: 'trip_ride',
      title: 'Trip / Ride',
      icon: Icons.commute_outlined,
      route: '/profile/trip_ride',
      description: 'View active coordinates, route logs, and past trips.',
    ),
    AppFeature(
      id: 'favourite_drivers',
      title: 'Favourite Drivers',
      icon: Icons.star_outline,
      route: '/profile/favourite_drivers',
      description: 'List and search your preferred service drivers.',
    ),
    AppFeature(
      id: 'history',
      title: 'History',
      icon: Icons.history,
      route: '/profile/history',
      description: 'View recent bookings, service calls, and payments.',
    ),
    AppFeature(
      id: 'kids_women_mode',
      title: 'Kids & Women Mode',
      icon: Icons.safety_divider,
      route: '/profile/kids_women_mode',
      description: 'Toggle enhanced security, child lock, and identity checks.',
    ),
    AppFeature(
      id: 'map_settings',
      title: 'Map Settings',
      icon: Icons.map_outlined,
      route: '/profile/map_settings',
      description: 'Configure offline maps, routing preferences, and updates.',
    ),
    AppFeature(
      id: 'live_status',
      title: 'Live Status Dashboard',
      icon: Icons.speed,
      route: '/profile/live_status',
      description: 'Diagnostic display of fuel, battery charge, and engine heat.',
    ),
    AppFeature(
      id: 'logout',
      title: 'Logout / Switch Account',
      icon: Icons.logout,
      route: '/profile/logout',
      description: 'Sign out of current profile or switch driver profiles.',
    ),
  ];
}
