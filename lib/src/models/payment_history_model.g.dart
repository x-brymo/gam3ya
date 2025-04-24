// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentHistoryItemAdapter extends TypeAdapter<PaymentHistoryItem> {
  @override
  final int typeId = 3;

  @override
  PaymentHistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentHistoryItem(
      fields[14] as Gam3ya,
      fields[15] as Gam3yaPayment,
      id: fields[0] as String,
      gam3yaId: fields[1] as String,
      userId: fields[2] as String,
      amount: fields[3] as double,
      date: fields[4] as DateTime,
      status: fields[5] as PaymentStatus,
      type: fields[6] as PaymentType,
      transactionId: fields[7] as String?,
      paymentMethod: fields[8] as String,
      notes: fields[9] as String?,
      receiptImageUrl: fields[10] as String?,
      verifiedByUserId: fields[11] as String?,
      verificationDate: fields[12] as DateTime?,
      cycleNumber: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentHistoryItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gam3yaId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.transactionId)
      ..writeByte(8)
      ..write(obj.paymentMethod)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.receiptImageUrl)
      ..writeByte(11)
      ..write(obj.verifiedByUserId)
      ..writeByte(12)
      ..write(obj.verificationDate)
      ..writeByte(13)
      ..write(obj.cycleNumber)
      ..writeByte(14)
      ..write(obj.gam3ya)
      ..writeByte(15)
      ..write(obj.payment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentHistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentStatusAdapter extends TypeAdapter<PaymentStatus> {
  @override
  final int typeId = 10;

  @override
  PaymentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentStatus.pending;
      case 1:
        return PaymentStatus.completed;
      case 2:
        return PaymentStatus.verified;
      case 3:
        return PaymentStatus.failed;
      case 4:
        return PaymentStatus.late;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentStatus obj) {
    switch (obj) {
      case PaymentStatus.pending:
        writer.writeByte(0);
        break;
      case PaymentStatus.completed:
        writer.writeByte(1);
        break;
      case PaymentStatus.verified:
        writer.writeByte(2);
        break;
      case PaymentStatus.failed:
        writer.writeByte(3);
        break;
      case PaymentStatus.late:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentTypeAdapter extends TypeAdapter<PaymentType> {
  @override
  final int typeId = 11;

  @override
  PaymentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentType.contribution;
      case 1:
        return PaymentType.receipt;
      case 2:
        return PaymentType.safetyFund;
      case 3:
        return PaymentType.penalty;
      default:
        return PaymentType.contribution;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentType obj) {
    switch (obj) {
      case PaymentType.contribution:
        writer.writeByte(0);
        break;
      case PaymentType.receipt:
        writer.writeByte(1);
        break;
      case PaymentType.safetyFund:
        writer.writeByte(2);
        break;
      case PaymentType.penalty:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
