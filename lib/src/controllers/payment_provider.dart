// providers/payment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/user_provider.dart' show userServiceProvider;
import 'package:gam3ya/src/models/gam3ya_model.dart';

import 'package:gam3ya/src/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

import '../models/payment_model.dart';
import 'auth_provider.dart';
import 'gam3ya_provider.dart';


final paymentServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
   
});

final paymentsForGam3yaProvider = FutureProvider.family<List<Gam3yaPayment>, String>((ref, gam3yaId) async {
  final gam3ya = await ref.watch(gam3yaProvider(gam3yaId).future);
  
  if (gam3ya == null) {
    return [];
  }
  
  return gam3ya.payments;
});
final allPaymentsProvider = FutureProvider<List<Gam3yaPayment>>((ref) async {
  final gam3yas = await ref.watch(gam3yasProvider.future);
  
  List<Gam3yaPayment> allPayments = [];
  for (final gam3ya in gam3yas) {
    allPayments.addAll(gam3ya.payments);
  }
  
  return allPayments;
});
final userPaymentsProvider = FutureProvider<List<Gam3yaPayment>>((ref) async {
  final currentUser =  ref.watch(currentUserProvider.notifier).state;
  
  final userGam3yas = await ref.watch(userGam3yasProvider.future);
  
  List<Gam3yaPayment> allPayments = [];
  for (final gam3ya in userGam3yas) {
    final payments = gam3ya.payments.where(
      (payment) => payment.userId == currentUser.id
    ).toList();
    allPayments.addAll(payments);
  }
  
  return allPayments;
});

final verificationCodeProvider = StateProvider.family<String?, String>((ref, paymentId) => null);

final paymentProcessingProvider = StateProvider<bool>((ref) => false);



final generatePaymentQRCodeProvider = FutureProvider.family<String, Map<String, dynamic>>((ref, params) async {
  final gam3yaId = params['gam3yaId'] as String;
  final userId = params['userId'] as String;
  final cycleNumber = params['cycleNumber'] as int;
  
  final gam3ya = await ref.watch(gam3yaProvider(gam3yaId).future);
  if (gam3ya == null) {
    throw Exception('Gam3ya not found');
  }
  
  // Generate a unique verification code
  final verificationCode = const Uuid().v4();
  
  final gam3yaService = ref.watch(gam3yaServiceProvider);
  
  // Create a new payment object
  final payment = Gam3yaPayment(
    id: const Uuid().v4(),
    userId: userId,
    amount: gam3ya.monthlyPayment,
    paymentDate: DateTime.now(),
    cycleNumber: cycleNumber,
    verificationCode: verificationCode,
    isVerified: false,
    paymentMethod: 'cash',
     receiptUrl: '',
    gam3yaId: gam3ya.id,
  );
  
  // Add the payment to the gam3ya payments list
  final updatedPayments = [...gam3ya.payments, payment];
  final updatedGam3ya = gam3ya.copyWith(payments: updatedPayments);
  
  // Update the gam3ya in Firestore
  await gam3yaService.updateGam3ya(gam3yaId, updatedGam3ya);
  
  // Store the verification code in the provider state
  ref.read(verificationCodeProvider(payment.id).notifier).state = verificationCode;
  
  return verificationCode;
});
final paymentQRCodeProvider = FutureProvider.family<String?, String>((ref, paymentId) async {
  final gam3ya = await ref.watch(gam3yaProvider(paymentId).future);
  
  if (gam3ya == null) {
    throw Exception('Gam3ya not found');
  }
  
  final payment = gam3ya.payments.firstWhere(
    (p) => p.id == paymentId,
    orElse: () => Gam3yaPayment(
      id: paymentId,
      userId: '',
      amount: 0,
      paymentDate: DateTime.now(),
      cycleNumber: 0,
      verificationCode: '',
      isVerified: false,
      paymentMethod: 'cash',
       receiptUrl: '',
    gam3yaId: gam3ya.id,
    ),
  );
  
  return payment.verificationCode;
});
final paymentProvider = FutureProvider.family<Gam3yaPayment?, String>((ref, paymentId) async {
  final gam3ya = await ref.watch(gam3yaProvider(paymentId).future);
  
  if (gam3ya == null) {
    return null;
  }
  
  return gam3ya.payments.firstWhere((p) => p.id == paymentId, orElse: () => Gam3yaPayment(
    id: paymentId,
    userId: '',
    amount: 0,
    paymentDate: DateTime.now(),
    cycleNumber: 0,
    verificationCode: '',
    isVerified: false,
    paymentMethod: 'cash',
    receiptUrl: '',
    gam3yaId: gam3ya.id,
  ));
});
final paymentHistoryProvider = FutureProvider.family<List<Gam3yaPayment>, String>((ref, userId) async {
  final gam3yas = await ref.watch(gam3yasProvider.future);
  
  List<Gam3yaPayment> allPayments = [];
  for (final gam3ya in gam3yas) {
    final payments = gam3ya.payments.where(
      (payment) => payment.userId == userId
    ).toList();
    allPayments.addAll(payments);
  }
  
  return allPayments;
});
final paymentHistoryForGam3yaProvider = FutureProvider.family<List<Gam3yaPayment>, String>((ref, gam3yaId) async {
  final gam3ya = await ref.watch(gam3yaProvider(gam3yaId).future);
  
  if (gam3ya == null) {
    return [];
  }
  
  return gam3ya.payments;
});
final upcomingPaymentsProvider = FutureProvider.family<List<Gam3yaPayment>, String>((ref, userId) async {
  final gam3yas = await ref.watch(userGam3yasProvider.future);
  
  List<Gam3yaPayment> allPayments = [];
  for (final gam3ya in gam3yas) {
    final payments = gam3ya.payments.where(
      (payment) => payment.userId == userId && !payment.isVerified
    ).toList();
    allPayments.addAll(payments);
  }
  
  return allPayments;
});
final paymentDetailsProvider = FutureProvider.family<Gam3yaPayment?, String>((ref, paymentId) async {
  final gam3ya = await ref.watch(gam3yaProvider(paymentId).future);
  
  if (gam3ya == null) {
    return null;
  }
  
  return gam3ya.payments.firstWhere((p) => p.id == paymentId, orElse: () => Gam3yaPayment(
    id: paymentId,
    userId: '',
    amount: 0,
    paymentDate: DateTime.now(),
    cycleNumber: 0,
    verificationCode: '',
    isVerified: false,
    paymentMethod: 'cash',
    receiptUrl: '',
    gam3yaId: gam3ya.id,
  ));
});

final verifyPaymentProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  final paymentId = params['paymentId'] as String;
  final verificationCode = params['verificationCode'] as String;
  final gam3yaId = params['gam3yaId'] as String;
  
  final gam3ya = await ref.watch(gam3yaProvider(gam3yaId).future);
  if (gam3ya == null) {
    throw Exception('Gam3ya not found');
  }
  
  final paymentIndex = gam3ya.payments.indexWhere((p) => p.id == paymentId);
  if (paymentIndex == -1) {
    throw Exception('Payment not found');
  }
  
  final payment = gam3ya.payments[paymentIndex];
  
  // Check if the verification code matches
  if (payment.verificationCode != verificationCode) {
    return false;
  }
  
  final gam3yaService = ref.watch(gam3yaServiceProvider);
  
  
  // Update the payment to be verified
  final updatedPayment = Gam3yaPayment(
    id: payment.id,
    userId: payment.userId,
    amount: payment.amount,
    paymentDate: payment.paymentDate,
    cycleNumber: payment.cycleNumber,
    verificationCode: payment.verificationCode,
    isVerified: true,
    paymentMethod: payment.paymentMethod,
    receiptUrl: payment.receiptUrl,
    gam3yaId: gam3yaId,
  );
  
  // Update the payments list
  final updatedPayments = [...gam3ya.payments];
  updatedPayments[paymentIndex] = updatedPayment;
  
  // Update the gam3ya in Firestore
  final updatedGam3ya = gam3ya.copyWith(payments: updatedPayments);
  await gam3yaService.updateGam3ya(gam3yaId, updatedGam3ya);
  
  // Update the user's reputation score
  final userService = ref.watch(userServiceProvider);
  final user = await userService.getUserProfile(payment.userId);
  
  // Increase reputation for on-time payment
  final updatedUser = user.copyWith(
    reputationScore: user.reputationScore + 1, // Small increment for payment
  );
  await userService.updateUserProfile(user.id, updatedUser);
  
  return true;
});
final paymentNotifierProvider = StateNotifierProvider<PaymentNotifier, List<Gam3yaPayment>>((ref) {
  return PaymentNotifier(ref.read(paymentServiceProvider));
});
class PaymentNotifier extends StateNotifier<List<Gam3yaPayment>> {
  final FirebaseService _paymentService;
  
  PaymentNotifier(this._paymentService) : super([]);
  
  Future<void> fetchPayments() async {
    final payments = await _paymentService.getAllPayments();
    state = payments;
  }
  
  Future<void> addPayment(Gam3yaPayment payment) async {
    await _paymentService.createPayment(payment);
    fetchPayments();
  }
  Future  processPayment(Gam3yaPayment payment , Gam3ya gam3ya ) async {
    await _paymentService.recordPayment(gam3ya.id, payment);
    fetchPayments();
  }
  Future verifyPayment (
    String gam3yaId,
    String paymentId,
    String verificationCode,
    )async{
      await _paymentService.verifyPayment(gam3yaId, paymentId, verificationCode);
      
    }
  
}