// widgets/gam3ya/gam3ya_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:intl/intl.dart';

import '../../constants/theme.dart';

class Gam3yaCard extends StatelessWidget {
  final Gam3ya gam3ya;
  final VoidCallback onTap;
  final bool isActive;
  final bool showDetails;
  final int? userTurnNumber;

  const Gam3yaCard({
    super.key,
    required this.gam3ya,
    required this.onTap,
    this.isActive = false,
    this.showDetails = true,
    this.userTurnNumber,
  });

  Color _getStatusColor() {
    switch (gam3ya.status) {
      case Gam3yaStatus.active:
        return Colors.green;
      case Gam3yaStatus.pending:
        return Colors.orange;
      case Gam3yaStatus.completed:
        return Colors.blue;
      case Gam3yaStatus.rejected:
        return Colors.red;
      case Gam3yaStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (gam3ya.status) {
      case Gam3yaStatus.active:
        return 'نشطة';
      case Gam3yaStatus.pending:
        return 'قيد الانتظار';
      case Gam3yaStatus.completed:
        return 'مكتملة';
      case Gam3yaStatus.rejected:
        return 'مرفوضة';
      case Gam3yaStatus.cancelled:
        return 'ملغية';
      default:
        return 'غير معروف';
    }
  }

  String _getDurationText() {
    switch (gam3ya.duration) {
      case Gam3yaDuration.monthly:
        return 'شهرية';
      case Gam3yaDuration.quarterly:
        return 'ربع سنوية';
      case Gam3yaDuration.yearly:
        return 'سنوية';
      default:
        return 'غير محددة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 0,
    );
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isActive
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        gam3ya.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoItem(
                      context,
                      'المبلغ الإجمالي',
                      '${formatter.format(gam3ya.amount)} ج.م',
                      Icons.money,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoItem(
                      context,
                      'القسط الشهري',
                      '${formatter.format(gam3ya.monthlyPayment)} ج.م',
                      Icons.calendar_month,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoItem(
                      context,
                      'عدد الأعضاء',
                      '${gam3ya.members.length}/${gam3ya.totalMembers}',
                      Icons.group,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoItem(
                      context,
                      'نوع الدورة',
                      _getDurationText(),
                      Icons.access_time,
                    ),
                  ],
                ),
                if (showDetails) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoItem(
                        context,
                        'تاريخ البدء',
                        DateFormat('yyyy/MM/dd').format(gam3ya.startDate),
                        Icons.date_range,
                      ),
                      const SizedBox(width: 16),
                      if (userTurnNumber != null)
                        _buildInfoItem(
                          context,
                          'دورك',
                          '$userTurnNumber',
                          Icons.person_pin_circle,
                          isHighlighted: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (gam3ya.status == Gam3yaStatus.active)
                    _buildNextPaymentInfo(context),
                ],
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 300.ms,
          ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isHighlighted ? AppTheme.primaryColor : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                        color: isHighlighted ? AppTheme.primaryColor : null,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPaymentInfo(BuildContext context) {
    final nextPayment = gam3ya.getNextPaymentDate(DateTime.now());
    final daysUntilPayment = DateTime.parse(nextPayment)
        .difference(DateTime.now())
        .inDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: daysUntilPayment <= 3
            ? Colors.red.withOpacity(0.08)
            : daysUntilPayment <= 7
                ? Colors.orange.withOpacity(0.08)
                : Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: daysUntilPayment <= 3
              ? Colors.red.withOpacity(0.3)
              : daysUntilPayment <= 7
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: daysUntilPayment <= 3
                ? Colors.red
                : daysUntilPayment <= 7
                    ? Colors.orange
                    : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الدفعة القادمة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      nextPayment,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(متبقي $daysUntilPayment يوم)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: daysUntilPayment <= 3
                                ? Colors.red
                                : daysUntilPayment <= 7
                                    ? Colors.orange
                                    : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (daysUntilPayment <= 7)
            ElevatedButton(
              onPressed: () {
                // Navigate to payment screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: daysUntilPayment <= 3
                    ? Colors.red
                    : daysUntilPayment <= 7
                        ? Colors.orange
                        : AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 36),
              ),
              child: const Text('ادفع الآن'),
            ),
        ],
      ),
    );
  }
}