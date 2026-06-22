import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';

class DriversScreen extends ConsumerStatefulWidget {
  const DriversScreen({super.key});

  @override
  ConsumerState<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends ConsumerState<DriversScreen> {
  String _activeFilter = 'All'; // All, Active, Available
  String _searchQuery = '';

  final List<Map<String, dynamic>> _mockDrivers = [
    {
      'id': 'drv-1',
      'name': 'Alexander Pierce',
      'rating': '4.9',
      'trips': '1,200',
      'status': 'Available',
      'languages': 'English, Spanish',
      'rate': 18.00,
      'exp': '6 Years',
      'bio': 'Punctual, safety-certified driver specializing in luxury electric vehicles and long highway trips.',
    },
    {
      'id': 'drv-2',
      'name': 'Marcus Vance',
      'rating': '4.8',
      'trips': '850',
      'status': 'Busy',
      'languages': 'English, French',
      'rate': 15.00,
      'exp': '4 Years',
      'bio': 'Professional chauffeur and navigator focusing on city commutes, airport transfers and parking systems.',
    },
    {
      'id': 'drv-3',
      'name': 'Sophia Chen',
      'rating': '4.95',
      'trips': '2,100',
      'status': 'Available',
      'languages': 'English, Mandarin',
      'rate': 22.00,
      'exp': '8 Years',
      'bio': 'VIP security driving credential holder, highly rated for night cruises and executive event dispatch.',
    },
  ];

  void _showDriverProfile(BuildContext context, Map<String, dynamic> driver) {
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
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(driver['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text('${driver['rating']} • ${driver['trips']} Trips completed', style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              const Text('Driver Biography', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                driver['bio'] as String,
                style: TextStyle(fontSize: 12.5, height: 1.4, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  _buildStatTile('Experience', driver['exp'] as String, isDark),
                  const SizedBox(width: 10),
                  _buildStatTile('Hourly Cost', '₹${driver['rate'].toStringAsFixed(0)} / hr', isDark),
                  const SizedBox(width: 10),
                  _buildStatTile('Languages', driver['languages'] as String, isDark),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: driver['status'] == 'Busy'
                      ? null
                      : () {
                          Navigator.pop(context);
                          _hireDriver(driver);
                        },
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(driver['status'] == 'Busy' ? 'Currently Unavailable' : 'Hire Driver Now', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: driver['status'] == 'Busy' ? Colors.grey : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatTile(String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.darkTextSecondary)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  void _hireDriver(Map<String, dynamic> driver) {
    final rate = driver['rate'] as double;
    final totalCost = rate * 3; // default hire minimum 3 hours
    final walletState = ref.read(walletInteractiveProvider);

    if (walletState.balance < totalCost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Insufficient Funds'),
          content: Text('Your wallet balance (₹${walletState.balance.toStringAsFixed(2)}) is lower than 3-hour minimum deposit (₹${totalCost.toStringAsFixed(2)}).'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }

    // Deduct and book
    ref.read(walletInteractiveProvider.notifier).deductMoney(
      totalCost,
      'Hire Driver: ${driver['name']} (3 Hrs Deposit)',
      'Drivers',
    );

    final booking = PrototypeBooking(
      id: 'bk-drv-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Hired Chauffeur: ${driver['name']}',
      type: 'Mechanic', // registers under service bookings
      dateTime: DateTime.now(),
      details: 'Duration: 3 Hours • Rate: ₹${rate.toStringAsFixed(0)}/hr',
      status: 'Active',
      cost: totalCost,
    );

    ref.read(bookingsInteractiveProvider.notifier).addBooking(booking);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Driver Hired Successfully!'),
        content: Text('${driver['name']} is preparing to dispatch. They will contact you shortly to align on details.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Great'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _mockDrivers.where((d) {
      final matchesSearch = d['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      if (_activeFilter == 'Available') {
        return matchesSearch && d['status'] == 'Available';
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers On Demand'),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Search Driver
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
                    hintText: 'Search drivers by name...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filter Choice
              Row(
                children: ['All', 'Available'].map((filter) {
                  final isSel = _activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          _activeFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Drivers feed
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No drivers found matching parameters.'))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final driver = filtered[index];
                          final isAvailable = driver['status'] == 'Available';

                          return Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                                child: const Icon(Icons.person, color: Colors.white, size: 24),
                              ),
                              title: Text(driver['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 12),
                                    const SizedBox(width: 2),
                                    Text('${driver['rating']} • Rate: ₹${driver['rate'].toStringAsFixed(0)}/hr', style: const TextStyle(fontSize: 10.5)),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isAvailable ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      driver['status'] as String,
                                      style: TextStyle(
                                        fontSize: 9.5, 
                                        fontWeight: FontWeight.bold, 
                                        color: isAvailable ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                                ],
                              ),
                              onTap: () => _showDriverProfile(context, driver),
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
