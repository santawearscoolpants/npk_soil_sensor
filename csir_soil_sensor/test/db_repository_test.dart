import 'package:flutter_test/flutter_test.dart';

import 'package:csir_soil_sensor/src/data/db/app_database.dart';
import 'package:drift/native.dart';

void main() {
  group('SensorRepository + Drift', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('can insert and read back sensor readings', () async {
      await db.into(db.sensorReadings).insert(
            SensorReadingsCompanion.insert(
              timestamp: DateTime.utc(2024, 1, 1),
              moisture: 30,
              ec: 1.2,
              temperature: 25,
              ph: 6.5,
              nitrogen: 40,
              phosphorus: 20,
              potassium: 50,
              salinity: 0.8,
            ),
          );

      final all = await db.select(db.sensorReadings).get();
      expect(all.length, 1);
      expect(all.first.moisture, 30);
      expect(all.first.nitrogen, 40);
    });
  });
}


