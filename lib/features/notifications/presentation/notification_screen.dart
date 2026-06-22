import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers.dart';
import '../domain/notification_model.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationProvider);
    final notifNotifier = ref.read(notificationProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter notifications based on active category selection
    final filteredNotifications = notifState.activeCategoryFilter == 'All'
        ? notifState.notifications
        : notifState.notifications.where((n) => n.category == notifState.activeCategoryFilter).toList();

    final categories = [
      'All',
      'SOS Alerts',
      'Ride Updates',
      'Booking Updates',
      'Wallet Updates',
      'Vehicle Alerts',
      'Community Alerts',
      'Service Center Alerts',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: notifNotifier.markAllAsRead,
              child: const Text('Read All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Filter Chips list
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = notifState.activeCategoryFilter == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected 
                            ? Colors.white 
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => notifNotifier.setFilter(category),
                    checkmarkColor: Colors.white,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected 
                            ? AppColors.primary 
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Notifications list
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState(context, isDark, notifState.activeCategoryFilter)
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          notifNotifier.deleteNotification(notification.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification deleted'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: _buildNotificationCard(context, notification, notifNotifier),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, String filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          const SizedBox(height: 16),
          Text(
            'No $filter notifications',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We will alert you when ecosystem triggers occur.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    NotificationNotifier notifier,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get color or icon depending on alert type
    IconData getIcon(String cat) {
      switch (cat) {
        case 'SOS Alerts':
          return Icons.warning;
        case 'Ride Updates':
          return Icons.directions_car;
        case 'Booking Updates':
          return Icons.confirmation_number;
        case 'Wallet Updates':
          return Icons.account_balance_wallet;
        case 'Vehicle Alerts':
          return Icons.gps_fixed;
        case 'Community Alerts':
          return Icons.forum;
        case 'Service Center Alerts':
          return Icons.home_repair_service;
        default:
          return Icons.notifications;
      }
    }

    Color getColor(String cat) {
      switch (cat) {
        case 'SOS Alerts':
          return AppColors.error;
        case 'Wallet Updates':
          return Colors.green;
        default:
          return AppColors.primary;
      }
    }

    final alertColor = getColor(notification.category);
    final alertIcon = getIcon(notification.category);

    return GestureDetector(
      onTap: () => notifier.markAsRead(notification.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark 
                ? (notification.isRead ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3)) 
                : (notification.isRead ? AppColors.lightBorder.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.2)),
            width: notification.isRead ? 1.0 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon with side glow indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(alertIcon, color: alertColor, size: 20),
            ),
            const SizedBox(width: 14),
            
            // Notification Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: alertColor,
                        ),
                      ),
                      Text(
                        '${notification.timestamp.minute}m ago',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.3,
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
}
