// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NearbyDeviceAdapter extends TypeAdapter<NearbyDevice> {
  @override
  final int typeId = 2;

  @override
  NearbyDevice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NearbyDevice(
      id: fields[0] as String,
      name: fields[1] as String,
      state: fields[2] as NearbyConnectionState?,
      serviceId: fields[3] as String,
      serviceName: fields[4] as String?,
      serviceType: fields[5] as String?,
      serviceData: fields[6] as String?,
      serviceDataType: fields[7] as String?,
      serviceDataId: fields[8] as String?,
      serviceDataName: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NearbyDevice obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.state)
      ..writeByte(3)
      ..write(obj.serviceId)
      ..writeByte(4)
      ..write(obj.serviceName)
      ..writeByte(5)
      ..write(obj.serviceType)
      ..writeByte(6)
      ..write(obj.serviceData)
      ..writeByte(7)
      ..write(obj.serviceDataType)
      ..writeByte(8)
      ..write(obj.serviceDataId)
      ..writeByte(9)
      ..write(obj.serviceDataName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyDeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
