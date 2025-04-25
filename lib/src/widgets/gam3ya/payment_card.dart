// widgets/gam3ya/payment_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../constants/theme.dart';
import '../../models/payment_model.dart';

class PaymentCard extends StatelessWidget {
  final Gam3yaPayment payment;
  final String userName;
  final String userImageUrl;
  final VoidCallback? onVerify;
  final VoidCallback? onViewReceipt;
  final bool isMyPayment;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.userName,
    this.userImageUrl = '',
    this.onVerify,
    this.onViewReceipt,
    this.isMyPayment = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: payment.isVerified
            ? const BorderSide(color: Colors.green, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildUserAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMyPayment ? 'دفعتك' : userName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'دورة ${payment.cycleNumber}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${formatter.format(payment.amount)} ج.م',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('yyyy/MM/dd').format(payment.paymentDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPaymentMethodChip(),
                const Spacer(),
                if (payment.isVerified)
                  _buildVerificationBadge(context)
                else
                  _buildVerifyButton(context),
              ],
            ),
            ...[
            const SizedBox(height: 12),
            _buildReceiptButton(context),
          ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      backgroundImage: userImageUrl.isNotEmpty ? NetworkImage(userImageUrl) : null,
      child: userImageUrl.isEmpty
          ? Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            )
          : null,
    );
  }

  Widget _buildPaymentMethodChip() {
    IconData iconData;
    Color iconColor;

    switch (payment.paymentMethod.toLowerCase()) {
      case 'cash':
        iconData = Icons.money;
        iconColor = Colors.green;
        break;
      case 'bank transfer':
        iconData = Icons.account_balance;
        iconColor = Colors.blue;
        break;
      case 'credit card':
      case 'visa':
      case 'mastercard':
        iconData = Icons.credit_card;
        iconColor = Colors.purple;
        break;
      case 'e-wallet':
      case 'vodafone cash':
      case 'fawry':
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.payment;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            payment.paymentMethod,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            'تم التأكيد',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onVerify,
      icon: const Icon(Icons.check_circle_outline, size: 16),
      label: Text(isMyPayment ? 'طلب تأكيد' : 'تأكيد الدفع'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReceiptButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onViewReceipt,
      icon: const Icon(Icons.receipt_long, size: 16),
      label: const Text('عرض الإيصال'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class PaymentSummaryCard extends StatelessWidget {
  final int totalPayments;
  final int completedPayments;
  final double totalAmount;
  final double paidAmount;
  final DateTime nextPaymentDate;
  final VoidCallback? onPayNow;

  const PaymentSummaryCard({
    super.key,
    required this.totalPayments,
    required this.completedPayments,
    required this.totalAmount,
    required this.paidAmount,
    required this.nextPaymentDate,
    this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 0,
    );
    
    final daysUntilPayment = nextPaymentDate.difference(DateTime.now()).inDays;
    final progressPercentage = completedPayments / totalPayments;

    return Card(
      margin: const EdgeInsets.all(16),
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
                Text(
                  'ملخص المدفوعات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completedPayments/$totalPayments',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAmountInfo(
                    context,
                    'المبلغ الإجمالي',
                    '${formatter.format(totalAmount)} ج.م',
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAmountInfo(
                    context,
                    'تم دفع',
                    '${formatter.format(paidAmount)} ج.م',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: daysUntilPayment <= 3
                    ? Colors.red.withOpacity(0.08)
                    : daysUntilPayment <= 7
                        ? Colors.orange.withOpacity(0.08)
                        : Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: daysUntilPayment <= 3
                        ? Colors.red
                        : daysUntilPayment <= 7
                            ? Colors.orange
                            : Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الدفعة القادمة',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('yyyy/MM/dd').format(nextPaymentDate),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'متبقي $daysUntilPayment يوم',
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
                  ),
                  ElevatedButton(
                    onPressed: onPayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: daysUntilPayment <= 3
                          ? Colors.red
                          : daysUntilPayment <= 7
                              ? Colors.orange
                              : AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('دفع الآن'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? iconColor,
  ]) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}