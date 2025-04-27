// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gam3ya_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Gam3yaAdapter extends TypeAdapter<Gam3ya> {
  @override
  final int typeId = 1;

  @override
  Gam3ya read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gam3ya(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      amount: fields[3] as double,
      totalMembers: fields[4] as int,
      creatorId: fields[5] as String,
      startDate: fields[6] as DateTime,
      status: fields[7] as Gam3yaStatus,
      duration: fields[8] as Gam3yaDuration,
      size: fields[9] as Gam3yaSize,
      access: fields[10] as Gam3yaAccess,
      purpose: fields[11] as String,
      safetyFundPercentage: fields[12] as double,
      members: (fields[13] as List).cast<Gam3yaMember>(),
      payments: (fields[14] as List).cast<Gam3yaPayment>(),
      minRequiredReputation: fields[15] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Gam3ya obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.totalMembers)
      ..writeByte(5)
      ..write(obj.creatorId)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.duration)
      ..writeByte(9)
      ..write(obj.size)
      ..writeByte(10)
      ..write(obj.access)
      ..writeByte(11)
      ..write(obj.purpose)
      ..writeByte(12)
      ..write(obj.safetyFundPercentage)
      ..writeByte(13)
      ..write(obj.members)
      ..writeByte(14)
      ..write(obj.payments)
      ..writeByte(15)
      ..write(obj.minRequiredReputation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gam3yaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class Gam3yaMemberAdapter extends TypeAdapter<Gam3yaMember> {
  @override
  final int typeId = 2;

  @override
  Gam3yaMember read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gam3yaMember(
      userId: fields[0] as String,
      turnNumber: fields[1] as int,
      hasReceivedFunds: fields[2] as bool,
      joinDate: fields[3] as DateTime,
      guarantorId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Gam3yaMember obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.turnNumber)
      ..writeByte(2)
      ..write(obj.hasReceivedFunds)
      ..writeByte(3)
      ..write(obj.joinDate)
      ..writeByte(4)
      ..write(obj.guarantorId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gam3yaMemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
