import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../core/providers.dart';
import 'home/home_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import 'store/store_screen.dart';
import 'profile/profile_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(navigationProvider);
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    // Keep PageView in sync with Riverpod navigation changes
    ref.listen<int>(navigationProvider, (previous, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    final List<Widget> screens = [
      const HomeScreen(),
      const ExploreScreen(),
      const StoreScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              ref.read(navigationProvider.notifier).state = index;
            },
            physics: const NeverScrollableScrollPhysics(),
            children: screens,
          ),
          
          // Floating Bottom Navigation overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(navigationProvider.notifier).state = index;
              },
            ),
          ),
        ],
      ),
      
    );
  }
}
