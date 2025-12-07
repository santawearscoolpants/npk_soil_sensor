import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/repositories/sensor_repository.dart';
import 'bluetooth_constants.dart';

class LiveReading {
  LiveReading({
    required this.timestamp,
    required this.moisture,
    required this.ec,
    required this.temperature,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.salinity,
  });

  final int timestamp;
  final double moisture;
  final double ec;
  final double temperature;
  final double ph;
  final int nitrogen;
  final int phosphorus;
  final int potassium;
  final double salinity;

  factory LiveReading.fromJson(Map<String, dynamic> json) {
    return LiveReading(
      timestamp: json['timestamp'] as int,
      moisture: (json['moisture'] as num).toDouble(),
      ec: (json['ec'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      ph: (json['ph'] as num).toDouble(),
      nitrogen: (json['nitrogen'] as num).toInt(),
      phosphorus: (json['phosphorus'] as num).toInt(),
      potassium: (json['potassium'] as num).toInt(),
      salinity: (json['salinity'] as num).toDouble(),
    );
  }
}

class DiscoveredDevice {
  DiscoveredDevice({
    required this.device,
    required this.name,
  });

  final BluetoothDevice device;
  final String name;
}

class BluetoothStateModel {
  const BluetoothStateModel({
    required this.connectionStatus,
    this.latestReading,
    this.devices = const [],
    this.connectedDeviceName,
  });

  final String connectionStatus;
  final LiveReading? latestReading;
  final List<DiscoveredDevice> devices;
  final String? connectedDeviceName;

  bool get isConnected => connectionStatus.startsWith('Connected');

  BluetoothStateModel copyWith({
    String? connectionStatus,
    LiveReading? latestReading,
    List<DiscoveredDevice>? devices,
    String? connectedDeviceName,
  }) {
    return BluetoothStateModel(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      latestReading: latestReading ?? this.latestReading,
      devices: devices ?? this.devices,
      connectedDeviceName: connectedDeviceName ?? this.connectedDeviceName,
    );
  }
}

class BluetoothService extends StateNotifier<BluetoothStateModel> {
  BluetoothService(this._sensorRepository)
      : super(const BluetoothStateModel(connectionStatus: 'Disconnected'));

  final SensorRepository _sensorRepository;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _sensorCharacteristic;

  Future<void> scanForDevices() async {
    try {
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        state = state.copyWith(
          connectionStatus: 'Bluetooth is off. Please turn it on.',
          devices: [],
        );
        return;
      }

      state = state.copyWith(
        connectionStatus: 'Scanning for devices...',
        devices: [],
      );

      final Map<String, DiscoveredDevice> devices = {};
      final subscription = FlutterBluePlus.scanResults.listen((results) {
        // If we've already selected a device (even if not fully connected yet), ignore further scan results.
        if (state.connectedDeviceName != null) return;
        for (final result in results) {
          final dev = result.device;
          final name =
              dev.platformName.isNotEmpty ? dev.platformName : dev.remoteId.str;
          devices[dev.remoteId.str] =
              DiscoveredDevice(device: dev, name: name);
        }
        if (devices.isNotEmpty) {
          state = state.copyWith(
            devices: devices.values.toList(),
          );
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      // Wait for the scan to finish (timeout handled by startScan).
      await Future.delayed(const Duration(seconds: 10));
      await FlutterBluePlus.stopScan();
      await subscription.cancel();

      final connected = state.isConnected;
      state = state.copyWith(
        connectionStatus: connected
            ? state.connectionStatus
            : devices.isEmpty
                ? 'No BLE devices found. Make sure the ESP32 is powered and advertising.'
                : 'Tap a device to connect',
        devices: devices.values.toList(),
      );
    } catch (e) {
      state = state.copyWith(connectionStatus: 'Error: $e');
    }
  }

  Future<void> connectToDevice(DiscoveredDevice device) async {
    // Stop any ongoing scan when user chooses a device.
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}

    _connectedDevice = device.device;
    // Clear device list immediately when user selects a device
    state = state.copyWith(
      connectedDeviceName: device.name,
      devices: const [],
    );
    await _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    final device = _connectedDevice;
    if (device == null) {
      state = state.copyWith(connectionStatus: 'No device selected');
      return;
    }

    state = state.copyWith(connectionStatus: 'Connecting...');
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      // Mark as connected for UI purposes regardless of service layout.
      state = state.copyWith(
        connectionStatus: 'Connected',
        devices: const [],
      );

      // Try to discover the soil sensor characteristic in the background.
      try {
        final services = await device.discoverServices();
        for (final service in services) {
          if (service.uuid.toString().toLowerCase() ==
              soilSensorServiceUuid.toLowerCase()) {
            for (final characteristic in service.characteristics) {
              if (characteristic.uuid.toString().toLowerCase() ==
                  soilSensorCharacteristicUuid.toLowerCase()) {
                _sensorCharacteristic = characteristic;
                await characteristic.setNotifyValue(true);
                characteristic.onValueReceived.listen(_onCharacteristicData);
                return;
              }
            }
          }
        }
      } catch (_) {
        // Ignore discovery errors; connection is still established.
      }
    } catch (e) {
      state = state.copyWith(connectionStatus: 'Connection error: $e');
    }
  }

  void _onCharacteristicData(List<int> data) {
    try {
      final payload = utf8.decode(data);
      final jsonMap = jsonDecode(payload) as Map<String, dynamic>;
      final reading = LiveReading.fromJson(jsonMap);
      state = state.copyWith(latestReading: reading);
    } catch (e) {
      state = state.copyWith(connectionStatus: 'Parse error: $e');
    }
  }

  /// Used by demo mode to inject a JSON payload without using real BLE.
  void emitMockReading(String jsonPayload) {
    try {
      final jsonMap = jsonDecode(jsonPayload) as Map<String, dynamic>;
      final reading = LiveReading.fromJson(jsonMap);
      state = state.copyWith(
        connectionStatus: 'Demo mode',
        latestReading: reading,
      );
    } catch (e) {
      state = state.copyWith(connectionStatus: 'Demo parse error: $e');
    }
  }

  Future<void> saveLatestReading([int? cropParamsId]) async {
    final latest = state.latestReading;
    if (latest == null) return;

    await _sensorRepository.insertReading(
      SensorReadingsCompanion.insert(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          latest.timestamp * 1000,
        ),
        moisture: latest.moisture,
        ec: latest.ec,
        temperature: latest.temperature,
        ph: latest.ph,
        nitrogen: latest.nitrogen,
        phosphorus: latest.phosphorus,
        potassium: latest.potassium,
        salinity: latest.salinity,
        cropParamsId: cropParamsId != null
            ? drift.Value(cropParamsId)
            : const drift.Value.absent(),
      ),
    );
  }

  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
    } catch (_) {
      // ignore disconnect errors
    }
    _connectedDevice = null;
    _sensorCharacteristic = null;
    state = state.copyWith(
      connectionStatus: 'Disconnected',
      connectedDeviceName: null,
      latestReading: null,
      devices: const [],
    );
  }
}

final bluetoothServiceProvider =
    StateNotifierProvider<BluetoothService, BluetoothStateModel>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = SensorRepository(db);
  return BluetoothService(repo);
});


