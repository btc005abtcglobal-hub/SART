import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../core/interactive_providers.dart';
import '../../widgets/location_selector.dart';
import '../../widgets/section_header.dart';
import '../../routes/routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _currentCity = "Fetching Location...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      // On Android, we can trigger the system dialog implicitly via getCurrentPosition.
      // On other platforms (iOS), we must redirect to settings.
      if (Theme.of(context).platform != TargetPlatform.android) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() => _currentCity = "Location Disabled");
          return;
        }
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _currentCity = "Permission Denied");
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() => _currentCity = "Permission Denied");
      return;
    } 

    setState(() => _currentCity = "Locating...");

    try {
      // On Android, if serviceEnabled was false, this call will trigger the 
      // Google Play Services location settings dialog (the "toggle popup").
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          String locality = place.locality ?? '';
          String subLocality = place.subLocality ?? '';
          if (subLocality.isNotEmpty && locality.isNotEmpty) {
            _currentCity = '$subLocality, $locality';
          } else if (locality.isNotEmpty) {
            _currentCity = locality;
          } else {
            _currentCity = 'Unknown Location';
          }
        });
      } else {
        setState(() => _currentCity = "Unknown Location");
      }
    } catch (e) {
      setState(() => _currentCity = "Location Error");
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifState = ref.watch(notificationProvider);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: const Text(
            'SART',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          centerTitle: false,
          actions: [
            // Unread notifications bell
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                ),
                if (notifState.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${notifState.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: LocationSelector(
                  currentLocation: _currentCity,
                  onTap: () {
                    _getCurrentLocation();
                  },
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Track'),
            ],
            indicatorColor: AppColors.primary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
          ),
        ),
        body: TabBarView(
          children: [
            _buildHomeContent(isDark),
            _buildMapPlaceholder(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 96.0), // Padding bottom for floating navigation bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              
              // 1. GREETING & WEATHER SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Morning, Alex',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_outlined, size: 14, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            '24°C, Sunny',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, size: 12, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Verified Account',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 2. LARGE SMART SEARCH ("Where would you like to go?")
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Where would you like to go?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Search ride, parking, mechanic...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 3. QUICK ACTIONS (Horizontal Premium Cards)
              const SectionHeader(title: 'Major Services'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildQuickActionCard(
                    context: context,
                    title: 'Ride',
                    icon: Icons.directions_car,
                    color: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.rides),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Carrier',
                    icon: Icons.local_shipping,
                    color: AppColors.secondary,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.carrier),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Rental',
                    icon: Icons.key,
                    color: AppColors.accent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.rental),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Drivers',
                    icon: Icons.supervised_user_circle,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.driversOnDemand),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Parking',
                    icon: Icons.local_parking,
                    color: Colors.deepPurple,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.sharedParking),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Mechanic',
                    icon: Icons.build,
                    color: Colors.blueGrey,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.mechanic),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Booking',
                    icon: Icons.confirmation_number_outlined,
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.booking),
                  ),
                  _buildQuickActionCard(
                    context: context,
                    title: 'News',
                    icon: Icons.newspaper,
                    color: Colors.indigo,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.autoNews),
                  ),
                ],
              ),
              
              const SizedBox(height: 28),
              
              // 4. LIVE STATUS DASHBOARD
              const SectionHeader(title: 'Nearby Activity Feed'),
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildLiveStatusChip(Icons.person_pin_circle, '8 Drivers Nearby'),
                    _buildLiveStatusChip(Icons.electric_car, '14 Rentals Active'),
                    _buildLiveStatusChip(Icons.local_parking, '3 Parking Spots'),
                    _buildLiveStatusChip(Icons.build_circle, '5 Mechanics Online'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 5. LATEST NEWS
              SectionHeader(
                title: 'Latest News',
                actionText: 'See All',
                onActionTap: () => Navigator.pushNamed(context, AppRoutes.autoNews),
              ),
              const SizedBox(height: 12),
              _buildLatestNews(context),

              const SizedBox(height: 28),

              // 7. SMART RECOMMENDATIONS ("Recommended For You")
              const SectionHeader(title: 'Recommended For You'),
              const SizedBox(height: 12),
              _buildSmartRecommendations(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Box Shape Map Widget (Empty Placeholder)
            Container(
              height: 380,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Empty Map Area
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'Interactive Map Ready',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            'Map interface ready for integration. Map elements will render here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Overlay Zoom and Favorite Buttons
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMapOverlayButton(Icons.favorite, Colors.redAccent, () {}, isDark),
                        const SizedBox(height: 12),
                        _buildMapOverlayButton(Icons.add, isDark ? Colors.white : Colors.black87, () {}, isDark),
                        const SizedBox(height: 8),
                        _buildMapOverlayButton(Icons.remove, isDark ? Colors.white : Colors.black87, () {}, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. Active Booking Section
            const Text(
              'My Booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Mock Active Booking Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_car, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ride to Airport', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Driver is 5 mins away • Tracking', 
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Live', 
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapOverlayButton(IconData icon, Color iconColor, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate width for 4 items per row minus spacing
    final cardWidth = (screenWidth - 40 - (3 * 12)) / 4; 

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: 85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusChip(IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLatestNews(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final articles = ref.watch(autoNewsInteractiveProvider);
    
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: articles.length > 5 ? 5 : articles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.autoNews),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(article.tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                      Text(article.date, style: const TextStyle(fontSize: 10, color: AppColors.darkTextSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.3),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.source, size: 12, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(article.source, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmartRecommendations(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, dynamic>> recommendations = [
      {'title': 'Tata Nexon EV near you', 'sub': 'Available hourly rate', 'tag': 'Rentals', 'icon': Icons.electric_car},
      {'title': 'Alexander Pierce (Gold)', 'sub': '4 mins away from current location', 'tag': 'Drivers', 'icon': Icons.person},
      {'title': 'Western Ghats Scenic NH-66', 'sub': 'Scenic coastal views', 'tag': 'Travel', 'icon': Icons.explore},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recommendations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final rec = recommendations[index];
          return Container(
            width: 250,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(rec['icon'], color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(rec['tag'], style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      ),
                      const SizedBox(height: 4),
                      Text(rec['title'], style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(rec['sub'], style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
