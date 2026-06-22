import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  final List<Map<String, dynamic>> _mockUpgrades = [
    {
      'id': 'upg-001',
      'title': 'AI Smart Dashcam Pro',
      'price': 499.00,
      'category': 'Smart Upgrades',
      'compatibility': 'Tata Nexon EV, RE Himalayan',
      'icon': Icons.terminal,
      'desc': 'High-fidelity dual-lens dashcam with real-time AI object detection, lane departure warnings, and parking guard telemetry linked straight to your phone.',
    },
    {
      'id': 'upg-002',
      'title': 'Long Range EV Booster Pack',
      'price': 1499.00,
      'category': 'Power Systems',
      'compatibility': 'Tata Nexon EV',
      'icon': Icons.bolt,
      'desc': 'Secondary lightweight auxiliary battery module that adds 70 km of emergency backup range. Certified secure cell design.',
    },
    {
      'id': 'upg-003',
      'title': 'Carbon Fiber steering wheel',
      'price': 249.00,
      'category': 'Accessories',
      'compatibility': 'Tata Nexon EV',
      'icon': Icons.circle,
      'desc': 'Genuine dry carbon fiber wrap with red sport accents. Lightweight, high-friction grip contours.',
    },
  ];

  void _buyNow(Map<String, dynamic> item) {
    final cost = item['price'] as double;
    final walletState = ref.read(walletInteractiveProvider);

    if (walletState.balance < cost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Insufficient Funds'),
          content: Text('Your wallet balance (₹${walletState.balance.toStringAsFixed(2)}) is lower than upgrade cost (₹${cost.toStringAsFixed(2)}).'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    ref.read(walletInteractiveProvider.notifier).deductMoney(
      cost,
      'Upgrade Purchase: ${item['title']}',
      'Store',
    );

    final booking = PrototypeBooking(
      id: 'bk-upg-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Upgrade: ${item['title']}',
      type: 'Service',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      details: 'Install Scheduled at Autoworks Hub',
      status: 'Active',
      cost: cost,
    );

    ref.read(bookingsInteractiveProvider.notifier).addBooking(booking);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Upgrade Scheduled!'),
        content: Text('Installation appointment booked for "${item['title']}". You can manage schedule dates under Bookings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Great')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlist = ref.watch(wishlistInteractiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Smart Upgrades'),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 14),
          ),
          onPressed: () => Navigator.pop(context),
        ),
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

                // Hero Upgrade Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.carbonGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Dynamic Upgrades', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('Browse performance packages and hardware upgrades compatible with your registered garage.', style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Compatible Upgrades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mockUpgrades.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = _mockUpgrades[index];
                    final isWished = wishlist.any((w) => w['id'] == item['id']);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(item['icon'] as IconData, color: AppColors.primary, size: 22),
                                  const SizedBox(width: 12),
                                  Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              IconButton(
                                icon: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: AppColors.primary),
                                onPressed: () => ref.read(wishlistInteractiveProvider.notifier).toggleWishlist(
                                  item['id'] as String,
                                  item['title'] as String,
                                  item['price'] as double,
                                  item['icon'] as IconData,
                                  item['category'] as String,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc'] as String,
                            style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Compat: ${item['compatibility']}', style: const TextStyle(fontSize: 9.5, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                              Text('₹${(item['price'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    ref.read(cartInteractiveProvider.notifier).addToCart(
                                      item['id'] as String,
                                      item['title'] as String,
                                      item['price'] as double,
                                      item['icon'] as IconData,
                                      item['category'] as String,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!')));
                                  },
                                  child: const Text('Add to Cart'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _buyNow(item),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  child: const Text('Buy & Schedule Install', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
