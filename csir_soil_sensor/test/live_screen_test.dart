import 'package:csir_soil_sensor/src/data/db/app_database.dart';
import 'package:csir_soil_sensor/src/data/repositories/sensor_repository.dart';
import 'package:csir_soil_sensor/src/features/live/live_screen.dart';
import 'package:csir_soil_sensor/src/services/bluetooth_service.dart';
import 'package:csir_soil_sensor/src/services/permission_service.dart';
import 'package:csir_soil_sensor/src/services/session_store.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBluetoothService extends BluetoothService {
  FakeBluetoothService._(this._db, BluetoothStateModel initialState)
    : super(SensorRepository(_db), SessionStore(), PermissionService()) {
    state = initialState;
  }

  factory FakeBluetoothService(BluetoothStateModel initialState) {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    return FakeBluetoothService._(db, initialState);
  }

  final AppDatabase _db;

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  testWidgets('Live screen shows latest reading for connected warning states', (
    tester,
  ) async {
    final bluetoothService = FakeBluetoothService(
      BluetoothStateModel(
        connectionStatus: 'Connected (service discovery failed: timeout)',
        connectedDeviceName: 'ESP32 Soil Sensor',
        latestReading: LiveReading(
          timestamp: 1717434300,
          moisture: 34.2,
          ec: 1.8,
          temperature: 27.4,
          ph: 6.3,
          nitrogen: 45,
          phosphorus: 22,
          potassium: 60,
          salinity: 0.9,
          tds: 310,
          ecConv: 0.061,
          nConv: 0.1148,
          pConv: 7.8,
          kConv: 0.164,
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bluetoothServiceProvider.overrideWith((ref) => bluetoothService),
        ],
        child: const MaterialApp(home: LiveScreen()),
      ),
    );

    expect(find.text('Latest Reading'), findsOneWidget);
    expect(find.text('Calibrated Values'), findsOneWidget);
    expect(find.text('34.2 %'), findsOneWidget);
    expect(find.text('EC (conv)'), findsOneWidget);
    expect(
      find.textContaining('Connected (service discovery failed: timeout)'),
      findsOneWidget,
    );
  });

  testWidgets('Live screen surfaces BLE data errors explicitly', (
    tester,
  ) async {
    final bluetoothService = FakeBluetoothService(
      const BluetoothStateModel(
        connectionStatus: 'Connected',
        connectedDeviceName: 'ESP32 Soil Sensor',
        lastDataErrorMessage: 'Could not process sensor payload: invalid json',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bluetoothServiceProvider.overrideWith((ref) => bluetoothService),
        ],
        child: const MaterialApp(home: LiveScreen()),
      ),
    );

    expect(
      find.text('Could not process sensor payload: invalid json'),
      findsOneWidget,
    );
    expect(find.text('Waiting for the next sensor reading...'), findsOneWidget);
  });
}
