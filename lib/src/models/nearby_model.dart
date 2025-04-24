// create class NearbyDevice
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nearby_connections/nearby_connections.dart';

part 'nearby_model.g.dart';


enum NearbyConnectionState {
  connected,
  disconnected,
  connecting,
  notConnected
}
  @HiveType(typeId: 2)
class NearbyDevice {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  NearbyConnectionState? state;

  @HiveField(3)
  final String serviceId;

  @HiveField(4)
  late final String? serviceName;

  @HiveField(5)
  final String? serviceType;

  @HiveField(6)
  final String? serviceData;

  @HiveField(7)
  final String? serviceDataType;

  @HiveField(8)
  final String? serviceDataId;

  @HiveField(9)
  final String? serviceDataName;

  NearbyDevice({
    required this.id,
    required this.name,
     this.state,
    required this.serviceId,
    this.serviceName,
    this.serviceType,
    this.serviceData,
    this.serviceDataType,
    this.serviceDataId,
    this.serviceDataName,
  });
}