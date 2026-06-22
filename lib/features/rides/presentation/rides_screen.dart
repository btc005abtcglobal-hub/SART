import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';
import '../../../widgets/interactive_map.dart';

class RidesScreen extends ConsumerStatefulWidget {
  const RidesScreen({super.key});

  @override
  ConsumerState<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends ConsumerState<RidesScreen> {
  final TextEditingController _pickupController = TextEditingController(text: "My Location (Bangalore)");
  final TextEditingController _destController = TextEditingController();
  
  String _bookingPhase = "Input"; // Input, TypeSelection, EnRoute, Arrived, Complete
  Map<String, dynamic>? _selectedRideType;
  String _activeRideId = '';
  
  final List<Map<String, dynamic>> _rideTypes = [
    {'name': 'Eco Hatchback', 'price': 150.00, 'eta': 3, 'icon': Icons.electric_car, 'desc': 'Daily compact rides'},
    {'name': 'Lux Nexon EV', 'price': 350.00, 'eta': 4, 'icon': Icons.bolt, 'desc': 'Premium electric SUV'},
    {'name': 'Super Bike', 'price': 70.00, 'eta': 2, 'icon': Icons.motorcycle, 'desc': 'Fastest solo travel'},
    {'name': 'Family Cargo SUV', 'price': 450.00, 'eta': 6, 'icon': Icons.local_shipping, 'desc': 'Spacious utility van'},
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _confirmBooking() {
    if (_selectedRideType == null) return;
    
    final cost = _selectedRideType!['price'] as double;
    final walletState = ref.read(walletInteractiveProvider);
    
    if (walletState.balance < cost) {
      // Show Error State
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Insufficient Funds', style: TextStyle(color: Colors.white)),
          content: Text('Your wallet balance (₹${walletState.balance.toStringAsFixed(2)}) is lower than the fare (₹${cost.toStringAsFixed(2)}). Please refill your wallet.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: AppColors.primary)),
            )
          ],
        ),
      );
      return;
    }

    // Deduct money & add booking
    ref.read(walletInteractiveProvider.notifier).deductMoney(
      cost,
      'Ride: ${_pickupController.text} ➔ ${_destController.text}',
      'Ride',
    );

    final bookingId = 'bk-ride-${DateTime.now().millisecondsSinceEpoch}';
    final newBooking = PrototypeBooking(
      id: bookingId,
      title: 'Premium Ride to ${_destController.text}',
      type: 'Ride',
      dateTime: DateTime.now(),
      details: 'Driver: Alexander • Plate: KA-03-MY-8820',
      status: 'Active',
      cost: cost,
      meta: {
        'pickup': _pickupController.text,
        'dest': _destController.text,
        'driver': 'Alexander Pierce',
        'eta': _selectedRideType!['eta'],
        'vehicle': _selectedRideType!['name'],
      }
    );

    ref.read(bookingsInteractiveProvider.notifier).addBooking(newBooking);

    setState(() {
      _activeRideId = bookingId;
      _bookingPhase = "EnRoute";
    });

