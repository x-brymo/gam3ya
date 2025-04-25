// models/payment_history_model.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'gam3ya_model.dart';
import 'payment_model.dart';

part 'payment_history_model.g.dart';

// enum PaymentStatus {
//   pending,
//   completed,
//   verified,
//   failed,
//   late
// }

// enum PaymentType {
//   contribution, // Regular monthly contribution
//   receipt,      // Receiving the total amount
//   safetyFund,   // Safety fund contribution
//   penalty       // Late payment penalty
// }

@HiveType(typeId: 5)
class PaymentHistoryItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String gam3yaId;
  
  @HiveField(2)
  final String userId;
  
  @HiveField(3)
  final double amount;
  
  @HiveField(4)
  final DateTime date;
  
  @HiveField(5)
  final PaymentStatus status;
  
  @HiveField(6)
  final PaymentType type;
  
  @HiveField(7)
  final String? transactionId;
  
  @HiveField(8)
  final String paymentMethod;
  
  @HiveField(9)
  final String? notes;
  
  @HiveField(10)
  final String? receiptImageUrl;
  
  @HiveField(11)
  final String? verifiedByUserId;
  
  @HiveField(12)
  final DateTime? verificationDate;
  
  @HiveField(13)
  final int cycleNumber;
  @HiveField(14)
  final Gam3ya gam3ya;
  @HiveField(15)
  final Gam3yaPayment payment;
  
  PaymentHistoryItem(this.gam3ya, this.payment,
   {
    required this.id,
    required this.gam3yaId,
    required this.userId,
    required this.amount,
    required this.date,
    required this.status,
    required this.type,
    this.transactionId,
    required this.paymentMethod,
    this.notes,
    this.receiptImageUrl,
    this.verifiedByUserId,
    this.verificationDate,
    required this.cycleNumber,
  });
  
  PaymentHistoryItem copyWith({
    String? id,
    String? gam3yaId,
    String? userId,
    double? amount,
    DateTime? date,
    PaymentStatus? status,
    PaymentType? type,
    String? transactionId,
    String? paymentMethod,
    String? notes,
    String? receiptImageUrl,
    String? verifiedByUserId,
    DateTime? verificationDate,
    int? cycleNumber,
  }) {
    return PaymentHistoryItem(
      gam3ya,
      payment,
      id: id ?? this.id,
      gam3yaId: gam3yaId ?? this.gam3yaId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      type: type ?? this.type,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      verifiedByUserId: verifiedByUserId ?? this.verifiedByUserId,
      verificationDate: verificationDate ?? this.verificationDate,
      cycleNumber: cycleNumber ?? this.cycleNumber,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gam3yaId': gam3yaId,
      'userId': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status.toString(),
      'type': type.toString(),
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'receiptImageUrl': receiptImageUrl,
      'verifiedByUserId': verifiedByUserId,
      'verificationDate': verificationDate?.toIso8601String(),
      'cycleNumber': cycleNumber,
      'gam3ya': gam3ya.toJson(),
      'payment': payment.toJson(),
    };
  }
  
  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      Gam3ya.fromJson(json['gam3ya']),
      Gam3yaPayment.fromJson(json['payment']),
      id: json['id'],
      gam3yaId: json['gam3yaId'],
      userId: json['userId'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      type: PaymentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PaymentType.contribution,
      ),
      transactionId: json['transactionId'],
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      receiptImageUrl: json['receiptImageUrl'],
      verifiedByUserId: json['verifiedByUserId'],
      verificationDate: json['verificationDate'] != null
        ? DateTime.parse(json['verificationDate'])
        : null,
      cycleNumber: json['cycleNumber'],
    );
  }
}

@HiveType(typeId: 6)
enum PaymentStatus {
  @HiveField(0)
  pending,
  
  @HiveField(1)
  completed,
  
  @HiveField(2)
  verified,
  
  @HiveField(3)
  failed,
  
  @HiveField(4)
  late
}

@HiveType(typeId: 7)
enum PaymentType {
  @HiveField(0)
  contribution,
  
  @HiveField(1)
  receipt,
  
  @HiveField(2)
  safetyFund,
  
  @HiveField(3)
  penalty
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.verified:
        return 'Verified';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.late:
        return 'Late';
    }
  }
  
  String get arabicName {
    switch (this) {
      case PaymentStatus.pending:
        return 'قيد الانتظار';
      case PaymentStatus.completed:
        return 'مكتمل';
      case PaymentStatus.verified:
        return 'تم التحقق';
      case PaymentStatus.failed:
        return 'فشل';
      case PaymentStatus.late:
        return 'متأخر';
    }
  }
  
  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.blue;
      case PaymentStatus.verified:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.late:
        return Colors.deepOrange;
    }
  }
  
  IconData get icon {
    switch (this) {
      case PaymentStatus.pending:
        return Icons.pending;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.verified:
        return Icons.verified;
      case PaymentStatus.failed:
        return Icons.cancel;
      case PaymentStatus.late:
        return Icons.warning;
    }
  }
}

extension PaymentTypeExtension on PaymentType {
  String get displayName {
    switch (this) {
      case PaymentType.contribution:
        return 'Contribution';
      case PaymentType.receipt:
        return 'Receipt';
      case PaymentType.safetyFund:
        return 'Safety Fund';
      case PaymentType.penalty:
        return 'Penalty';
    }
  }
  
  String get arabicName {
    switch (this) {
      case PaymentType.contribution:
        return 'مساهمة';
      case PaymentType.receipt:
        return 'استلام';
      case PaymentType.safetyFund:
        return 'صندوق الأمان';
      case PaymentType.penalty:
        return 'غرامة';
    }
  }
  
  IconData get icon {
    switch (this) {
      case PaymentType.contribution:
        return Icons.attach_money;
      case PaymentType.receipt:
        return Icons.account_balance_wallet;
      case PaymentType.safetyFund:
        return Icons.shield;
      case PaymentType.penalty:
        return Icons.warning_amber;
    }
  }
}