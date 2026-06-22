import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String _activeFilter = 'All'; // All, Active, Past, Cancelled

  void _showBookingReceipt(BuildContext context, PrototypeBooking b) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text('Booking Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text('Type: ${b.type}', style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Date/Time:', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                  Text(b.dateTime.toString().split('.')[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Details:', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                  Text(b.details, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status:', style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
                  Text(b.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: b.status == 'Cancelled' ? AppColors.error : Colors.green)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Charges:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('₹${b.cost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.darkTextSecondary)),
            ),
            if (b.status == 'Active')
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelBookingFlow(b);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Cancel Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
          ],
        );
      },
    );
  }

  void _cancelBookingFlow(PrototypeBooking b) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Confirm Cancellation', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to cancel "${b.title}"? A full refund of ₹${b.cost.toStringAsFixed(2)} will be credited back to your Super App wallet.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep Booking')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Refund wallet
              ref.read(walletInteractiveProvider.notifier).addMoney(b.cost, 'Refund for cancelled booking');
              // Cancel booking
              ref.read(bookingsInteractiveProvider.notifier).cancelBooking(b.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Refund of ₹${b.cost.toStringAsFixed(2)} credited!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel and Refund', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String type) {
    switch (type.toLowerCase()) {
      case 'ride':
        return Icons.directions_car;
      case 'rental':
        return Icons.key;
      case 'parking':
        return Icons.local_parking;
      case 'mechanic':
        return Icons.build;
      case 'service':
        return Icons.home_repair_service;
      default:
        return Icons.confirmation_number;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allBookings = ref.watch(bookingsInteractiveProvider);

    // Apply active filter
    final filtered = allBookings.where((b) {
      if (_activeFilter == 'Active') return b.status == 'Active';
      if (_activeFilter == 'Cancelled') return b.status == 'Cancelled';
      if (_activeFilter == 'Past') return b.status == 'Completed';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings Registry'),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Filter Tabs
              Row(
                children: ['All', 'Active', 'Past', 'Cancelled'].map((filter) {
                  final isSel = _activeFilter == filter;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ChoiceChip(
                        label: Text(filter, style: const TextStyle(fontSize: 11)),
                        selected: isSel,
                        onSelected: (val) {
                          setState(() {
                            _activeFilter = filter;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Booking list view
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final b = filtered[index];
                          final isCancelled = b.status == 'Cancelled';
                          final isCompleted = b.status == 'Completed';

                          return Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCancelled 
                                      ? Colors.grey.withValues(alpha: 0.12)
                                      : (isCompleted ? Colors.green.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1)),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconData(b.type),
                                  color: isCancelled ? Colors.grey : (isCompleted ? Colors.green : AppColors.primary),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                b.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  decoration: isCancelled ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(b.details, style: const TextStyle(fontSize: 11)),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${b.cost.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: isCancelled ? Colors.grey : AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    b.status,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: isCancelled 
                                          ? AppColors.error 
                                          : (isCompleted ? Colors.green : AppColors.secondary),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _showBookingReceipt(context, b),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 48, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          const SizedBox(height: 12),
          Text(
            'No bookings matching "$_activeFilter" found.',
            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
