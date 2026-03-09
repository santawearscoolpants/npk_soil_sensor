import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/repositories/sensor_repository.dart';
import 'bluetooth_constants.dart';
import 'permission_service.dart';
import 'session_store.dart';

const _noStateChange = Object();

void _logBluetoothEvent(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  int level = 800,
}) {
  developer.log(
    message,
    name: 'csir_soil_sensor.bluetooth',
    error: error,
    stackTrace: stackTrace,
    level: level,
  );
}

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
    required this.tds,

    this.ecConv,
    this.ecCal,
    this.phConv,
    this.phCal,
    this.nConv,
    this.nCal,
    this.pConv,
    this.pCal,
    this.kConv,
    this.kCal,
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

  // Raw TDS value (not persisted in history yet)
  final int tds;

  // Optional converted + calibrated values (if provided by firmware JSON)
  final double? ecConv; // EC converted (dS/m)
  final double? ecCal; // EC calibrated (dS/m)
  final double? phConv;
  final double? phCal;
  final double? nConv; // N converted (%)
  final double? nCal; // N calibrated (%)
  final double? pConv; // P converted (mg/kg)
  final double? pCal; // P calibrated (mg/kg)
  final double? kConv; // K converted (cmol(+)/kg)
  final double? kCal; // K calibrated (cmol(+)/kg)

  static const double _ecCalibrationSlope = 0.220636585;
  static const double _ecCalibrationOffset = 0.06098882155;
  static const double _phCalibrationSlope = 0.06749371859;
  static const double _phCalibrationOffset = 5.126893844;
  static const double _nCalibrationSlope = 0.005542328042;
  static const double _nCalibrationOffset = 0.1148412698;
  static const double _pCalibrationSlope = 0.0414315776;
  static const double _pCalibrationOffset = 7.840383242;
  static const double _kCalibrationSlope = 0.3580341716;
  static const double _kCalibrationOffset = 0.1642282588;

  bool get hasConvertedValues =>
      ecConv != null ||
      phConv != null ||
      nConv != null ||
      pConv != null ||
      kConv != null;

  bool get hasCalibratedValues =>
      ecCal != null ||
      phCal != null ||
      nCal != null ||
      pCal != null ||
      kCal != null;

  bool get hasDerivedValues => hasConvertedValues || hasCalibratedValues;

  double get ecConvertedValue => ecConv ?? (ec / 1000.0);
  double get phConvertedValue => phConv ?? ph;
  double get nitrogenConvertedValue => nConv ?? (nitrogen / 10000.0);
  double get phosphorusConvertedValue => pConv ?? phosphorus.toDouble();
  double get potassiumConvertedValue => kConv ?? (potassium / 391.0);

  double get ecCalibratedValue =>
      ecCal ?? (_ecCalibrationSlope * ecConvertedValue) + _ecCalibrationOffset;
  double get phCalibratedValue =>
      phCal ?? (_phCalibrationSlope * phConvertedValue) + _phCalibrationOffset;
  double get nitrogenCalibratedValue =>
      nCal ??
      (_nCalibrationSlope * nitrogenConvertedValue) + _nCalibrationOffset;
  double get phosphorusCalibratedValue =>
      pCal ??
      (_pCalibrationSlope * phosphorusConvertedValue) + _pCalibrationOffset;
  double get potassiumCalibratedValue =>
      kCal ??
      (_kCalibrationSlope * potassiumConvertedValue) + _kCalibrationOffset;

  double get ecDisplayValue => ecConv ?? ecCal ?? ec;
  String get ecDisplayUnit =>
      (ecConv != null || ecCal != null) ? 'dS/m' : 'mS/cm';

  double get phDisplayValue => phConv ?? phCal ?? ph;

  double get nitrogenDisplayValue => nConv ?? nCal ?? nitrogen.toDouble();
  String get nitrogenDisplayUnit =>
      (nConv != null || nCal != null) ? '%' : 'mg/kg';
  int get nitrogenDisplayPrecision => (nConv != null || nCal != null) ? 4 : 0;

  double get phosphorusDisplayValue => pConv ?? pCal ?? phosphorus.toDouble();
  String get phosphorusDisplayUnit =>
      (pConv != null || pCal != null) ? 'mg/kg' : 'mg/kg';
  int get phosphorusDisplayPrecision => (pConv != null || pCal != null) ? 1 : 0;

  double get potassiumDisplayValue => kConv ?? kCal ?? potassium.toDouble();
  String get potassiumDisplayUnit =>
      (kConv != null || kCal != null) ? 'cmol(+)/kg' : 'mg/kg';
  int get potassiumDisplayPrecision => (kConv != null || kCal != null) ? 3 : 0;

  static num? _readNum(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
  }) {
    for (final candidate in [key, ...aliases]) {
      final value = json[candidate];
      if (value == null) continue;
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
    }
    return null;
  }

  static double _requiredDouble(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
  }) {
    final value = _readNum(json, key, aliases: aliases);
    if (value == null) {
      throw FormatException('Missing numeric field: $key');
    }
    return value.toDouble();
  }

  static int _requiredInt(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
  }) {
    final value = _readNum(json, key, aliases: aliases);
    if (value == null) {
      throw FormatException('Missing numeric field: $key');
    }
    return value.toInt();
  }

  static double? _optionalDouble(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
  }) {
    return _readNum(json, key, aliases: aliases)?.toDouble();
  }

  factory LiveReading.fromJson(Map<String, dynamic> json) {
    final timestampValue = _readNum(json, 'timestamp');
    final ecConverted = _optionalDouble(json, 'ec_conv', aliases: ['ec_dSm']);
    final ecCalibrated = _optionalDouble(json, 'ec_cal');
    final phConverted = _optionalDouble(json, 'ph_conv');
    final phCalibrated = _optionalDouble(json, 'ph_cal');
    final nitrogenConverted = _optionalDouble(
      json,
      'n_conv',
      aliases: ['n_percent'],
    );
    final nitrogenCalibrated = _optionalDouble(json, 'n_cal');
    final phosphorusConverted = _optionalDouble(
      json,
      'p_conv',
      aliases: ['p_mgkg'],
    );
    final phosphorusCalibrated = _optionalDouble(json, 'p_cal');
    final potassiumConverted = _optionalDouble(
      json,
      'k_conv',
      aliases: ['k_cmolkg'],
    );
    final potassiumCalibrated = _optionalDouble(json, 'k_cal');

    return LiveReading(
      timestamp:
          timestampValue?.toInt() ??
          (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      moisture: _requiredDouble(json, 'moisture', aliases: ['moisture_pct']),
      ec: _requiredDouble(json, 'ec', aliases: ['ec_dSm']),
      temperature: _requiredDouble(
        json,
        'temperature',
        aliases: ['temperature_c'],
      ),
      ph: _requiredDouble(json, 'ph'),
      nitrogen:
          _readNum(json, 'nitrogen')?.toInt() ??
          ((nitrogenCalibrated ?? nitrogenConverted) != null
              ? ((nitrogenCalibrated ?? nitrogenConverted)! * 10000).round()
              : _requiredInt(json, 'nitrogen')),
      phosphorus:
          _readNum(json, 'phosphorus')?.toInt() ??
          ((phosphorusCalibrated ?? phosphorusConverted) != null
              ? (phosphorusCalibrated ?? phosphorusConverted)!.round()
              : _requiredInt(json, 'phosphorus')),
      potassium:
          _readNum(json, 'potassium')?.toInt() ??
          ((potassiumCalibrated ?? potassiumConverted) != null
              ? ((potassiumCalibrated ?? potassiumConverted)! * 391).round()
              : _requiredInt(json, 'potassium')),
      salinity: _requiredDouble(json, 'salinity'),
      tds: _readNum(json, 'tds')?.toInt() ?? 0,
      ecConv: ecConverted,
      ecCal: ecCalibrated,
      phConv: phConverted,
      phCal: phCalibrated,
      nConv: nitrogenConverted,
      nCal: nitrogenCalibrated,
      pConv: phosphorusConverted,
      pCal: phosphorusCalibrated,
      kConv: potassiumConverted,
      kCal: potassiumCalibrated,
    );
  }
}

