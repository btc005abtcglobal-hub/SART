import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';
import '../domain/vehicle_model.dart';

class GarageScreen extends ConsumerStatefulWidget {
  const GarageScreen({super.key});

  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _odoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _amountController.dispose();
    _costController.dispose();
    _odoController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showAddVehicleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Add Linked Vehicle', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name (e.g. Nexon EV)')),
              TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model Spec (e.g. XZ+ Lux)')),
              TextField(controller: _plateController, decoration: const InputDecoration(labelText: 'License Plate (e.g. KA-03-MY-8820)')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearInputs();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _plateController.text.isNotEmpty) {
                  ref.read(garageInteractiveProvider.notifier).addVehicle(
                    _nameController.text,
                    _modelController.text,
                    _plateController.text,
                    100.0, // initial charge
                  );
                  _clearInputs();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditVehicleDialog(BuildContext context, String id, String name, String model, String plate) {
    _nameController.text = name;
    _modelController.text = model;
    _plateController.text = plate;
    
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit Vehicle Details', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model Spec')),
              TextField(controller: _plateController, decoration: const InputDecoration(labelText: 'License Plate')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearInputs();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  ref.read(garageInteractiveProvider.notifier).updateVehicle(
                    id,
                    _nameController.text,
                    _modelController.text,
                    _plateController.text,
                    88.0,
                  );
                  _clearInputs();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showLogFuelDialog(BuildContext context, String vehicleId) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Log Refill Metric', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fuel / Charge added (L / kWh)')),
              TextField(controller: _costController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Cost (₹ fee)')),
              TextField(controller: _odoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Odometer ODO (km)')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearLogs();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                final cost = double.tryParse(_costController.text) ?? 0.0;
                final odo = int.tryParse(_odoController.text) ?? 0;
                if (amount > 0 && odo > 0) {
                  ref.read(garageInteractiveProvider.notifier).addFuelLog(vehicleId, amount, cost, odo);
                  _clearLogs();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refill telemetry registered.')));
                }
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  void _clearInputs() {
    _nameController.clear();
    _modelController.clear();
    _plateController.clear();
  }

  void _clearLogs() {
    _amountController.clear();
    _costController.clear();
    _odoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final garageState = ref.watch(garageInteractiveProvider);
    final list = garageState.vehicles;
    final active = garageState.selectedVehicle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garage'),
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
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showAddVehicleDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: list.isEmpty
            ? _buildEmptyState(isDark)
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Vehicle selector lane
                      SizedBox(
                        height: 70,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final v = list[index];
                            final isSel = active?.id == v.id;
                            return GestureDetector(
                              onTap: () => ref.read(garageInteractiveProvider.notifier).selectVehicle(v),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.primary : (isDark ? AppColors.darkCard : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isSel ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5))),
                                ),
                                child: Row(
                                  children: [
                                    Icon(v.name.contains('Ducati') ? Icons.motorcycle : Icons.directions_car, color: isSel ? Colors.white : AppColors.secondary, size: 18),
                                    const SizedBox(width: 8),
                                    Text(v.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSel ? Colors.white : null)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Active Vehicle Detail Overview
                      if (active != null) ...[
                        _buildVehicleDashboard(context, active, isDark, garageState),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildVehicleDashboard(BuildContext context, VehicleModel active, bool isDark, GarageState state) {
    final isLocked = state.locks[active.id] ?? true;
    final isClimate = state.climate[active.id] ?? false;
    final logs = state.fuelLogs[active.id] ?? [];
    final notes = state.vehicleNotes[active.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Specs box details
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(active.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      Text('${active.model} • ${active.plateNumber}', style: const TextStyle(fontSize: 11.5, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                        onPressed: () => _showEditVehicleDialog(context, active.id, active.name, active.model, active.plateNumber),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        onPressed: () {
                          ref.read(garageInteractiveProvider.notifier).deleteVehicle(active.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle removed from garage.')));
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusText('Security Status', isLocked ? 'Locked' : 'Unlocked', isLocked ? Colors.green : Colors.amber),
                  _buildStatusText('HVAC Control', isClimate ? 'Climate ON' : 'Climate OFF', isClimate ? Colors.cyan : Colors.grey),
                  _buildStatusText('Odometer ODO', logs.isNotEmpty ? '${logs[0]['odometer']} km' : '12,450 km', AppColors.primary),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => ref.read(garageInteractiveProvider.notifier).toggleLock(active.id),
                      icon: Icon(isLocked ? Icons.lock_open : Icons.lock, size: 16, color: Colors.white),
                      label: Text(isLocked ? 'Unlock Vehicle' : 'Lock Vehicle', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: isLocked ? AppColors.primary : Colors.green),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(garageInteractiveProvider.notifier).toggleClimate(active.id),
                      icon: const Icon(Icons.ac_unit, size: 16),
                      label: Text(isClimate ? 'AC Climate Off' : 'AC Climate On'),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: isClimate ? AppColors.error : AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Fuel Tracker Lane
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Refill & Charge Logs', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => _showLogFuelDialog(context, active.id),
              child: const Text('Add Refill +', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (logs.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(12), child: Text('No fuel logs recorded yet.', style: TextStyle(fontSize: 12, color: Colors.grey))))
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final log = logs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Refill Mileage', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text('${log['date']} • ${log['odometer']} km', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${(log['cost'] as double).toStringAsFixed(2)} Paid', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${log['amount']} units', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        
        const SizedBox(height: 24),

        // Mechanic diagnostics Notes log
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Diagnostics & Notes Log', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                if (_noteController.text.isNotEmpty) {
                  ref.read(garageInteractiveProvider.notifier).addNote(active.id, _noteController.text);
                  _noteController.clear();
                }
              },
              child: const Text('Save Note +', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        TextField(
          controller: _noteController,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Type any diagnostic details, reminders, or garage logs...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        if (notes.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(12), child: Text('No notes links registered.', style: TextStyle(fontSize: 12, color: Colors.grey))))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(note, style: const TextStyle(fontSize: 12.5))),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 14, color: AppColors.error),
                      onPressed: () => ref.read(garageInteractiveProvider.notifier).deleteNote(active.id, index),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatusText(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_filled_outlined, size: 64, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          const SizedBox(height: 12),
          const Text('No vehicles added yet.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showAddVehicleDialog(context),
            child: const Text('Add Vehicle'),
          ),
        ],
      ),
    );
  }
}
