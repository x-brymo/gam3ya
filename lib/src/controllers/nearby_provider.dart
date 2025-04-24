
// providers/nearby_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/services/nearby_service.dart';

import '../models/nearby_model.dart';



final nearbyServiceProvider = Provider<NearbyService>((ref) {
  final service = NearbyService();
  ref.onDispose(() => service.dispose());
  return service;
});

final nearbyDevicesProvider = StreamProvider<List<NearbyDevice>>((ref) {
  final service = ref.watch(nearbyServiceProvider);
  return service.nearbyDevices;
});

final connectedDeviceProvider = StateProvider<NearbyDevice?>((ref) => null);