class DiscoveredDevice {
  DiscoveredDevice({required this.device, required this.name});

  final BluetoothDevice device;
  final String name;
}

class BluetoothStateModel {
  const BluetoothStateModel({
    required this.connectionStatus,
    this.latestReading,
    this.devices = const [],
    this.connectedDeviceName,
    this.pendingCount = 0,
    this.lastDataErrorMessage,
  });

  final String connectionStatus;
  final LiveReading? latestReading;
  final List<DiscoveredDevice> devices;
  final String? connectedDeviceName;
  final int pendingCount;
  final String? lastDataErrorMessage;

  bool get isConnected => connectionStatus.startsWith('Connected');
  bool get isConnecting => connectionStatus.startsWith('Connecting');
  bool get isScanning => connectionStatus.startsWith('Scanning');
  bool get isDisconnected => connectionStatus.startsWith('Disconnected');
  bool get hasSelectedDevice => connectedDeviceName != null;
  bool get hasLiveReading => latestReading != null;
  bool get canDisplayLiveReading => hasSelectedDevice && hasLiveReading;
  bool get hasConnectionIssue =>
      lastDataErrorMessage != null && lastDataErrorMessage!.isNotEmpty;
  bool get hasActiveDeviceSession => hasSelectedDevice && !isDisconnected;

