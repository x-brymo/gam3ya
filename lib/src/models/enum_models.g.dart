// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enum_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStateLifeAdapter extends TypeAdapter<UserStateLife> {
  @override
  final int typeId = 17;

  @override
  UserStateLife read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStateLife(
      reputationScore: fields[1] as String,
      activeGam3yas: fields[2] as String,
      monthlyDue: fields[3] as String,
      expectedIncome: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserStateLife obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.expectedIncome)
      ..writeByte(1)
      ..write(obj.reputationScore)
      ..writeByte(2)
      ..write(obj.activeGam3yas)
      ..writeByte(3)
      ..write(obj.monthlyDue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStateLifeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 11;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.user;
      case 1:
        return UserRole.organizer;
      case 2:
        return UserRole.moderator;
      case 3:
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.user:
        writer.writeByte(0);
        break;
      case UserRole.organizer:
        writer.writeByte(1);
        break;
      case UserRole.moderator:
        writer.writeByte(2);
        break;
      case UserRole.admin:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class Gam3yaStatusAdapter extends TypeAdapter<Gam3yaStatus> {
  @override
  final int typeId = 12;

  @override
  Gam3yaStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gam3yaStatus.pending;
      case 1:
        return Gam3yaStatus.active;
      case 2:
        return Gam3yaStatus.completed;
      case 3:
        return Gam3yaStatus.rejected;
      case 4:
        return Gam3yaStatus.cancelled;
      default:
        return Gam3yaStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, Gam3yaStatus obj) {
    switch (obj) {
      case Gam3yaStatus.pending:
        writer.writeByte(0);
        break;
      case Gam3yaStatus.active:
        writer.writeByte(1);
        break;
      case Gam3yaStatus.completed:
        writer.writeByte(2);
        break;
      case Gam3yaStatus.rejected:
        writer.writeByte(3);
        break;
      case Gam3yaStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gam3yaStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class Gam3yaDurationAdapter extends TypeAdapter<Gam3yaDuration> {
  @override
  final int typeId = 13;

  @override
  Gam3yaDuration read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gam3yaDuration.monthly;
      case 1:
        return Gam3yaDuration.quarterly;
      case 2:
        return Gam3yaDuration.yearly;
      default:
        return Gam3yaDuration.monthly;
    }
  }

  @override
  void write(BinaryWriter writer, Gam3yaDuration obj) {
    switch (obj) {
      case Gam3yaDuration.monthly:
        writer.writeByte(0);
        break;
      case Gam3yaDuration.quarterly:
        writer.writeByte(1);
        break;
      case Gam3yaDuration.yearly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gam3yaDurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class Gam3yaSizeAdapter extends TypeAdapter<Gam3yaSize> {
  @override
  final int typeId = 14;

  @override
  Gam3yaSize read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gam3yaSize.small;
      case 1:
        return Gam3yaSize.medium;
      case 2:
        return Gam3yaSize.large;
      default:
        return Gam3yaSize.small;
    }
  }

  @override
  void write(BinaryWriter writer, Gam3yaSize obj) {
    switch (obj) {
      case Gam3yaSize.small:
        writer.writeByte(0);
        break;
      case Gam3yaSize.medium:
        writer.writeByte(1);
        break;
      case Gam3yaSize.large:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gam3yaSizeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class Gam3yaAccessAdapter extends TypeAdapter<Gam3yaAccess> {
  @override
  final int typeId = 15;

  @override
  Gam3yaAccess read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gam3yaAccess.public;
      case 1:
        return Gam3yaAccess.private;
      default:
        return Gam3yaAccess.public;
    }
  }

  @override
  void write(BinaryWriter writer, Gam3yaAccess obj) {
    switch (obj) {
      case Gam3yaAccess.public:
        writer.writeByte(0);
        break;
      case Gam3yaAccess.private:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gam3yaAccessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatusAdapter extends TypeAdapter<UserStatus> {
  @override
  final int typeId = 16;

  @override
  UserStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserStatus.active;
      case 1:
        return UserStatus.inactive;
      case 2:
        return UserStatus.banned;
      case 3:
        return UserStatus.suspended;
      case 4:
        return UserStatus.offline;
      default:
        return UserStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, UserStatus obj) {
    switch (obj) {
      case UserStatus.active:
        writer.writeByte(0);
        break;
      case UserStatus.inactive:
        writer.writeByte(1);
        break;
      case UserStatus.banned:
        writer.writeByte(2);
        break;
      case UserStatus.suspended:
        writer.writeByte(3);
        break;
      case UserStatus.offline:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
