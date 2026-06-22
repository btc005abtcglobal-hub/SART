import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';

class RentalScreen extends ConsumerStatefulWidget {
  const RentalScreen({super.key});

  @override
  ConsumerState<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends ConsumerState<RentalScreen> {
  String _categoryFilter = 'All'; // All, Cars, Bikes, EVs
  String _searchQuery = '';
  
  // Local active rental variables
  Map<String, dynamic>? _selectedVehicle;
  int _rentalDays = 3;
  bool _includeInsurance = true;
  String _rentalPhase = 'Catalog'; // Catalog, Details, Success

  final List<Map<String, dynamic>> _mockVehicles = [
    {
      'id': 'rent-001',
      'name': 'Tata Nexon EV',
      'category': 'EVs',
      'type': 'Car',
      'price': 2500.00,
      'range': '312 km',
      'seats': 5,
      'power': '127 hp',
      'rating': '4.9',
      'icon': Icons.bolt,
      'imageUrl': 'https://images.unsplash.com/photo-1617788138017-80ad40651399',
    },
    {
      'id': 'rent-002',
      'name': 'Ducati Panigale V4',
      'category': 'Bikes',
      'type': 'Bike',
      'price': 3500.00,
      'range': '290 km',
      'seats': 1,
      'power': '214 hp',
      'rating': '4.8',
      'icon': Icons.motorcycle,
      'imageUrl': 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87',
    },
    {
      'id': 'rent-003',
      'name': 'Mahindra XUV400 EV',
      'category': 'EVs',
      'type': 'Car',
      'price': 2800.00,
      'range': '375 km',
      'seats': 5,
      'power': '150 hp',
      'rating': '4.9',
      'icon': Icons.electric_car,
      'imageUrl': 'https://images.unsplash.com/photo-1609521263047-f8f205293f24',
    },
    {
      'id': 'rent-004',
      'name': 'BMW 3 Series',
      'category': 'Cars',
      'type': 'Car',
      'price': 4500.00,
      'range': '660 km',
      'seats': 5,
      'power': '503 hp',
      'rating': '4.7',
      'icon': Icons.directions_car,
      'imageUrl': 'https://images.unsplash.com/photo-1555215695-3004980ad54e',
    },
  ];

  void _bookVehicle() {
    if (_selectedVehicle == null) return;

    final double pricePerDay = _selectedVehicle!['price'] as double;
    double totalCost = pricePerDay * _rentalDays;
    if (_includeInsurance) {
      totalCost += 1000.00 * _rentalDays;
    }

    final walletState = ref.read(walletInteractiveProvider);
    if (walletState.balance < totalCost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Insufficient Funds'),
          content: Text('Your wallet balance (₹${walletState.balance.toStringAsFixed(2)}) is lower than total rental price (₹${totalCost.toStringAsFixed(2)}).'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    // Deduct and add booking
    ref.read(walletInteractiveProvider.notifier).deductMoney(
      totalCost,
      'Rental: ${_selectedVehicle!['name']} for $_rentalDays days',
      'Rental',
    );

    final booking = PrototypeBooking(
      id: 'bk-rent-${DateTime.now().millisecondsSinceEpoch}',
      title: '${_selectedVehicle!['name']} Rental',
      type: 'Rental',
      dateTime: DateTime.now(),
      details: 'Duration: $_rentalDays Days • Status: Reserved',
      status: 'Active',
      cost: totalCost,
    );

    ref.read(bookingsInteractiveProvider.notifier).addBooking(booking);

    setState(() {
      _rentalPhase = 'Success';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookings = ref.watch(bookingsInteractiveProvider).where((b) => b.type == 'Rental').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Rentals'),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 14),
          ),
          onPressed: () {
            if (_rentalPhase == 'Details') {
              setState(() {
                _rentalPhase = 'Catalog';
              });
            } else if (_rentalPhase == 'Success') {
              setState(() {
                _rentalPhase = 'Catalog';
                _selectedVehicle = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: _buildBody(isDark, bookings),
      ),
    );
  }

  Widget _buildBody(bool isDark, List<PrototypeBooking> bookings) {
    if (_rentalPhase == 'Success') {
      return _buildSuccessLayout(isDark);
    }
    if (_rentalPhase == 'Details') {
      return _buildDetailsLayout(isDark);
    }
    return _buildCatalogLayout(isDark, bookings);
  }

  Widget _buildCatalogLayout(bool isDark, List<PrototypeBooking> bookings) {
    // Filter vehicles
    final list = _mockVehicles.where((v) {
      final matchesCat = _categoryFilter == 'All' || v['category'] == _categoryFilter;
      final matchesSearch = v['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Search Bar & Filter chips
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
                  hintText: 'Search rental cars or bikes...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: ['All', 'Cars', 'Bikes', 'EVs'].map((cat) {
                  final isSel = _categoryFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          _categoryFilter = cat;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Grid of vehicles
            const Text('Available Fleet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (list.isEmpty)
              _buildEmptyFleet(isDark)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final vehicle = list[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVehicle = vehicle;
                        _rentalPhase = 'Details';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.5),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: Icon(vehicle['icon'] as IconData, size: 44, color: AppColors.primary),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vehicle['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('₹${(vehicle['price'] as double).toStringAsFixed(0)} / day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 12, color: Colors.amber),
                                        Text(vehicle['rating'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 28),

            // RENTAL HISTORY
            const Text('Rental Booking Logs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (bookings.isEmpty)
              _buildEmptyHistory(isDark)
            else
              _buildRentalHistoryList(bookings, isDark),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsLayout(bool isDark) {
    final v = _selectedVehicle!;
    final double pricePerDay = v['price'] as double;
    double totalCost = pricePerDay * _rentalDays;
    if (_includeInsurance) {
      totalCost += 1000.00 * _rentalDays;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Vehicle visual and specs
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(v['icon'] as IconData, size: 64, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(v['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Specs grid
            Row(
              children: [
                _buildSpecItem('Est. Range', v['range'] as String, Icons.electric_car, isDark),
                const SizedBox(width: 10),
                _buildSpecItem('Seats Count', '${v['seats']} Seats', Icons.airline_seat_recline_normal, isDark),
                const SizedBox(width: 10),
                _buildSpecItem('Traction Power', v['power'] as String, Icons.speed, isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Rent Duration Slider
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rental Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('$_rentalDays Days', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: _rentalDays.toDouble(),
                    min: 1,
                    max: 14,
                    divisions: 13,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _rentalDays = val.toInt();
                      });
                    },
                  ),
                  const Divider(height: 24),
                  CheckboxListTile(
                    title: const Text('Premium Chauffeur Insurance', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Covers liability, towing and full glass coverage (+ ₹1000/day)', style: TextStyle(fontSize: 10.5, color: AppColors.darkTextSecondary)),
                    value: _includeInsurance,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        _includeInsurance = val ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Confirm payment details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Estimation', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                    Text('₹${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ],
                ),
                SizedBox(
                  width: 180,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _bookVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Confirm Rental', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessLayout(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 24),
            const Text('Rental Booking Confirmed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(
              'Your dispatch vehicle reservation for ${_selectedVehicle!['name']} is logged successfully. Show the digital key at terminal to release the vehicle.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _rentalPhase = 'Catalog';
                    _selectedVehicle = null;
                  });
                },
                child: const Text('Back to Fleet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String val, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.secondary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.darkTextSecondary)),
            const SizedBox(height: 2),
            Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFleet(bool isDark) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Center(child: Text('No vehicles found matching filters.')),
    );
  }

  Widget _buildEmptyHistory(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
      ),
      child: const Center(child: Text('No rental history found.', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary))),
    );
  }

  Widget _buildRentalHistoryList(List<PrototypeBooking> list, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = list[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.key, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(b.details, style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${b.cost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
