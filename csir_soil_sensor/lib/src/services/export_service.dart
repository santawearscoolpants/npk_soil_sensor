import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../data/db/app_database.dart';
import '../data/repositories/crop_repository.dart';
import '../data/repositories/sensor_repository.dart';

/// Abstraction for export logic so we can plug in other backends later
/// (Google Drive, external DB, etc.).
abstract class ExportService {
  Future<String> exportSensorCsv();
  Future<String> exportCombinedCsv();
  Future<String> exportPdfReport();
  Future<String> exportImages();
  Future<String> exportCropParamsCsv();
}

class LocalExportService implements ExportService {
  LocalExportService(this._db);

  final AppDatabase _db;

  Future<File> _createTempFile(String name) async {
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, name);
    return File(path).create(recursive: true);
  }

  @override
  Future<String> exportSensorCsv() async {
    final sensorRepo = SensorRepository(_db);
    final readings = await sensorRepo.getAllReadings();

    final rows = <List<dynamic>>[
      [
        'id',
        'timestamp',
        'moisture',
        'ec',
        'temperature',
        'ph',
        'nitrogen',
        'phosphorus',
        'potassium',
        'salinity',
        'cropParamsId',
      ],
      ...readings.map((r) => [
            r.id,
            r.timestamp.toIso8601String(),
            r.moisture,
            r.ec,
            r.temperature,
            r.ph,
            r.nitrogen,
            r.phosphorus,
            r.potassium,
            r.salinity,
            r.cropParamsId ?? '', // Handle null as empty string
          ]),
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final file = await _createTempFile('sensor_readings.csv');
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)]);
    return 'Sensor CSV exported and share sheet opened.';
  }

  @override
  Future<String> exportCombinedCsv() async {
    final sensorRepo = SensorRepository(_db);
    final cropRepo = CropRepository(_db);

    final readings = await sensorRepo.getAllReadings();
    final cropParamsList = await cropRepo.getAllCropParams();
    final cropParamsById = {for (final c in cropParamsList) c.id: c};

    // Get all images grouped by cropParamsId
    final imagesByCropId = <int, List<String>>{};
    for (final crop in cropParamsList) {
      final images = await cropRepo.getImagesForCrop(crop.id);
      imagesByCropId[crop.id] = images
          .map((img) => img.relabelledFileName)
          .toList();
    }

    final rows = <List<dynamic>>[
      [
        'readingId',
        'timestamp',
        'moisture',
        'ec',
        'temperature',
        'ph',
        'nitrogen',
        'phosphorus',
        'potassium',
        'salinity',
        'cropParamsId',
        'soilType',
        'soilProperties',
        'leafColor',
        'stemDescription',
        'heightCm',
        'notes',
        'imageFilenames',
      ],
      ...readings.map((r) {
        final cp = r.cropParamsId != null ? cropParamsById[r.cropParamsId] : null;
        final imageFilenames = r.cropParamsId != null
            ? (imagesByCropId[r.cropParamsId] ?? []).join('; ')
            : '';
        return [
          r.id,
          r.timestamp.toIso8601String(),
          r.moisture,
          r.ec,
          r.temperature,
          r.ph,
          r.nitrogen,
          r.phosphorus,
          r.potassium,
          r.salinity,
          r.cropParamsId ?? '', // Handle null as empty string
          cp?.soilType ?? '',
          cp?.soilProperties ?? '',
          cp?.leafColor ?? '',
          cp?.stemDescription ?? '',
          cp?.heightCm ?? '',
          cp?.notes ?? '',
          imageFilenames,
        ];
      }),
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final file = await _createTempFile('combined_data.csv');
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)]);
    return 'Combined CSV exported and share sheet opened.';
  }

  @override
  Future<String> exportPdfReport() async {
    final sensorRepo = SensorRepository(_db);
    final cropRepo = CropRepository(_db);

    final readings = await sensorRepo.getAllReadings();
    final crops = await cropRepo.getAllCropParams();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Text(
              'Tomato Soil Sensor Report',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Generated: ${DateTime.now()}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Crop parameter sets',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: const [
                'ID',
                'Created',
                'Soil type',
                'Leaf color',
                'Height (cm)',
              ],
              data: crops
                  .map(
                    (c) => [
                      c.id,
                      c.createdAt.toIso8601String(),
                      c.soilType,
                      c.leafColor,
                      c.heightCm.toStringAsFixed(1),
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Recent sensor readings',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: const [
                'Time',
                'Moisture',
                'EC',
                'Temp',
                'pH',
                'N',
                'P',
                'K',
                'Salinity',
              ],
              data: readings
                  .take(50)
                  .map(
                    (r) => [
                      r.timestamp.toIso8601String(),
                      r.moisture.toStringAsFixed(1),
                      r.ec.toStringAsFixed(2),
                      r.temperature.toStringAsFixed(1),
                      r.ph.toStringAsFixed(1),
                      r.nitrogen,
                      r.phosphorus,
                      r.potassium,
                      r.salinity.toStringAsFixed(2),
                    ],
                  )
                  .toList(),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'soil_report.pdf',
    );
    return 'PDF report generated and share sheet opened.';
  }

  @override
  Future<String> exportImages() async {
    final cropRepo = CropRepository(_db);
    final allCropParams = await cropRepo.getAllCropParams();

    if (allCropParams.isEmpty) {
      return 'No crop parameters found. No images to export.';
    }

    final List<XFile> imageFiles = [];
    for (final crop in allCropParams) {
      final images = await cropRepo.getImagesForCrop(crop.id);
      for (final image in images) {
        final file = File(image.filePath);
        if (await file.exists()) {
          imageFiles.add(XFile(file.path));
        }
      }
    }

    if (imageFiles.isEmpty) {
      return 'No images found to export.';
    }

    await Share.shareXFiles(imageFiles, text: 'Crop parameter images');
    return '${imageFiles.length} image(s) exported and share sheet opened.';
  }

  @override
  Future<String> exportCropParamsCsv() async {
    final cropRepo = CropRepository(_db);
    final allCropParams = await cropRepo.getAllCropParams();

    final rows = <List<dynamic>>[
      [
        'id',
        'createdAt',
        'soilType',
        'soilProperties',
        'leafColor',
        'stemDescription',
        'heightCm',
        'notes',
        'imageFilenames',
      ],
      ...await Future.wait(
        allCropParams.map((crop) async {
          final images = await cropRepo.getImagesForCrop(crop.id);
          final imageFilenames = images
              .map((img) => img.relabelledFileName)
              .join('; ');
          return [
            crop.id,
            crop.createdAt.toIso8601String(),
            crop.soilType,
            crop.soilProperties,
            crop.leafColor,
            crop.stemDescription,
            crop.heightCm,
            crop.notes ?? '',
            imageFilenames,
          ];
        }),
      ),
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final file = await _createTempFile('crop_parameters.csv');
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)]);
    return 'Crop parameters CSV exported and share sheet opened.';
  }
}


