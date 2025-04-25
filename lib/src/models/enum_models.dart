// models/enum_models.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'enum_models.g.dart';

@HiveType(typeId: 11)
enum UserRole {
  @HiveField(0)
  user,
  
  @HiveField(1)
  organizer,
  
  @HiveField(2)
  moderator,
  
  @HiveField(3)
  admin,
}

@HiveType(typeId: 12)
enum Gam3yaStatus {
  @HiveField(0)
  pending,
  
  @HiveField(1)
  active,
  
  @HiveField(2)
  completed,
  
  @HiveField(3)
  rejected,
  
  @HiveField(4)
  cancelled
}

@HiveType(typeId: 13)
enum Gam3yaDuration {
  @HiveField(0)
  monthly,
  
  @HiveField(1)
  quarterly,
  
  @HiveField(2)
  yearly
}

@HiveType(typeId: 14)
enum Gam3yaSize {
  @HiveField(0)
  small,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  large
}

@HiveType(typeId: 15)
enum Gam3yaAccess {
  @HiveField(0)
  public,
  
  @HiveField(1)
  private
}

// Extension methods for more descriptive names
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.organizer:
        return 'Organizer';
      case UserRole.moderator:
        return 'Moderator';
      case UserRole.admin:
        return 'Admin';
    }
  }
  
  String get arabicName {
    switch (this) {
      case UserRole.user:
        return 'مستخدم';
      case UserRole.organizer:
        return 'منظم';
      case UserRole.moderator:
        return 'مشرف';
      case UserRole.admin:
        return 'مدير';
    }
  }
}

extension Gam3yaStatusExtension on Gam3yaStatus {
  String get displayName {
    switch (this) {
      case Gam3yaStatus.pending:
        return 'Pending';
      case Gam3yaStatus.active:
        return 'Active';
      case Gam3yaStatus.completed:
        return 'Completed';
      case Gam3yaStatus.rejected:
        return 'Rejected';
      case Gam3yaStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  String get arabicName {
    switch (this) {
      case Gam3yaStatus.pending:
        return 'قيد الإنتظار';
      case Gam3yaStatus.active:
        return 'نشطة';
      case Gam3yaStatus.completed:
        return 'مكتملة';
      case Gam3yaStatus.rejected:
        return 'مرفوضة';
      case Gam3yaStatus.cancelled:
        return 'ملغاة';
    }
  }
  
  Color get color {
    switch (this) {
      case Gam3yaStatus.pending:
        return Colors.orange;
      case Gam3yaStatus.active:
        return Colors.green;
      case Gam3yaStatus.completed:
        return Colors.blue;
      case Gam3yaStatus.rejected:
        return Colors.red;
      case Gam3yaStatus.cancelled:
        return Colors.grey;
    }
  }
}

extension Gam3yaDurationExtension on Gam3yaDuration {
  String get displayName {
    switch (this) {
      case Gam3yaDuration.monthly:
        return 'Monthly';
      case Gam3yaDuration.quarterly:
        return 'Quarterly';
      case Gam3yaDuration.yearly:
        return 'Yearly';
    }
  }
  
  String get arabicName {
    switch (this) {
      case Gam3yaDuration.monthly:
        return 'شهرية';
      case Gam3yaDuration.quarterly:
        return 'ربع سنوية';
      case Gam3yaDuration.yearly:
        return 'سنوية';
    }
  }
  
  int get monthsInterval {
    switch (this) {
      case Gam3yaDuration.monthly:
        return 1;
      case Gam3yaDuration.quarterly:
        return 3;
      case Gam3yaDuration.yearly:
        return 12;
    }
  }
}

extension Gam3yaSizeExtension on Gam3yaSize {
  String get displayName {
    switch (this) {
      case Gam3yaSize.small:
        return 'Small';
      case Gam3yaSize.medium:
        return 'Medium';
      case Gam3yaSize.large:
        return 'Large';
    }
  }
  
  String get arabicName {
    switch (this) {
      case Gam3yaSize.small:
        return 'صغيرة';
      case Gam3yaSize.medium:
        return 'متوسطة';
      case Gam3yaSize.large:
        return 'كبيرة';
    }
  }
}

extension Gam3yaAccessExtension on Gam3yaAccess {
  String get displayName {
    switch (this) {
      case Gam3yaAccess.public:
        return 'Public';
      case Gam3yaAccess.private:
        return 'Private';
    }
  }
  
  String get arabicName {
    switch (this) {
      case Gam3yaAccess.public:
        return 'عامة';
      case Gam3yaAccess.private:
        return 'خاصة';
    }
  }
  
  IconData get icon {
    switch (this) {
      case Gam3yaAccess.public:
        return Icons.public;
      case Gam3yaAccess.private:
        return Icons.lock;
    }
  }
}