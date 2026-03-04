import 'dart:io';
import 'dart:ui';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../data/db/app_database.dart';
import '../data/repositories/crop_repository.dart';
import '../data/repositories/sensor_repository.dart';
import '../services/session_store.dart';

/// Abstraction for export logic so we can plug in other backends later
/// (Google Drive, external DB, etc.).
abstract class ExportService {
  Future<String> exportSensorCsv({List<int>? readingIds, Rect? shareOrigin});
  Future<String> exportCombinedCsv({List<int>? readingIds, Rect? shareOrigin});
  Future<String> exportPdfReport({int? sessionId, Rect? shareOrigin});
  Future<String> exportImages({Rect? shareOrigin});
  Future<String> exportCropParamsCsv({Rect? shareOrigin});
}

class LocalExportService implements ExportService {
  LocalExportService(this._db, this._sessionStore);

  static const List<String> _sensorCsvHeaders = [
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
  ];

  final AppDatabase _db;
  final SessionStore _sessionStore;

  Future<File> _createTempFile(String name) async {
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, name);
    return File(path).create(recursive: true);
  }

  double? _averageOptional(
    Iterable<SensorReading> readings,
    double? Function(SensorReading reading) selector,
  ) {
    final values = readings.map(selector).whereType<double>().toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @visibleForTesting
  List<List<dynamic>> buildSensorCsvRows(Iterable<SensorReading> readings) {
    return <List<dynamic>>[
      _sensorCsvHeaders,
      ...readings.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final reading = entry.value;
        return [
          index + 1, // Start IDs from 1 for each export
          reading.timestamp.toIso8601String(),
          reading.moisture,
          reading.ec,
          reading.temperature,
          reading.ph,
          reading.nitrogen,
          reading.phosphorus,
          reading.potassium,
          reading.salinity,
          reading.tds,
        ];
      }),
    ];
  }

  @override
  Future<String> exportSensorCsv({
    List<int>? readingIds,
    Rect? shareOrigin,
  }) async {
    final sensorRepo = SensorRepository(_db);
    final readings = readingIds == null
        ? await sensorRepo.getAllReadings()
        : await sensorRepo.getReadingsByIds(readingIds);

    final rows = buildSensorCsvRows(readings);

    final csvData = const ListToCsvConverter().convert(rows);
    final file = await _createTempFile('sensor_readings.csv');
    await file.writeAsString(csvData);
    await Share.shareXFiles([
      XFile(file.path),
    ], sharePositionOrigin: shareOrigin);
    return 'Sensor CSV exported and share sheet opened.';
  }

  @override
  Future<String> exportCombinedCsv({
    List<int>? readingIds,
    Rect? shareOrigin,
  }) async {
    final sensorRepo = SensorRepository(_db);
    final cropRepo = CropRepository(_db);

    final readings = readingIds == null
        ? await sensorRepo.getAllReadings()
        : await sensorRepo.getReadingsByIds(readingIds);
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
        'moisture (%)',
        'ec (mS/cm)',
        'temperature (°C)',
        'ph',
        'nitrogen (mg/kg)',
        'phosphorus (mg/kg)',
        'potassium (mg/kg)',
        'salinity (g/L)',
        'tds (ppm)',
        'ecConv',
        'ecCal',
        'phConv',
        'phCal',
        'nConv',
        'nCal',
        'pConv',
        'pCal',
        'kConv',
        'kCal',
        'cropParamsId',
        'soilType',
        'soilProperties',
        'leafColor',
        'stemDescription',
        'heightCm (cm)',
        'notes',
        'imageFilenames',
      ],
      ...readings.asMap().entries.map((entry) {
        final index = entry.key;
        final r = entry.value;
        final cp = r.cropParamsId != null
            ? cropParamsById[r.cropParamsId]
            : null;
        final imageFilenames = r.cropParamsId != null
            ? (imagesByCropId[r.cropParamsId] ?? []).join('; ')
            : '';
        return [
          index + 1, // Start IDs from 1 for each export
          r.timestamp.toIso8601String(),
          r.moisture,
          r.ec,
          r.temperature,
          r.ph,
          r.nitrogen,
          r.phosphorus,
          r.potassium,
          r.salinity,
          r.tds,
          r.ecConv ?? '',
          r.ecCal ?? '',
          r.phConv ?? '',
          r.phCal ?? '',
          r.nConv ?? '',
          r.nCal ?? '',
          r.pConv ?? '',
          r.pCal ?? '',
          r.kConv ?? '',
          r.kCal ?? '',
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
    await Share.shareXFiles([
      XFile(file.path),
    ], sharePositionOrigin: shareOrigin);
    return 'Combined CSV exported and share sheet opened.';
  }

  @override
  Future<String> exportPdfReport({int? sessionId, Rect? shareOrigin}) async {
    final sensorRepo = SensorRepository(_db);
    final cropRepo = CropRepository(_db);

    // Load sessions - filter by sessionId if provided
    final allSessions = await _sessionStore.loadSessions();
    final sessions = sessionId != null
        ? allSessions.where((s) => s.id == sessionId).toList()
        : allSessions;
    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first

    // Load all crop parameters
    final crops = await cropRepo.getAllCropParams();
    final cropsById = {for (final c in crops) c.id: c};

    // Pre-load all readings for all sessions
    final sessionData = <_SessionData>[];
    for (final session in sessions) {
      final readings = await sensorRepo.getReadingsByIds(session.readingIds);
      if (readings.isEmpty) continue;

      // Calculate averages
      final avgMoisture =
          readings.map((r) => r.moisture).reduce((a, b) => a + b) /
          readings.length;
      final avgEC =
          readings.map((r) => r.ec).reduce((a, b) => a + b) / readings.length;
      final avgTemp =
          readings.map((r) => r.temperature).reduce((a, b) => a + b) /
          readings.length;
      final avgPH =
          readings.map((r) => r.ph).reduce((a, b) => a + b) / readings.length;
      final avgN =
          readings.map((r) => r.nitrogen).reduce((a, b) => a + b) /
          readings.length;
      final avgP =
          readings.map((r) => r.phosphorus).reduce((a, b) => a + b) /
          readings.length;
      final avgK =
          readings.map((r) => r.potassium).reduce((a, b) => a + b) /
          readings.length;
      final avgSalinity =
          readings.map((r) => r.salinity).reduce((a, b) => a + b) /
          readings.length;
      final avgTds =
          readings.map((r) => r.tds).reduce((a, b) => a + b) / readings.length;
      final avgEcConv = _averageOptional(readings, (r) => r.ecConv);
      final avgEcCal = _averageOptional(readings, (r) => r.ecCal);
      final avgPhConv = _averageOptional(readings, (r) => r.phConv);
      final avgPhCal = _averageOptional(readings, (r) => r.phCal);
      final avgNConv = _averageOptional(readings, (r) => r.nConv);
      final avgNCal = _averageOptional(readings, (r) => r.nCal);
      final avgPConv = _averageOptional(readings, (r) => r.pConv);
      final avgPCal = _averageOptional(readings, (r) => r.pCal);
      final avgKConv = _averageOptional(readings, (r) => r.kConv);
      final avgKCal = _averageOptional(readings, (r) => r.kCal);

      // Get time range
      final timestamps = readings.map((r) => r.timestamp).toList()..sort();
      final startTime = timestamps.first;
      final endTime = timestamps.last;
      final duration = endTime.difference(startTime);

      // Get linked crop parameters
      final cropParamsIds = readings
          .where((r) => r.cropParamsId != null)
          .map((r) => r.cropParamsId!)
          .toSet()
          .toList();
      final linkedCrops = cropParamsIds
          .map((id) => cropsById[id])
          .whereType<CropParam>()
          .toList();

      sessionData.add(
        _SessionData(
          session: session,
          readings: readings,
          avgMoisture: avgMoisture,
          avgEC: avgEC,
          avgTemp: avgTemp,
          avgPH: avgPH,
          avgN: avgN,
          avgP: avgP,
          avgK: avgK,
          avgSalinity: avgSalinity,
          avgTds: avgTds,
          avgEcConv: avgEcConv,
          avgEcCal: avgEcCal,
          avgPhConv: avgPhConv,
          avgPhCal: avgPhCal,
          avgNConv: avgNConv,
          avgNCal: avgNCal,
          avgPConv: avgPConv,
          avgPCal: avgPCal,
          avgKConv: avgKConv,
          avgKCal: avgKCal,
          startTime: startTime,
          endTime: endTime,
          duration: duration,
          linkedCrops: linkedCrops,
        ),
      );
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text(
              'Crop Soil Sensor Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Generated: ${DateTime.now().toLocal().toString().split('.')[0]}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 24),
          ];

          // Add session summaries
          if (sessionData.isEmpty) {
            widgets.add(
              pw.Text(
                'No reading sessions available.',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            );
          } else {
            widgets.add(
              pw.Text(
                'Reading Sessions Summary',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 16));

            for (final data in sessionData) {
              // Generate summary sentence
              final summaryParts = <String>[];
              summaryParts.add(
                'Session #${data.session.id} collected ${data.readings.length} readings',
              );
              summaryParts.add(
                'from ${data.startTime.toLocal().toString().split('.')[0]}',
              );
              summaryParts.add(
                'to ${data.endTime.toLocal().toString().split('.')[0]}',
              );
              if (data.duration.inMinutes > 0) {
                summaryParts.add('(${data.duration.inMinutes} minutes)');
              }
              if (data.linkedCrops.isNotEmpty) {
                summaryParts.add(
                  'linked to ${data.linkedCrops.map((c) => 'Set #${c.id}: ${c.soilType}').join(', ')}',
                );
              }
              final summary = summaryParts.join(' ');

              widgets.addAll([
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Session #${data.session.id}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(summary, style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'Average Values:',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(2),
                          1: const pw.FlexColumnWidth(1),
                        },
                        children: [
                          _buildTableRow(
                            'Moisture',
                            '${data.avgMoisture.toStringAsFixed(1)} %',
                          ),
                          _buildTableRow(
                            'EC',
                            '${data.avgEC.toStringAsFixed(2)} mS/cm',
                          ),
                          _buildTableRow(
                            'Temperature',
                            '${data.avgTemp.toStringAsFixed(1)} °C',
                          ),
                          _buildTableRow('pH', data.avgPH.toStringAsFixed(1)),
                          _buildTableRow(
                            'Nitrogen (N)',
                            '${data.avgN.toStringAsFixed(0)} mg/kg',
                          ),
                          _buildTableRow(
                            'Phosphorus (P)',
                            '${data.avgP.toStringAsFixed(0)} mg/kg',
                          ),
                          _buildTableRow(
                            'Potassium (K)',
                            '${data.avgK.toStringAsFixed(0)} mg/kg',
                          ),
                          _buildTableRow(
                            'Salinity',
                            data.avgSalinity.toStringAsFixed(2),
                          ),
                          _buildTableRow(
                            'TDS',
                            '${data.avgTds.toStringAsFixed(0)} ppm',
                          ),
                        ],
                      ),
                      if (data.hasDerivedValues) ...[
                        pw.SizedBox(height: 12),
                        pw.Text(
                          'Converted / Calibrated Values:',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(2),
                            1: const pw.FlexColumnWidth(1),
                          },
                          children: [
                            if (data.avgEcConv != null)
                              _buildTableRow(
                                'EC (conv)',
                                '${data.avgEcConv!.toStringAsFixed(3)} dS/m',
                              ),
                            if (data.avgEcCal != null)
                              _buildTableRow(
                                'EC (cal)',
                                '${data.avgEcCal!.toStringAsFixed(3)} dS/m',
                              ),
                            if (data.avgPhConv != null)
                              _buildTableRow(
                                'pH (conv)',
                                data.avgPhConv!.toStringAsFixed(2),
                              ),
                            if (data.avgPhCal != null)
                              _buildTableRow(
                                'pH (cal)',
                                data.avgPhCal!.toStringAsFixed(2),
                              ),
                            if (data.avgNConv != null)
                              _buildTableRow(
                                'N (conv)',
                                '${data.avgNConv!.toStringAsFixed(4)} %',
                              ),
                            if (data.avgNCal != null)
                              _buildTableRow(
                                'N (cal)',
                                '${data.avgNCal!.toStringAsFixed(4)} %',
                              ),
                            if (data.avgPConv != null)
                              _buildTableRow(
                                'P (conv)',
                                '${data.avgPConv!.toStringAsFixed(1)} mg/kg',
                              ),
                            if (data.avgPCal != null)
                              _buildTableRow(
                                'P (cal)',
                                '${data.avgPCal!.toStringAsFixed(1)} mg/kg',
                              ),
                            if (data.avgKConv != null)
                              _buildTableRow(
                                'K (conv)',
                                '${data.avgKConv!.toStringAsFixed(3)} cmol(+)/kg',
                              ),
                            if (data.avgKCal != null)
                              _buildTableRow(
                                'K (cal)',
                                '${data.avgKCal!.toStringAsFixed(3)} cmol(+)/kg',
                              ),
                          ],
                        ),
                      ],
                      if (data.linkedCrops.isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Linked Crop Parameters:',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        ...data.linkedCrops.map(
                          (crop) => pw.Padding(
                            padding: const pw.EdgeInsets.only(
                              left: 8,
                              bottom: 2,
                            ),
                            child: pw.Text(
                              'Set #${crop.id}: ${crop.soilType} (${crop.createdAt.toLocal().toString().split(' ')[0]})',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
              ]);
            }
          }

          // Add crop parameters section
          if (crops.isNotEmpty) {
            widgets.addAll([
              pw.SizedBox(height: 16),
              pw.Text(
                'Crop Parameter Sets',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
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
                        c.createdAt.toLocal().toString().split('.')[0],
                        c.soilType,
                        c.leafColor,
                        c.heightCm.toStringAsFixed(1),
                      ],
                    )
                    .toList(),
              ),
            ]);
          }

          return widgets;
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'soil_report.pdf',
      bounds: shareOrigin,
    );
    return 'PDF report generated and share sheet opened.';
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ),
      ],
    );
  }

  @override
  Future<String> exportImages({Rect? shareOrigin}) async {
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

    await Share.shareXFiles(
      imageFiles,
      text: 'Crop parameter images',
      sharePositionOrigin: shareOrigin,
    );
    return '${imageFiles.length} image(s) exported and share sheet opened.';
  }

  @override
  Future<String> exportCropParamsCsv({Rect? shareOrigin}) async {
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
    await Share.shareXFiles([
      XFile(file.path),
    ], sharePositionOrigin: shareOrigin);
    return 'Crop parameters CSV exported and share sheet opened.';
  }
}

