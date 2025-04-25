// screens/profile/reputation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/user_provider.dart' show currentUserProvider;
import 'package:gam3ya/src/models/user_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class ReputationScreen extends ConsumerStatefulWidget {
  const ReputationScreen({super.key});

  @override
  ConsumerState<ReputationScreen> createState() => _ReputationScreenState();
}

class _ReputationScreenState extends ConsumerState<ReputationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green[700]!;
    if (score >= 70) return Colors.green[400]!;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getReputationLevel(int score) {
    if (score >= 90) return 'ممتاز (Excellent)';
    if (score >= 70) return 'جيد جدا (Very Good)';
    if (score >= 50) return 'متوسط (Average)';
    return 'ضعيف (Poor)';
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('سمعتي - My Reputation'),
        centerTitle: true,
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('لم يتم تسجيل الدخول'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReputationCard(user),
                const SizedBox(height: 24),
                _buildReputationHistory(),
                const SizedBox(height: 24),
                _buildReputationBenefits(),
                const SizedBox(height: 24),
                _buildHowToImproveCard(),
              ].animate(interval: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('حدث خطأ: $error'),
        ),
      ),
    );
  }

  Widget _buildReputationCard(User user) {
    final score = user.reputationScore;
    final level = _getReputationLevel(score);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'درجة السمعة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Reputation Score',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    color: _getScoreColor(score),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      score.toString(),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: _getScoreColor(score),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/100',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getScoreColor(score).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                level,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _getScoreColor(score),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عدد الجمعيات المكتملة:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  user.joinedGam3yasIds.length.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'جمعيات أنت ضامن فيها:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  user.guarantorForUserIds.length.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReputationHistory() {
    // Simulated reputation history data
    final List<Map<String, dynamic>> historyItems = [
      {
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'change': 0+2,
        'reason': 'دفع مبكر للقسط الشهري',
        'reasonEn': 'Early payment of monthly installment',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'change': 0+5,
        'reason': 'اكتمال جمعية بنجاح',
        'reasonEn': 'Successful completion of a Gam3ya',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 45)),
        'change': -3,
        'reason': 'تأخر في الدفع',
        'reasonEn': 'Delayed payment',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'change': 0+2,
        'reason': 'دفع مبكر للقسط الشهري',
        'reasonEn': 'Early payment of monthly installment',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سجل السمعة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _toggleExpand,
                  child: Row(
                    children: [
                      Text(_isExpanded ? 'عرض أقل' : 'عرض المزيد'),
                      const SizedBox(width: 4),
                      RotationTransition(
                        turns: Tween<double>(begin: 0, end: 0.5).animate(_animationController),
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reputation History',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  ...historyItems.take(_isExpanded ? historyItems.length : 2).map((item) {
                    final bool isPositive = item['change'] > 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                isPositive ? '+${item['change']}' : '${item['change']}',
                                style: TextStyle(
                                  color: isPositive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['reason']} (${item['reasonEn']})',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('yyyy-MM-dd').format(item['date']),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReputationBenefits() {
    final benefits = [
      {
        'title': 'جمعيات أكبر',
        'titleEn': 'Larger Gam3yas',
        'description': 'الانضمام للجمعيات ذات القيمة العالية',
        'descriptionEn': 'Join high-value Gam3yas',
        'icon': Icons.trending_up,
      },
      {
        'title': 'أولوية الأدوار',
        'titleEn': 'Turn Priority',
        'description': 'حصل على أدوار مبكرة في الجمعيات الجديدة',
        'descriptionEn': 'Get early turns in new Gam3yas',
        'icon': Icons.low_priority,
      },
      {
        'title': 'رسوم أقل',
        'titleEn': 'Lower Fees',
        'description': 'تخفيض نسبة صندوق الأمان',
        'descriptionEn': 'Reduced safety fund percentage',
        'icon': Icons.money_off,
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مزايا السمعة العالية',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Benefits of High Reputation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ...benefits.map((benefit) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        benefit['icon'] as IconData,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${benefit['title']} (${benefit['titleEn']})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${benefit['description']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${benefit['descriptionEn']}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToImproveCard() {
    final tips = [
      {
        'tip': 'التزم بدفع الأقساط في موعدها',
        'tipEn': 'Pay installments on time',
      },
      {
        'tip': 'كن ضامنًا موثوقًا للآخرين',
        'tipEn': 'Be a reliable guarantor for others',
      },
      {
        'tip': 'أكمل الجمعيات التي تنضم إليها',
        'tipEn': 'Complete the Gam3yas you join',
      },
      {
        'tip': 'حافظ على تواصل جيد مع منظمي الجمعية',
        'tipEn': 'Maintain good communication with organizers',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'كيف تحسن سمعتك؟',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'How to Improve Your Reputation?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['tip']!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            tip['tipEn']!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to a detailed guide or show more information
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سيتم إضافة دليل تفصيلي قريبًا'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.star),
                label: const Text('عرض دليل تفصيلي للسمعة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// // reputation_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gam3ya/src/models/user_model.dart';
// import 'package:gam3ya/src/providers/user_provider.dart';
// import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

// final reputationHistoryProvider = FutureProvider.autoDispose<List<ReputationRecord>>((ref) async {
//   final user = await ref.watch(currentUserProvider.future);
//   if (user == null) {
//     throw Exception('تسجيل الدخول مطلوب');
//   }
  
//   final userService = ref.read(userServiceProvider);
//   return userService.getReputationHistory(user.id);
// });

// class ReputationRecord {
//   final DateTime date;
//   final int score;
//   final String reason;
//   final int change;

//   ReputationRecord({
//     required this.date,
//     required this.score,
//     required this.reason,
//     required this.change,
//   });
// }

// class ReputationScreen extends ConsumerWidget {
//   const ReputationScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final userAsync = ref.watch(currentUserProvider);
//     final reputationHistory = ref.watch(reputationHistoryProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تقييم الحساب'),
//       ),
//       body: userAsync.when(
//         data: (user) {
//           if (user == null) {
//             return const Center(
//               child: Text('تسجيل الدخول مطلوب'),
//             );
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Score Display
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         theme.colorScheme.primary,
//                         theme.colorScheme.secondary,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: theme.colorScheme.primary.withOpacity(0.3),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.star,
//                             color: Colors.amber,
//                             size: 32,
//                           ),
//                           const SizedBox(width: 12),
//                           Text(
//                             'تقييمك الحالي',
//                             style: theme.textTheme.titleLarge?.copyWith(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         '${user.reputationScore}',
//                         style: theme.textTheme.displayMedium?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: LinearProgressIndicator(
//                           value: user.reputationScore / 100,
//                           backgroundColor: Colors.white.withOpacity(0.3),
//                           valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//                           minHeight: 10,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         _getReputationText(user.reputationScore),
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Reputation Guidelines
//                 Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'كيف يتم حساب التقييم؟',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildGuidelineItem(
//                           context,
//                           icon: Icons.payments,
//                           title: 'دفع الأقساط في الموعد',
//                           description: 'تسديد الأقساط بانتظام وقبل الموعد النهائي',
//                           points: '+5 نقاط لكل قسط',
//                           color: Colors.green,
//                         ),
//                         _buildGuidelineItem(
//                           context,
//                           icon: Icons.assignment_late,
//                           title: 'تأخير الدفع',
//                           description: 'تأخير دفع القسط بعد الموعد المحدد',
//                           points: '-10 نقاط لكل تأخير',
//                           color: Colors.red,
//                         ),
//                         _buildGuidelineItem(
//                           context,
//                           icon: Icons.handshake,
//                           title: 'الالتزام بالجمعيات',
//                           description: 'إكمال الجمعية بنجاح كاملة',
//                           points: '+15 نقاط لكل جمعية مكتملة',
//                           color: Colors.blue,
//                         ),
//                         _buildGuidelineItem(
//                           context,
//                           icon: Icons.cancel,
//                           title: 'الانسحاب من الجمعية',
//                           description: 'الانسحاب من الجمعية قبل اكتمالها',