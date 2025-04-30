// models/gam3ya_model.dart
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'enum_models.dart';
import 'payment_model.dart';

part 'gam3ya_model.g.dart';



@HiveType(typeId: 1)
class Gam3ya {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final int totalMembers;

  @HiveField(5)
  final String creatorId;

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final Gam3yaStatus status;

  @HiveField(8)
  final Gam3yaDuration duration;

  @HiveField(9)
  final Gam3yaSize size;

  @HiveField(10)
  final Gam3yaAccess access;

  @HiveField(11)
  final String purpose;

  @HiveField(12)
  final double safetyFundPercentage;

  @HiveField(13)
  final List<Gam3yaMember> members;

  @HiveField(14)
  final List<Gam3yaPayment> payments;

  @HiveField(15)
  final int minRequiredReputation;

  Gam3ya({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.totalMembers,
    required this.creatorId,
    required this.startDate,
    this.status = Gam3yaStatus.pending,
    this.duration = Gam3yaDuration.monthly,
    this.size = Gam3yaSize.medium,
    this.access = Gam3yaAccess.public,
    this.purpose = '',
    this.safetyFundPercentage = 5.0,
    this.members = const [],
    this.payments = const [],
    this.minRequiredReputation = 80,
  });

  Gam3ya copyWith({
    String? name,
    String? description,
    double? amount,
    int? totalMembers,
    DateTime? startDate,
    Gam3yaStatus? status,
    Gam3yaDuration? duration,
    Gam3yaSize? size,
    Gam3yaAccess? access,
    String? purpose,
    double? safetyFundPercentage,
    List<Gam3yaMember>? members,
    List<Gam3yaPayment>? payments,
    int? minRequiredReputation,
  }) {
    return Gam3ya(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      totalMembers: totalMembers ?? this.totalMembers,
      creatorId: creatorId,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      size: size ?? this.size,
      access: access ?? this.access,
      purpose: purpose ?? this.purpose,
      safetyFundPercentage: safetyFundPercentage ?? this.safetyFundPercentage,
      members: members ?? this.members,
      payments: payments ?? this.payments,
      minRequiredReputation: minRequiredReputation ?? this.minRequiredReputation,
    );
  }

  double get safetyFundAmount {
    return amount * safetyFundPercentage / 100;
  }

  double get monthlyPayment {
    return amount / totalMembers;
  }

  String getNextPaymentDate(DateTime currentDate) {
    if (status != Gam3yaStatus.active) return 'N/A';
    
    int monthsToAdd;
    switch (duration) {
      case Gam3yaDuration.monthly:
        monthsToAdd = 1;
        break;
      case Gam3yaDuration.quarterly:
        monthsToAdd = 3;
        break;
      case Gam3yaDuration.yearly:
        monthsToAdd = 12;
        break;
    }
    
    // Calculate next payment based on start date and current date
    DateTime nextPayment = startDate;
    while (nextPayment.isBefore(currentDate)) {
      nextPayment = DateTime(
        nextPayment.year,
        nextPayment.month + monthsToAdd,
        nextPayment.day,
      );
    }
    
    return DateFormat('yyyy-MM-dd').format(nextPayment);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'totalMembers': totalMembers,
      'creatorId': creatorId,
      'startDate': startDate.toIso8601String(),
      'status': status.toString(),
      'duration': duration.toString(),
      'size': size.toString(),
      'access': access.toString(),
      'purpose': purpose,
      'safetyFundPercentage': safetyFundPercentage,
      'members': members.map((e) => e.toJson()).toList(),
      'payments': payments.map((e) => e.toJson()).toList(),
      'minRequiredReputation': minRequiredReputation,
    };
  }

  factory Gam3ya.fromJson(Map<String, dynamic> json) {
    return Gam3ya(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      amount: json['amount'],
      totalMembers: json['totalMembers'],
      creatorId: json['creatorId'],
      startDate: DateTime.parse(json['startDate']),
      status: Gam3yaStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => Gam3yaStatus.pending,
      ),
      duration: Gam3yaDuration.values.firstWhere(
        (e) => e.toString() == json['duration'],
        orElse: () => Gam3yaDuration.monthly,
      ),
      size: Gam3yaSize.values.firstWhere(
        (e) => e.toString() == json['size'],
        orElse: () => Gam3yaSize.medium,
      ),
      access: Gam3yaAccess.values.firstWhere(
        (e) => e.toString() == json['access'],
        orElse: () => Gam3yaAccess.public,
      ),
      purpose: json['purpose'] ?? '',
      safetyFundPercentage: json['safetyFundPercentage'] ?? 5.0,
      members: (json['members'] as List?)
          ?.map((e) => Gam3yaMember.fromJson(e))
          .toList() ?? [],
      payments: (json['payments'] as List?)
          ?.map((e) => Gam3yaPayment.fromJson(e))
          .toList() ?? [],
      minRequiredReputation: json['minRequiredReputation'] ?? 80,
    );
  }
}

@HiveType(typeId: 2)
class Gam3yaMember {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final int turnNumber;

  @HiveField(2)
  final bool hasReceivedFunds;

  @HiveField(3)
  final DateTime joinDate;

  @HiveField(4)
  final String? guarantorId;

  Gam3yaMember({
    required this.userId,
    required this.turnNumber,
    this.hasReceivedFunds = false,
    required this.joinDate,
    this.guarantorId,
  });

  Gam3yaMember copyWith({
    int? turnNumber,
    bool? hasReceivedFunds,
    String? guarantorId,
  }) {
    return Gam3yaMember(
      userId: userId,
      turnNumber: turnNumber ?? this.turnNumber,
      hasReceivedFunds: hasReceivedFunds ?? this.hasReceivedFunds,
      joinDate: joinDate,
      guarantorId: guarantorId ?? this.guarantorId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'turnNumber': turnNumber,
      'hasReceivedFunds': hasReceivedFunds,
      'joinDate': joinDate.toIso8601String(),
      'guarantorId': guarantorId,
    };
  }

  factory Gam3yaMember.fromJson(Map<String, dynamic> json) {
    return Gam3yaMember(
      userId: json['userId'],
      turnNumber: json['turnNumber'],
      hasReceivedFunds: json['hasReceivedFunds'] ?? false,
      joinDate: DateTime.parse(json['joinDate']),
      guarantorId: json['guarantorId'],
    );
  }
}