class _SessionData {
  _SessionData({
    required this.session,
    required this.readings,
    required this.avgMoisture,
    required this.avgEC,
    required this.avgTemp,
    required this.avgPH,
    required this.avgN,
    required this.avgP,
    required this.avgK,
    required this.avgSalinity,
    required this.avgTds,
    required this.avgEcConv,
    required this.avgEcCal,
    required this.avgPhConv,
    required this.avgPhCal,
    required this.avgNConv,
    required this.avgNCal,
    required this.avgPConv,
    required this.avgPCal,
    required this.avgKConv,
    required this.avgKCal,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.linkedCrops,
  });

  final ReadingSession session;
  final List<SensorReading> readings;
  final double avgMoisture;
  final double avgEC;
  final double avgTemp;
  final double avgPH;
  final double avgN;
  final double avgP;
  final double avgK;
  final double avgSalinity;
  final double avgTds;
  final double? avgEcConv;
  final double? avgEcCal;
  final double? avgPhConv;
  final double? avgPhCal;
  final double? avgNConv;
  final double? avgNCal;
  final double? avgPConv;
  final double? avgPCal;
  final double? avgKConv;
  final double? avgKCal;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final List<CropParam> linkedCrops;

  bool get hasDerivedValues =>
      avgEcConv != null ||
      avgEcCal != null ||
      avgPhConv != null ||
      avgPhCal != null ||
      avgNConv != null ||
      avgNCal != null ||
      avgPConv != null ||
      avgPCal != null ||
      avgKConv != null ||
      avgKCal != null;
}
