import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/feature_registry.dart';
import '../../widgets/section_header.dart';
import '../../routes/routes.dart';
import 'profile_sub_pages.dart';
import '../wallet/wallet_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load Left & Right profile items from Registry
    final leftItems = FeatureRegistry.profileLeftItems;
    final rightItems = FeatureRegistry.profileRightItems;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Profile Dashboard'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WalletScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Wallet',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.sos),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.sosGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 96.0), // Padding bottom for floating navigation bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                
                // 1. PREMIUM HEADER (Verification & Gold tier indicator)
                _buildProfileHeader(context),
                
                const SizedBox(height: 24),
                
                // 2. VEHICLE SUMMARY
                _buildVehicleSummary(context),
                
                const SizedBox(height: 24),
                
                // 3. MEMBERSHIP TIERS CAROUSEL
                const SectionHeader(title: 'Membership Tier Details'),
                const SizedBox(height: 12),
                _buildMembershipTiers(context),
                
                const SizedBox(height: 28),
                
                // 4. EMERGENCY HUB (SOS, Roadside Support, Hospitals)
                const SectionHeader(title: 'Emergency Response Hub'),
                const SizedBox(height: 12),
                _buildEmergencyHub(context),
                
                const SizedBox(height: 28),
                
                // 5. SETTINGS GROUPS (Collapsible Settings Grid)
                const SectionHeader(title: 'Account Settings'),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: leftItems.map((item) => _buildSettingsTile(context, item)).toList(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: rightItems.map((item) => _buildSettingsTile(context, item)).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Alex Pierce',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified, color: AppColors.primary, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'alex.pierce@example.com',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Gold Elite Tier Member',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSummary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, color: AppColors.primary, size: 24),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Tata Nexon EV & RE Himalayan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('2 Active Garage Vehicles Linked', style: TextStyle(fontSize: 10.5, color: AppColors.secondary)),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.findMyVehicle);
            },
            child: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipTiers(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tiers = [
      {'name': 'Silver Shield', 'desc': 'Standard priority dispatch, 2% cashback points', 'color': Colors.blueGrey},
      {'name': 'Gold Elite (Active)', 'desc': 'VIP airport pickups, 5% fuel savings, dedicated support line', 'color': Colors.amber},
      {'name': 'Platinum Orbit', 'desc': 'Immediate chauffeur arrival, free dynamic parking slots, 10% cashbacks', 'color': Colors.deepPurple},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tiers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final tier = tiers[index];
          final isActive = index == 1;
          return Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                width: isActive ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, color: tier['color'] as Color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tier['name'] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(tier['desc'] as String, style: TextStyle(fontSize: 9.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
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

  Widget _buildEmergencyHub(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emergency_share, color: AppColors.error, size: 22),
              SizedBox(width: 8),
              Text('Emergency Response Hub', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 18),
          
          // Emergency contact, roadside assist, hospital locator links
          Row(
            children: [
              _buildEmergencyHubItem(context, 'Roadside Support', Icons.car_crash, () {
                Navigator.pushNamed(context, AppRoutes.sos);
              }),
              const SizedBox(width: 10),
              _buildEmergencyHubItem(context, 'Hospital Map', Icons.local_hospital, () {
                Navigator.pushNamed(context, AppRoutes.sos);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyHubItem(
    BuildContext context, 
    String label, 
    IconData icon, 
    VoidCallback onTap
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, AppFeature item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          if (item.id == 'wallet') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WalletScreen(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSubPage(
                  featureId: item.id,
                  title: item.title,
                ),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 10,
                color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : AppColors.lightTextSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
