import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../routes/routes.dart';
import '../screens/wallet/wallet_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Column(
        children: [
          // Header Section
          _buildHeader(context, isDark),
          
          const SizedBox(height: 12),

          // Primary Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet,
                  label: 'Wallet',
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WalletScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.history,
                  label: 'Activity History',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Activity History is under development'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Divider(color: AppColors.darkBorder),
                ),
                
                // Settings & Configuration
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  label: 'App Settings',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings Panel is under development'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.security_outlined,
                  label: 'Privacy & Security',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy settings are coming soon'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Divider(color: AppColors.darkBorder),
                ),
                
                // Support Links
                _buildDrawerItem(
                  context: context,
                  icon: Icons.help_outline,
                  label: 'Help & FAQ',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help Center is under development'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.support_agent,
                  label: 'Support Chat',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Customer Support Chat is offline'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.info_outline,
                  label: 'About SART',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SART: Vehicle Ecosystem v1.5.0'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Bottom Footer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'v1.5.0 - SKELETON ARCHITECTURE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 24, right: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vehicle Super App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Alexander Pierce',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    IconData? selectedIcon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        selectedColor: AppColors.primary,
        iconColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        textColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        leading: Icon(isSelected ? (selectedIcon ?? icon) : icon),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
                ? AppColors.primary 
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
