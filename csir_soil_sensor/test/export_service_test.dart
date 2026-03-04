import 'package:csir_soil_sensor/src/data/db/app_database.dart';
import 'package:csir_soil_sensor/src/services/export_service.dart';
import 'package:csir_soil_sensor/src/services/session_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSessionStore extends SessionStore {
  @override
  Future<List<ReadingSession>> loadSessions() async => [];

  @override
  Future<void> saveSessions(List<ReadingSession> sessions) async {}

  @override
  Future<ReadingSession> addSession(List<int> readingIds) {
    throw UnimplementedError();
  }
}

void main() {
  group('LocalExportService sensor CSV rows', () {
    late AppDatabase db;
    late LocalExportService service;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      service = LocalExportService(db, _FakeSessionStore());
    });

    tearDown(() async {
      await db.close();
    });

    test('includes only public sensor columns', () {
      final rows = service.buildSensorCsvRows([
        SensorReading(
          id: 42,
          timestamp: DateTime.utc(2026, 1, 2, 3, 4, 5),
          moisture: 31.5,
          ec: 1.8,
          temperature: 27.4,
          ph: 6.7,
          nitrogen: 14,
          phosphorus: 9,
          potassium: 22,
          salinity: 0.6,
          tds: 420.0,
          ecConv: 0.18,
          ecCal: 0.17,
          phConv: 6.8,
          phCal: 6.9,
          nConv: 0.12,
          nCal: 0.11,
          pConv: 10.0,
          pCal: 11.0,
          kConv: 12.0,
          kCal: 13.0,
          cropParamsId: 7,
        ),
      ]);

      expect(rows.first, [
        'id',
        'timestamp',
        'moisture (%)',
        'ec (mS/cm)',
        'temperature (°C)',
        'ph',
        'nitrogen (mg/kg)',
        'phosphorus (mg/kg)',
        'potassium (mg/kg)',
        'salinity (g/L)',
        'tds (ppm)',
      ]);
      expect(rows.first, isNot(contains('ecCal')));
      expect(rows.first, isNot(contains('nConv')));
      expect(rows.first, isNot(contains('cropParamsId')));
      expect(rows[1], [
        1,
        '2026-01-02T03:04:05.000Z',
        31.5,
        1.8,
        27.4,
        6.7,
        14,
        9,
        22,
        0.6,
        420.0,
      ]);
    });
  });
}
