import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';

class MechanicScreen extends ConsumerStatefulWidget {
  const MechanicScreen({super.key});

  @override
  ConsumerState<MechanicScreen> createState() => _MechanicScreenState();
}

class _MechanicScreenState extends ConsumerState<MechanicScreen> {
  String _activeExpertise = 'All'; // All, Engine, Electrical, Tuning
  String _searchQuery = '';

  final List<Map<String, dynamic>> _mockMechanics = [
    {
      'id': 'mech-1',
      'name': 'Dave Vance',
      'rating': '4.9',
      'expertise': 'Engine Diagnostics',
      'rate': 25.00,
      'distance': '1.0 km',
      'bio': 'ASE Certified Master Technician with 12+ years experience in luxury sedans, electric drivetrains, and full transmission overhauls.',
    },
    {
      'id': 'mech-2',
      'name': 'Clara Pierce',
      'rating': '4.8',
      'expertise': 'Electrical & ECU',
      'rate': 22.00,
      'distance': '2.0 km',
      'bio': 'Specialist in computerized vehicle diagnostics, sensor alignment, dynamic calibrations, and auxiliary battery wiring upgrades.',
    },
    {
      'id': 'mech-3',
      'name': 'Michael Chen',
      'rating': '4.95',
      'expertise': 'Tuning & Suspensions',
      'rate': 30.00,
      'distance': '1.5 km',
      'bio': 'High performance racing setup tuning, custom sports suspensions, tyre alignment balancing, and brake system overhauls.',
    },
  ];

  void _showMechanicBio(BuildContext context, Map<String, dynamic> mechanic) {
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
                    child: const Icon(Icons.build, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mechanic['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text('${mechanic['rating']} • ${mechanic['distance']} away', style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              const Text('Expert Biography', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                mechanic['bio'] as String,
                style: TextStyle(fontSize: 12.5, height: 1.4, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  _buildStatTile('Expertise', mechanic['expertise'] as String, isDark),
                  const SizedBox(width: 10),
                  _buildStatTile('Diagnostic Fee', '₹${mechanic['rate'].toStringAsFixed(0)}', isDark),
                  const SizedBox(width: 10),
                  _buildStatTile('Pro Distance', mechanic['distance'] as String, isDark),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _bookMechanic(mechanic);
                  },
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('Book Diagnostic Inspection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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

  void _bookMechanic(Map<String, dynamic> mechanic) {
    final cost = mechanic['rate'] as double;
    final walletState = ref.read(walletInteractiveProvider);

    if (walletState.balance < cost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Insufficient Funds'),
          content: Text('Your wallet balance (₹${walletState.balance.toStringAsFixed(2)}) is lower than inspection fee (₹${cost.toStringAsFixed(2)}).'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }

    // Deduct and book
    ref.read(walletInteractiveProvider.notifier).deductMoney(
      cost,
      'Mechanic Dispatch: ${mechanic['name']} Callout',
      'Mechanic',
    );

    final booking = PrototypeBooking(
      id: 'bk-mech-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Mechanic Diagnostic: ${mechanic['name']}',
      type: 'Mechanic',
      dateTime: DateTime.now().add(const Duration(hours: 1)),
      details: 'Expert: ${mechanic['name']} • Diagnostic Callout',
      status: 'Active',
      cost: cost,
    );

    ref.read(bookingsInteractiveProvider.notifier).addBooking(booking);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Mechanic Request Active!'),
        content: Text('${mechanic['name']} is dispatched. ETA is approximately 25 minutes. Telemetry status available under Bookings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Understood'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _mockMechanics.where((m) {
      final matchesSearch = m['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _activeExpertise == 'All' || m['expertise'].toLowerCase().contains(_activeExpertise.toLowerCase());
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanics Directory'),
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

              // Search Mechanic
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
                    hintText: 'Search mechanics by name or expertise...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Expertise Choice Chips
              Row(
                children: ['All', 'Engine', 'Electrical', 'Tuning'].map((filter) {
                  final isSel = _activeExpertise == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          _activeExpertise = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Mechanics directory feed
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No mechanics found matching parameters.'))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final mech = filtered[index];

                          return Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                                child: const Icon(Icons.build, color: Colors.white, size: 20),
                              ),
                              title: Text(mech['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 12),
                                    const SizedBox(width: 2),
                                    Text('${mech['rating']} • ${mech['expertise']}', style: const TextStyle(fontSize: 10.5)),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${mech['rate'].toStringAsFixed(0)} Fee', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13.5)),
                                  const SizedBox(height: 6),
                                  Text(mech['distance'] as String, style: const TextStyle(fontSize: 10, color: AppColors.darkTextSecondary)),
                                ],
                              ),
                              onTap: () => _showMechanicBio(context, mech),
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