  BluetoothStateModel copyWith({
    String? connectionStatus,
    LiveReading? latestReading,
    List<DiscoveredDevice>? devices,
    Object? connectedDeviceName = _noStateChange,
    int? pendingCount,
    Object? lastDataErrorMessage = _noStateChange,
  }) {
    return BluetoothStateModel(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      latestReading: latestReading ?? this.latestReading,
      devices: devices ?? this.devices,
      connectedDeviceName: identical(connectedDeviceName, _noStateChange)
          ? this.connectedDeviceName
          : connectedDeviceName as String?,
      pendingCount: pendingCount ?? this.pendingCount,
      lastDataErrorMessage: identical(lastDataErrorMessage, _noStateChange)
          ? this.lastDataErrorMessage
          : lastDataErrorMessage as String?,
    );
  }
}

({List<String> messages, String remainder}) splitJsonPayloads(String buffer) {
  final messages = <String>[];
  final firstBrace = buffer.indexOf('{');
  if (firstBrace == -1) {
    return (messages: messages, remainder: '');
  }

  final trimmedBuffer = buffer.substring(firstBrace);
  int depth = 0;
  int? objectStart;
  int lastConsumedIndex = 0;
  bool inString = false;
  bool isEscaped = false;

  for (var i = 0; i < trimmedBuffer.length; i++) {
    final char = trimmedBuffer[i];

    if (isEscaped) {
      isEscaped = false;
      continue;
    }

    if (char == r'\') {
      isEscaped = true;
      continue;
    }

    if (char == '"') {
      inString = !inString;
      continue;
    }

    if (inString) {
      continue;
    }

    if (char == '{') {
      objectStart ??= i;
      depth++;
      continue;
    }

    if (char == '}') {
      if (depth == 0) {
        continue;
      }

      depth--;
      if (depth == 0 && objectStart != null) {
        messages.add(trimmedBuffer.substring(objectStart, i + 1));
        lastConsumedIndex = i + 1;
        objectStart = null;
      }
    }
  }

  final remainder = lastConsumedIndex == 0
      ? trimmedBuffer
      : trimmedBuffer.substring(lastConsumedIndex);

  return (messages: messages, remainder: remainder);
}

bool isSensorReadingPayload(Map<String, dynamic> json) {
  const keyGroups = [
    ['moisture', 'moisture_pct'],
    ['ec', 'ec_dSm'],
    ['temperature', 'temperature_c'],
    ['ph'],
    ['nitrogen', 'n_percent', 'n_conv', 'n_cal'],
    ['phosphorus', 'p_mgkg', 'p_conv', 'p_cal'],
    ['potassium', 'k_cmolkg', 'k_conv', 'k_cal'],
    ['salinity'],
  ];

  return keyGroups.every((group) => group.any(json.containsKey));
}

class BluetoothService extends StateNotifier<BluetoothStateModel> {
  BluetoothService(
    this._sensorRepository,
    this._sessionStore,
    this._permissionService,
  ) : super(const BluetoothStateModel(connectionStatus: 'Disconnected'));

  final SensorRepository _sensorRepository;
  final SessionStore _sessionStore;
  final PermissionService _permissionService;

  BluetoothDevice? _connectedDevice;
  // ignore: unused_field
  BluetoothCharacteristic? _sensorCharacteristic;
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  final List<int> _pendingReadingIds = [];
  int? _activeCropParamsId;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _shouldIgnoreScanResults = false;
  String _payloadBuffer = '';

  void setActiveCropParamsId(int? id) {
    _activeCropParamsId = id;
  }

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

