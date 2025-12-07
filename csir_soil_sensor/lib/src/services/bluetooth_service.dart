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

  /// Normalizes a UUID string to handle both short and full formats.
  /// Returns the short form (4 hex digits) for comparison.
  /// For full UUIDs like "0000F001-0000-1000-8000-00805F9B34FB", extracts "f001".
  /// For short UUIDs like "f001", returns as is.
  String _normalizeUuid(String uuid) {
    final lower = uuid.toLowerCase().replaceAll('-', '').replaceAll(':', '');
    
    // If it's a full 128-bit UUID (32 hex chars), extract the 16-bit part
    if (lower.length == 32) {
      // Standard BLE base UUID: 0000XXXX-0000-1000-8000-00805F9B34FB
      // The 16-bit UUID is at positions 4-7 (characters 4-8 in 0-indexed)
      return lower.substring(4, 8);
    }
    
    // If it's already short form (4 hex digits), return as is
    if (lower.length == 4) {
      return lower;
    }
    
    // For other formats, try to extract last 4 digits
    return lower.length >= 4 ? lower.substring(lower.length - 4) : lower;
  }

  /// Checks if two UUIDs match (handles both short and full formats).
  bool _uuidMatches(String uuid1, String uuid2) {
    return _normalizeUuid(uuid1) == _normalizeUuid(uuid2);
  }

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
        print('Discovered ${services.length} BLE services');
        
        bool serviceFound = false;
        bool characteristicFound = false;
        
        for (final service in services) {
          final serviceUuid = service.uuid.toString();
          print('Service UUID: $serviceUuid');
          
          if (_uuidMatches(serviceUuid, soilSensorServiceUuid)) {
            serviceFound = true;
            print('Found matching service!');
            print('Service has ${service.characteristics.length} characteristics');
            
            for (final characteristic in service.characteristics) {
              final charUuid = characteristic.uuid.toString();
              print('Characteristic UUID: $charUuid');
              
              if (_uuidMatches(charUuid, soilSensorCharacteristicUuid)) {
                characteristicFound = true;
                print('Found matching characteristic!');
                
                _sensorCharacteristic = characteristic;
                
                // Enable notifications
                await characteristic.setNotifyValue(true);
                print('Notifications enabled');
                
                // Subscribe to value updates
                characteristic.onValueReceived.listen(
                  _onCharacteristicData,
                  onError: (error) {
                    print('Error receiving BLE data: $error');
                    state = state.copyWith(
                      connectionStatus: 'Data receive error: $error',
                    );
                  },
                );
                
                print('Listening for sensor data...');
                return;
              }
            }
          }
        }
        
        if (!serviceFound) {
          print('Warning: Service ${soilSensorServiceUuid} not found');
        } else if (!characteristicFound) {
          print('Warning: Characteristic ${soilSensorCharacteristicUuid} not found');
        }
      } catch (e) {
        print('Service discovery error: $e');
        // Don't fail the connection, but log the error
        state = state.copyWith(
          connectionStatus: 'Connected (service discovery failed: $e)',
        );
      }
    } catch (e) {
      state = state.copyWith(connectionStatus: 'Connection error: $e');
    }
  }

  void _onCharacteristicData(List<int> data) {
    try {
      if (data.isEmpty) {
        print('Received empty BLE data');
        return;
      }
      
      final payload = utf8.decode(data);
      print('Received BLE data: $payload');
      
      final jsonMap = jsonDecode(payload) as Map<String, dynamic>;
      print('Parsed JSON: $jsonMap');
      
      final reading = LiveReading.fromJson(jsonMap);
      print('Created LiveReading: timestamp=${reading.timestamp}, moisture=${reading.moisture}');
      
      state = state.copyWith(
        latestReading: reading,
        connectionStatus: 'Connected', // Ensure status stays "Connected"
      );
    } catch (e, stackTrace) {
      print('Error parsing BLE data: $e');
      print('Stack trace: $stackTrace');
      print('Raw data: ${data.map((b) => b.toRadixString(16)).join(' ')}');
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


