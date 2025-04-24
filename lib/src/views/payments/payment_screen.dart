// payments/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/user_provider.dart' show currentUserProvider;
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/models/user_model.dart';

import 'package:gam3ya/src/widgets/common/custom_button.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../controllers/gam3ya_provider.dart';
import '../../controllers/payment_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  static const String routeName = '/payment';

  const PaymentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedPaymentMethod = 'credit_card';
  final List<String> _paymentMethods = [
    'credit_card',
    'debit_card',
    'vodafone_cash',
    'fawry',
    'aman',
    'cash',
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final gam3yaId = args['gam3yaId'] as String;
    final cycleNumber = args['cycleNumber'] as int;
    
    final gam3yaAsyncValue = ref.watch(gam3yaProvider(gam3yaId));
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
        elevation: 0,
      ),
      body: gam3yaAsyncValue.when(
        data: (gam3ya) {
          if (gam3ya == null) {
            return Center(child: Text('Gam3ya not found'));
          }
          
          return _buildPaymentForm(context, gam3ya, currentUser as User?, cycleNumber);
        },
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(BuildContext context, Gam3ya gam3ya, User? currentUser, int cycleNumber) {
    final paymentAmount = gam3ya.monthlyPayment;
    final formatter = NumberFormat.currency(locale: 'ar_EG', symbol: 'E£');
    
    // Check if user has already paid for this cycle
    final hasAlreadyPaid = gam3ya.payments.any(
      (payment) => payment.userId == currentUser?.id && payment.cycleNumber == cycleNumber,
    );

    if (hasAlreadyPaid) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'You have already paid for this cycle',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: () => Navigator.of(context).pop(),
              text: 'Go Back',
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Payment Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gam3ya.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cycle: $cycleNumber of ${gam3ya.totalMembers}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Amount:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        formatter.format(paymentAmount),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Safety Fund (${gam3ya.safetyFundPercentage}%):',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        formatter.format(gam3ya.safetyFundAmount),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        formatter.format(paymentAmount + gam3ya.safetyFundAmount),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment Method Selection
          Text(
            'Select Payment Method',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          _buildPaymentMethodsList(),
          
          const SizedBox(height: 32),
          
          // Pay Button
          CustomButton(
            onPressed: () => _processPayment(context, gam3ya, currentUser, cycleNumber, paymentAmount),
            text: 'Complete Payment',
            isLoading: ref.watch(paymentProcessingProvider),
          ),
          
          const SizedBox(height: 16),
          
          // Cash Payment Option
          if (_selectedPaymentMethod == 'cash')
            OutlinedButton(
              onPressed: () => _navigateToQrScanner(context, gam3ya, cycleNumber),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner),
                  const SizedBox(width: 8),
                  Text('Scan QR Code for Cash Payment'),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    final Map<String, IconData> methodIcons = {
      'credit_card': Icons.credit_card,
      'debit_card': Icons.credit_card,
      'vodafone_cash': Icons.phone_android,
      'fawry': Icons.storefront,
      'aman': Icons.account_balance,
      'cash': Icons.money,
    };
    
    final Map<String, String> methodNames = {
      'credit_card': 'Credit Card',
      'debit_card': 'Debit Card',
      'vodafone_cash': 'Vodafone Cash',
      'fawry': 'Fawry',
      'aman': 'Aman',
      'cash': 'Cash Payment',
    };
    
    return Column(
      children: _paymentMethods.map((method) {
        return RadioListTile<String>(
          value: method,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            }
          },
          title: Row(
            children: [
              Icon(methodIcons[method]),
              const SizedBox(width: 12),
              Text(methodNames[method] ?? method),
            ],
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          activeColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Future<void> _processPayment(BuildContext context, Gam3ya gam3ya, User? currentUser, int cycleNumber, double amount) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to make a payment')),
      );
      return;
    }

    try {
      ref.read(paymentProcessingProvider.notifier).state = true;
      
      final paymentId = const Uuid().v4();
      final now = DateTime.now();
      
      final payment = Gam3yaPayment(
        id: paymentId,
        userId: currentUser.id,
        amount: amount,
        paymentDate: now,
        cycleNumber: cycleNumber,
        paymentMethod: _selectedPaymentMethod,
        isVerified: _selectedPaymentMethod != 'cash', // Only cash payments need verification
        verificationCode: _selectedPaymentMethod == 'cash' 
            ? '${paymentId.substring(0, 6).toUpperCase()}'
            : null,
      );
      
      // If not cash payment, process it directly
      if (_selectedPaymentMethod != 'cash') {
        final success = await ref.read(paymentNotifierProvider.notifier).processPayment(
         payment,
         gam3ya,
          
        );
        
        if (success) {
          _showSuccessDialog(context);
        } else {
          _showErrorDialog(context, 'Payment processing failed');
        }
      } else {
        // For cash payments, show QR code
        Navigator.pushNamed(
          context,
          '/payment/qr-code',
          arguments: {
            'payment': payment,
            'gam3ya': gam3ya,
          },
        );
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    } finally {
      ref.read(paymentProcessingProvider.notifier).state = false;
    }
  }

  void _navigateToQrScanner(BuildContext context, Gam3ya gam3ya, int cycleNumber) {
    Navigator.pushNamed(
      context,
      '/payment/scan',
      arguments: {
        'gam3yaId': gam3ya.id,
        'cycleNumber': cycleNumber,
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            SizedBox(height: 16),
            Text('Your payment has been processed successfully.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Error'),
        content: Text('An error occurred: $errorMessage'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}