  Future<void> _cancelScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<void> scanForDevices() async {
    try {
      // Ensure permissions first (Android requires runtime permissions)
      final perm = await _permissionService.ensureBluetoothPermissions();
      if (perm != BlePermissionState.granted) {
        state = state.copyWith(
          connectionStatus: perm == BlePermissionState.permanentlyDenied
              ? 'Bluetooth permission permanently denied. Enable it in Settings.'
              : 'Bluetooth permission denied. Please allow to scan.',
          devices: [],
          lastDataErrorMessage: null,
        );
        return;
      }

      // If already connected, keep status but allow a fresh scan if user wants.
      // Cancel any previous scan subscriptions to avoid stale results.
      await _cancelScan();

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        // On Android, prompt the system dialog to enable Bluetooth.
        if (Platform.isAndroid) {
          try {
            await FlutterBluePlus.turnOn();
          } catch (_) {}
        }

        final newState = await FlutterBluePlus.adapterState.first;
        if (newState != BluetoothAdapterState.on) {
          state = state.copyWith(
            connectionStatus: 'Bluetooth is off. Please turn it on.',
            devices: [],
          );
          return;
        }
      }

      state = state.copyWith(
        connectionStatus: 'Scanning for devices...',
        devices: [],
        lastDataErrorMessage: null,
      );

      final Map<String, DiscoveredDevice> devices = {};
      _shouldIgnoreScanResults = false; // Reset flag for new scan
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        // If we've already selected a device (even if not fully connected yet), ignore further scan results.
        if (_shouldIgnoreScanResults || state.connectedDeviceName != null) {
          return;
        }
        for (final result in results) {
          final dev = result.device;
          final name = dev.platformName.isNotEmpty
              ? dev.platformName
              : dev.remoteId.str;
          devices[dev.remoteId.str] = DiscoveredDevice(device: dev, name: name);
        }
        if (devices.isNotEmpty) {
          state = state.copyWith(devices: devices.values.toList());
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      // Wait for the scan to finish (timeout handled by startScan).
      await Future.delayed(const Duration(seconds: 10));
      await _cancelScan();

      // Only update state if we're still not connected (user might have connected during scan)
      final connected = state.isConnected;
      if (!connected) {
        state = state.copyWith(
          connectionStatus: devices.isEmpty
              ? 'No BLE devices found. Make sure the ESP32 is powered and advertising.'
              : 'Tap a device to connect',
          devices: devices.values.toList(),
          lastDataErrorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        connectionStatus: 'Error: $e',
        lastDataErrorMessage: 'Bluetooth scan failed: $e',
      );
    }
  }

  Future<void> connectToDevice(DiscoveredDevice device) async {
    // Stop any ongoing scan when user chooses a device.
    _shouldIgnoreScanResults = true; // Stop processing scan results
    await _cancelScan();
    _payloadBuffer = '';

    _connectedDevice = device.device;
    // Clear device list immediately when user selects a device
    state = state.copyWith(
      connectedDeviceName: device.name,
      devices: const [],
      lastDataErrorMessage: null,
    );
    await _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    final device = _connectedDevice;
    if (device == null) {
      state = state.copyWith(connectionStatus: 'No device selected');
      return;
    }

    state = state.copyWith(
      connectionStatus: 'Connecting...',
      lastDataErrorMessage: null,
    );
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      // Mark as connected for UI purposes regardless of service layout.
      state = state.copyWith(
        connectionStatus: 'Connected',
        devices: const [],
        lastDataErrorMessage: null,
      );

      // Listen for connection state changes to detect disconnections
      await _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen(
        (connectionState) {
          if (connectionState == BluetoothConnectionState.disconnected) {
            // Device disconnected (either manually or device turned off)
            _handleDisconnection();
          }
        },
        onError: (error) {
          _logBluetoothEvent(
            'Connection state stream error',
            error: error,
            level: 1000,
          );
          _handleDisconnection();
        },
      );

      // Try to discover the soil sensor characteristic in the background.
      try {
        final services = await device.discoverServices();
        _logBluetoothEvent('Discovered ${services.length} BLE services');

        bool serviceFound = false;
        bool characteristicFound = false;

        for (final service in services) {
          final serviceUuid = service.uuid.toString();
          _logBluetoothEvent('Discovered service UUID: $serviceUuid');

          if (_uuidMatches(serviceUuid, soilSensorServiceUuid)) {
            serviceFound = true;
            _logBluetoothEvent('Found matching BLE service');
            _logBluetoothEvent(
              'Service has ${service.characteristics.length} characteristics',
            );

            for (final characteristic in service.characteristics) {
              final charUuid = characteristic.uuid.toString();
              _logBluetoothEvent('Discovered characteristic UUID: $charUuid');

              if (_uuidMatches(charUuid, soilSensorCharacteristicUuid)) {
                characteristicFound = true;
                _logBluetoothEvent('Found matching BLE characteristic');

                _sensorCharacteristic = characteristic;

                // Enable notifications
                await characteristic.setNotifyValue(true);
                _logBluetoothEvent('Notifications enabled');

                // Cancel any existing subscription before creating a new one
                await _characteristicSubscription?.cancel();

                // Subscribe to value updates
                _characteristicSubscription = characteristic.onValueReceived
                    .listen(
                      (data) {
                        _onCharacteristicData(data);
                      },
                      onError: (error) {
                        _logBluetoothEvent(
                          'BLE data listener error',
                          error: error,
                          level: 1000,
                        );
                        state = state.copyWith(
                          connectionStatus: 'Data receive error: $error',
                          lastDataErrorMessage:
                              'BLE notification listener error: $error',
                        );
                      },
                    );

                _logBluetoothEvent('Listening for sensor data');
                return;
              }
            }
          }
        }

        if (!serviceFound) {
          _logBluetoothEvent(
            'Expected BLE service not found: $soilSensorServiceUuid',
            level: 900,
          );
        } else if (!characteristicFound) {
          _logBluetoothEvent(
            'Expected BLE characteristic not found: '
            '$soilSensorCharacteristicUuid',
            level: 900,
          );
        }
      } catch (e) {
        _logBluetoothEvent('Service discovery error', error: e, level: 1000);
        // Don't fail the connection, but log the error
        state = state.copyWith(
          connectionStatus: 'Connected (service discovery failed: $e)',
          lastDataErrorMessage:
              'Connected, but service discovery did not complete: $e',
        );
      }
    } catch (e) {
      // Connection failed - clean up
      await _connectionStateSubscription?.cancel();
      _connectionStateSubscription = null;
      _connectedDevice = null;
      state = state.copyWith(
        connectionStatus: 'Connection error: $e',
        connectedDeviceName: null,
        lastDataErrorMessage: 'Bluetooth connection failed: $e',
      );
    }
  }

