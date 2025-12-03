import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class SensorReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get moisture => real()();
  RealColumn get ec => real()();
  RealColumn get temperature => real()();
  RealColumn get ph => real()();
  IntColumn get nitrogen => integer()();
  IntColumn get phosphorus => integer()();
  IntColumn get potassium => integer()();
  RealColumn get salinity => real()();
  IntColumn get cropParamsId =>
      integer().nullable().references(CropParams, #id)();
}

class CropParams extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get soilType => text()();
  TextColumn get soilProperties => text()();
  TextColumn get leafColor => text()();
  TextColumn get stemDescription => text()();
  RealColumn get heightCm => real()();
  TextColumn get notes => text().nullable()();
}

class CropImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cropParamsId =>
      integer().references(CropParams, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
  TextColumn get relabelledFileName => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [SensorReadings, CropParams, CropImages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'csir_soil_sensor.sqlite');
    return NativeDatabase(File(dbPath));
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});


