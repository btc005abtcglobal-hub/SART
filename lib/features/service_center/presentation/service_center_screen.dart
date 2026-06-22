import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';

class ServiceCenterScreen extends ConsumerStatefulWidget {
  const ServiceCenterScreen({super.key});

  @override
  ConsumerState<ServiceCenterScreen> createState() => _ServiceCenterScreenState();
}

class _ServiceCenterScreenState extends ConsumerState<ServiceCenterScreen> {
  final List<Map<String, dynamic>> _serviceCenters = [
    {
      'id': 'center-1',
      'name': 'Elite Autoworks Diagnostics',
      'location': 'Downtown Bay Meadows',
      'distance': '1.4 km',
      'rating': '4.9',
      'hours': '8:00 AM - 6:00 PM',
    },
    {
      'id': 'center-2',
      'name': 'Indiranagar Superchargers & Service',
      'location': 'Indiranagar Crossing',
      'distance': '2.8 km',
      'rating': '4.85',
      'hours': '24 Hours Open',
    },
  ];

  final List<Map<String, dynamic>> _maintenancePackages = [
    {
      'name': 'Eco Diagnostic Check',
      'price': 45.00,
      'duration': '45 Mins',
      'details': 'OBD2 scan diagnostics, tyre check, battery cell inspect, warning clear.',
    },
    {
      'name': 'Premium Annual Service',
      'price': 180.00,
      'duration': '2 Hours',
      'details': 'Full cabin filter clean, brake pad checks, suspension alignment, tyre balancing.',
    },
  ];

  Map<String, dynamic>? _selectedCenter;
  Map<String, dynamic>? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _selectedCenter = _serviceCenters[0];
    _selectedPackage = _maintenancePackages[0];
  }

  void _bookServiceCenter() {
    if (_selectedCenter == null || _selectedPackage == null) return;

    final cost = _selectedPackage!['price'] as double;
    final walletState = ref.read(walletInteractiveProvider);

    if (walletState.balance < cost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Insufficient Funds'),
          content: Text('Your balance (₹${walletState.balance.toStringAsFixed(2)}) is lower than selected service package charge (₹${cost.toStringAsFixed(2)}).'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }

    // Deduct and book
    ref.read(walletInteractiveProvider.notifier).deductMoney(
      cost,
      'Maintenance: ${_selectedPackage!['name']} booked',
      'Service',
    );

    final booking = PrototypeBooking(
      id: 'bk-srv-${DateTime.now().millisecondsSinceEpoch}',
      title: '${_selectedPackage!['name']} Reservation',
      type: 'Service',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      details: 'Location: ${_selectedCenter!['name']} • Reserved',
      status: 'Active',
      cost: cost,
    );

    ref.read(bookingsInteractiveProvider.notifier).addBooking(booking);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Service Scheduled!'),
        content: Text('Maintenance appointment registered at "${_selectedCenter!['name']}" for tomorrow. Confirmation details are stored under Bookings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Perfect'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Centers'),
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

                // Center selector
                const Text('Choose Workshop Location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _serviceCenters.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final center = _serviceCenters[index];
                    final isSel = _selectedCenter?['id'] == center['id'];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCenter = center),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                            width: isSel ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.home_repair_service, color: AppColors.primary, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(center['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  Text('${center['location']} • Hours: ${center['hours']}', style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(center['distance'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 12),
                                    Text(center['rating'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Maintenance Package Selector
                const Text('Select Maintenance Package', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _maintenancePackages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pack = _maintenancePackages[index];
                    final isSel = _selectedPackage?['name'] == pack['name'];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPackage = pack),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                            width: isSel ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(pack['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('₹${(pack['price'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 14.5)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(pack['details'] as String, style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, height: 1.35)),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Estimated Duration', style: TextStyle(fontSize: 10.5, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                Text(pack['duration'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Action booking
                if (_selectedCenter != null && _selectedPackage != null) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _bookServiceCenter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Schedule Service Center Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
