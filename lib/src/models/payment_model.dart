// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
part 'payment_model.g.dart';
@HiveType(typeId: 4)
class Gam3yaPayment {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime paymentDate;
  @HiveField(4)
  final int cycleNumber;
  @HiveField(5)
  final String verificationCode;
  @HiveField(6)
  final bool isVerified;
  @HiveField(7)
  final String paymentMethod;
  @HiveField(8)
  final String receiptUrl;
  @HiveField(9)
  final String gam3yaId;

  Gam3yaPayment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.paymentDate,
    required this.cycleNumber,
    required this.verificationCode,
    required this.isVerified,
    required this.paymentMethod,
    required this.receiptUrl,
    required this.gam3yaId,
  });

  Gam3yaPayment copyWith({
    String? id,
    String? userId,
    double? amount,
    DateTime? paymentDate,
    int? cycleNumber,
    String? verificationCode,
    bool? isVerified,
    String? paymentMethod,
    String? receiptUrl,
    String? gam3yaId,
  }) {
    return Gam3yaPayment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      verificationCode: verificationCode ?? this.verificationCode,
      isVerified: isVerified ?? this.isVerified,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      gam3yaId: gam3yaId ?? this.gam3yaId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'amount': amount,
      'paymentDate': paymentDate.millisecondsSinceEpoch,
      'cycleNumber': cycleNumber,
      'verificationCode': verificationCode,
      'isVerified': isVerified,
      'paymentMethod': paymentMethod,
      'receiptUrl': receiptUrl,
      'gam3yaId': gam3yaId,
    };
  }

  factory Gam3yaPayment.fromMap(Map<String, dynamic> map) {
    return Gam3yaPayment(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: map['amount'] as double,
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['paymentDate'] as int),
      cycleNumber: map['cycleNumber'] as int,
      verificationCode: map['verificationCode'] as String,
      isVerified: map['isVerified'] as bool,
      paymentMethod: map['paymentMethod'] as String,
      receiptUrl: map['receiptUrl'] as String,
      gam3yaId: map['gam3yaId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Gam3yaPayment.fromJson(String source) => Gam3yaPayment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Gam3yaPayment(id: $id, userId: $userId, amount: $amount, paymentDate: $paymentDate, cycleNumber: $cycleNumber, verificationCode: $verificationCode, isVerified: $isVerified, paymentMethod: $paymentMethod, receiptUrl: $receiptUrl, gam3yaId: $gam3yaId)';
  }

  @override
  bool operator ==(covariant Gam3yaPayment other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.userId == userId &&
      other.amount == amount &&
      other.paymentDate == paymentDate &&
      other.cycleNumber == cycleNumber &&
      other.verificationCode == verificationCode &&
      other.isVerified == isVerified &&
      other.paymentMethod == paymentMethod &&
      other.receiptUrl == receiptUrl &&
      other.gam3yaId == gam3yaId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      amount.hashCode ^
      paymentDate.hashCode ^
      cycleNumber.hashCode ^
      verificationCode.hashCode ^
      isVerified.hashCode ^
      paymentMethod.hashCode ^
      receiptUrl.hashCode ^
      gam3yaId.hashCode;
  }
}
