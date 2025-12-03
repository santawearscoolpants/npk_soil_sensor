import 'package:drift/drift.dart';

import '../db/app_database.dart';

class SensorRepository {
  SensorRepository(this._db);

  final AppDatabase _db;

  Future<int> insertReading(SensorReadingsCompanion companion) {
    return _db.into(_db.sensorReadings).insert(companion);
  }

  Future<List<SensorReading>> getAllReadings() {
    return _db.select(_db.sensorReadings).get();
  }

  Stream<List<SensorReading>> watchAllReadings() {
    return _db.select(_db.sensorReadings).watch();
  }
}


