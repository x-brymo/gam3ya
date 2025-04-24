// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enum_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 7;

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
  final int typeId = 8;

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
  final int typeId = 9;

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
  final int typeId = 10;

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
  final int typeId = 11;

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
