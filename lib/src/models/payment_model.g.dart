// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Gam3yaPaymentAdapter extends TypeAdapter<Gam3yaPayment> {
  @override
  final int typeId = 8;

  @override
  Gam3yaPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gam3yaPayment(
      id: fields[0] as String,
      userId: fields[1] as String,
      amount: fields[2] as double,
      paymentDate: fields[3] as DateTime,
      cycleNumber: fields[4] as int,
      verificationCode: fields[5] as String,
      isVerified: fields[6] as bool,
      paymentMethod: fields[7] as String,
      receiptUrl: fields[8] as String,
      gam3yaId: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Gam3yaPayment obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paymentDate)
      ..writeByte(4)
      ..write(obj.cycleNumber)
      ..writeByte(5)
      ..write(obj.verificationCode)
      ..writeByte(6)
      ..write(obj.isVerified)
      ..writeByte(7)
      ..write(obj.paymentMethod)
      ..writeByte(8)
      ..write(obj.receiptUrl)
      ..writeByte(9)
      ..write(obj.gam3yaId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gam3yaPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