  Future<void> _onCharacteristicData(List<int> data) async {
    if (data.isEmpty) {
      _logBluetoothEvent('Received empty BLE payload', level: 900);
      return;
    }

    final payloadChunk = utf8.decode(data, allowMalformed: true);
    _logBluetoothEvent('Received BLE data chunk: $payloadChunk');

    _payloadBuffer += payloadChunk;
    final splitResult = splitJsonPayloads(_payloadBuffer);
    _payloadBuffer = splitResult.remainder;

    for (final payload in splitResult.messages) {
      try {
        final decoded = jsonDecode(payload);
        if (decoded is! Map<String, dynamic>) {
          _logBluetoothEvent(
            'Ignoring non-object BLE payload: $payload',
            level: 900,
          );
          continue;
        }

        if (!isSensorReadingPayload(decoded)) {
          _logBluetoothEvent(
            'Ignoring non-sensor BLE payload: $decoded',
            level: 900,
          );
          continue;
        }

        final rawReading = LiveReading.fromJson(decoded);

        // Normalize timestamp: if it looks too small (e.g., millis since boot),
        // replace with current Unix time so UI and exports show a real date.
        final normalizedSeconds = rawReading.timestamp > 946684800
            ? rawReading.timestamp
            : DateTime.now().millisecondsSinceEpoch ~/ 1000;

        final reading = LiveReading(
          timestamp: normalizedSeconds,
          moisture: rawReading.moisture,
          ec: rawReading.ec,
          temperature: rawReading.temperature,
          ph: rawReading.ph,
          nitrogen: rawReading.nitrogen,
          phosphorus: rawReading.phosphorus,
          potassium: rawReading.potassium,
          salinity: rawReading.salinity,
          tds: rawReading.tds,
          ecConv: rawReading.ecConv,
          ecCal: rawReading.ecCal,
          phConv: rawReading.phConv,
          phCal: rawReading.phCal,
          nConv: rawReading.nConv,
          nCal: rawReading.nCal,
          pConv: rawReading.pConv,
          pCal: rawReading.pCal,
          kConv: rawReading.kConv,
          kCal: rawReading.kCal,
        );

        _logBluetoothEvent(
          'Created LiveReading: timestamp=${reading.timestamp}, moisture=${reading.moisture}',
        );

        // Persist immediately and track pending batch ids
        final ts = DateTime.fromMillisecondsSinceEpoch(
          reading.timestamp * 1000,
        );

        final id = await _sensorRepository.insertReading(
          SensorReadingsCompanion.insert(
            timestamp: ts,
            moisture: reading.moisture,
            ec: reading.ec,
            temperature: reading.temperature,
            ph: reading.ph,
            nitrogen: reading.nitrogen,
            phosphorus: reading.phosphorus,
            potassium: reading.potassium,
            salinity: reading.salinity,
            tds: drift.Value(reading.tds.toDouble()),
            ecConv: drift.Value(reading.ecConv),
            ecCal: drift.Value(reading.ecCal),
            phConv: drift.Value(reading.phConv),
            phCal: drift.Value(reading.phCal),
            nConv: drift.Value(reading.nConv),
            nCal: drift.Value(reading.nCal),
            pConv: drift.Value(reading.pConv),
            pCal: drift.Value(reading.pCal),
            kConv: drift.Value(reading.kConv),
            kCal: drift.Value(reading.kCal),
            cropParamsId: _activeCropParamsId != null
                ? drift.Value(_activeCropParamsId!)
                : const drift.Value.absent(),
          ),
        );
        _pendingReadingIds.add(id);

        state = state.copyWith(
          latestReading: reading,
          connectionStatus: 'Connected',
          pendingCount: _pendingReadingIds.length,
          lastDataErrorMessage: null,
        );
      } catch (e, stackTrace) {
        _logBluetoothEvent(
          'Error parsing BLE payload: $payload',
          error: e,
          stackTrace: stackTrace,
          level: 1000,
        );
        state = state.copyWith(
          lastDataErrorMessage: 'Could not process sensor payload: $e',
        );
      }
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
        lastDataErrorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        connectionStatus: 'Demo parse error: $e',
        lastDataErrorMessage: 'Demo payload parsing failed: $e',
      );
    }
  }

  Future<ReadingSession?> savePendingReadings() async {
    if (_pendingReadingIds.isEmpty) return null;
    final session = await _sessionStore.addSession(_pendingReadingIds);
    _pendingReadingIds.clear();
    state = state.copyWith(pendingCount: 0);
    return session;
  }

  void discardPendingReadings() {
    _pendingReadingIds.clear();
    state = state.copyWith(pendingCount: 0);
  }

  void _handleDisconnection() {
    // This is called when the device disconnects unexpectedly (e.g., device turned off)
    // Cancel subscriptions
    _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    // Clear device references
    _connectedDevice = null;
    _sensorCharacteristic = null;
    _payloadBuffer = '';

    // Update state to reflect disconnection
    state = BluetoothStateModel(
      connectionStatus: 'Disconnected (device disconnected)',
      connectedDeviceName: null,
      devices: const [],
      pendingCount:
          _pendingReadingIds.length, // Keep pending count so user can save
      latestReading: state.latestReading, // Preserve latest reading
      lastDataErrorMessage: null,
    );

    _shouldIgnoreScanResults =
        false; // Allow scan results again after disconnect
  }

  Future<void> disconnect() async {
    _shouldIgnoreScanResults =
        false; // Allow scan results again after disconnect
    await _cancelScan();

    // Cancel characteristic subscription and disable notifications
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;

    // Cancel connection state subscription
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    try {
      // Disable notifications before disconnecting
      if (_sensorCharacteristic != null) {
        try {
          await _sensorCharacteristic!.setNotifyValue(false);
        } catch (_) {
          // ignore if already disconnected
        }
      }
      await _connectedDevice?.disconnect();
    } catch (_) {
      // ignore disconnect errors
    }

    _connectedDevice = null;
    _sensorCharacteristic = null;
    _pendingReadingIds.clear();
    _payloadBuffer = '';

    // Fully reset state to ensure clean disconnection - clear everything except latestReading
    // Use a fresh state to avoid any potential stale data
    state = BluetoothStateModel(
      connectionStatus: 'Disconnected',
      connectedDeviceName: null,
      devices: const [],
      pendingCount: 0,
      latestReading: state
          .latestReading, // Preserve latest reading (UI will hide it when disconnected)
      lastDataErrorMessage: null,
    );
  }
}

final bluetoothServiceProvider =
    StateNotifierProvider<BluetoothService, BluetoothStateModel>((ref) {
      final db = ref.watch(appDatabaseProvider);
      final repo = SensorRepository(db);
      final sessions = ref.read(sessionStoreProvider);
      final permissions = ref.read(permissionServiceProvider);
      return BluetoothService(repo, sessions, permissions);
    });
