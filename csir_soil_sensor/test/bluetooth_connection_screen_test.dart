import 'package:csir_soil_sensor/src/data/db/app_database.dart';
import 'package:csir_soil_sensor/src/data/repositories/sensor_repository.dart';
import 'package:csir_soil_sensor/src/features/bluetooth/bluetooth_connection_screen.dart';
import 'package:csir_soil_sensor/src/services/bluetooth_service.dart';
import 'package:csir_soil_sensor/src/services/permission_service.dart';
import 'package:csir_soil_sensor/src/services/session_store.dart';
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
  bool disconnectCalled = false;

  @override
  Future<void> disconnect() async {
    disconnectCalled = true;
    state = BluetoothStateModel(
      connectionStatus: 'Disconnected',
      latestReading: state.latestReading,
    );
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }
}

void main() {
  testWidgets(
    'shows disconnect button for a selected device and disconnects cleanly',
    (tester) async {
      final bluetoothService = FakeBluetoothService(
        const BluetoothStateModel(
          connectionStatus: 'Connected (service discovery failed: timeout)',
          connectedDeviceName: 'ESP32 Soil Sensor',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bluetoothServiceProvider.overrideWith((ref) => bluetoothService),
          ],
          child: const MaterialApp(home: BluetoothConnectionScreen()),
        ),
      );

      expect(find.text('Disconnect from device'), findsOneWidget);

      await tester.tap(find.text('Disconnect from device'));
      await tester.pump();

      expect(bluetoothService.disconnectCalled, isTrue);
      expect(find.text('Disconnect from device'), findsNothing);
      expect(find.text('Disconnected'), findsOneWidget);
    },
  );
}
