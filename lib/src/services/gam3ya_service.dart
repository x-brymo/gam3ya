// services/gam3ya_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:gam3ya/src/models/gam3ya_model.dart';
import 'package:gam3ya/src/services/notification_service.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/enum_models.dart';
import '../models/payment_model.dart';

class Gam3yaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  final Box<Gam3ya> _gam3yasBox = Hive.box<Gam3ya>('gam3yas');
  final Uuid _uuid = const Uuid();

  // Get all public Gam3yas
  Future<List<Gam3ya>> getAllPublicGam3yas() async {
    try {
      // Try to get from local first
      final List<Gam3ya> localGam3yas = _gam3yasBox.values
          .where((gam3ya) => 
              gam3ya.access == Gam3yaAccess.public && 
              gam3ya.status != Gam3yaStatus.rejected)
          .toList();
      
      // If we have local data, return it
      if (localGam3yas.isNotEmpty) {
        return localGam3yas;
      }
      
      // Otherwise fetch from Firebase
      final snapshot = await _firestore
          .collection('gam3yas')
          .where('access', isEqualTo: Gam3yaAccess.public.toString())
          .where('status', isNotEqualTo: Gam3yaStatus.rejected.toString())
          .get();
      
      final gam3yas = snapshot.docs
          .map((doc) => Gam3ya.fromJson(doc.data()))
          .toList();
      
      // Save to local storage
      for (var gam3ya in gam3yas) {
        _gam3yasBox.put(gam3ya.id, gam3ya);
      }
      
      return gam3yas;
    } catch (e) {
      print('Error getting public gam3yas: $e');
      rethrow;
    }
  }

  // Get Gam3yas that user has joined
  Future<List<Gam3ya>> getUserGam3yas(String userId) async {
    try {
      // Try local first
      final List<Gam3ya> localGam3yas = _gam3yasBox.values
          .where((gam3ya) => 
              gam3ya.members.any((member) => member.userId == userId))
          .toList();
      
      if (localGam3yas.isNotEmpty) {
        return localGam3yas;
      }
      
      // Fetch from Firebase
      final snapshot = await _firestore
          .collection('gam3yas')
          .where('members', arrayContains: {'userId': userId})
          .get();
      
      final gam3yas = snapshot.docs
          .map((doc) => Gam3ya.fromJson(doc.data()))
          .toList();
      
      // Save to local
      for (var gam3ya in gam3yas) {
        _gam3yasBox.put(gam3ya.id, gam3ya);
      }
      
      return gam3yas;
    } catch (e) {
      print('Error getting user gam3yas: $e');
      rethrow;
    }
  }

  // Create a new Gam3ya
  Future<Gam3ya> createGam3ya(Gam3ya gam3ya) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Generate a unique ID for the new Gam3ya
      final String gam3yaId = _uuid.v4();
      final newGam3ya = Gam3ya(
        id: gam3yaId,
        name: gam3ya.name,
        description: gam3ya.description,
        amount: gam3ya.amount,
        totalMembers: gam3ya.totalMembers,
        creatorId: currentUser.uid,
        startDate: gam3ya.startDate,
        status: Gam3yaStatus.pending, // Always starts as pending
        duration: gam3ya.duration,
        size: gam3ya.size,
        access: gam3ya.access,
        purpose: gam3ya.purpose,
        safetyFundPercentage: gam3ya.safetyFundPercentage,
        minRequiredReputation: gam3ya.minRequiredReputation,
        // Creator is automatically the first member with turn 1
        members: [
          Gam3yaMember(
            userId: currentUser.uid,
            turnNumber: 1,
            joinDate: DateTime.now(),
          )
        ],
        payments: [],
      );

      // Save to Firebase
      await _firestore
          .collection('gam3yas')
          .doc(gam3yaId)
          .set(newGam3ya.toJson());

      // Save to local storage
      _gam3yasBox.put(gam3yaId, newGam3ya);

      // Notify admins
      await _notificationService.sendAdminNotification(
        'New Gam3ya Request',
        '${newGam3ya.name} has been created and needs approval',
      );

      return newGam3ya;
    } catch (e) {
      print('Error creating gam3ya: $e');
      rethrow;
    }
  }

  // Join a Gam3ya
  Future<void> joinGam3ya(String gam3yaId, String? guarantorId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the Gam3ya from local or Firebase
      Gam3ya? gam3ya = _gam3yasBox.get(gam3yaId);

      // Check if the user can join
      if (gam3ya!.status != Gam3yaStatus.active) {
        throw Exception('This Gam3ya is not active');
      }

      if (gam3ya.members.length >= gam3ya.totalMembers) {
        throw Exception('This Gam3ya is already full');
      }

      if (gam3ya.members.any((member) => member.userId == currentUser.uid)) {
        throw Exception('You have already joined this Gam3ya');
      }

      // Get next available turn number
      final usedTurns = gam3ya.members.map((m) => m.turnNumber).toList();
      int nextTurn = 1;
      while (usedTurns.contains(nextTurn)) {
        nextTurn++;
      }

      // Add the member
      final newMember = Gam3yaMember(
        userId: currentUser.uid,
        turnNumber: nextTurn,
        joinDate: DateTime.now(),
        guarantorId: guarantorId,
      );

      final updatedMembers = [...gam3ya.members, newMember];
      final updatedGam3ya = gam3ya.copyWith(members: updatedMembers);

      // Update in Firebase
      await _firestore
          .collection('gam3yas')
          .doc(gam3yaId)
          .update({'members': updatedMembers.map((m) => m.toJson()).toList()});

      // Update local storage
      _gam3yasBox.put(gam3yaId, updatedGam3ya);

      // Notify the Gam3ya creator
      await _notificationService.sendUserNotification(
        gam3ya.creatorId,
        'New Member Joined',
        
        
      );

      // If there's a guarantor, notify them
      if (guarantorId != null) {
        await _notificationService.sendUserNotification(
          guarantorId,
          'Guarantor Request',
         // 'You have been requested to be a guarantor for a member in ${gam3ya.name}',
        );
      }
    } catch (e) {
      print('Error joining gam3ya: $e');
      rethrow;
    }
  }

  // Make a payment
  Future<void> makePayment(String gam3yaId, double amount, String paymentMethod, String? receiptUrl) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the Gam3ya
      Gam3ya? gam3ya = _gam3yasBox.get(gam3yaId);

      // Check if user is a member
      if (!gam3ya!.members.any((member) => member.userId == currentUser.uid)) {
        throw Exception('You are not a member of this Gam3ya');
      }

      // Calculate current cycle number based on start date
      final now = DateTime.now();
      int monthsFromStart = (now.year - gam3ya.startDate.year) * 12 + now.month - gam3ya.startDate.month;
      int cycleNumber;

      switch (gam3ya.duration) {
        case Gam3yaDuration.monthly:
          cycleNumber = monthsFromStart + 1;
          break;
        case Gam3yaDuration.quarterly:
          cycleNumber = (monthsFromStart / 3).ceil();
          break;
        case Gam3yaDuration.yearly:
          cycleNumber = (monthsFromStart / 12).ceil();
          break;
      }

      // Check if payment for this cycle was already made
      if (gam3ya.payments.any((p) => p.userId == currentUser.uid && p.cycleNumber == cycleNumber)) {
        throw Exception('You have already made a payment for this cycle');
      }

      // Create verification code for cash payments
      String? verificationCode;
      if (paymentMethod == 'cash') {
        verificationCode = _generateVerificationCode();
      }

      // Create payment record
      final payment = Gam3yaPayment(
        id: _uuid.v4(),
        userId: currentUser.uid,
        amount: amount,
        paymentDate: now,
        cycleNumber: cycleNumber,
        verificationCode: verificationCode!,
        isVerified: paymentMethod != 'cash', // Electronic payments auto-verified
        paymentMethod: paymentMethod,
        receiptUrl: receiptUrl!,
        gam3yaId: gam3yaId,
      );

      final updatedPayments = [...gam3ya.payments, payment];
      final updatedGam3ya = gam3ya.copyWith(payments: updatedPayments);

      // Update in Firebase
      await _firestore
          .collection('gam3yas')
          .doc(gam3yaId)
          .update({'payments': updatedPayments.map((p) => p.toJson()).toList()});

      // Update local storage
      _gam3yasBox.put(gam3yaId, updatedGam3ya);

      // Notify the Gam3ya creator
      await _notificationService.sendUserNotification(
        gam3ya.creatorId,
        'New Payment Made',
        //'A member has made a payment for ${gam3ya.name}',
      );

      // If cash payment, provide verification code to user
      await _notificationService.sendUserNotification(
        currentUser.uid,
        'Payment Verification Code',
      //  'Your verification code is: $verificationCode. Show this to the organizer.',
      );
        } catch (e) {
      print('Error making payment: $e');
      rethrow;
    }
  }

  // Verify a cash payment using QR/Barcode
  Future<void> verifyPayment(String gam3yaId, String paymentId, String verificationCode) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the Gam3ya
      Gam3ya? gam3ya = _gam3yasBox.get(gam3yaId);

      // Check if current user is the creator
      if (gam3ya!.creatorId != currentUser.uid) {
        throw Exception('Only the Gam3ya organizer can verify payments');
      }

      // Find the payment
      final paymentIndex = gam3ya.payments.indexWhere((p) => p.id == paymentId);
      if (paymentIndex == -1) {
        throw Exception('Payment not found');
      }

      final payment = gam3ya.payments[paymentIndex];
      
      // Verify the code
      if (payment.verificationCode != verificationCode) {
        throw Exception('Invalid verification code');
      }

      // Mark as verified
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

      final updatedPayments = List<Gam3yaPayment>.from(gam3ya.payments);
      updatedPayments[paymentIndex] = updatedPayment;
      
      final updatedGam3ya = gam3ya.copyWith(payments: updatedPayments);

      // Update in Firebase
      await _firestore
          .collection('gam3yas')
          .doc(gam3yaId)
          .update({'payments': updatedPayments.map((p) => p.toJson()).toList()});

      // Update local storage
      _gam3yasBox.put(gam3yaId, updatedGam3ya);

      // Notify the user
      await _notificationService.sendUserNotification(
        payment.userId,
        'Payment Verified',
       // 'Your payment for ${gam3ya.name} has been verified.',
      );
    } catch (e) {
      print('Error verifying payment: $e');
      rethrow;
    }
  }

  // Change a member's turn
  Future<void> changeMemberTurn(String gam3yaId, String userId, int newTurn) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the Gam3ya
      Gam3ya? gam3ya = _gam3yasBox.get(gam3yaId);

      // Only creator or the user themselves can change turns
      if (gam3ya!.creatorId != currentUser.uid && userId != currentUser.uid) {
        throw Exception('You do not have permission to change this turn');
      }

      // Find the member
      final memberIndex = gam3ya.members.indexWhere((m) => m.userId == userId);
      if (memberIndex == -1) {
        throw Exception('Member not found');
      }

      // Check if new turn is available
      if (gam3ya.members.any((m) => m.userId != userId && m.turnNumber == newTurn)) {
        throw Exception('This turn is already taken');
      }

      // Update the member's turn
      final member = gam3ya.members[memberIndex];
      final updatedMember = member.copyWith(turnNumber: newTurn);
      
      final updatedMembers = List<Gam3yaMember>.from(gam3ya.members);
      updatedMembers[memberIndex] = updatedMember;
      
      final updatedGam3ya = gam3ya.copyWith(members: updatedMembers);

      // Update in Firebase
      await _firestore
          .collection('gam3yas')
          .doc(gam3yaId)
          .update({'members': updatedMembers.map((m) => m.toJson()).toList()});

      // Update local storage
      _gam3yasBox.put(gam3yaId, updatedGam3ya);

      // Notify the affected user
      if (userId != currentUser.uid) {
        await _notificationService.sendUserNotification(
          userId,
          'Turn Changed',
          //'Your turn in ${gam3ya.name} has been changed to #$newTurn',
        );
      }
    } catch (e) {
      print('Error changing turn: $e');
      rethrow;
    }
  }

  // Generate a random verification code for cash payments
  String _generateVerificationCode() {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = _uuid.v4().split('-')[0];
    return random.substring(0, 6).toUpperCase();
  }

  // Sync local data with Firebase
  Future<void> syncWithFirebase() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Get user's Gam3yas from Firebase
      final snapshot = await _firestore
          .collection('gam3yas')
          .where('members', arrayContains: {'userId': currentUser.uid})
          .get();
      
      final gam3yas = snapshot.docs
          .map((doc) => Gam3ya.fromJson(doc.data()))
          .toList();
      
      // Update local storage
      for (var gam3ya in gam3yas) {
        _gam3yasBox.put(gam3ya.id, gam3ya);
      }
      
      // Get all public Gam3yas
      final publicSnapshot = await _firestore
          .collection('gam3yas')
          .where('access', isEqualTo: Gam3yaAccess.public.toString())
          .where('status', isEqualTo: Gam3yaStatus.active.toString())
          .limit(20) // Limit to prevent excessive downloads
          .get();
      
      final publicGam3yas = publicSnapshot.docs
          .map((doc) => Gam3ya.fromJson(doc.data()))
          .toList();
      
      // Update local storage
      for (var gam3ya in publicGam3yas) {
        _gam3yasBox.put(gam3ya.id, gam3ya);
      }
    } catch (e) {
      print('Error syncing with Firebase: $e');
    }
  }
}