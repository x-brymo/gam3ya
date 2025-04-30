// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/constants/routes.dart';
import 'package:gam3ya/src/controllers/user_provider.dart';
import 'package:gam3ya/src/views/admin/admin_dashboard.dart';

import 'package:gam3ya/src/widgets/animations/fade_animation.dart';

import '../../controllers/notification_provider.dart';
import '../gam3ya/gam3ya_list_screen.dart';
import '../profile/profile_screen.dart';
import 'dashboard_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const Gam3yaListScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
   
   
  return user.when(
    data: (userData) {
      final isAdmin = userData.role.name == 'admin';

      return isAdmin ? AdminDashboard(): Scaffold(
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _screens,
          ),
        ),
        bottomNavigationBar: FadeAnimation(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'الرئيسية',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.group_outlined),
                    activeIcon: Icon(Icons.group),
                    label: 'جمعياتي',
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined),
                        if (_hasUnreadNotifications())
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    activeIcon: Stack(
                      children: [
                        const Icon(Icons.notifications),
                        if (_hasUnreadNotifications())
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: 'إشعارات',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    activeIcon: const Icon(Icons.person),
                    label: isAdmin ? 'لوحة التحكم' : 'حسابي',
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _currentIndex == 1
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.createGam3ya);
                },
                tooltip: 'إنشاء جمعية جديدة',
                child: const Icon(Icons.add),
              )
            : null,
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) {
      print("Error for err: $err");
      print("Error for stack: $stack");
    return Center(child: Text('حدث خطأ: $err'));
    }
  );
}


  bool _hasUnreadNotifications() {
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    return unreadNotifications > 0;
  }
}