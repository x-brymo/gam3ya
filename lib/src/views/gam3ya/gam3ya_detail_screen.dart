// gam3ya/gam3ya_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';

import 'package:gam3ya/src/widgets/common/custom_button.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:gam3ya/src/widgets/gam3ya/payment_card.dart';
import 'package:gam3ya/src/widgets/gam3ya/turn_calendar.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_provider.dart';
import '../../controllers/gam3ya_provider.dart';

class Gam3yaDetailScreen extends ConsumerStatefulWidget {
  final String gam3yaId;

  const Gam3yaDetailScreen({Key? key, required this.gam3yaId})
    : super(key: key);

  @override
  ConsumerState<Gam3yaDetailScreen> createState() => _Gam3yaDetailScreenState();
}

class _Gam3yaDetailScreenState extends ConsumerState<Gam3yaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'EGP',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load gam3ya details
    Future.microtask(
      () => ref
          .read(gam3yasNotifierProvider.notifier)
          .fetchSingleGam3ya(widget.gam3yaId),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getDurationText(Gam3yaDuration duration) {
    switch (duration) {
      case Gam3yaDuration.monthly:
        return 'شهرية';
      case Gam3yaDuration.quarterly:
        return 'ربع سنوية';
      case Gam3yaDuration.yearly:
        return 'سنوية';
    }
  }

  String _getStatusText(Gam3yaStatus status) {
    switch (status) {
      case Gam3yaStatus.pending:
        return 'قيد الانتظار';
      case Gam3yaStatus.active:
        return 'نشطة';
      case Gam3yaStatus.completed:
        return 'مكتملة';
      case Gam3yaStatus.rejected:
        return 'مرفوضة';
      case Gam3yaStatus.cancelled:
        return 'ملغاة';
    }
  }

  Color _getStatusColor(Gam3yaStatus status) {
    switch (status) {
      case Gam3yaStatus.pending:
        return Colors.orange;
      case Gam3yaStatus.active:
        return Colors.green;
      case Gam3yaStatus.completed:
        return Colors.blue;
      case Gam3yaStatus.rejected:
        return Colors.red;
      case Gam3yaStatus.cancelled:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gam3yaState = ref.watch(singleGam3yaProvider(widget.gam3yaId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الجمعية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً: مشاركة تفاصيل الجمعية')),
              );
            },
          ),
        ],
      ),
      body: gam3yaState.when(
        data: (gam3ya) {
          if (gam3ya == null) {
            return const Center(child: Text('لم يتم العثور على الجمعية'));
          }

          final isCurrentUserMember = gam3ya.members.any(
            (member) => member.userId == currentUser?.id,
          );
          final isCreator = currentUser?.id == gam3ya.creatorId;

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gam3ya.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              gam3ya.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(gam3ya.status),
                            ),
                          ),
                          child: Text(
                            _getStatusText(gam3ya.status),
                            style: TextStyle(
                              color: _getStatusColor(gam3ya.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 8),
                    Text(
                      gam3ya.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.attach_money,
                            title: 'المبلغ الإجمالي',
                            value: currencyFormat.format(gam3ya.amount),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.people,
                            title: 'عدد الأعضاء',
                            value:
                                '${gam3ya.members.length}/${gam3ya.totalMembers}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.calendar_today,
                            title: 'المدة',
                            value: _getDurationText(gam3ya.duration),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payments_outlined),
                          const SizedBox(width: 8),
                          Text(
                            'القسط الشهري: ',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currencyFormat.format(gam3ya.monthlyPayment),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                  ],
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.calendar_month), text: 'الأدوار'),
                  Tab(icon: Icon(Icons.people), text: 'الأعضاء'),
                  Tab(icon: Icon(Icons.payments), text: 'المدفوعات'),
                ],
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Turns Tab
                    TurnCalendar(
                      gam3ya: gam3ya,
                      memberNames: {
                        for (var member in gam3ya.members)
                          member.userId:
                              'User #${member.userId.substring(0, 5)}',
                      },
                      currentUserId: currentUser!.id,
                         
                    ),

                    // Members Tab (Simplified - For complete list use MembersScreen)
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: gam3ya.members.length,
                      itemBuilder: (context, index) {
                        final member = gam3ya.members[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${member.turnNumber}'),
                            ),
                            title: FutureBuilder(
                              // In a real app, fetch user details
                              future: Future.value(
                                'User #${member.userId.substring(0, 5)}',
                              ),
                              builder: (context, snapshot) {
                                return Text(snapshot.data ?? 'Loading...');
                              },
                            ),
                            subtitle: Text('الدور: ${member.turnNumber}'),
                            trailing:
                                member.hasReceivedFunds
                                    ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                    : const Icon(
                                      Icons.pending,
                                      color: Colors.orange,
                                    ),
                          ),
                        );
                      },
                    ),

                    // Payments Tab
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: gam3ya.payments.length,
                      itemBuilder: (context, index) {
                        final payment = gam3ya.payments[index];
                        return PaymentCard(payment: payment, userName: currentUser.name,);
                      },
                    ),
                  ],
                ),
              ),

              // Action Buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (!isCurrentUserMember &&
                          gam3ya.status == Gam3yaStatus.active)
                        Expanded(
                          child: CustomButton(
                            text: 'طلب الانضمام',
                            icon: Icons.person_add,
                            onPressed: () {
                              // Request to join logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إرسال طلب الانضمام'),
                                ),
                              );
                            },
                          ),
                        ),

                      if (isCurrentUserMember) ...[
                        Expanded(
                          child: CustomButton(
                            text: 'دفع القسط',
                            icon: Icons.payment,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/payment',
                                arguments: {'gam3yaId': gam3ya.id},
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'الدردشة',
                            icon: Icons.chat,
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            onPressed: () {
                              // Navigate to chat
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('قريباً: دردشة الجمعية'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      if (isCreator) ...[
                        if (!isCurrentUserMember) const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Navigate to edit screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('قريباً: تعديل الجمعية'),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => Center(child: Text('حدث خطأ: $error')),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}





// // screens/gam3ya/gam3ya_detail_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gam3ya/src/models/gam3ya_model.dart';
// import 'package:gam3ya/src/models/user_model.dart';
// import 'package:gam3ya/src/providers/auth_provider.dart';
// import 'package:gam3ya/src/providers/gam3ya_provider.dart';
// import 'package:gam3ya/src/providers/user_provider.dart';
// import 'package:gam3ya/src/widgets/animations/slide_animation.dart';
// import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
// import 'package:gam3ya/src/widgets/common/error_widget.dart';
// import 'package:gam3ya/src/widgets/gam3ya/turn_calendar.dart';
// import 'package:intl/intl.dart';

// class Gam3yaDetailScreen extends ConsumerStatefulWidget {
//   const Gam3yaDetailScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<Gam3yaDetailScreen> createState() => _Gam3yaDetailScreenState();
// }

// class _Gam3yaDetailScreenState extends ConsumerState<Gam3yaDetailScreen> {
//   final formatter = NumberFormat('#,###');
  
//   @override
//   Widget build(BuildContext context) {
//     final gam3yaId = ModalRoute.of(context)!.settings.arguments as String;
//     final gam3yaAsyncValue = ref.watch(gam3yaDetailProvider(gam3yaId));
//     final currentUser = ref.watch(currentUserProvider);
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Gam3ya Details'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.chat),
//             onPressed: () {
//               Navigator.pushNamed(context, '/chat', arguments: gam3yaId);
//             },
//           ),
//         ],
//       ),
//       body: gam3yaAsyncValue.when(
//         data: (gam3ya) {
//           // Get user's status in this gam3ya
//           final isMember = gam3ya.members.any((m) => 
//             currentUser.valueOrNull?.id == m.userId);
//           final isCreator = gam3ya.creatorId == currentUser.valueOrNull?.id;
//           final userMember = isMember 
//             ? gam3ya.members.firstWhere((m) => m.userId == currentUser.valueOrNull?.id)
//             : null;
          
//           return CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(
//                 child: _buildHeader(gam3ya),
//               ),
//               SliverToBoxAdapter(
//                 child: _buildStatusBar(gam3ya),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Card(
//                     elevation: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Description',
//                             style: Theme.of(context).textTheme.titleLarge,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(gam3ya.description),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Card(
//                     elevation: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Financial Details',
//                             style: Theme.of(context).textTheme.titleLarge,
//                           ),
//                           const SizedBox(height: 16),
//                           _buildInfoRow(
//                             'Total Amount',
//                             '${formatter.format(gam3ya.amount)} EGP',
//                             Icons.monetization_on,
//                           ),
//                           _buildInfoRow(
//                             'Monthly Payment',
//                             '${formatter.format(gam3ya.monthlyPayment)} EGP',
//                             Icons.calendar_today,
//                           ),
//                           _buildInfoRow(
//                             'Safety Fund',
//                             '${gam3ya.safetyFundPercentage}% (${formatter.format(gam3ya.safetyFundAmount)} EGP)',
//                             Icons.security,
//                           ),
//                           _buildInfoRow(
//                             'Next Payment',
//                             gam3ya.getNextPaymentDate(DateTime.now()),
//                             Icons.date_range,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Card(
//                     elevation: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Members',
//                                 style: Theme.of(context).textTheme.titleLarge,
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/gam3ya/members',
//                                     arguments: gam3yaId,
//                                   );
//                                 },
//                                 child: const Text('See All'),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           TurnCalendar(gam3ya: gam3ya),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
              
//               // User's payment section if they're a member
//               if (isMember)
//                 SliverToBoxAdapter(
//                   child: SlideAnimation(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Card(
//                         elevation: 2,
//                         color: Theme.of(context).colorScheme.primary,
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Your Details',
//                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               _buildInfoRow(
//                                 'Your Turn',
//                                 'Turn ${userMember!.turnNumber}',
//                                 Icons.person,
//                                 textColor: Colors.white,
//                               ),
//                               _buildInfoRow(
//                                 'Status',
//                                 userMember.hasReceivedFunds ? 'Received' : 'Waiting',
//                                 Icons.info,
//                                 textColor: Colors.white,
//                               ),
//                               const SizedBox(height: 16),
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.white,
//                                     foregroundColor: Theme.of(context).colorScheme.primary,
//                                   ),
//                                   onPressed: () {
//                                     Navigator.pushNamed(context, '/payment', arguments: gam3yaId);
//                                   },
//                                   child: const Text('Make Payment'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
              
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: isMember
//                       ? Column(
//                           children: [
//                             ElevatedButton(
//                               onPressed: () {
//                                 _showRequestTurnChangeDialog(context, gam3ya);
//                               },
//                               child: const Text('Request Turn Change'),
//                             ),
//                             const SizedBox(height: 8),
//                             OutlinedButton(
//                               onPressed: () {
//                                 _showLeaveGam3yaDialog(context, gam3ya);
//                               },
//                               style: OutlinedButton.styleFrom(
//                                 foregroundColor: Colors.red,
//                                 side: const BorderSide(color: Colors.red),
//                               ),
//                               child: const Text('Leave Gam3ya'),
//                             ),
//                           ],
//                         )
//                       : gam3ya.status == Gam3yaStatus.active
//                           ? ElevatedButton(
//                               onPressed: () {
//                                 _showJoinGam3yaDialog(context, gam3ya);
//                               },
//                               child: const Text('Join Gam3ya'),
//                             )
//                           : const SizedBox.shrink(),
//                 ),
//               ),
              
//               // Admin actions if user is creator
//               if (isCreator)
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Card(
//                       color: Theme.of(context).colorScheme.secondary,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Creator Actions',
//                               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.white,
//                                   foregroundColor: Theme.of(context).colorScheme.secondary,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/gam3ya/manage',
//                                     arguments: gam3yaId,
//                                   );
//                                 },
//                                 child: const Text('Manage Gam3ya'),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
                
//               // Bottom padding
//               const SliverToBoxAdapter(
//                 child: SizedBox(height: 80),
//               ),
//             ],
//           );
//         },
//         loading: () => const LoadingIndicator(),
//         error: (error, stackTrace) => CustomErrorWidget(
//           message: 'Failed to load Gam3ya details: $error',
//           onRetry: () => ref.refresh(gam3yaDetailProvider(gam3yaId)),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(Gam3ya gam3ya) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24.0),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Theme.of(context).colorScheme.primary,
//             Theme.of(context).colorScheme.secondary,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             gam3ya.name,
//             style: Theme.of(context).textTheme.displaySmall?.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               _buildCategoryChip(
//                 _getDurationText(gam3ya.duration),
//                 Icons.access_time,
//               ),
//               const SizedBox(width: 8),
//               _buildCategoryChip(
//                 _getSizeText(gam3ya.size),
//                 Icons.attach_money,
//               ),
//               const SizedBox(width: 8),
//               _buildCategoryChip(
//                 gam3ya.access == Gam3yaAccess.public ? 'Public' : 'Private',
//                 gam3ya.access == Gam3yaAccess.public ? Icons.public : Icons.lock,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBar(Gam3ya gam3ya) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       color: _getStatusColor(gam3ya.status).withOpacity(0.2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             _getStatusIcon(gam3ya.status),
//             color: _getStatusColor(gam3ya.status),
//             size: 20,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             _getStatusText(gam3ya.status),
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: _getStatusColor(gam3ya.status),
//             ),
//           ),
//           const SizedBox(width: 8),
//           const Expanded(
//             child: Divider(),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '${gam3ya.members.length}/${gam3ya.totalMembers} members',
//             style: const TextStyle(
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryChip(String label, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             color: Colors.white,
//             size: 14,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value, IconData icon, {Color? textColor}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 20,
//             color: textColor ?? Theme.of(context).colorScheme.primary,
//           ),
//           const SizedBox(width: 12),
//           Text(
//             label,
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: textColor,
//             ),
//           ),
//           const Spacer(),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: textColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getDurationText(Gam3yaDuration duration) {
//     switch (duration) {
//       case Gam3yaDuration.monthly:
//         return 'Monthly';
//       case Gam3yaDuration.quarterly:
//         return 'Quarterly';
//       case Gam3yaDuration.yearly:
//         return 'Yearly';
//     }
//   }

//   String _getSizeText(Gam3yaSize size) {
//     switch (size) {
//       case Gam3yaSize.small:
//         return 'Small';
//       case Gam3yaSize.medium:
//         return 'Medium';
//       case Gam3yaSize.large:
//         return 'Large';
//     }
//   }

//   String _getStatusText(Gam3yaStatus status) {
//     switch (status) {
//       case Gam3yaStatus.pending:
//         return 'Pending';
//       case Gam3yaStatus.active:
//         return 'Active';
//       case Gam3yaStatus.completed:
//         return 'Completed';
//       case Gam3yaStatus.rejected:
//         return 'Rejected';
//       case Gam3yaStatus.cancelled:
//         return 'Cancelled';
//     }
//   }

//   IconData _getStatusIcon(Gam3yaStatus status) {
//     switch (status) {
//       case Gam3yaStatus.pending:
//         return Icons.hourglass_empty;
//       case Gam3yaStatus.active:
//         return Icons.check_circle;
//       case Gam3yaStatus.completed:
//         return Icons.task_alt;
//       case Gam3yaStatus.rejected:
//         return Icons.cancel;
//       case Gam3yaStatus.cancelled:
//         return Icons.block;
//     }
//   }

//   Color _getStatusColor(Gam3yaStatus status) {
//     switch (status) {
//       case Gam3yaStatus.pending:
//         return Colors.orange;
//       case Gam3yaStatus.active:
//         return Colors.green;
//       case Gam3yaStatus.completed:
//         return Colors.blue;
//       case Gam3yaStatus.rejected:
//         return Colors.red;
//       case Gam3yaStatus.cancelled:
//         return Colors.grey;
//     }
//   }

//   void _showJoinGam3yaDialog(BuildContext context, Gam3ya gam3ya) {
//     int selectedTurn = 0;
//     String? guarantorId;
  
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text('Join Gam3ya'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Monthly payment: ${formatter.format(gam3ya.monthlyPayment)} EGP'),
//                 const SizedBox(height: 16),
//                 const Text('Select your preferred turn:'),
//                 const SizedBox(height: 8),
                
//                 // Turn selector
//                 SizedBox(
//                   height: 60,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: gam3ya.totalMembers,
//                     itemBuilder: (context, index) {
//                       // Check if turn is already taken
//                       final isTaken = gam3ya.members.any((m) => m.turnNumber == index + 1);
                      
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: ChoiceChip(
//                           selected: selectedTurn == index + 1,
//                           label: Text('${index + 1}'),
//                           onSelected: isTaken ? null : (selected) {
//                             setState(() {
//                               selectedTurn = selected ? index + 1 : 0;
//                             });
//                           },
//                           backgroundColor: isTaken ? Colors.grey.shade300 : null,
//                           labelStyle: TextStyle(
//                             color: isTaken ? Colors.grey : null,
//                             decoration: isTaken ? TextDecoration.lineThrough : null,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
                
//                 const SizedBox(height: 16),
//                 const Text('Add a guarantor (optional):'),
//                 const SizedBox(height: 8),
                
//                 // This would normally be a dropdown/search with actual
