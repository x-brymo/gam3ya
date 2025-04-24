// payments/payment_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/user_provider.dart' show currentUserProvider;
import 'package:intl/intl.dart';

import '../../controllers/payment_provider.dart';
import '../../models/gam3ya_model.dart';
import '../../models/payment_history_model.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_indicator.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  static const String routeName = '/payment/history';

  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final paymentsAsync = ref.watch(userPaymentsProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        elevation: 0,
      ),
      body: paymentsAsync.when(
        data: (payments) {
          if (payments.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.payments_outlined,
              title: 'No Payment History',
              message: 'You have not made any payments yet.',
            );
          }
          final listItem = <PaymentHistoryItem>[];
          return _buildPaymentsList(context, listItem);
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildPaymentsList(BuildContext context, List<PaymentHistoryItem> payments) {
    // Sort payments by date, newest first
    payments.sort((a, b) => b.payment.paymentDate.compareTo(a.payment.paymentDate));
    
    final formatter = NumberFormat.currency(locale: 'ar_EG', symbol: 'E£');
    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final item = payments[index];
        final payment = item.payment;
        final gam3ya = item.gam3ya;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _showPaymentDetails(context, item),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          gam3ya.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusChip(context, payment),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cycle ${payment.cycleNumber} of ${gam3ya.totalMembers}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatter.format(payment.amount),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Date',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatter.format(payment.paymentDate),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _getPaymentMethodIcon(payment.paymentMethod),
                      const SizedBox(width: 8),
                      Text(
                        _formatPaymentMethod(payment.paymentMethod),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, Gam3yaPayment payment) {
    Color chipColor;
    String statusText;
    IconData statusIcon;
    
    if (payment.isVerified) {
      chipColor = Colors.green;
      statusText = 'Verified';
      statusIcon = Icons.check_circle;
    } else {
      chipColor = Colors.orange;
      statusText = 'Pending';
      statusIcon = Icons.pending;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPaymentMethodIcon(String method) {
    final iconMap = {
      'credit_card': Icons.credit_card,
      'debit_card': Icons.credit_card,
      'vodafone_cash': Icons.phone_android,
      'fawry': Icons.storefront,
      'aman': Icons.account_balance,
      'cash': Icons.money,
    };
    
    return Icon(
      iconMap[method] ?? Icons.payments,
      size: 20,
      color: Colors.grey[600],
    );
  }

  String _formatPaymentMethod(String method) {
    final methodNames = {
      'credit_card': 'Credit Card',
      'debit_card': 'Debit Card',
      'vodafone_cash': 'Vodafone Cash',
      'fawry': 'Fawry',
      'aman': 'Aman',
      'cash': 'Cash Payment',
    };
    
    return methodNames[method] ?? method;
  }

  void _showPaymentDetails(BuildContext context, PaymentHistoryItem item) {
    final payment = item.payment;
    final gam3ya = item.gam3ya;
    final formatter = NumberFormat.currency(locale: 'ar_EG', symbol: 'E£');
    final dateFormatter = DateFormat('dd MMMM yyyy, hh:mm a');
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Payment Receipt',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(context, 'Gam3ya', gam3ya.name),
              _buildDetailRow(context, 'Payment ID', payment.id.substring(0, 8).toUpperCase()),
              _buildDetailRow(context, 'Cycle', '${payment.cycleNumber} of ${gam3ya.totalMembers}'),
              _buildDetailRow(context, 'Date', dateFormatter.format(payment.paymentDate)),
              _buildDetailRow(context, 'Amount', formatter.format(payment.amount)),
              _buildDetailRow(context, 'Payment Method', _formatPaymentMethod(payment.paymentMethod)),
              _buildDetailRow(context, 'Status', payment.isVerified ? 'Verified' : 'Pending Verification'),
              
              if (payment.verificationCode != null)
                _buildDetailRow(context, 'Verification Code', payment.verificationCode!),
              
              const SizedBox(height: 32),
              
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}