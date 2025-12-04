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

class BluetoothStateModel {
  const BluetoothStateModel({
    required this.connectionStatus,
    this.latestReading,
  });

  final String connectionStatus;
  final LiveReading? latestReading;

  BluetoothStateModel copyWith({
    String? connectionStatus,
    LiveReading? latestReading,
  }) {
    return BluetoothStateModel(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      latestReading: latestReading ?? this.latestReading,
    );
  }
}

class BluetoothService extends StateNotifier<BluetoothStateModel> {
  BluetoothService(this._sensorRepository)
      : super(const BluetoothStateModel(connectionStatus: 'Disconnected'));

  final SensorRepository _sensorRepository;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _sensorCharacteristic;

  Future<void> scanAndConnect() async {
    state = state.copyWith(connectionStatus: 'Scanning...');
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      final scanResults = await FlutterBluePlus.scanResults.first;
      for (final result in scanResults) {
        final name = result.device.platformName;
        if (name.startsWith(soilSensorDeviceNamePrefix)) {
          _connectedDevice = result.device;
          await FlutterBluePlus.stopScan();
          await _connectToDevice();
          return;
        }
      }

      await FlutterBluePlus.stopScan();
      state = state.copyWith(connectionStatus: 'Device not found');
    } catch (e) {
      state = state.copyWith(connectionStatus: 'Error: $e');
    }
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
      state = state.copyWith(connectionStatus: 'Discovering services...');

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
              state = state.copyWith(connectionStatus: 'Connected');
              return;
            }
          }
        }
      }

      state = state.copyWith(
          connectionStatus: 'Service/characteristic not found on device');
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
}

final bluetoothServiceProvider =
    StateNotifierProvider<BluetoothService, BluetoothStateModel>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = SensorRepository(db);
  return BluetoothService(repo);
});


