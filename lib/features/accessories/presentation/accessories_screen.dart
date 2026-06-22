import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';

class AccessoriesScreen extends ConsumerStatefulWidget {
  const AccessoriesScreen({super.key});

  @override
  ConsumerState<AccessoriesScreen> createState() => _AccessoriesScreenState();
}

class _AccessoriesScreenState extends ConsumerState<AccessoriesScreen> {
  String _activeCategory = 'All'; // All, Interior, Safety, Lighting
  String _searchQuery = '';

  final List<Map<String, dynamic>> _mockAccessories = [
    {
      'id': 'acc-001',
      'title': 'All-Weather Floor Mats',
      'category': 'Interior',
      'price': 2499.00,
      'rating': '4.8',
      'icon': Icons.layers,
      'desc': 'Heavy-duty rubber protection mats customized precisely for EV footwells. Anti-slip back grip.',
    },
    {
      'id': 'acc-002',
      'title': 'OBD2 Diagnostics Connector',
      'category': 'Safety',
      'price': 1999.00,
      'rating': '4.75',
      'icon': Icons.bluetooth,
      'desc': 'Bluetooth OBD2 car reader that streams vehicle engine battery logs, temperature alerts to phone.',
    },
    {
      'id': 'acc-003',
      'title': 'Carbon Fiber steering Cover',
      'category': 'Interior',
      'price': 899.00,
      'rating': '4.6',
      'icon': Icons.circle,
      'desc': 'Genuine carbon styling wrap with sweat-resistant grips. Snug fit on standard sports wheels.',
    },
    {
      'id': 'acc-004',
      'title': 'LED Dynamic Road Flares',
      'category': 'Safety',
      'price': 799.00,
      'rating': '4.9',
      'icon': Icons.warning_amber,
      'desc': 'Emergency magnetic hazard beacons, fully waterproof with flashing visual alerts en-route.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlist = ref.watch(wishlistInteractiveProvider);
    final cart = ref.watch(cartInteractiveProvider);

    final filtered = _mockAccessories.where((acc) {
      final matchesSearch = acc['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _activeCategory == 'All' || acc['category'] == _activeCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessories Point'),
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
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manage your purchases inside the Store Cart tab!')));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Search Accessories
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search styling kits, safety devices...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tabs
              Row(
                children: ['All', 'Interior', 'Safety'].map((cat) {
                  final isSel = _activeCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          _activeCategory = cat;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Items Grid
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No accessories found.'))
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isWished = wishlist.any((w) => w['id'] == item['id']);

                          return Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.5),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        child: Icon(item['icon'] as IconData, size: 40, color: AppColors.primary),
                                      ),
                                      Positioned(
                                        right: 4,
                                        top: 4,
                                        child: IconButton(
                                          icon: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: AppColors.primary, size: 18),
                                          onPressed: () => ref.read(wishlistInteractiveProvider.notifier).toggleWishlist(
                                            item['id'] as String,
                                            item['title'] as String,
                                            item['price'] as double,
                                            item['icon'] as IconData,
                                            item['category'] as String,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('₹${(item['price'] as double).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                                          GestureDetector(
                                            onTap: () {
                                              ref.read(cartInteractiveProvider.notifier).addToCart(
                                                item['id'] as String,
                                                item['title'] as String,
                                                item['price'] as double,
                                                item['icon'] as IconData,
                                                item['category'] as String,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!'), duration: Duration(milliseconds: 600)));
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                              child: const Icon(Icons.add_shopping_cart, size: 12, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
