import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';
import '../../../widgets/interactive_map.dart';

class ParkingScreen extends ConsumerStatefulWidget {
  const ParkingScreen({super.key});

  @override
  ConsumerState<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends ConsumerState<ParkingScreen> {
  int _selectedFloor = 1;
  String? _selectedSlot;
  int _durationHours = 2;
  String _parkingPhase = 'Selector'; // Selector, Pass, Success

  // Mock slot statuses for Floor 1, 2, 3
  final Map<int, List<Map<String, dynamic>>> _floorSlots = {
    1: [
      {'slot': 'A-101', 'status': 'Occupied', 'ev': true},
      {'slot': 'A-102', 'status': 'Available', 'ev': true},
      {'slot': 'A-103', 'status': 'Occupied', 'ev': false},
      {'slot': 'A-104', 'status': 'Available', 'ev': false},
      {'slot': 'A-105', 'status': 'Available', 'ev': false},
      {'slot': 'A-106', 'status': 'Occupied', 'ev': true},
    ],
    2: [
      {'slot': 'B-201', 'status': 'Available', 'ev': false},
      {'slot': 'B-202', 'status': 'Occupied', 'ev': false},
      {'slot': 'B-203', 'status': 'Available', 'ev': true},
      {'slot': 'B-204', 'status': 'Occupied', 'ev': false},
      {'slot': 'B-205', 'status': 'Available', 'ev': false},
      {'slot': 'B-206', 'status': 'Occupied', 'ev': false},
    ],
    3: [
      {'slot': 'C-301', 'status': 'Available', 'ev': true},
      {'slot': 'C-302', 'status': 'Available', 'ev': true},
      {'slot': 'C-303', 'status': 'Occupied', 'ev': false},
      {'slot': 'C-304', 'status': 'Available', 'ev': false},
      {'slot': 'C-305', 'status': 'Occupied', 'ev': false},
      {'slot': 'C-306', 'status': 'Available', 'ev': false},
    ],
  };

  void _reserveSlot() {
    if (_selectedSlot == null) return;

    final cost = _durationHours * 3.50;
    final walletState = ref.read(walletInteractiveProvider);

    if (walletState.balance < cost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Insufficient Funds'),
          content: Text('Your wallet balance (₹${walletState.balance.toStringAsFixed(2)}) is lower than total parking reservation cost (₹${cost.toStringAsFixed(2)}).'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    // Deduct and add booking
    ref.read(walletInteractiveProvider.notifier).deductMoney(
      cost,
      'Parking Reservation: Slot $_selectedSlot',
      'Parking',
    );

    final booking = PrototypeBooking(
      id: 'bk-park-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Reserved Spot $_selectedSlot',
      type: 'Parking',
      dateTime: DateTime.now(),
      details: 'Floor $_selectedFloor • Slot $_selectedSlot • $_durationHours Hours',
      status: 'Active',
      cost: cost,
    );

    ref.read(bookingsInteractiveProvider.notifier).addBooking(booking);

    setState(() {
      _parkingPhase = 'Pass';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookings = ref.watch(bookingsInteractiveProvider).where((b) => b.type == 'Parking').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Parking'),
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
            if (_parkingPhase == 'Pass') {
              setState(() {
                _parkingPhase = 'Selector';
                _selectedSlot = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: _parkingPhase == 'Pass' ? _buildPassLayout(isDark) : _buildSelectorLayout(isDark, bookings),
      ),
    );
  }

  Widget _buildSelectorLayout(bool isDark, List<PrototypeBooking> bookings) {
    final double cost = _durationHours * 3.50;
    final slots = _floorSlots[_selectedFloor] ?? [];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Map preview locator
            SizedBox(
              height: 150,
              child: InteractiveMapWidget(
                mode: 'Parking',
                onLocationSelected: (lat, lng, address) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected lot near: $address')));
                },
              ),
            ),
            const SizedBox(height: 20),

            // Floor levels tabs
            Row(
              children: [1, 2, 3].map((floor) {
                final isSel = _selectedFloor == floor;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFloor = floor;
                          _selectedSlot = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSel ? AppColors.primary : (isDark ? AppColors.darkCard : Colors.white),
                        side: BorderSide(color: isSel ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                      ),
                      child: Text('Floor $floor', style: TextStyle(color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black))),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Slots Grid
            const Text('Select Parking Slot', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final item = slots[index];
                final String slotName = item['slot'] as String;
                final isOccupied = item['status'] == 'Occupied';
                final isSelected = _selectedSlot == slotName;
                final isEv = item['ev'] as bool;

                return GestureDetector(
                  onTap: isOccupied
                      ? null
                      : () {
                          setState(() {
                            _selectedSlot = slotName;
                          });
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOccupied
                          ? (isDark ? Colors.red.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.05))
                          : (isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : (isDark ? AppColors.darkCard : Colors.white)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOccupied
                            ? Colors.red.withValues(alpha: 0.4)
                            : (isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5))),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(slotName, style: TextStyle(fontWeight: FontWeight.bold, color: isOccupied ? Colors.grey : null)),
                              const SizedBox(height: 4),
                              Text(isOccupied ? 'Occupied' : 'Free', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: isOccupied ? Colors.red : Colors.green)),
                            ],
                          ),
                        ),
                        if (isEv)
                          const Positioned(
                            top: 6,
                            right: 6,
                            child: Icon(Icons.bolt, size: 12, color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Duration and Reservation
            if (_selectedSlot != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Booking Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        Text('$_durationHours Hours', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ],
                    ),
                    Slider(
                      value: _durationHours.toDouble(),
                      min: 1,
                      max: 12,
                      divisions: 11,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _durationHours = val.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Cost', style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary)),
                      Text('₹${cost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                  SizedBox(
                    width: 180,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _reserveSlot,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Reserve Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 28),

            // Parking reservation history
            const Text('Reservation History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (bookings.isEmpty)
              _buildEmptyHistory(isDark)
            else
              _buildParkingHistoryList(bookings, isDark),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPassLayout(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  const Text('PARKING ACCESS PASS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text('Floor $_selectedFloor • Slot $_selectedSlot', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 18),
                  
                  // Glowing Mock QR Code
                  Container(
                    width: 160,
                    height: 160,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(140, 140),
                        painter: _MockQrPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  
                  Text('Duration: $_durationHours Hours', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Scan QR code at parking gate reader to entry.', style: TextStyle(fontSize: 10.5, color: AppColors.darkTextSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _parkingPhase = 'Selector';
                    _selectedSlot = null;
                  });
                },
                child: const Text('Back to Grid'),
              ),
            ),
          ],
        ),
      ),
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
      child: const Center(child: Text('No reservation logs found.', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary))),
    );
  }

  Widget _buildParkingHistoryList(List<PrototypeBooking> list, bool isDark) {
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
              const Icon(Icons.local_parking, color: AppColors.primary, size: 20),
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

class _MockQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    final random = Random(42); // deterministic

    // Draw standard QR corner markers
    _drawFinderPattern(canvas, 0, 0, 36);
    _drawFinderPattern(canvas, size.width - 36, 0, 36);
    _drawFinderPattern(canvas, 0, size.height - 36, 36);

    // Fill the rest with random square dot noise
    for (double x = 4; x < size.width - 4; x += 6) {
      for (double y = 4; y < size.height - 4; y += 6) {
        // Skip corner finder bounds
        final isFinderTopLeft = x < 40 && y < 40;
        final isFinderTopRight = x > size.width - 40 && y < 40;
        final isFinderBottomLeft = x < 40 && y > size.height - 40;

        if (!isFinderTopLeft && !isFinderTopRight && !isFinderBottomLeft) {
          if (random.nextBool()) {
            canvas.drawRect(Rect.fromLTWH(x, y, 4, 4), paint);
          }
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double size) {
    final paintBlack = Paint()..color = Colors.black;
    final paintWhite = Paint()..color = Colors.white;

    canvas.drawRect(Rect.fromLTWH(x, y, size, size), paintBlack);
    canvas.drawRect(Rect.fromLTWH(x + 4, y + 4, size - 8, size - 8), paintWhite);
    canvas.drawRect(Rect.fromLTWH(x + 8, y + 8, size - 16, size - 16), paintBlack);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
