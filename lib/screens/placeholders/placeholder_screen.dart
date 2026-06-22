import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PlaceholderScreen extends StatelessWidget {
  final String serviceName;
  final String subtitle;

  const PlaceholderScreen({
    super.key,
    required this.serviceName,
    required this.subtitle,
  });

  // Map service names to their respective icons for custom placeholder visuals
  IconData _getServiceIcon(String name) {
    switch (name.toLowerCase()) {
      case 'rides':
        return Icons.directions_car;
      case 'carrier':
        return Icons.local_shipping;
      case 'rental':
        return Icons.key;
      case 'community':
        return Icons.people_outline;
      case 'drivers on demand':
        return Icons.supervised_user_circle;
      case 'shared parking':
        return Icons.local_parking;
      case 'travel guide':
        return Icons.explore_outlined;
      case 'booking':
        return Icons.confirmation_number_outlined;
      case 'find my vehicle':
        return Icons.gps_fixed;
      case 'auto news':
        return Icons.newspaper;
      case 'smart upgrade':
        return Icons.bolt;
      case 'mechanic':
        return Icons.build;
      case 'service center':
        return Icons.home_repair_service;
      case 'accessories point':
        return Icons.dashboard_customize;
      default:
        return Icons.layers_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final serviceIcon = _getServiceIcon(serviceName);

    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 14),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Big Neon Icon Container
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2.0,
                    ),
                  ),
                  child: Icon(
                    serviceIcon,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                serviceName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 48),
              // Modern visual representing that this feature is ready for integration
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'UI Skeleton Verified',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'The design, responsive layout, navigation parameters, and visual system for this component are fully prepared. Integration of maps, real-time APIs, and databases can be built directly on top of this structure.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go Back to Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
