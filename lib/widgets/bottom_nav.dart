import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<BottomNavItem> items = [
      BottomNavItem(
        icon: Icons.directions_car_outlined, 
        activeIcon: Icons.directions_car, 
        label: 'Home'
      ),
      BottomNavItem(
        icon: Icons.explore_outlined, 
        activeIcon: Icons.explore, 
        label: 'Explore'
      ),
      BottomNavItem(
        icon: Icons.storefront_outlined, 
        activeIcon: Icons.storefront, 
        label: 'Service'
      ),
      BottomNavItem(
        icon: Icons.person_outline, 
        activeIcon: Icons.person, 
        label: 'Profile'
      ),
    ];

    return Container(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.lightBorder.withValues(alpha: 0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return _AnimatedBottomNavItem(
                isSelected: isSelected,
                item: item,
                isDark: isDark,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBottomNavItem extends StatelessWidget {
  final bool isSelected;
  final BottomNavItem item;
  final bool isDark;
  final VoidCallback onTap;

  static const Map<String, double> _labelWidths = {
    'Home': 44.0,
    'Explore': 58.0,
    'Service': 56.0,
    'Profile': 48.0,
  };

  const _AnimatedBottomNavItem({
    required this.isSelected,
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If the label is on the left, we add width to text.
    final double targetWidth = isSelected
        ? (_labelWidths[item.label] ?? 50.0) + 12.0
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text Label Opacity & Width Slide Animation (Left of icon)
            ClipRect(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: targetWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  reverse: true, // align text to right boundary before icon
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
            // Icon Scale Animation
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
