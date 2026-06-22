import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/interactive_providers.dart';
import '../../widgets/section_header.dart';
import '../../models/transaction.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _showAddMoneyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Add Funds', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹ INR)'),
              ),
              const SizedBox(height: 12),
              const Text('Using linked card ending in **** 4242', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _amountController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final double amount = double.tryParse(_amountController.text) ?? 0.0;
                if (amount > 0) {
                  ref.read(walletInteractiveProvider.notifier).addMoney(amount, 'Visa **** 4242');
                  _amountController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ₹${amount.toStringAsFixed(2)} successfully!')));
                }
              },
              child: const Text('Top-Up'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Transfer Money', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _recipientController, decoration: const InputDecoration(labelText: 'Recipient Name')),
              TextField(controller: _accountController, decoration: const InputDecoration(labelText: 'Account / Card Number')),
              TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹ INR)')),
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
                final double amount = double.tryParse(_amountController.text) ?? 0.0;
                if (amount > 0 && _recipientController.text.isNotEmpty) {
                  final success = ref.read(walletInteractiveProvider.notifier).transferMoney(
                    amount,
                    _recipientController.text,
                    _accountController.text,
                  );
                  if (success) {
                    _clearInputs();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transferred ₹${amount.toStringAsFixed(2)} to ${_recipientController.text}')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient balance.'), backgroundColor: AppColors.error));
                  }
                }
              },
              child: const Text('Transfer'),
            ),
          ],
        );
      },
    );
  }

  void _clearInputs() {
    _amountController.clear();
    _recipientController.clear();
    _accountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletState = ref.watch(walletInteractiveProvider);
    final txs = walletState.transactions;

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: Icon(
                  Icons.menu,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        title: const Text('Fintech Wallet'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.darkCard,
                  title: const Text('Mock QR Scanner'),
                  content: const Text('Simulating QR reader camera... Alignment lock established.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 96.0), // Padding bottom for floating navigation bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                
                // Fintech Card
                _buildFintechCard(context, walletState),
                
                const SizedBox(height: 24),
                
                // Quick Actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFintechActionItem(context, 'Add Money', Icons.add, () => _showAddMoneyDialog(context)),
                    _buildFintechActionItem(context, 'Transfer', Icons.send, () => _showTransferDialog(context)),
                    _buildFintechActionItem(context, 'Claim Cashback', Icons.price_check, () {
                      if (walletState.cashback > 0) {
                        ref.read(walletInteractiveProvider.notifier).claimCashback();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cashback claimed!')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No cashback available to claim.')));
                      }
                    }),
                    _buildFintechActionItem(context, 'Analytics', Icons.bar_chart, () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.darkCard,
                          title: const Text('Spending Analytics'),
                          content: const Text('Monthly Category breakdown:\n• Rides: 35%\n• Rentals: 45%\n• Store Upgrades: 20%'),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                        ),
                      );
                    }),
                  ],
                ),
                
                const SizedBox(height: 28),
                
                // Coupons list
                const SectionHeader(title: 'Active Promo Coupons'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCouponChip('FUEL5', '5% Off Fuel Upgrades'),
                      _buildCouponChip('RIDESAFE', 'Free Emergency Assist'),
                      _buildCouponChip('SUPERCOMMUTE', '₹500 Off airport taxis'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                
                // Transaction Timeline
                const SectionHeader(title: 'Transaction Timeline'),
                const SizedBox(height: 14),
                _buildTransactionTimeline(context, txs, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFintechCard(BuildContext context, WalletState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Super App Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Gold Elite',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              '₹${state.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 38,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Available Balance',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardStat('Rewards Points', '${state.points} pts'),
                _buildCardStat('Cashback Available', '+₹${state.cashback.toStringAsFixed(2)}'),
                const Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFintechActionItem(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponChip(String code, String desc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coupon code "$code" copied!')));
                },
                child: const Icon(Icons.copy, size: 10, color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTransactionTimeline(BuildContext context, List<Transaction> list, bool isDark) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text('No transactions registered.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = list[index];
        final amountText = '${tx.isCredit ? '+' : '-'}₹${tx.amount.toStringAsFixed(2)}';
        final amountColor = tx.isCredit ? Colors.green : AppColors.error;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: amountColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tx.category,
                      style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Text(
                amountText,
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
