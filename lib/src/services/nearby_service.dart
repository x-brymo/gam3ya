// services/nearby_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:nearby_connections/nearby_connections.dart';
import 'package:gam3ya/src/models/nearby_model.dart';

class NearbyService {
  static final NearbyService _instance = NearbyService._internal();
  factory NearbyService() => _instance;
  NearbyService._internal();

  final Strategy _strategy = Strategy.P2P_CLUSTER;
  final String _serviceId = 'com.gam3ya.app';
  final Nearby _nearby = Nearby();

  bool _isAdvertising = false;
  bool _isDiscovering = false;

  final Map<String, ConnectionInfo> _connections = {};
  final List<NearbyDevice> _discoveredDevices = [];
  final StreamController<List<NearbyDevice>> _nearbyDevicesController =
      StreamController<List<NearbyDevice>>.broadcast();

  Stream<List<NearbyDevice>> get nearbyDevices => _nearbyDevicesController.stream;

  void _addNearbyDevice(String id, String name, String serviceId) {
    final device = NearbyDevice(id: id, name: name, serviceId: serviceId,
        state: NearbyConnectionState.notConnected);
    device.serviceName = name;
    if (!_discoveredDevices.any((d) => d.id == id)) {
      _discoveredDevices.add(device);
      _nearbyDevicesController.add(List.from(_discoveredDevices));
    }
  }

  Future<bool> startAdvertising(
      String userId, Function(dynamic) onPaymentReceived) async {
    try {
      _isAdvertising = await _nearby.startAdvertising(
        userId,
        _strategy,
        onConnectionInitiated: (String endpointId, ConnectionInfo connectionInfo) {
          _connections[endpointId] = connectionInfo;
          _nearby.acceptConnection(
            endpointId,
            onPayLoadRecieved: (String endpointId, Payload payload) {
              if (payload.type == PayloadType.BYTES) {
                final data = String.fromCharCodes(payload.bytes!);
                final Map<String, dynamic> paymentData = jsonDecode(data);
                onPaymentReceived(paymentData);
              }
            },
            onPayloadTransferUpdate: (String endpointId, PayloadTransferUpdate update) {},
          );
        },
        onConnectionResult: (String endpointId, Status status) {},
        onDisconnected: (String endpointId) {
          _connections.remove(endpointId);
        },
        serviceId: _serviceId,
      );

      return _isAdvertising;
    } catch (e) {
      print('Error starting advertising: $e');
      return false;
    }
  }

  Future<bool> startDiscovery(Function(String, ConnectionInfo) onEndpointFound) async {
    try {
      _isDiscovering = await _nearby.startDiscovery(
        '',
        _strategy,
        onEndpointFound: (String endpointId, String endpointName, String serviceId) {
          _addNearbyDevice(endpointId, endpointName, serviceId);

          _nearby.requestConnection(
            endpointName,
            endpointId,
            onConnectionInitiated: (String endpointId, ConnectionInfo connectionInfo) {
              _connections[endpointId] = connectionInfo;
              onEndpointFound(endpointId, connectionInfo);
            },
            onConnectionResult: (String endpointId, Status status) {},
            onDisconnected: (String endpointId) {
              _connections.remove(endpointId);
            },
          );
        },
        onEndpointLost: (String? endpointId) {},
        serviceId: _serviceId,
      );

      return _isDiscovering;
    } catch (e) {
      print('Error starting discovery: $e');
      return false;
    }
  }

  Future<void> stopAdvertising() async {
    if (_isAdvertising) {
      await _nearby.stopAdvertising();
      _isAdvertising = false;
    }
  }

  Future<void> stopDiscovery() async {
    if (_isDiscovering) {
      await _nearby.stopDiscovery();
      _isDiscovering = false;
      _discoveredDevices.clear();
      _nearbyDevicesController.add([]);
    }
  }

  Future<void> acceptConnection(String endpointId, Function(dynamic) onPaymentReceived) async {
    await _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: (String endpointId, Payload payload) {
        if (payload.type == PayloadType.BYTES) {
          final data = String.fromCharCodes(payload.bytes!);
          final Map<String, dynamic> paymentData = jsonDecode(data);
          onPaymentReceived(paymentData);
        }
      },
      onPayloadTransferUpdate: (String endpointId, PayloadTransferUpdate update) {},
    );
  }

  Future<void> sendPaymentData(String endpointId, Map<String, dynamic> paymentData) async {
    final payload = Payload(
      id: 0,
      type: PayloadType.BYTES,
      bytes: Uint8List.fromList(jsonEncode(paymentData).codeUnits),
    );
    await _nearby.sendBytesPayload(endpointId, payload.bytes!);
  }

  Future<void> disconnect(String endpointId) async {
    await _nearby.disconnectFromEndpoint(endpointId);
    _connections.remove(endpointId);
  }

  Future<void> stopAllEndpoints() async {
    await stopAdvertising();
    await stopDiscovery();
    final endpoints = List<String>.from(_connections.keys);
    for (final endpointId in endpoints) {
      await disconnect(endpointId);
    }
    _connections.clear();
  }

  void dispose() {
    _nearbyDevicesController.close();
  }
}
