import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/feature_registry.dart';
import '../../core/interactive_providers.dart';
import '../../widgets/section_header.dart';
import '../../widgets/service_card.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  final String _activeCategory = 'All'; // All, Smart Upgrades, Diagnostics, Accessories, Lighting
  String _searchQuery = '';

  final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': 'st-001',
      'name': 'AI Smart Dash Pro',
      'price': 499.00,
      'rating': '4.9',
      'icon': Icons.terminal,
      'category': 'Smart Upgrades',
      'desc': 'High-fidelity dual-lens dashcam with real-time AI object detection, lane departure warnings, and parking guard telemetry linked straight to your phone.',
    },
    {
      'id': 'st-002',
      'name': 'OBD2 Diagnostics Scanner',
      'price': 119.00,
      'rating': '4.7',
      'icon': Icons.settings_remote,
      'category': 'Diagnostics',
      'desc': 'Premium hardware scanner reading real-time engine telemetry, transmission codes, battery capacity status, and emission logs.',
    },
    {
      'id': 'st-003',
      'name': 'Carbon Fiber Trim Kit',
      'price': 249.00,
      'rating': '4.8',
      'icon': Icons.space_dashboard,
      'category': 'Accessories',
      'desc': 'Genuine carbon styling wrap with sweat-resistant grips. Snug fit on standard sports dash panels.',
    },
    {
      'id': 'st-004',
      'name': 'LED Sports Headlamps',
      'price': 189.00,
      'rating': '4.6',
      'icon': Icons.highlight,
      'category': 'Lighting',
      'desc': 'High intensity illumination bulbs delivering 200% brighter beams for safer night cruises and highway route previews.',
    },
  ];

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Consumer(
          builder: (context, ref, child) {
            final cartItems = ref.watch(cartInteractiveProvider);
            final double totalCartCost = cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 18),
                  Text('My Shopping Cart (${cartItems.length} items)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  
                  Expanded(
                    child: cartItems.isEmpty
                        ? const Center(child: Text('Your cart is empty. Add accessories to begin!'))
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: cartItems.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(item.icon, color: AppColors.primary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                          Text('₹${item.price.toStringAsFixed(2)} each', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove, size: 14),
                                          onPressed: () => ref.read(cartInteractiveProvider.notifier).decrementQuantity(item.id),
                                        ),
                                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 14),
                                          onPressed: () => ref.read(cartInteractiveProvider.notifier).incrementQuantity(item.id),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                                          onPressed: () => ref.read(cartInteractiveProvider.notifier).removeItem(item.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Charges:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('₹${totalCartCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: cartItems.isEmpty
                          ? null
                          : () {
                              Navigator.pop(context);
                              _checkoutCart(totalCartCost, cartItems);
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Checkout with Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _checkoutCart(double cost, List<CartItem> items) {
    final walletState = ref.read(walletInteractiveProvider);
    if (walletState.balance < cost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Insufficient Funds'),
          content: Text('Your wallet balance (₹${walletState.balance.toStringAsFixed(2)}) is lower than cart total (₹${cost.toStringAsFixed(2)}).'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    ref.read(walletInteractiveProvider.notifier).deductMoney(
      cost,
      'Checkout: ${items.length} Store items',
      'Store',
    );

    // Add booking/orders tracking
    for (final item in items) {
      final booking = PrototypeBooking(
        id: 'bk-store-${DateTime.now().millisecondsSinceEpoch}-${item.id}',
        title: 'Ordered: ${item.title}',
        type: 'Carrier', // registers under package carrier for shipping tracking
        dateTime: DateTime.now(),
        details: 'Shipping Status: Processing Dispatch',
        status: 'Active',
        cost: item.price * item.quantity,
      );
      ref.read(bookingsInteractiveProvider.notifier).addBooking(booking);
    }

    ref.read(cartInteractiveProvider.notifier).clearCart();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Order Placed Successfully!'),
        content: const Text('Your order has been paid. You can track carrier shipping logs under Bookings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Great')),
        ],
      ),
    );
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Icon(product['icon'] as IconData, size: 28, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 4),
              Text(product['category'] as String, style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              const Text('Product Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                product['desc'] as String,
                style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const Spacer(),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Price', style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary)),
                      Text('₹${(product['price'] as double).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(cartInteractiveProvider.notifier).addToCart(
                          product['id'] as String,
                          product['name'] as String,
                          product['price'] as double,
                          product['icon'] as IconData,
                          product['category'] as String,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!'), duration: Duration(milliseconds: 600)));
                      },
                      icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                      label: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final cart = ref.watch(cartInteractiveProvider);
    final wishlist = ref.watch(wishlistInteractiveProvider);
    
    final int serviceColumns = screenWidth > 600 ? 4 : 2;
    final int productColumns = screenWidth > 600 ? 3 : 2;

    final List<AppFeature> storeServices = FeatureRegistry.storeServices;

    // Filter products
    final filteredProducts = _mockProducts.where((p) {
      final matchesSearch = p['name'].toLowerCase().contains(_searchQuery.toLowerCase()) || p['category'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _activeCategory == 'All' || p['category'] == _activeCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Auto Store'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
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
            onPressed: () => _showCartSheet(context),
          ),
          const SizedBox(width: 8),
        ],
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
                
                // Header Welcome Text
                Text(
                  'Explore Auto Gear',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Premium gear and professional services',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Product Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search products, parts, diagnostics...',
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Store Services Header
                const SectionHeader(title: 'Service Options'),
                const SizedBox(height: 14),
                
                // Grid of 4 services rendered dynamically
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: storeServices.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: serviceColumns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final feature = storeServices[index];
                    return ServiceCard(
                      title: feature.title,
                      subtitle: feature.subtitle,
                      icon: feature.icon,
                      onTap: () => Navigator.pushNamed(context, feature.route),
                    );
                  },
                ),
                
                const SizedBox(height: 28),
                
                // Product feed Header
                const SectionHeader(title: 'Premium Products'),
                const SizedBox(height: 14),
                
                // Responsive Grid of Mock Products
                if (filteredProducts.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No matching products found.')))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: productColumns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final prod = filteredProducts[index];
                      final isWished = wishlist.any((w) => w['id'] == prod['id']);

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image Card
                            Expanded(
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showProductDetails(context, prod),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.5),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          prod['icon'] as IconData,
                                          size: 40,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: IconButton(
                                      icon: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: AppColors.primary, size: 18),
                                      onPressed: () => ref.read(wishlistInteractiveProvider.notifier).toggleWishlist(
                                        prod['id'] as String,
                                        prod['name'] as String,
                                        prod['price'] as double,
                                        prod['icon'] as IconData,
                                        prod['category'] as String,
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
                                  Text(
                                    (prod['category'] as String).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    prod['name'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₹${(prod['price'] as double).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          ref.read(cartInteractiveProvider.notifier).addToCart(
                                            prod['id'] as String,
                                            prod['name'] as String,
                                            prod['price'] as double,
                                            prod['icon'] as IconData,
                                            prod['category'] as String,
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
