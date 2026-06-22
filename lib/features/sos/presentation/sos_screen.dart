import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/interactive_map.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  String _activeTab = 'Assistance'; // Assistance, Hospitals, Guidelines
  bool _isDialing = false;
  String _dialStatus = 'Initiating Emergency Link...';

  final List<Map<String, dynamic>> _hospitals = [
    {'name': 'Manipal Hospital Indiranagar', 'distance': '1.3 km', 'address': '98, HAL Old Airport Rd, Kodihalli, Bengaluru', 'phone': '080-2502-4444', 'eta': '6 mins'},
    {'name': 'St. John\'s Medical College Hospital', 'distance': '3.8 km', 'address': 'Sarjapur Main Rd, John Nagar, Koramangala, Bengaluru', 'phone': '080-2206-5000', 'eta': '11 mins'},
  ];

  void _triggerEmergencyCall() {
    setState(() {
      _isDialing = true;
      _dialStatus = 'Dialing Emergency Dispatcher...';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _dialStatus = 'Line Open • Sending GPS Telemetry...';
        });
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _dialStatus = 'Operator Connected. Talk now.';
        });
      }
    });
  }

  void _dispatchRoadside(String serviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text('$serviceName Confirmed'),
        content: const Text('Emergency support crew is dispatched to your active GPS coordinates. Expect an SMS route tracking link in 2 minutes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Understood'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS Hub'),
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
          onPressed: () {
            if (_isDialing) {
              setState(() {
                _isDialing = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: _isDialing ? _buildCallingLayout(isDark) : _buildHubLayout(isDark),
      ),
    );
  }

  Widget _buildHubLayout(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Glowing Panic button
          Center(
            child: GestureDetector(
              onTap: _triggerEmergencyCall,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: AppColors.sosGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.error.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.emergency, color: Colors.white, size: 48),
                      SizedBox(height: 8),
                      Text('TAP SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu Tabs
          Row(
            children: ['Assistance', 'Hospitals', 'Guidelines'].map((tab) {
              final isSel = _activeTab == tab;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ChoiceChip(
                    label: Text(tab, style: const TextStyle(fontSize: 11)),
                    selected: isSel,
                    onSelected: (val) {
                      setState(() {
                        _activeTab = tab;
                      });
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 24),

          // Selected tab views
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildSelectedTabContent(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(bool isDark) {
    if (_activeTab == 'Hospitals') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: InteractiveMapWidget(
              mode: 'SOS',
              onLocationSelected: (lat, lng, address) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hospital GPS set to: $address')));
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text('Closest Trauma Facilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _hospitals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final hosp = _hospitals[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_hospital, color: AppColors.error, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hosp['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text(hosp['address'] as String, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(hosp['distance'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        Text('ETA: ${hosp['eta']}', style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }

    if (_activeTab == 'Guidelines') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuidelineItem('In Event of Collision', '1. Turn hazard flashers on.\n2. Safely exit vehicle if possible.\n3. Take photos of license plates and contact local police via dialer.', isDark),
          const SizedBox(height: 12),
          _buildGuidelineItem('Flat Tire Protocol', '1. Move vehicle fully onto hard shoulder.\n2. Engage emergency electronic brake.\n3. Request "Flat Tire Towing Dispatch" below.', isDark),
        ],
      );
    }

    // Default Roadside Assistance dispatches
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Roadside Assistance Support', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDispatchRow('Flat Tire Towing', 'Flat tire replacement and towing dispatch', Icons.car_crash, isDark),
        const SizedBox(height: 12),
        _buildDispatchRow('Battery Jumpstart', 'Emergency auxiliary jumpstart kit', Icons.flash_on, isDark),
        const SizedBox(height: 12),
        _buildDispatchRow('Fuel / Charge Refill', 'Emergency charging cell delivery', Icons.local_gas_station, isDark),
      ],
    );
  }

  Widget _buildDispatchRow(String title, String desc, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                Text(desc, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _dispatchRoadside(title),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(horizontal: 14)),
            child: const Text('Call', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String title, String desc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.error)),
          const Divider(height: 16),
          Text(desc, style: const TextStyle(fontSize: 12.5, height: 1.45)),
        ],
      ),
    );
  }

  Widget _buildCallingLayout(bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkBg : Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Audio Call Waveform simulator
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_in_talk, color: AppColors.error, size: 64),
          ),
          const SizedBox(height: 32),
          const Text('EMERGENCY SOS LINK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.error, letterSpacing: 2.0)),
          const SizedBox(height: 12),
          Text(
            _dialStatus,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Coordinates: Lat 12.9716, Lng 77.5946', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
          const Spacer(),
          SizedBox(
            width: 200,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isDialing = false;
                });
              },
              icon: const Icon(Icons.call_end, color: Colors.white),
              label: const Text('End SOS Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
            ),
          ),
        ],
      ),
    );
  }
}
