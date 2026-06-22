import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';

class CarrierScreen extends ConsumerStatefulWidget {
  const CarrierScreen({super.key});

  @override
  ConsumerState<CarrierScreen> createState() => _CarrierScreenState();
}

class _CarrierScreenState extends ConsumerState<CarrierScreen> {
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  double _weight = 2.0;
  String _packageCategory = 'Document';
  String _carrierPhase = 'Input'; // Input, Tracking, Success
  String _activeTrackingNum = '';
  
  final List<String> _categories = ['Document', 'Box / Carton', 'Electronics', 'Fragile Item', 'Medicine'];

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _dispatchPackage() {
    if (_recipientNameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient name and address.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final double price = 12.0 + (_weight * 1.5);
    final walletState = ref.read(walletInteractiveProvider);

    if (walletState.balance < price) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Insufficient Funds', style: TextStyle(color: Colors.white)),
          content: Text('Insufficient balance (₹${walletState.balance.toStringAsFixed(2)}) for carrier charge (₹${price.toStringAsFixed(2)}).'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    // Deduct and book
    ref.read(walletInteractiveProvider.notifier).deductMoney(
      price,
      'Package Dispatch: $_packageCategory to ${_recipientNameController.text}',
      'Carrier',
    );

    final trackNum = 'TRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-IN';
    final booking = PrototypeBooking(
      id: trackNum,
      title: 'Package Carrier ($trackNum)',
      type: 'Carrier',
      dateTime: DateTime.now(),
      details: 'To: ${_recipientNameController.text} • Status: In Transit',
      status: 'Active',
      cost: price,
      meta: {
        'recipient': _recipientNameController.text,
        'phone': _recipientPhoneController.text,
        'address': _addressController.text,
        'weight': _weight,
        'category': _packageCategory,
        'transitStep': 1, // 0: Picked Up, 1: In Transit, 2: Out for Delivery, 3: Delivered
      }
    );

    ref.read(bookingsInteractiveProvider.notifier).addBooking(booking);

    setState(() {
      _activeTrackingNum = trackNum;
      _carrierPhase = 'Tracking';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookings = ref.watch(bookingsInteractiveProvider).where((b) => b.type == 'Carrier').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrier Module'),
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

                // 1. CARRIER ACTIVE TRACKING OR DISPATCH VIEW
                if (_carrierPhase == 'Tracking') ...[
                  _buildTrackingLayout(isDark),
                ] else ...[
                  _buildDispatchLayout(isDark),
                ],

                const SizedBox(height: 28),

                // 2. PAST SHIPMENTS LIST
                const Text('Past Deliveries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (bookings.isEmpty)
                  _buildEmptyHistory(isDark)
                else
                  _buildShipmentHistoryList(bookings, isDark),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDispatchLayout(bool isDark) {
    final double computedPrice = 12.0 + (_weight * 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dispatch Header Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('On-Demand Cargo Carrier', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('Send documents, boxes or electronics across town in under 45 minutes.', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Recipient Details Card
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
              const Text('Recipient Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              TextField(
                controller: _recipientNameController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _recipientPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Recipient Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Package classification & weight
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
              const Text('Package Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSel = _packageCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          _packageCategory = cat;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Package Weight (Est.)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('${_weight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
              Slider(
                value: _weight,
                min: 0.5,
                max: 30.0,
                divisions: 59,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _weight = val;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Price details and Dispatch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Delivery Fare', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                Text('₹${computedPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ],
            ),
            SizedBox(
              width: 180,
              height: 52,
              child: ElevatedButton(
                onPressed: _dispatchPackage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Book Dispatch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingLayout(bool isDark) {
    return Container(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tracking Active', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                  Text(_activeTrackingNum, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updating courier GPS tracking...'), duration: Duration(milliseconds: 500)));
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Timeline steps
          _buildTimelineStep('Order Registered', 'Package weight validated & paid', true, isDark),
          _buildTimelineStep('Carrier Dispatched', 'Courier Alexander en-route to pickup', true, isDark),
          _buildTimelineStep('In Transit', 'Package traveling to destination drop', false, isDark),
          _buildTimelineStep('Delivered', 'Recipient verification signoff', false, isDark),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _carrierPhase = 'Input';
                      _recipientNameController.clear();
                      _recipientPhoneController.clear();
                      _addressController.clear();
                      _weight = 2.0;
                    });
                  },
                  child: const Text('Send Another Package'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String desc, bool isDone, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? Colors.green : Colors.grey),
              ),
              child: isDone ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
            ),
            Container(
              width: 2,
              height: 40,
              color: isDone ? Colors.green : Colors.grey.withValues(alpha: 0.3),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDone ? null : Colors.grey)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ],
          ),
        ),
      ],
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
          'No parcel history found.',
          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildShipmentHistoryList(List<PrototypeBooking> bookings, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = bookings[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_shipping, color: AppColors.secondary, size: 22),
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
