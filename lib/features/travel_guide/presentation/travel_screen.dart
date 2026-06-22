import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  String _activeTab = 'Explore'; // Explore, Saved
  String _searchQuery = '';
  final List<String> _likedIds = [];

  final List<Map<String, dynamic>> _destinations = [
    {
      'id': 'tr-001',
      'title': 'Western Ghats Highway (NH-66)',
      'location': 'Konkan Coastline',
      'distance': '450 km',
      'difficulty': 'Moderate',
      'rating': '4.9',
      'stops': 'Mumbai, Ratnagiri, Panaji',
      'desc': 'Cruising along NH-66 offers breathtaking views of the Arabian Sea, lush coconut groves, and majestic waterfalls of the Western Ghats.',
      'icon': Icons.beach_access,
    },
    {
      'id': 'tr-002',
      'title': 'Manali to Leh Highway',
      'location': 'Himalayan Pass',
      'distance': '480 km',
      'difficulty': 'Hard',
      'rating': '4.8',
      'stops': 'Solang Valley, Keylong, Sarchu, Leh',
      'desc': 'A high-altitude mountain route with sweeping vistas, sharp hairpin curves, and extreme elevations. Fast-chargers are located at major transit checkpoints.',
      'icon': Icons.landscape,
    },
    {
      'id': 'tr-003',
      'title': 'Nashik Vineyard Trail',
      'location': 'Wine Capital Loop',
      'distance': '140 km',
      'difficulty': 'Easy',
      'rating': '4.7',
      'stops': 'Sula Vineyards, Gangapur Dam, Someshwar',
      'desc': 'A smooth, pleasant cruise through rolling vineyard hills, beautiful lake viewpoints, and local farm resorts in India\'s wine country.',
      'icon': Icons.wine_bar,
    },
  ];

  void _toggleLike(String id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_likedIds.contains(id) ? 'Added to Saved Drives' : 'Removed from Saved Drives'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openDetails(Map<String, dynamic> route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(route['location'] as String, style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Icon(route['icon'] as IconData, size: 28, color: AppColors.primary),
                ],
              ),
              const Divider(height: 28),
              const Text('Route Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(route['desc'] as String, style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              const SizedBox(height: 20),
              
              const Text('Scenic Stops En-Route', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pin_drop, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(route['stops'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  _buildSpecBlock('Distance', route['distance'] as String, isDark),
                  const SizedBox(width: 10),
                  _buildSpecBlock('Difficulty', route['difficulty'] as String, isDark),
                  const SizedBox(width: 10),
                  _buildSpecBlock('Rating', '${route['rating']} Stars', isDark),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Starting GPS route preview for: ${route['title']}')));
                  },
                  icon: const Icon(Icons.explore_outlined, color: Colors.white),
                  label: const Text('Start Route Preview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecBlock(String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.darkTextSecondary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter list
    final filtered = _destinations.where((d) {
      final matchesSearch = d['title'].toLowerCase().contains(_searchQuery.toLowerCase()) || d['location'].toLowerCase().contains(_searchQuery.toLowerCase());
      if (_activeTab == 'Saved') {
        return matchesSearch && _likedIds.contains(d['id']);
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scenic Guides'),
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

              // Search Guide
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
                    hintText: 'Search destinations, parks, trails...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'Explore'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: _activeTab == 'Explore' ? AppColors.primary : Colors.transparent, width: 2.0)),
                        ),
                        child: Text('Explore Drives', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: _activeTab == 'Explore' ? AppColors.primary : Colors.grey)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'Saved'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: _activeTab == 'Saved' ? AppColors.primary : Colors.transparent, width: 2.0)),
                        ),
                        child: Text('Saved Drives (${_likedIds.length})', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: _activeTab == 'Saved' ? AppColors.primary : Colors.grey)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Drives Feed
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final route = filtered[index];
                          final isLiked = _likedIds.contains(route['id']);
                          return Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(route['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                            const SizedBox(height: 2),
                                            Text(route['location'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.secondary)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(isLiked ? Icons.bookmark : Icons.bookmark_border, color: AppColors.primary),
                                        onPressed: () => _toggleLike(route['id']),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    route['desc'] as String,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.route_outlined, size: 14, color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text(route['distance'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () => _openDetails(route),
                                        child: const Text('View Guide ➔', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
          Icon(Icons.explore_off_outlined, size: 48, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          const SizedBox(height: 12),
          Text(
            _activeTab == 'Saved' ? 'No bookmarked scenic guides yet.' : 'No destinations found.',
            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