    // Simulate arrival after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && _bookingPhase == "EnRoute") {
        setState(() {
          _bookingPhase = "Arrived";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletState = ref.watch(walletInteractiveProvider);
    final bookings = ref.watch(bookingsInteractiveProvider).where((b) => b.type == 'Ride').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rides Module'),
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

                // 1. ACTIVE BOOKING EN-ROUTE FLOWS
                if (_bookingPhase == "EnRoute" || _bookingPhase == "Arrived") ...[
                  _buildEnRouteLayout(isDark),
                ] else ...[
                  // 2. INPUT PHASE / RIDE SELECTOR
                  _buildInputPhaseLayout(isDark, walletState),
                ],

                const SizedBox(height: 28),

                // 3. RIDE HISTORY
                const Text('Recent Trips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (bookings.isEmpty)
                  _buildEmptyHistory(isDark)
                else
                  _buildHistoryList(bookings, isDark),
                  
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputPhaseLayout(bool isDark, WalletState walletState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Map Preview Container
        SizedBox(
          height: 180,
          child: InteractiveMapWidget(
            mode: 'Rides',
            onLocationSelected: (lat, lng, address) {
              setState(() {
                _destController.text = address;
                _bookingPhase = "TypeSelection";
                _selectedRideType = _rideTypes[1]; // default Lux
              });
            },
          ),
        ),
        const SizedBox(height: 20),

        // Pickup / Drop Form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _pickupController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Pickup Location',
                  prefixIcon: Icon(Icons.my_location, color: AppColors.primary),
                  border: InputBorder.none,
                ),
              ),
              const Divider(height: 1),
              TextField(
                controller: _destController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Destination Dropoff',
                  hintText: 'Enter dropoff address or tap map',
                  prefixIcon: Icon(Icons.location_on, color: AppColors.error),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && _bookingPhase == "Input") {
                    setState(() {
                      _bookingPhase = "TypeSelection";
                      _selectedRideType = _rideTypes[0];
                    });
                  } else if (val.isEmpty) {
                    setState(() {
                      _bookingPhase = "Input";
                      _selectedRideType = null;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Saved Places Quick Tags
        Wrap(
          spacing: 8,
          children: [
            _buildSavedPlaceChip('Home', 'Koramangala, Bangalore', isDark),
            _buildSavedPlaceChip('Work', 'Whitefield Tech Park', isDark),
            _buildSavedPlaceChip('Airport', 'Kempegowda Airport T2', isDark),
          ],
        ),
        const SizedBox(height: 20),

        // Type selection items
        if (_bookingPhase == "TypeSelection" && _selectedRideType != null) ...[
          const Text('Choose Ride Class', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rideTypes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final type = _rideTypes[index];
              final isSelected = _selectedRideType!['name'] == type['name'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRideType = type;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.secondary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(type['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            Text(type['desc'] as String, style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${(type['price'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                          Text('${type['eta']} mins away', style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Booking Action
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _confirmBooking,
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text('Request ${_selectedRideType!['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEnRouteLayout(bool isDark) {
    final statusText = _bookingPhase == "EnRoute" ? "Driver is coming..." : "Driver has Arrived!";
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(statusText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _bookingPhase == "EnRoute" ? Colors.amber.withValues(alpha: 0.12) : Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _bookingPhase == "EnRoute" ? 'ETA 4 Mins' : 'Outside Now',
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: _bookingPhase == "EnRoute" ? Colors.amber : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: InteractiveMapWidget(
              mode: 'Rides',
              showRoute: true,
              customDestination: _destController.text,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alexander Pierce', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        SizedBox(width: 2),
                        Text('4.9 Elite Driver', style: TextStyle(fontSize: 10.5, color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('KA-03-MY-8820', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  Text('Tata Nexon EV (Black)', style: TextStyle(fontSize: 10, color: AppColors.darkTextSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling Driver (simulated)...')));
                  },
                  icon: const Icon(Icons.call, size: 16, color: AppColors.primary),
                  label: const Text('Call Driver'),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Cancel Ride
                    ref.read(bookingsInteractiveProvider.notifier).cancelBooking(_activeRideId);
                    setState(() {
                      _bookingPhase = "Input";
                      _destController.clear();
                      _selectedRideType = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ride Cancelled and Refunded.')));
                  },
                  icon: const Icon(Icons.close, size: 16, color: Colors.white),
                  label: const Text('Cancel Ride', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlaceChip(String label, String address, bool isDark) {
    return ActionChip(
      avatar: const Icon(Icons.bookmark_border, size: 12, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 11.5)),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () {
        setState(() {
          _destController.text = address;
          _bookingPhase = "TypeSelection";
          _selectedRideType = _rideTypes[1]; // Nexon EV
        });
      },
    );
  }

  Widget _buildEmptyHistory(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          'No recent ride history found.',
          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<PrototypeBooking> bookings, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = bookings[index];
        final isCancelled = b.status == 'Cancelled';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.directions_car, color: isCancelled ? Colors.grey : AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, decoration: isCancelled ? TextDecoration.lineThrough : null)),
                    Text(b.details, style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${b.cost.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: isCancelled ? Colors.grey : AppColors.primary)),
                  Text(b.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCancelled ? AppColors.error : Colors.green)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
