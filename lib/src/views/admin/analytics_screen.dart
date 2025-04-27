// screens/admin/analytics_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/models/user_model.dart';

import 'package:gam3ya/src/widgets/common/error_widget.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_provider.dart';
import '../../controllers/gam3ya_provider.dart';
import '../../controllers/payment_provider.dart';
import '../../models/enum_models.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _startDate;
  late DateTime _endDate;
  String _timeRange = 'month'; // 'week', 'month', 'year'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize date range for analytics (default: last month)
    _endDate = DateTime.now();
    _startDate = DateTime(_endDate.year, _endDate.month - 1, _endDate.day);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateTimeRange(String range) {
    setState(() {
      _timeRange = range;
      _endDate = DateTime.now();
      
      switch (range) {
        case 'week':
          _startDate = _endDate.subtract(const Duration(days: 7));
          break;
        case 'month':
          _startDate = DateTime(_endDate.year, _endDate.month - 1, _endDate.day);
          break;
        case 'quarter':
          _startDate = DateTime(_endDate.year, _endDate.month - 3, _endDate.day);
          break;
        case 'year':
          _startDate = DateTime(_endDate.year - 1, _endDate.month, _endDate.day);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersData = ref.watch(allUsersProvider);
    final gam3yasData = ref.watch(gam3yasProvider);
    final paymentsData = ref.watch(allPaymentsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Gam3yas'),
            Tab(text: 'Payments'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Select time range',
            onSelected: _updateTimeRange,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('Last Week'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('Last Month'),
              ),
              const PopupMenuItem(
                value: 'quarter',
                child: Text('Last Quarter'),
              ),
              const PopupMenuItem(
                value: 'year',
                child: Text('Last Year'),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(usersData, gam3yasData, paymentsData as AsyncValue<List<Map<String, dynamic>>>),
          _buildUsersTab(usersData),
          _buildGam3yasTab(gam3yasData),
          _buildPaymentsTab(paymentsData as AsyncValue<List<Map<String, dynamic>>>),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    AsyncValue<List<User>> usersData,
    AsyncValue<List<Gam3ya>> gam3yasData,
    AsyncValue<List<Map<String, dynamic>>> paymentsData,
  ) {
    return usersData.when(
      data: (users) {
        return gam3yasData.when(
          data: (gam3yas) {
            return paymentsData.when(
              data: (payments) {
                return _buildOverviewContent(users, gam3yas, payments);
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => ErrorDisplayWidget(
                message: error.toString(),
                onRetry: () => ref.refresh(allPaymentsProvider),
              ),
            );
          },
          loading: () => const LoadingIndicator(),
          error: (error, stack) => ErrorDisplayWidget(
            message: error.toString(),
            onRetry: () => ref.refresh(gam3yasProvider),
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorDisplayWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(allUsersProvider),
      ),
    );
  }

  Widget _buildOverviewContent(
    List<User> users, 
    List<Gam3ya> gam3yas, 
    List<Map<String, dynamic>> payments
  ) {
    // Filter data based on selected date range
    final filteredGam3yas = gam3yas.where((g) => 
      g.startDate.isAfter(_startDate) && g.startDate.isBefore(_endDate)
    ).toList();
    
    final filteredPayments = payments.where((p) => 
      DateTime.parse(p['paymentDate']).isAfter(_startDate) && 
      DateTime.parse(p['paymentDate']).isBefore(_endDate)
    ).toList();
    
    // Calculate statistics
    final newUsers = users.where((u) => 
      DateTime.parse(u.id.substring(0, 10)).isAfter(_startDate) && 
      DateTime.parse(u.id.substring(0, 10)).isBefore(_endDate)
    ).length;
    
    final totalActive = gam3yas.where((g) => g.status == Gam3yaStatus.active).length;
    final totalCompleted = gam3yas.where((g) => g.status == Gam3yaStatus.completed).length;
    
    final totalPaymentAmount = filteredPayments.fold<double>(
      0, (sum, payment) => sum + (payment['amount'] as double)
    );

    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 20),
          
          // Stats cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                'Total Users', 
                users.length.toString(),
                Icons.people,
                Colors.blue,
              ),
              _buildStatCard(
                'New Users', 
                newUsers.toString(),
                Icons.person_add,
                Colors.green,
              ),
              _buildStatCard(
                'Active Gam3yas', 
                totalActive.toString(),
                Icons.loop,
                Colors.orange,
              ),
              _buildStatCard(
                'Total Payments', 
                formatter.format(totalPaymentAmount),
                Icons.payment,
                Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Gam3ya status chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gam3ya Status Distribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildGam3yaStatusChart(gam3yas),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment activity chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildPaymentActivityChart(filteredPayments),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent activity
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentActivityList(filteredGam3yas, filteredPayments, users),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Analytics from ${DateFormat('MMM d, yyyy').format(_startDate)} to ${DateFormat('MMM d, yyyy').format(_endDate)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGam3yaStatusChart(List<Gam3ya> gam3yas) {
    final pending = gam3yas.where((g) => g.status == Gam3yaStatus.pending).length;
    final active = gam3yas.where((g) => g.status == Gam3yaStatus.active).length;
    final completed = gam3yas.where((g) => g.status == Gam3yaStatus.completed).length;
    final rejected = gam3yas.where((g) => g.status == Gam3yaStatus.rejected).length;
    final cancelled = gam3yas.where((g) => g.status == Gam3yaStatus.cancelled).length;
    
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: pending.toDouble(),
                  title: 'Pending',
                  color: Colors.amber,
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: active.toDouble(),
                  title: 'Active',
                  color: Colors.green,
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: completed.toDouble(),
                  title: 'Completed',
                  color: Colors.blue,
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: rejected.toDouble(),
                  title: 'Rejected',
                  color: Colors.red,
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: cancelled.toDouble(),
                  title: 'Cancelled',
                  color: Colors.grey,
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem('Pending', Colors.amber, pending),
            _buildLegendItem('Active', Colors.green, active),
            _buildLegendItem('Completed', Colors.blue, completed),
            _buildLegendItem('Rejected', Colors.red, rejected),
            _buildLegendItem('Cancelled', Colors.grey, cancelled),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$label ($count)'),
        ],
      ),
    );
  }

  Widget _buildPaymentActivityChart(List<Map<String, dynamic>> payments) {
    // Group payments by date
    final groupedPayments = <String, double>{};
    
    for (final payment in payments) {
      final date = DateFormat('MMM d').format(DateTime.parse(payment['paymentDate']));
      final amount = payment['amount'] as double;
      
      if (groupedPayments.containsKey(date)) {
        groupedPayments[date] = groupedPayments[date]! + amount;
      } else {
        groupedPayments[date] = amount;
      }
    }
    
    // Create chart data
    final List<FlSpot> spots = [];
    final List<String> labels = [];
    
    // Sort dates
    final sortedDates = groupedPayments.keys.toList()
      ..sort((a, b) => DateFormat('MMM d').parse(a).compareTo(DateFormat('MMM d').parse(b)));
    
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      spots.add(FlSpot(i.toDouble(), groupedPayments[date]!));
      labels.add(date);
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(
    List<Gam3ya> gam3yas,
    List<Map<String, dynamic>> payments,
    List<User> users
  ) {
    // Create a list of activities (both gam3yas and payments) sorted by date
    final List<Map<String, dynamic>> activities = [];
    
    // Add gam3yas
    for (final gam3ya in gam3yas) {
      final user = users.firstWhere(
        (u) => u.id == gam3ya.creatorId,
        orElse: () => User(id: '', name: 'Unknown', email: '', phone: ''),
      );
      
      activities.add({
        'date': gam3ya.startDate,
        'type': 'gam3ya',
        'title': 'New Gam3ya: ${gam3ya.name}',
        'subtitle': 'Created by ${user.name}',
        'icon': Icons.group_add,
        'color': Colors.blue,
      });
    }
    
    // Add payments
    for (final payment in payments) {
      final user = users.firstWhere(
        (u) => u.id == payment['userId'],
        orElse: () => User(id: '', name: 'Unknown', email: '', phone: ''),
      );
      
      activities.add({
        'date': DateTime.parse(payment['paymentDate']),
        'type': 'payment',
        'title': 'Payment of \$${payment['amount']}',
        'subtitle': 'Paid by ${user.name}',
        'icon': Icons.payment,
        'color': Colors.green,
      });
    }
    
    // Sort by date (newest first)
    activities.sort((a, b) => b['date'].compareTo(a['date']));
    
    // Take only the most recent 10 activities
    final recentActivities = activities.take(10).toList();
    
    return recentActivities.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No recent activity in the selected period'),
            ),
          )
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentActivities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = recentActivities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: activity['color'].withOpacity(0.2),
                  child: Icon(activity['icon'], color: activity['color']),
                ),
                title: Text(activity['title']),
                subtitle: Text(activity['subtitle']),
                trailing: Text(
                  DateFormat('MMM d, h:mm a').format(activity['date']),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              );
            },
          );
  }

  Widget _buildUsersTab(AsyncValue<List<User>> usersData) {
    return usersData.when(
      data: (users) => _buildUsersAnalyticsContent(users),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorDisplayWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(allUsersProvider),
      ),
    );
  }

Widget  _buildGam3yasTab(AsyncValue<List<Gam3ya>> gam3yasData) {
    return gam3yasData.when(
      data: (gam3yas) => _buildGam3yasAnalyticsContent(gam3yas),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorDisplayWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(gam3yasProvider),
      ),
    );
  } 
  Widget _buildPaymentsTab(AsyncValue<List<Map<String, dynamic>>> paymentsData) {
    return paymentsData.when(
      data: (payments) => _buildPaymentsAnalyticsContent(payments),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorDisplayWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(allPaymentsProvider),
      ),
    );
  } 
  _buildPaymentsAnalyticsContent(List<Map<String, dynamic>> payments) {
    // Calculate payment statistics
    final totalPayments = payments.length;
    final totalAmount = payments.fold<double>(0, (sum, payment) => sum + (payment['amount'] as double));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Payments: $totalPayments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
  _buildGam3yasAnalyticsContent(List<Gam3ya> gam3yas) {
    // Calculate gam3ya statistics
    final totalGam3yas = gam3yas.length;
    final activeGam3yas = gam3yas.where((g) => g.status == Gam3yaStatus.active).length;
    final completedGam3yas = gam3yas.where((g) => g.status == Gam3yaStatus.completed).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Gam3yas: $totalGam3yas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Active Gam3yas: $activeGam3yas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Completed Gam3yas: $completedGam3yas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
  Widget _buildUsersAnalyticsContent(List<User> users) {
    // Calculate user statistics
    final totalUsers = users.length;
    final usersByRole = <UserRole, int>{};
    final usersByReputationRange = <String, int>{
      '0-50': 0,
      '51-80': 0,
      '81-90': 0,
      '91-100': 0,
    };

    for (final user in users) {
      // Count by role
      usersByRole[user.role] = (usersByRole[user.role] ?? 0) + 1;
      
      // Count by reputation score
      if (user.reputationScore <= 50) {
        usersByReputationRange['0-50'] = usersByReputationRange['0-50']! + 1;
      } else if (user.reputationScore <= 80) {
        usersByReputationRange['51-80'] = usersByReputationRange['51-80']! + 1;
      } else if (user.reputationScore <= 90) {
        usersByReputationRange['81-90'] = usersByReputationRange['81-90']! + 1;
      } else {
        usersByReputationRange['91-100'] = usersByReputationRange['91-100']! + 1;
      }
    }

    // Sort users by reputation (highest first)
    final sortedUsers = List<User>.from(users)
      ..sort((a, b) => b.reputationScore.compareTo(a.reputationScore));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Users: $totalUsers',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          
          // User roles chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Users by Role',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildUserRolesChart(usersByRole),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // User reputation chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Users by Reputation Score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildUserReputationChart(usersByReputationRange),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Top users by reputation
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Users by Reputation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTopUsersList(sortedUsers.take(10).toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 Widget _buildTopUsersList(List<User> topUsers) {
   return ListView.builder(
     shrinkWrap: true,
     physics: const NeverScrollableScrollPhysics(),
     itemCount: topUsers.length,
     itemBuilder: (context, index) {
       final user = topUsers[index];
       return ListTile(
         leading: CircleAvatar(
           backgroundColor: Colors.blue.withOpacity(0.2),
           child: Icon(Icons.person, color: Colors.blue),
         ),
         title: Text(user.name),
         subtitle: Text('Reputation Score: ${user.reputationScore}'),
       );
     },
   );
 }
  Widget _buildUserRolesChart(Map<UserRole, int> usersByRole) {
    final List<PieChartSectionData> sections = [];
    final Map<UserRole, Color> roleColors = {
      UserRole.user: Colors.blue,
      UserRole.organizer: Colors.green,
      UserRole.moderator: Colors.orange,
      UserRole.admin: Colors.purple,
    };
    
    usersByRole.forEach((role, count) {
      sections.add(
        PieChartSectionData(
          value: count.toDouble(),
          title: role.toString().split('.').last,
          color: roleColors[role] ?? Colors.grey,
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });
    
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: usersByRole.entries
              .map((entry) => _buildLegendItem(
                    entry.key.toString().split('.').last,
                    roleColors[entry.key] ?? Colors.grey,
                    entry.value,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildUserReputationChart(Map<String, int> usersByReputationRange) {
    final List<BarChartGroupData> barGroups = [];
    final Map<String, Color> reputationColors = {
      '0-50': Colors.red,
      '51-80': Colors.orange,
      '81-90': Colors.blue,
      '91-100': Colors.green,
    };
    
    int i = 0;
    usersByReputationRange.forEach((range, count) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: reputationColors[range],
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      i++;
    });
    
    final List<String> rangeLabels = usersByReputationRange.keys.toList();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: usersByReputationRange.values
                .fold(0, (max, value) => value > max ? value : max)
                .toDouble() *
            1.2,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < rangeLabels.length) {
                  return SideTitleWidget(
                  meta: meta,
                    child: Text(
                      rangeLabels[value.toInt()],
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (rod) {
              return Colors.blueAccent;
            },
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final range = usersByReputationRange.keys.elementAt(group.x.toInt());
              return BarTooltipItem(
                '$range\n${rod.toY} users',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );}

    }