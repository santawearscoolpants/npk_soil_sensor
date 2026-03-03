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
  RealColumn get tds => real().withDefault(const Constant(0))();
  RealColumn get ecConv => real().nullable()();
  RealColumn get ecCal => real().nullable()();
  RealColumn get phConv => real().nullable()();
  RealColumn get phCal => real().nullable()();
  RealColumn get nConv => real().nullable()();
  RealColumn get nCal => real().nullable()();
  RealColumn get pConv => real().nullable()();
  RealColumn get pCal => real().nullable()();
  RealColumn get kConv => real().nullable()();
  RealColumn get kCal => real().nullable()();
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

  // Testing-only constructor to inject an in-memory database.
  AppDatabase.forTesting(super.executor) : super();

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < schemaVersion) {
        final existingColumns = await _existingColumns(
          sensorReadings.actualTableName,
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'tds',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.tds),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'ec_conv',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.ecConv),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'ec_cal',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.ecCal),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'ph_conv',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.phConv),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'ph_cal',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.phCal),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'n_conv',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.nConv),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'n_cal',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.nCal),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'p_conv',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.pConv),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'p_cal',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.pCal),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'k_conv',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.kConv),
        );
        await _addColumnIfMissing(
          existingColumns: existingColumns,
          columnName: 'k_cal',
          addColumn: () => m.addColumn(sensorReadings, sensorReadings.kCal),
        );
      }
    },
  );

  Future<Set<String>> _existingColumns(String tableName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();
    return rows.map((row) => row.data['name']).whereType<String>().toSet();
  }

  Future<void> _addColumnIfMissing({
    required Set<String> existingColumns,
    required String columnName,
    required Future<void> Function() addColumn,
  }) async {
    if (existingColumns.contains(columnName)) return;
    await addColumn();
    existingColumns.add(columnName);
  }
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
