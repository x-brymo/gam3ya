// screens/gam3ya/gam3ya_members_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/gam3ya_provider.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/models/user_model.dart';
import 'package:gam3ya/src/widgets/animations/fade_animation.dart';
import 'package:gam3ya/src/widgets/common/error_widget.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

// import '../../controllers/auth_provider.dart';
import '../../controllers/user_provider.dart';
import '../../models/enum_models.dart';

class Gam3yaMembersScreen extends ConsumerStatefulWidget {
  const Gam3yaMembersScreen({super.key});

  static const routeName = '/gam3ya-members';

  @override
  ConsumerState<Gam3yaMembersScreen> createState() => _Gam3yaMembersScreenState();
}

class _Gam3yaMembersScreenState extends ConsumerState<Gam3yaMembersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedMemberId;
  bool _isEditingTurns = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gam3yaId = ModalRoute.of(context)!.settings.arguments as String;
    final gam3yaAsyncValue = ref.watch(gam3yaProvider(gam3yaId));
    final currentUserAsyncValue = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(gam3yaAsyncValue.when(
          data: (gam3ya) => 'أعضاء ${gam3ya!.name}',
          loading: () => 'أعضاء الجمعية',
          error: (_, __) => 'أعضاء الجمعية',
        )),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الأعضاء', icon: Icon(Icons.people)),
            Tab(text: 'جدول الأدوار', icon: Icon(Icons.calendar_month)),
          ],
        ),
