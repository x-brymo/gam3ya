// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 9;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      photoUrl: fields[4] as String,
      role: fields[5] as UserRole,
      reputationScore: fields[6] as int,
      joinedGam3yasIds: (fields[7] as List).cast<String>(),
      createdGam3yasIds: (fields[8] as List).cast<String>(),
      guarantorForUserIds: (fields[9] as List).cast<String>(),
      guarantorUserId: fields[10] as String?,
      status: fields[11] as UserStatus?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.reputationScore)
      ..writeByte(7)
      ..write(obj.joinedGam3yasIds)
      ..writeByte(8)
      ..write(obj.createdGam3yasIds)
      ..writeByte(9)
      ..write(obj.guarantorForUserIds)
      ..writeByte(10)
      ..write(obj.guarantorUserId)
      ..writeByte(11)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
