// models/user_model.dart
import 'package:hive/hive.dart';

part 'user_model.g.dart';

enum UserRole {
  user,
  organizer,
  moderator,
  admin,
}
enum UserStatus {
  active,
  inactive,
  banned,
  suspended,  
  offline,

} 


@HiveType(typeId: 9)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String photoUrl;

  @HiveField(5)
  final UserRole role;

  @HiveField(6)
  final int reputationScore;

  @HiveField(7)
  final List<String> joinedGam3yasIds;

  @HiveField(8)
  final List<String> createdGam3yasIds;

  @HiveField(9)
  final List<String> guarantorForUserIds;

  @HiveField(10)
  final String? guarantorUserId;
  @HiveField(11)
  final UserStatus? status;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl = '',
    this.role = UserRole.user,
    this.reputationScore = 100,
    this.joinedGam3yasIds = const [],
    this.createdGam3yasIds = const [],
    this.guarantorForUserIds = const [],
    this.guarantorUserId,
    this.status = UserStatus.active,
  }) : assert(
          reputationScore >= 0 && reputationScore <= 100,
          'Reputation score must be between 0 and 100',
        );
  

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    UserRole? role,
    int? reputationScore,
    List<String>? joinedGam3yasIds,
    List<String>? createdGam3yasIds,
    List<String>? guarantorForUserIds,
    String? guarantorUserId,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      reputationScore: reputationScore ?? this.reputationScore,
      joinedGam3yasIds: joinedGam3yasIds ?? this.joinedGam3yasIds,
      createdGam3yasIds: createdGam3yasIds ?? this.createdGam3yasIds,
      guarantorForUserIds: guarantorForUserIds ?? this.guarantorForUserIds,
      guarantorUserId: guarantorUserId ?? this.guarantorUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role.toString(),
      'reputationScore': reputationScore,
      'joinedGam3yasIds': joinedGam3yasIds,
      'createdGam3yasIds': createdGam3yasIds,
      'guarantorForUserIds': guarantorForUserIds,
      'guarantorUserId': guarantorUserId,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      photoUrl: json['photoUrl'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => UserRole.user,
      ),
      reputationScore: json['reputationScore'] ?? 100,
      joinedGam3yasIds: List<String>.from(json['joinedGam3yasIds'] ?? []),
      createdGam3yasIds: List<String>.from(json['createdGam3yasIds'] ?? []),
      guarantorForUserIds: List<String>.from(json['guarantorForUserIds'] ?? []),
      guarantorUserId: json['guarantorUserId'],
    );
  }



  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, phone: $phone, photoUrl: $photoUrl, role: $role, reputationScore: $reputationScore, joinedGam3yasIds: $joinedGam3yasIds, createdGam3yasIds: $createdGam3yasIds, guarantorForUserIds: $guarantorForUserIds, guarantorUserId: $guarantorUserId}';
  }
}