actions: [
  ...gam3yaAsyncValue.whenOrNull(
    data: (gam3ya) => currentUserAsyncValue.whenOrNull(
      data: (currentUser) {
        if (currentUser.id == gam3ya!.creatorId || 
            currentUser.role == UserRole.admin || 
            currentUser.role == UserRole.moderator) {
          return [
            IconButton(
              icon: Icon(_isEditingTurns ? Icons.save : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditingTurns = !_isEditingTurns;
                });
                if (!_isEditingTurns) {
                  // Save changes logic here
                  ref.read(gam3yasNotifierProvider.notifier).updateGam3ya(currentUser.id,gam3ya);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ التغييرات')),
                  );
                }
              },
            ),
          ];
        }
        return null; // Return null explicitly
      },
    ),
  ) ?? [], // Return an empty list if null
]

      ),
      body: gam3yaAsyncValue.when(
        data: (gam3ya) => _buildBody(context, gam3ya!),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(gam3yaProvider(gam3yaId)),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Gam3ya gam3ya) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildMembersTab(context, gam3ya),
        _buildTurnsTab(context, gam3ya),
      ],
    );
  }

  Widget _buildMembersTab(BuildContext context, Gam3ya gam3ya) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عدد الأعضاء: ${gam3ya.members.length}/${gam3ya.totalMembers}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (gam3ya.members.length < gam3ya.totalMembers &&
                      gam3ya.status == Gam3yaStatus.active)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('دعوة عضو'),
                      onPressed: () {
                        _showInviteMemberDialog(context, gam3ya);
                      },
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: gam3ya.members.isEmpty
                ? const Center(
                    child: Text(
                      'لا يوجد أعضاء حتى الآن',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : FadeAnimation(
                    child: ListView.builder(
                      itemCount: gam3ya.members.length,
                      itemBuilder: (context, index) {
                        final member = gam3ya.members[index];
                        return _buildMemberItem(context, member, gam3ya);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context, Gam3yaMember member, Gam3ya gam3ya) {
    final userAsyncValue = ref.watch(userProvider(member.userId));
    
    return userAsyncValue.when(
      data: (user) {
        final hasGuarantor = member.guarantorId != null;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              backgroundImage:
                  user!.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
              child: user.photoUrl.isEmpty
                  ? Text(user.name[0].toUpperCase())
                  : null,
            ),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الدور: ${member.turnNumber}'),
                Text(
                  member.hasReceivedFunds ? 'استلم المبلغ' : 'لم يستلم بعد',
                  style: TextStyle(
                    color: member.hasReceivedFunds
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'النقاط: ${user.reputationScore}',
                  style: TextStyle(
                    color: user.reputationScore > 90
                        ? Colors.green
                        : user.reputationScore > 70
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                Icon(
                  hasGuarantor ? Icons.verified_user : Icons.person,
                  color: hasGuarantor ? Colors.green : Colors.grey,
                  size: 18,
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18),
                        const SizedBox(width: 8),
                        Text('رقم الهاتف: ${user.phone}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'تاريخ الانضمام: ${DateFormat('yyyy-MM-dd').format(member.joinDate)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (hasGuarantor) ...[
                      const Divider(),
                      _buildGuarantorInfo(member.guarantorId!),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.message,
                          label: 'مراسلة',
                          onPressed: () {
                            // Implement chat functionality
                          },
                        ),
                        if (ref.read(currentUserProvider).value!.id == gam3ya.creatorId)
                          _buildActionButton(
                            context,
                            icon: Icons.remove_circle,
                            label: 'إزالة',
                            color: Colors.red,
                            onPressed: () {
                              _showRemoveMemberDialog(context, user, gam3ya);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            child: CircularProgressIndicator(),
          ),
          title: Text('جاري التحميل...'),
        ),
      ),
      error: (error, _) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.red.shade50,
        child: ListTile(
          leading: const Icon(Icons.error, color: Colors.red),
          title: const Text('حدث خطأ'),
          subtitle: Text(error.toString()),
        ),
      ),
    );
  }

  Widget _buildGuarantorInfo(String guarantorId) {
    final guarantorAsyncValue = ref.watch(userProvider(guarantorId));
    
    return guarantorAsyncValue.when(
      data: (guarantor) => Row(
        children: [
          const Icon(Icons.security, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            'الضامن: ${guarantor!.name}',
            style: const TextStyle(color: Colors.green),
          ),
        ],
      ),
      loading: () => const Text('جاري تحميل بيانات الضامن...'),
      error: (_, __) => const Text('لا يمكن تحميل بيانات الضامن'),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildTurnsTab(BuildContext context, Gam3ya gam3ya) {
    final sortedMembers = List<Gam3yaMember>.from(gam3ya.members)
      ..sort((a, b) => a.turnNumber.compareTo(b.turnNumber));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'جدول الأدوار والاستحقاق',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قيمة الجمعية: ${gam3ya.amount} جنيه',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'القسط الشهري: ${gam3ya.monthlyPayment.toStringAsFixed(2)} جنيه',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: gam3ya.members.isEmpty
                ? const Center(
                    child: Text(
                      'لا يوجد أعضاء حتى الآن',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : FadeAnimation(
                    child: ReorderableListView.builder(
                      onReorder: (oldIndex, newIndex) {
                        if (_isEditingTurns) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = sortedMembers.removeAt(oldIndex);
                            sortedMembers.insert(newIndex, item);
                            
                            // Update turn numbers
                            for (int i = 0; i < sortedMembers.length; i++) {
                              final memberIndex = gam3ya.members.indexWhere(
                                (m) => m.userId == sortedMembers[i].userId,
                              );
                              if (memberIndex != -1) {
                                gam3ya.members[memberIndex] = gam3ya.members[memberIndex].copyWith(
                                  turnNumber: i + 1,
                                );
                              }
                            }
                          });
                        }
                      },
                      itemCount: sortedMembers.length,
                      itemBuilder: (context, index) {
                        final member = sortedMembers[index];
                        return _buildTurnItem(context, member, gam3ya, index);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnItem(BuildContext context, Gam3yaMember member, Gam3ya gam3ya, int index) {
    final userAsyncValue = ref.watch(userProvider(member.userId));
    // Calculate payment date for this turn
    final paymentDate = _calculatePaymentDate(gam3ya, index);
    
    return userAsyncValue.when(
      data: (user) {
        return Card(
          key: ValueKey(member.userId),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: member.hasReceivedFunds
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text((index + 1).toString()),
            ),
            title: Text(user!.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تاريخ الاستحقاق: $paymentDate'),
                Text(
                  member.hasReceivedFunds ? 'تم الاستلام' : 'في الانتظار',
                  style: TextStyle(
                    color: member.hasReceivedFunds ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            trailing: _isEditingTurns
                ? const Icon(Icons.drag_handle)
                : member.hasReceivedFunds
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.pending, color: Colors.orange),
            onTap: () {
              if (_isEditingTurns) {
                setState(() {
                  _selectedMemberId = member.userId;
                });
              } else {
                // Show member details or payment history
                _showMemberPaymentHistory(context, user, gam3ya);
              }
            },
          ),
        );
      },
      loading: () => Card(
        key: ValueKey('loading-$index'),
        margin: const EdgeInsets.only(bottom: 12),
        child: const ListTile(
          leading: CircleAvatar(child: CircularProgressIndicator()),
          title: Text('جاري التحميل...'),
        ),
      ),
      error: (error, _) => Card(
        key: ValueKey('error-$index'),
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.red.shade50,
        child: ListTile(
          leading: const Icon(Icons.error, color: Colors.red),
          title: const Text('حدث خطأ'),
          subtitle: Text(error.toString()),
        ),
      ),
    );
  }

  String _calculatePaymentDate(Gam3ya gam3ya, int turnIndex) {
    DateTime paymentDate = gam3ya.startDate;
    
    switch (gam3ya.duration) {
      case Gam3yaDuration.monthly:
        paymentDate = DateTime(
          paymentDate.year,
          paymentDate.month + turnIndex,
          paymentDate.day,
        );
        break;
      case Gam3yaDuration.quarterly:
        paymentDate = DateTime(
          paymentDate.year,
          paymentDate.month + (turnIndex * 3),
          paymentDate.day,
        );
        break;
      case Gam3yaDuration.yearly:
        paymentDate = DateTime(
          paymentDate.year + turnIndex,
          paymentDate.month,
          paymentDate.day,
        );
        break;
    }
    
    return DateFormat('yyyy-MM-dd').format(paymentDate);
  }

  void _showInviteMemberDialog(BuildContext context, Gam3ya gam3ya) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('دعوة عضو جديد'),
        content: const Text('سيتم إرسال دعوة للمستخدم للانضمام إلى الجمعية'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement invitation logic
              Navigator.of(context).pop();
              
              // Show invitation UI or navigate to invite screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال الدعوة بنجاح')),
              );
            },
            child: const Text('إرسال دعوة'),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, User user, Gam3ya gam3ya) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إزالة العضو'),
        content: Text('هل أنت متأكد من إزالة ${user.name} من الجمعية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Remove member logic
              final memberIndex = gam3ya.members.indexWhere((m) => m.userId == user.id);
              if (memberIndex != -1) {
                final updatedMembers = List<Gam3yaMember>.from(gam3ya.members)
                  ..removeAt(memberIndex);
                
                // Update Gam3ya with new members list
                final updatedGam3ya = gam3ya.copyWith(members: updatedMembers);
                ref.read(gam3yasNotifierProvider.notifier).updateGam3ya(user.id,updatedGam3ya );
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم إزالة ${user.name} من الجمعية')),
                );
              }
            },
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }

  void _showMemberPaymentHistory(BuildContext context, User user, Gam3ya gam3ya) {
    // Filter payments for this specific user
    final userPayments = gam3ya.payments.where((p) => p.userId == user.id).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage:
                            user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                        child: user.photoUrl.isEmpty
                            ? Text(user.name[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary))
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'النقاط: ${user.reputationScore}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'سجل المدفوعات',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'عدد الدفعات: ${userPayments.length}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: userPayments.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد مدفوعات حتى الآن',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: userPayments.length,
                      itemBuilder: (context, index) {
                        final payment = userPayments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: payment.isVerified
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              child: Icon(
                                payment.isVerified ? Icons.check : Icons.pending,
                              ),
                            ),
                            title: Text(
                              'دورة #${payment.cycleNumber} - ${payment.amount} جنيه',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تاريخ الدفع: ${DateFormat('yyyy-MM-dd').format(payment.paymentDate)}',
                                ),
                                Text(
                                  'طريقة الدفع: ${payment.paymentMethod}',
                                ),
                              ],
                            ),
                            trailing: payment.isVerified
                                ? const Icon(Icons.verified, color: Colors.green)
                                : IconButton(
                                    icon: const Icon(Icons.qr_code_scanner),
                                    onPressed: () {
                                      // Implement QR verification
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('يرجى مسح رمز QR للتحقق من الدفع'),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// // screens/gam3ya/gam3ya_members_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:gam3ya/src/models/gam3ya_model.dart';
// import 'package:gam3ya/src/models/user_model.dart';
// import 'package:gam3ya/src/providers/gam3ya_provider.dart';
// import 'package:gam3ya/src/providers/user_provider.dart';
// import 'package:gam3ya/src/providers/auth_provider.dart';
// import 'package:gam3ya/src/widgets/animations/fade_animation.dart';
// import 'package:gam3ya/src/widgets/common/custom_button.dart';

// class Gam3yaMembersScreen extends ConsumerStatefulWidget {
//   final String gam3yaId;

//   const Gam3yaMembersScreen({
//     Key? key,
//     required this.gam3yaId,
//   }) : super(key: key);

//   @override
//   ConsumerState<Gam3yaMembersScreen> createState() => _Gam3yaMembersScreenState();
// }

// class _Gam3yaMembersScreenState extends ConsumerState<Gam3yaMembersScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isCreator = false;
  
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _swapTurns(String userId1, String userId2, int turn1, int turn2, Gam3ya gam3ya) async {
//     try {
//       await ref.read(gam3yaProvider.notifier).swapMemberTurns(
//         gam3yaId: gam3ya.id,
//         userId1: userId1,
//         userId2: userId2,
//         turn1: turn1,
//         turn2: turn2,
//       );
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Successfully swapped turns'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error swapping turns: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _showSwapTurnDialog(Gam3ya gam3ya, Gam3yaMember member, User user) {
//     final otherMembers = gam3ya.members
//         .where((m) => m.userId != member.userId)
//         .toList();

//     showDialog(
//       context: context,
//       builder: (context) {
//         Gam3yaMember? selectedMember;
        
//         return AlertDialog(
//           title: const Text('Swap Turn'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Your current turn: ${member.turnNumber}'),
//               const SizedBox(height: 16),
//               const Text('Select member to swap with:'),
//               const SizedBox(height: 8),
//               DropdownButtonFormField<Gam3yaMember>(
//                 items: otherMembers.map((m) {
//                   final otherUser = ref.read(userProvider(m.userId)).value;
//                   return DropdownMenuItem<Gam3yaMember>(
//                     value: m,
//                     child: Text(
//                       '${otherUser?.name ?? 'Unknown'} (Turn ${m.turnNumber})',
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   selectedMember = value;
//                 },
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (selectedMember != null) {
//                   Navigator.pop(context);
//                   _swapTurns(
//                     member.userId,
//                     selectedMember!.userId,
//                     member.turnNumber,
//                     selectedMember!.turnNumber,
//                     gam3ya,
//                   );
//                 }
//               },
//               child: const Text('Swap'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _showMemberDetailsDialog(User member, Gam3yaMember memberDetails) async {
//     final guarantor = memberDetails.guarantorId != null
//         ? await ref.read(userProvider(memberDetails.guarantorId!).future)
//         : null;

//     if (!mounted) return;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(member.name),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.email),
//                 title: Text(member.email),
//                 subtitle: const Text('Email'),
//                 dense: true,
//               ),
//               ListTile(
//                 leading: const Icon(Icons.phone),
//                 title: Text(member.phone),
//                 subtitle: const Text('Phone'),
//                 dense: true,
//               ),
//               ListTile(
//                 leading: const Icon(Icons.stars),
//                 title: Text('${member.reputationScore}'),
//                 subtitle: const Text('Reputation Score'),
//                 dense: true,
//               ),
//               ListTile(
//                 leading: const Icon(Icons.date_range),
//                 title: Text(DateFormat('yyyy-MM-dd').format(memberDetails.joinDate)),
//                 subtitle: const Text('Join Date'),
//                 dense: true,
//               ),
//               ListTile(
//                 leading: const Icon(Icons.format_list_numbered),
//                 title: Text('${memberDetails.turnNumber}'),
//                 subtitle: const Text('Turn Number'),
//                 dense: true,
//               ),
//               if (guarantor != null)
//                 ListTile(
//                   leading: const Icon(Icons.security),
//                   title: Text(guarantor.name),
//                   subtitle: const Text('Guarantor'),
//                   dense: true,
//                 ),
//               ListTile(
//                 leading: Icon(
//                   memberDetails.hasReceivedFunds
//                       ? Icons.check_circle
//                       : Icons.circle_outlined,
//                   color: memberDetails.hasReceivedFunds ? Colors.green : Colors.orange,
//                 ),
//                 title: Text(
//                   memberDetails.hasReceivedFunds
//                       ? 'Has received funds'
//                       : 'Waiting for funds',
//                 ),
//                 dense: true,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildMemberItem(User member, Gam3yaMember memberDetails, Gam3ya gam3ya) {
//     final currentUser = ref.watch(currentUserProvider).valueOrNull;
//     final isSelf = currentUser?.id == member.userId;
//     final isCurrentUserMember = gam3ya.members
//         .any((m) => m.userId == currentUser?.id);
    
//     return FadeAnimation(
//       duration: const Duration(milliseconds: 300),
//       child: Card(
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: isSelf
//               ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
//               : BorderSide.none,
//         ),
//         child: InkWell(
//           onTap: () => _showMemberDetailsDialog(member, memberDetails),
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 // Profile image or avatar
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//                   backgroundImage: member.photoUrl.isNotEmpty
//                       ? NetworkImage(member.photoUrl)
//                       : null,
//                   child: member.photoUrl.isEmpty
//                       ? Text(
//                           member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         )
//                       : null,
//                 ),
                
//                 const SizedBox(width: 12),
                
//                 // Member info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               member.name,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           if (gam3ya.creatorId == member.id)
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 6,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).colorScheme.primary,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Text(
//                                 'Creator',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           if (isSelf)
//                             Container(
//                               margin: const EdgeInsets.only(left: 4),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 6,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Text(
//                                 'You',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.format_list_numbered,
//                             size: 14,
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Turn ${memberDetails.turnNumber}',
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Icon(
//                             memberDetails.hasReceivedFunds
//                                 ? Icons.check_circle
//                                 : Icons.access_time,
//                             size: 14,
//                             color: memberDetails.hasReceivedFunds
//                                 ? Colors.green
//                                 : Colors.orange,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             memberDetails.hasReceivedFunds
//                                 ? 'Received'
//                                 : 'Waiting',
//                             style: TextStyle(
//                               color: memberDetails.hasReceivedFunds
//                                   ? Colors.green
//                                   : Colors.orange,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.star,
//                             size: 14,
//                             color: Colors.amber,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Rating: ${member.reputationScore}',
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 // Actions
//                 if ((isSelf || _isCreator) && gam3ya.status == Gam3yaStatus.active)
//                   Column(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.swap_horiz),
//                         tooltip: 'Swap Turn',
//                         onPressed: () {
//                           if (isCurrentUserMember) {
//                             _showSwapTurnDialog(
//                               gam3ya,
//                               memberDetails,
//                               member,
//                             );
//                           } else {