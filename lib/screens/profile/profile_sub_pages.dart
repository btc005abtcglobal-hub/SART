import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/interactive_providers.dart';

class ProfileSubPage extends ConsumerStatefulWidget {
  final String featureId;
  final String title;

  const ProfileSubPage({
    super.key,
    required this.featureId,
    required this.title,
  });

  @override
  ConsumerState<ProfileSubPage> createState() => _ProfileSubPageState();
}

class _ProfileSubPageState extends ConsumerState<ProfileSubPage> {
  // Account state
  final TextEditingController _nameController = TextEditingController(text: 'Alex Pierce');
  final TextEditingController _emailController = TextEditingController(text: 'alex.pierce@example.com');
  
  // Documents state
  final List<Map<String, String>> _docs = [
    {'name': 'Driver License', 'status': 'Verified', 'expiry': '12/2030'},
    {'name': 'Tata Nexon EV Registration', 'status': 'Verified', 'expiry': '05/2027'},
  ];

  // Support State
  final List<String> _tickets = ['Issue with Wallet Deposit Refill (Resolved)'];
  final TextEditingController _supportController = TextEditingController();

  // Feedback State
  final TextEditingController _feedbackController = TextEditingController();
  final List<Map<String, dynamic>> _featuresRequests = [
    {'title': 'Add hydrogen charging stations map layer', 'votes': 42},
    {'title': 'Track carbon offsets on ride history summary', 'votes': 18},
  ];

  // Language State
  String _activeLanguage = 'English (IN)';

  // Emergency settings State
  final TextEditingController _contactController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _supportController.dispose();
    _feedbackController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildSubPageContent(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildSubPageContent(bool isDark) {
    switch (widget.featureId) {
      case 'documents':
        return _buildDocumentsContent(isDark);
      case 'payment':
        return _buildPaymentContent(isDark);
      case 'language_country':
        return _buildLanguageContent(isDark);
      case 'help_support':
        return _buildSupportContent(isDark);
      case 'feature_suggestion':
        return _buildFeedbackContent(isDark);
      case 'ride_sharing':
        return _buildRideSharingContent(isDark);
      case 'history':
        return _buildTripHistoryContent(isDark);
      default:
        // Default Account details
        return _buildAccountContent(isDark);
    }
  }

  Widget _buildAccountContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Profile Name')),
        const SizedBox(height: 12),
        TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Profile Email')),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account details saved.')));
              Navigator.pop(context);
            },
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = _docs[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        Text('Expires: ${doc['expiry']}', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(doc['status']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _docs.add({'name': 'Vehicle Insurance Permit', 'status': 'Pending Verification', 'expiry': '10/2026'});
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock Document uploaded. Pending review.')));
          },
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Upload Document scanner / camera'),
        ),
      ],
    );
  }

  Widget _buildPaymentContent(bool isDark) {
    final wallet = ref.watch(walletInteractiveProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: wallet.paymentMethods.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final card = wallet.paymentMethods[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.credit_card, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${card['type']} •••• ${card['last4']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text('Exp: ${card['expiry']}', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                    onPressed: () => ref.read(walletInteractiveProvider.notifier).deletePaymentMethod(index),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ref.read(walletInteractiveProvider.notifier).addPaymentMethod('Visa', '1092', '04/29', 'Alex Pierce');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved new Visa Card ending in 1092.')));
          },
          child: const Text('Add Credit Card'),
        ),
      ],
    );
  }

  Widget _buildLanguageContent(bool isDark) {
    return RadioGroup<String>(
      groupValue: _activeLanguage,
      onChanged: (val) {
        setState(() {
          _activeLanguage = val ?? 'English (IN)';
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language set to: $_activeLanguage')));
      },
      child: Column(
        children: ['English (IN)', 'Hindi (HI)', 'Kannada (KN)', 'Tamil (TA)'].map((lang) {
          return RadioListTile<String>(
            title: Text(lang),
            value: lang,
            activeColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSupportContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Raise Support Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _supportController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Describe issue with transactions, coordinates or mechanics...', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            if (_supportController.text.isNotEmpty) {
              setState(() {
                _tickets.insert(0, '${_supportController.text} (Open)');
              });
              _supportController.clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support ticket raised.')));
            }
          },
          child: const Text('Submit Ticket'),
        ),
        const SizedBox(height: 24),
        const Text('Your Active Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tickets.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text(_tickets[index], style: const TextStyle(fontSize: 12.5)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeedbackContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Submit Feature Request', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _feedbackController,
          decoration: const InputDecoration(hintText: 'Suggest improvements...', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            if (_feedbackController.text.isNotEmpty) {
              setState(() {
                _featuresRequests.insert(0, {'title': _feedbackController.text, 'votes': 1});
              });
              _feedbackController.clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you! Suggestion added to votes.')));
            }
          },
          child: const Text('Add Suggestion'),
        ),
        const SizedBox(height: 24),
        const Text('Feature Votes', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _featuresRequests.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final req = _featuresRequests[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(req['title'] as String, style: const TextStyle(fontSize: 12.5))),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        req['votes'] = (req['votes'] as int) + 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                    child: Text('Vote (${req['votes']})'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRideSharingContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Driver Pooling Mode', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Allow matching your trips with other commuters along similar coordinates.'),
          value: true,
          activeThumbColor: AppColors.primary,
          onChanged: (val) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pooling is ${val ? 'enabled' : 'disabled'}.')));
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Safety Direct Alerts sharing', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Share real-time tracking links automatically with emergency contacts upon booking.'),
          value: false,
          activeThumbColor: AppColors.primary,
          onChanged: (val) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auto share is ${val ? 'enabled' : 'disabled'}.')));
          },
        ),
      ],
    );
  }

  Widget _buildTripHistoryContent(bool isDark) {
    final bookings = ref.watch(bookingsInteractiveProvider).where((b) => b.type == 'Ride').toList();
    if (bookings.isEmpty) {
      return const Center(child: Text('No trip route history logged.'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = bookings[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(Icons.navigation_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(b.dateTime.toString().split(' ')[0], style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
