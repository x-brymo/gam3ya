// screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/models/user_model.dart';

import 'package:gam3ya/src/widgets/animations/fade_animation.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_provider.dart';
import '../../controllers/gam3ya_provider.dart';
import '../../widgets/common/custom_card.dart';
import 'analytics_screen.dart';
import 'manage_gam3yas_screen.dart';
import 'manage_users_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Fetch latest data when dashboard is opened
    Future.microtask(() {
      ref.read(allUsersProvider.future);
      ref.read(gam3yasProvider.future);
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(allUsersProvider);
    final allGam3yas = ref.watch(gam3yasProvider);
    final pendingGam3yas = ref.watch(pendingGam3yasProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('لوحة التحكم الإدارية', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(allUsersProvider.future);
              ref.read(gam3yasProvider.future);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث البيانات'))
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الملخص', icon: Icon(Icons.dashboard)),
            Tab(text: 'المستخدمون', icon: Icon(Icons.people)),
            Tab(text: 'الجمعيات', icon: Icon(Icons.account_balance_wallet)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Summary Tab
          _buildSummaryTab(context, allUsers.value, allGam3yas.value, pendingGam3yas.value),
          
          // Users Tab
          const ManageUsersScreen(),
          
          // Gam3yas Tab
          const ManageGam3yasScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
          );
        },
        tooltip: 'التحليلات والإحصائيات',
        child: const Icon(Icons.insights),
      ),
    );
  }
  
  Widget _buildSummaryTab(BuildContext context, List<User>? users, List<Gam3ya>? gam3yas, List<Gam3ya>? pendingGam3yas) {
    final theme = Theme.of(context);
    
    // Calculate dashboard statistics
    final int totalUsers = users?.length ?? 0;
    final int totalGam3yas = gam3yas?.length ?? 0;
    final int activeGam3yas = gam3yas?.where((g) => g.status == Gam3yaStatus.active).length ?? 0;
    final int pendingCount = pendingGam3yas?.length ?? 0;
    
    // Calculate total money in circulation
    double totalMoneyInCirculation = 0;
    gam3yas?.where((g) => g.status == Gam3yaStatus.active).forEach((gam3ya) {
      totalMoneyInCirculation += gam3ya.amount;
    });
    
    // Format the currency amount
    final currencyFormatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 0,
    );
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(allUsersProvider.future);
        await ref.read(gam3yasProvider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص النظام',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'مرحبًا بك في لوحة التحكم الإدارية', 
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Stats Cards Row
            FadeAnimation(
              delay: Duration(milliseconds: 100),
              child: Row(
                children: [
                  _buildStatCard(
                    context, 
                    'المستخدمون',
                    totalUsers.toString(),
                    Icons.people,
                    Colors.blue,
                    () {
                      _tabController.animateTo(1);
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    context, 
                    'الجمعيات النشطة',
                    activeGam3yas.toString(),
                    Icons.account_balance_wallet,
                    Colors.green,
                    () {
                      _tabController.animateTo(2);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Second Row of Stats
            FadeAnimation(
              delay: Duration(milliseconds: 200),
              child: Row(
                children: [
                  _buildStatCard(
                    context, 
                    'طلبات قيد الانتظار',
                    pendingCount.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                    () {
                      // Navigate to pending requests view
                      _tabController.animateTo(2);
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    context, 
                    'إجمالي الجمعيات',
                    totalGam3yas.toString(),
                    Icons.account_balance,
                    Colors.purple,
                    () {
                      _tabController.animateTo(2);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Money in circulation
            FadeAnimation(
              delay:Duration(milliseconds: 300),
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'الأموال المتداولة',
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          currencyFormatter.format(totalMoneyInCirculation),
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activities
            FadeAnimation(
              delay: Duration(milliseconds: 400),
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'النشاطات الأخيرة',
                            style: theme.textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to detailed activity log
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                              );
                            },
                            child: const Text('عرض الكل'),
                          ),
                        ],
                      ),
                      const Divider(),
                      if (pendingGam3yas != null && pendingGam3yas.isNotEmpty)
                        ...pendingGam3yas.take(3).map((gam3ya) => _buildActivityItem(
                          context,
                          title: gam3ya.name,
                          subtitle: 'تم إنشاء جمعية جديدة بقيمة ${currencyFormatter.format(gam3ya.amount)}',
                          icon: Icons.add_circle,
                          iconColor: Colors.green,
                          timestamp: gam3ya.startDate,
                        )),
                      if (pendingGam3yas == null || pendingGam3yas.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('لا توجد نشاطات حديثة'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            FadeAnimation(
              delay: Duration(milliseconds: 500),
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجراءات سريعة',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildActionButton(
                            context,
                            'مراجعة الطلبات',
                            Icons.assignment,
                            () {
                              _tabController.animateTo(2);
                            },
                          ),
                          _buildActionButton(
                            context,
                            'تحليلات النظام',
                            Icons.analytics,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                              );
                            },
                          ),
                          _buildActionButton(
                            context,
                            'إعدادات النظام',
                            Icons.settings,
                            () {
                              // Navigate to system settings
                            },
                          ),
                          _buildActionButton(
                            context,
                            'تقارير',
                            Icons.summarize,
                            () {
                              // Navigate to reports
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 28),
                    const Spacer(),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required DateTime timestamp,
  }) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('dd/MM/yyyy - hh:mm a').format(timestamp);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    final theme = Theme.of(context);
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}



// widgets/animations/fade_animation.dart
// import 'package:flutter/material.dart';

// import '../../controllers/auth_provider.dart';
// import '../../controllers/gam3ya_provider.dart';
// import 'analytics_screen.dart';
// import 'manage_gam3yas_screen.dart';
// import 'manage_users_screen.dart';

// class FadeAnimation extends StatefulWidget {
//   final Widget child;
//   final double delay;
//   final Duration duration;
//   final Curve curve;

//   const FadeAnimation({
//     super.key,
//     required this.child,
//     this.delay = 0.0,
//     this.duration = const Duration(milliseconds: 500),
//     this.curve = Curves.easeOut,
//   });

//   @override
//   State<FadeAnimation> createState() => _FadeAnimationState();
// }

// class _FadeAnimationState extends State<FadeAnimation> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacityAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: widget.duration,
//     );

//     _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: widget.curve),
//     );

//     _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
//       CurvedAnimation(parent: _controller, curve: widget.curve),
//     );

//     Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
//       if (mounted) {
//         _controller.forward();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Opacity(
//           opacity: _opacityAnimation.value,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: widget.child,
//           ),
//         );
//       },
//     );
//   }
// }