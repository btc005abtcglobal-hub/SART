import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/feature_registry.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/service_card.dart';
import '../../../routes/routes.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final ridesFeatures = [
      const AppFeature(
        id: 'bike_taxi',
        title: 'Bike Taxi',
        subtitle: 'Fast commutes',
        icon: Icons.motorcycle,
        route: AppRoutes.rides,
        description: 'Fast single commutes',
      ),
      const AppFeature(
        id: 'auto_rickshaw',
        title: 'Auto',
        subtitle: 'Local travel',
        icon: Icons.electric_rickshaw,
        route: AppRoutes.rides,
        description: 'Direct local transport',
      ),
      const AppFeature(
        id: 'cab_rides',
        title: 'Cab',
        subtitle: 'Premium rides',
        icon: Icons.local_taxi,
        route: AppRoutes.rides,
        description: 'Premium car rides',
      ),
    ];

    final carriersFeatures = [
      const AppFeature(
        id: 'bike_courier',
        title: 'Bike Courier',
        subtitle: 'Instant parcels',
        icon: Icons.delivery_dining,
        route: AppRoutes.carrier,
        description: 'Parcels & documents',
      ),
      const AppFeature(
        id: 'mini_truck',
        title: 'Mini Truck',
        subtitle: 'Medium loads',
        icon: Icons.local_shipping,
        route: AppRoutes.carrier,
        description: 'Appliance & furniture move',
      ),
      const AppFeature(
        id: 'big_truck',
        title: 'Big Truck',
        subtitle: 'Heavy cargo',
        icon: Icons.local_shipping,
        route: AppRoutes.carrier,
        description: 'Heavy industrial logistics',
      ),
    ];

    final rentalFeatures = [
      const AppFeature(
        id: 'bike_rentals',
        title: 'Bike Rentals',
        subtitle: 'Hourly scooters',
        icon: Icons.two_wheeler,
        route: AppRoutes.rental,
        description: 'Hourly self-ride scooters',
      ),
      const AppFeature(
        id: 'self_drive_cars',
        title: 'Self Drive',
        subtitle: 'Cars & SUVs',
        icon: Icons.car_rental,
        route: AppRoutes.rental,
        description: 'Hatchbacks to SUVs',
      ),
      const AppFeature(
        id: 'luxury_rentals',
        title: 'Luxury Rentals',
        subtitle: 'Premium sedans',
        icon: Icons.key,
        route: AppRoutes.rental,
        description: 'Premium & sports sedans',
      ),
    ];

    final driversOnDemandFeatures = [
      const AppFeature(
        id: 'car_drivers',
        title: 'Car Drivers',
        subtitle: 'Verified drivers',
        icon: Icons.supervised_user_circle,
        route: AppRoutes.driversOnDemand,
        description: 'Verified professional car drivers',
      ),
      const AppFeature(
        id: 'heavy_drivers',
        title: 'Heavy Vehicle',
        subtitle: 'Bus & truck drivers',
        icon: Icons.local_shipping,
        route: AppRoutes.driversOnDemand,
        description: 'Heavy commercial vehicle operators',
      ),
    ];

    // Responsive columns counting
    final double cardWidth = screenWidth > 600 ? 180 : 150;
    const double cardHeight = 110;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Discovery Hub'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                
                // Greeting and Search Header
                Text(
                  'Explore Ecosystem',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Locate and access all on-demand mobility modules',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Search Bar Redirection
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Search services, updates, products...',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 28),

                // 1. Rides Category
                const SectionHeader(title: 'Rides'),
                const SizedBox(height: 12),
                _buildHorizontalLane(context, ridesFeatures, cardWidth, cardHeight),

                const SizedBox(height: 28),

                // 2. Carriers Category
                const SectionHeader(title: 'Carriers'),
                const SizedBox(height: 12),
                _buildHorizontalLane(context, carriersFeatures, cardWidth, cardHeight),

                const SizedBox(height: 28),

                // 3. Rental Category
                const SectionHeader(title: 'Rental'),
                const SizedBox(height: 12),
                _buildHorizontalLane(context, rentalFeatures, cardWidth, cardHeight),
                
                const SizedBox(height: 28),

                // 4. Drivers On Demand Category
                const SectionHeader(title: 'Drivers On Demand'),
                const SizedBox(height: 12),
                _buildHorizontalLane(context, driversOnDemandFeatures, cardWidth, cardHeight),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalLane(
    BuildContext context, 
    List<AppFeature> features, 
    double itemWidth, 
    double itemHeight
  ) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: features.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final feature = features[index];
          return SizedBox(
            width: itemWidth,
            child: ServiceCard(
              title: feature.title,
              subtitle: feature.subtitle,
              icon: feature.icon,
              onTap: () => Navigator.pushNamed(context, feature.route),
            ),
          );
        },
      ),
    );
  }


}
