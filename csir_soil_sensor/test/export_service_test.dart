import 'dart:io';

import 'package:csir_soil_sensor/src/data/db/app_database.dart';
import 'package:csir_soil_sensor/src/services/export_service.dart';
import 'package:csir_soil_sensor/src/services/session_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

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
        'salinity (mg/L)',
        'tds (mg/L)',
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
        600.0,
        420.0,
      ]);
    });
  });

  group('LocalExportService combined CSV rows', () {
    late AppDatabase db;
    late LocalExportService service;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      service = LocalExportService(db, _FakeSessionStore());
    });

    tearDown(() async {
      await db.close();
    });

    test('includes crop values without internal sensor fields', () {
      final rows = service.buildCombinedCsvRows(
        readings: [
          SensorReading(
            id: 1,
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
            cropParamsId: 7,
          ),
        ],
        cropParamsList: [
          CropParam(
            id: 7,
            createdAt: DateTime.utc(2026, 1, 1),
            soilType: 'Loam',
            soilProperties: 'Well drained',
            leafColor: 'Dark green',
            stemDescription: 'Firm',
            heightCm: 42.0,
            notes: 'Healthy crop',
          ),
        ],
        imagesByCropId: {
          7: ['Crop_001.jpg'],
        },
      );

      expect(rows.first, [
        'readingId',
        'timestamp',
        'moisture (%)',
        'ec (mS/cm)',
        'temperature (°C)',
        'ph',
        'nitrogen (mg/kg)',
        'phosphorus (mg/kg)',
        'potassium (mg/kg)',
        'salinity (mg/L)',
        'tds (mg/L)',
        'soilType',
        'soilProperties',
        'leafColor',
        'stemDescription',
        'heightCm (cm)',
        'notes',
        'imageFilenames',
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
        600.0,
        420.0,
        'Loam',
        'Well drained',
        'Dark green',
        'Firm',
        42.0,
        'Healthy crop',
        'Crop_001.jpg',
      ]);
    });

    test('falls back to the only crop parameter set for unlinked readings', () {
      final rows = service.buildCombinedCsvRows(
        readings: [
          SensorReading(
            id: 1,
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
            cropParamsId: null,
          ),
        ],
        cropParamsList: [
          CropParam(
            id: 3,
            createdAt: DateTime.utc(2026, 1, 1),
            soilType: 'Clay',
            soilProperties: 'Dense',
            leafColor: 'Pale green',
            stemDescription: 'Thin',
            heightCm: 18.0,
            notes: 'Needs nutrients',
          ),
        ],
        imagesByCropId: {
          3: ['Crop_003.jpg'],
        },
      );

      expect(rows[1].sublist(11), [
        'Clay',
        'Dense',
        'Pale green',
        'Thin',
        18.0,
        'Needs nutrients',
        'Crop_003.jpg',
      ]);
    });
  });

  group('LocalExportService PDF crop overview', () {
    late AppDatabase db;
    late LocalExportService service;
    late List<CropParam> crops;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      service = LocalExportService(db, _FakeSessionStore());
      crops = [
        CropParam(
          id: 1,
          createdAt: DateTime.utc(2026, 1, 1),
          soilType: 'Loam',
          soilProperties: 'Well drained',
          leafColor: 'Dark green',
          stemDescription: 'Firm',
          heightCm: 42.0,
          notes: 'Healthy crop',
        ),
        CropParam(
          id: 2,
          createdAt: DateTime.utc(2026, 1, 2),
          soilType: 'Clay',
          soilProperties: 'Dense',
          leafColor: 'Pale green',
          stemDescription: 'Thin',
          heightCm: 18.0,
          notes: 'Needs nutrients',
        ),
      ];
    });

    tearDown(() async {
      await db.close();
    });

    test('includes crop parameter overview only for all-sessions report', () {
      expect(
        service
            .pdfOverviewCropParams(sessionId: null, allCropParams: crops)
            .map((crop) => crop.id)
            .toList(),
        [1, 2],
      );
      expect(
        service.pdfOverviewCropParams(sessionId: 1, allCropParams: crops),
        isEmpty,
      );
    });
  });

  group('LocalExportService export-all crop image selection', () {
    late AppDatabase db;
    late LocalExportService service;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      service = LocalExportService(db, _FakeSessionStore());
    });

    tearDown(() async {
      await db.close();
    });

    test('collects only crop ids resolved into the combined export', () {
      final cropIds = service.combinedExportCropIds(
        readings: [
          SensorReading(
            id: 1,
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
            cropParamsId: 7,
          ),
          SensorReading(
            id: 2,
            timestamp: DateTime.utc(2026, 1, 2, 3, 5, 5),
            moisture: 32.0,
            ec: 1.9,
            temperature: 27.6,
            ph: 6.6,
            nitrogen: 15,
            phosphorus: 10,
            potassium: 23,
            salinity: 0.7,
            tds: 430.0,
            cropParamsId: 7,
          ),
        ],
        cropParamsList: [
          CropParam(
            id: 7,
            createdAt: DateTime.utc(2026, 1, 1),
            soilType: 'Loam',
            soilProperties: 'Well drained',
            leafColor: 'Dark green',
            stemDescription: 'Firm',
            heightCm: 42.0,
            notes: 'Healthy crop',
          ),
          CropParam(
            id: 9,
            createdAt: DateTime.utc(2026, 1, 3),
            soilType: 'Clay',
            soilProperties: 'Dense',
            leafColor: 'Pale green',
            stemDescription: 'Thin',
            heightCm: 18.0,
            notes: 'Needs nutrients',
          ),
        ],
      );

      expect(cropIds, {7});
    });
  });

  group('LocalExportService image path resolution', () {
    late AppDatabase db;
    late LocalExportService service;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      service = LocalExportService(db, _FakeSessionStore());
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'resolves image from fallback crop_images directory when stored path is stale',
      () async {
        final appDir = Directory.systemTemp.createTempSync(
          'crop_image_export_test',
        );
        addTearDown(() async {
          if (await appDir.exists()) {
            await appDir.delete(recursive: true);
          }
        });

        final imagesDir = Directory(p.join(appDir.path, 'crop_images'))
          ..createSync(recursive: true);
        final fallbackFile = File(p.join(imagesDir.path, 'Crop_001.jpg'))
          ..writeAsStringSync('fake image bytes');

        final resolved = await service.resolveCropImageFileForTest(
          CropImage(
            id: 1,
            cropParamsId: 7,
            filePath: p.join(appDir.path, 'missing', 'Crop_001.jpg'),
            relabelledFileName: 'Crop_001.jpg',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
          appDocumentsPath: appDir.path,
        );

        expect(resolved?.path, fallbackFile.path);
      },
    );
  });
}
