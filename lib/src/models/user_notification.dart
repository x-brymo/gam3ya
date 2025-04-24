// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
part 'user_notification.g.dart';
enum NotificationType{
  payment,
  reminder,
  turn,
  system,
  gam3ya
}
@HiveType(typeId: 6)
class UserNotification {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String message;
  @HiveField(3)
  final DateTime timestamp; 
  @HiveField(4)
  late final bool isRead; // New field to track read status
  @HiveField(5)
  final String? imageUrl; // New field for image URL
  @HiveField(6)
  final NotificationType type; // New field for notification type

  UserNotification(this.isRead, this.imageUrl, this.type, {
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
  });
  

  UserNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
  }) {
    return UserNotification(
      isRead,
      imageUrl,
      type,
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'type': type.toString(),
    };
  }

  factory UserNotification.fromMap(Map<String, dynamic> map) {
    return UserNotification(
      map['isRead'] as bool,
      map['imageUrl'] as String?,
      NotificationType.values.firstWhere((e) => e.toString() == map['type'] as String),
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      

    );
  }

  String toJson() => json.encode(toMap());

  factory UserNotification.fromJson(String source) => UserNotification.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserNotification(id: $id, title: $title, message: $message, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant UserNotification other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.title == title &&
      other.message == message &&
      other.timestamp == timestamp;
      
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      message.hashCode ^
      timestamp.hashCode;
  }
}
