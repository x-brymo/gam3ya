// screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/constants/routes.dart';
import 'package:gam3ya/src/controllers/user_provider.dart'
    show userStatsProvider;
import 'package:gam3ya/src/models/payment_model.dart';
import 'package:gam3ya/src/models/user_model.dart';

import 'package:gam3ya/src/widgets/animations/slide_animation.dart';
import 'package:gam3ya/src/widgets/common/error_widget.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:gam3ya/src/widgets/gam3ya/gam3ya_card.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_provider.dart';
import '../../controllers/gam3ya_provider.dart';
import '../../controllers/payment_provider.dart';
import '../../models/enum_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userGam3yas = ref.watch(userGam3yasProvider);
    final upcomingPayments = ref.watch(upcomingPaymentsProvider(user.id));
    final userStats = ref.watch(userStatsProvider(user.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(userGam3yasProvider);
        ref.refresh(upcomingPaymentsProvider(user.id));
        ref.refresh(userStatsProvider(user.id));
      },
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            automaticallyImplyLeading: false,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'مرحباً ${user.name.split(' ').first ?? 'بك'}',
                //style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(52), bottomRight: Radius.circular(52)),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Show search dialog
                  showSearch(
                    context: context,
                    delegate: Gam3yaSearchDelegate(),
                  );
                },
              ),
              
              IconButton(
                icon: const Icon(Icons.new_releases_rounded),
                onPressed: () {
                  // Show search dialog
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text(
                            'قريبا كل الاخبار الجديده داخل التطبيق',
                          ),
                          content: const Text('تبعونا'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("نعم"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("لا"),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),

          // User Stats
          SliverToBoxAdapter(
            child: SlideAnimation(
              delay: Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: userStats.when(
                  data: (stats) {
                    return _buildStatsCards(context, stats!);
                  },
                  error: (Object error, StackTrace stackTrace) {
                    return ErrorDisplayWidget(
                      message: 'حدث خطأ أثناء تحميل الإحصائيات',
                      onRetry: () => ref.refresh(userStatsProvider(user.id)),
                    );
                  },
                  loading: () {
                    return const LoadingIndicator();
                  },
                ),
              ),
            ),
          ),

          // Upcoming Payments
          SliverToBoxAdapter(
            child: SlideAnimation(
              delay: Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المدفوعات القادمة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.gam3yaList);
                          },
                          child: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    upcomingPayments.when(
                      data: (payments) {
                        if (payments.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'لا توجد مدفوعات قادمة',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return _buildUpcomingPayments(context, payments);
                      },
                      loading: () => const LoadingIndicator(),
                      error:
                          (error, stackTrace) => ErrorDisplayWidget(
                            message: 'حدث خطأ أثناء تحميل المدفوعات',
                            onRetry:
                                () => ref.refresh(
                                  upcomingPaymentsProvider as Refreshable<void>,
                                ),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Active Gam3yas
          SliverToBoxAdapter(
            child: SlideAnimation(
              delay: Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'جمعياتي النشطة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.gam3yaList);
                          },
                          child: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    userGam3yas.when(
                      data: (gam3yas) {
                        final activeGam3yas =
                            gam3yas
                                .where((g) => g.status == Gam3yaStatus.active)
                                .toList();

                        if (activeGam3yas.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'لا توجد جمعيات نشطة',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: activeGam3yas.length,
                            itemBuilder: (context, index) {
                              final gam3ya = activeGam3yas[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: SizedBox(
                                  width: 300,
                                  child: Gam3yaCard(
                                    gam3ya: gam3ya,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.gam3yaDetail,
                                        arguments: gam3ya.id,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const LoadingIndicator(),
                      error:
                          (error, stackTrace) => ErrorDisplayWidget(
                            message: 'حدث خطأ أثناء تحميل الجمعيات',
                            onRetry: () => ref.refresh(userGam3yasProvider),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, User stats) {
    final stateData =
        stats.statusLife!.isNotEmpty ? stats.statusLife!.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatItem(
                  context,
                  'نقاط السمعة',
                  '${stats.reputationScore}',
                  Icons.star,
                  Colors.amber,
                ),
                _buildStatItem(
                  context,
                  'جمعيات نشطة',
                  stateData?.activeGam3yas ?? 'غير متاح',
                  Icons.group,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  context,
                  'مستحقات شهرية',
                  '${stateData != null ? NumberFormat("#,###").format(int.tryParse(stateData.monthlyDue) ?? 0) : 'غير متاح'} ج.م',
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'دخل متوقع',
                  '${stateData != null ? NumberFormat("#,###").format(int.tryParse(stateData.expectedIncome) ?? 0) : 'غير متاح'} ج.م',
                  Icons.monetization_on,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPayments(
    BuildContext context,
    List<Gam3yaPayment> payments,
  ) {
    return Column(
      children:
          payments.take(3).map((payment) {
            final DateTime dueDate = payment.paymentDate;
            final bool isLate = dueDate.isBefore(DateTime.now());
            final daysLeft = dueDate.difference(DateTime.now()).inDays;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        isLate
                            ? Colors.red.withOpacity(0.1)
                            : daysLeft <= 3
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isLate
                          ? Icons.warning
                          : daysLeft <= 3
                          ? Icons.access_time
                          : Icons.calendar_today,
                      color:
                          isLate
                              ? Colors.red
                              : daysLeft <= 3
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
                //title: Text(),
                subtitle: Text(
                  isLate
                      ? 'متأخر بـ ${-daysLeft} يوم'
                      : daysLeft == 0
                      ? 'اليوم'
                      : 'متبقي $daysLeft يوم',
                  style: TextStyle(
                    color:
                        isLate
                            ? Colors.red
                            : daysLeft <= 3
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
                trailing: Text(
                  '${NumberFormat("#,###").format(payment.amount)} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/payments/pay',
                    arguments: payment,
                  );
                },
              ),
            );
          }).toList(),
    );
  }
}

class Gam3yaSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isEmpty
        ? const Center(child: Text('ابحث عن جمعية باسمها أو وصفها'))
        : _buildSearchResults(context, query);
  }

  Widget _buildSearchResults(BuildContext context, String query) {
    return Consumer(
      builder: (context, ref, child) {
        final searchResults = ref.watch(searchGam3yasProvider(query));

        return searchResults.when(
          data: (results) {
            if (results.isEmpty) {
              return const Center(child: Text('لا توجد نتائج'));
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final gam3ya = results[index];
                return ListTile(
                  title: Text(gam3ya.name),
                  subtitle: Text(gam3ya.description),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      gam3ya.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/gam3ya-details',
                      arguments: gam3ya.id,
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('حدث خطأ: $error')),
        );
      },
    );
  }
}
