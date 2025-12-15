import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../services/export_service.dart';
import '../../services/permission_service.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/sensor_repository.dart';
import '../../data/repositories/crop_repository.dart';
import '../../services/session_store.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final sessionStore = ref.read(sessionStoreProvider);
  return LocalExportService(db, sessionStore);
});

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _status = 'No export yet.';
  bool _busy = false;
  bool _loadingSessions = true;
  List<ReadingSession> _sessions = [];
  int? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final store = ref.read(sessionStoreProvider);
    final sessions = await store.loadSessions();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loadingSessions = false;
    });
  }

  List<int>? _selectedReadingIds() {
    if (_selectedSessionId == null) return null;
    final session =
        _sessions.firstWhere((s) => s.id == _selectedSessionId, orElse: () => ReadingSession(id: -1, createdAt: DateTime.now(), readingIds: []));
    if (session.id == -1) return null;
    return session.readingIds;
  }

  Future<void> _exportSensorCsv() async {
    setState(() {
      _busy = true;
      _status = 'Exporting sensor data CSV...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportSensorCsv(
        readingIds: _selectedReadingIds(),
      );
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error exporting sensor CSV: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportCombinedCsv() async {
    setState(() {
      _busy = true;
      _status = 'Exporting combined data CSV...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportCombinedCsv(
        readingIds: _selectedReadingIds(),
      );
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error exporting combined CSV: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportPdfReport() async {
    setState(() {
      _busy = true;
      _status = 'Generating PDF report...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportPdfReport(sessionId: _selectedSessionId);
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error generating PDF report: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportCropParamsCsv() async {
    setState(() {
      _busy = true;
      _status = 'Exporting crop parameters CSV...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportCropParamsCsv();
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error exporting crop parameters CSV: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportImages() async {
    setState(() {
      _busy = true;
      _status = 'Exporting images...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportImages();
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error exporting images: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportCharts() async {
    setState(() {
      _busy = true;
      _status = 'Exporting charts...';
    });
    
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }

      // Get readings based on selected session
      final readingIds = _selectedReadingIds();
      final sensorRepo = SensorRepository(ref.read(appDatabaseProvider));
      final readings = readingIds == null
          ? await sensorRepo.getAllReadings()
          : await sensorRepo.getReadingsByIds(readingIds);

      if (readings.isEmpty) {
        if (mounted) {
          setState(() {
            _status = 'No readings available to export.';
            _busy = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No readings available to export')),
          );
        }
        return;
      }

      // Sort readings by timestamp
      final sortedReadings = List<SensorReading>.from(readings)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating charts... Please wait.')),
        );
      }

      // Create PDF with all sensor charts
      final pdf = pw.Document();
      final sessionText = _selectedSessionId != null
          ? 'Session #$_selectedSessionId'
          : 'All Readings';
      final exportDate = DateTime.now();

      // Chart configurations: [title, unit, valueExtractor, color]
      final chartConfigs = [
        ['Moisture', '%', (SensorReading r) => r.moisture, Colors.blue],
        ['EC', 'mS/cm', (SensorReading r) => r.ec, Colors.green],
        ['Temperature', '°C', (SensorReading r) => r.temperature, Colors.orange],
        ['pH', '', (SensorReading r) => r.ph, Colors.purple],
        ['Nitrogen', 'ppm', (SensorReading r) => r.nitrogen.toDouble(), Colors.red],
        ['Phosphorus', 'ppm', (SensorReading r) => r.phosphorus.toDouble(), Colors.teal],
        ['Potassium', 'ppm', (SensorReading r) => r.potassium.toDouble(), Colors.amber],
        ['Salinity', 'g/L', (SensorReading r) => r.salinity, Colors.cyan],
      ];

      // Build and capture each chart
      for (final config in chartConfigs) {
        final title = config[0] as String;
        final unit = config[1] as String;
        final valueExtractor = config[2] as double Function(SensorReading);
        final color = config[3] as Color;

        // Create chart widget and capture it
        final chartImage = await _captureChartWidget(
          sortedReadings,
          title,
          unit,
          valueExtractor,
          color,
        );

        if (chartImage == null) {
          print('Failed to capture chart for $title');
          continue;
        }

        final ByteData? byteData =
            await chartImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) continue;

        final imageBytes = byteData.buffer.asUint8List();
        final pdfImage = pw.MemoryImage(imageBytes);

        // Calculate image dimensions
        final imageWidth = chartImage.width.toDouble();
        final imageHeight = chartImage.height.toDouble();
        final aspectRatio = imageWidth / imageHeight;

        const pageWidth = 595.28;
        const pageHeight = 841.89;
        const margin = 40.0;
        final availableWidth = pageWidth - (margin * 2);
        final availableHeight = pageHeight - (margin * 2) - 80;

        double imageWidthPdf = availableWidth;
        double imageHeightPdf = imageWidthPdf / aspectRatio;

        if (imageHeightPdf > availableHeight) {
          imageHeightPdf = availableHeight;
          imageWidthPdf = imageHeightPdf * aspectRatio;
        }

        // Add page for this chart
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(margin),
            build: (pw.Context context) {
              return pw.Stack(
                children: [
                  // Title and metadata at top
                  pw.Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          title,
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '$sessionText • ${exportDate.toLocal().toString().split('.')[0]}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chart image
                  pw.Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: pw.Center(
                      child: pw.Image(
                        pdfImage,
                        width: imageWidthPdf,
                        height: imageHeightPdf,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Save PDF
      final dir = await getTemporaryDirectory();
      final fileName = _selectedSessionId != null
          ? 'all_readings_session${_selectedSessionId}_chart.pdf'
          : 'all_readings_chart.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)]);

      if (mounted) {
        setState(() {
          _status = 'Charts exported successfully.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Charts exported as PDF')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error exporting charts: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<ui.Image?> _captureChartWidget(
    List<SensorReading> readings,
    String title,
    String unit,
    double Function(SensorReading) valueExtractor,
    Color color,
  ) async {
    if (readings.isEmpty) return null;

    // Prepare chart data
    final spots = readings.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final value = valueExtractor(entry.value);
      return FlSpot(index, value);
    }).toList();

    final values = readings.map(valueExtractor).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final padding = range > 0 ? range * 0.1 : (minValue.abs() * 0.1 + 1);
    final yMin = minValue - padding;
    final yMax = maxValue + padding;

    // Create a widget tree with the chart
    final key = GlobalKey();
    final chartWidget = RepaintBoundary(
      key: key,
      child: Container(
        width: 800,
        height: 600,
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title ($unit)',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (yMax - yMin) / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (readings.length / 5).ceil().toDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < readings.length) {
                            final time = readings[index].timestamp;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: (yMax - yMin) / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  minX: 0,
                  maxX: (readings.length - 1).toDouble(),
                  minY: yMin,
                  maxY: yMax,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Render the widget to an image
    // We need to use a BuildContext, so we'll use the current context
    if (!mounted) return null;

    try {
      // Create an overlay entry to render the widget off-screen
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000, // Off-screen
          top: -10000,
          child: Material(
            type: MaterialType.transparency,
            child: chartWidget,
          ),
        ),
      );

      overlay.insert(overlayEntry);

      // Wait for the widget to render
      await Future.delayed(const Duration(milliseconds: 300));

      // Get the render object and capture
      final renderObject = key.currentContext?.findRenderObject();
      RenderRepaintBoundary? boundary;
      if (renderObject is RenderRepaintBoundary) {
        boundary = renderObject;
      } else {
        overlayEntry.remove();
        return null;
      }

      await Future.delayed(const Duration(milliseconds: 100));
      final image = await boundary.toImage(pixelRatio: 2.0);

      overlayEntry.remove();
      return image;
    } catch (e) {
      print('Error capturing chart: $e');
      return null;
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete ALL sensor readings, crop parameters, and images. This action cannot be undone.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _status = 'Clearing all data...';
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final sensorRepo = SensorRepository(db);
      final cropRepo = CropRepository(db);
      final sessionStore = ref.read(sessionStoreProvider);

      // Delete all sensor readings
      await sensorRepo.deleteAllReadings();
      
      // Delete all crop parameters (this also deletes associated images from DB)
      await cropRepo.deleteAllCropParams();

      // Clear session groupings
      await sessionStore.saveSessions([]);

      // Note: Physical image files would need to be deleted separately if needed
      // For now, we're just clearing the database references

      setState(() {
        _status = 'All data cleared successfully.';
        _selectedSessionId = null;
      });

      // Reload sessions so the dropdown immediately reflects the cleared state.
      await _loadSessions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Error clearing data: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Export & Share'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadingSessions)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(minHeight: 4),
                ),
              if (!_loadingSessions)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select session to export (or All readings):',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: _selectedSessionId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All readings'),
                        ),
                        ..._sessions.map(
                          (s) => DropdownMenuItem<int?>(
                            value: s.id,
                            child: Text(
                              'Session #${s.id} — ${s.readingIds.length} readings (${s.createdAt.toLocal().toString().split(" ").first})',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedSessionId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportSensorCsv,
                  child: const Text('Export Sensor Data (CSV)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportCombinedCsv,
                  child: const Text('Export Sensor + Params (CSV)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportPdfReport,
                  child: const Text('Export PDF Report'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _exportCharts,
                  icon: const Icon(Icons.show_chart),
                  label: const Text('Export Charts (PDF)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportCropParamsCsv,
                  child: const Text('Export Crop Parameters (CSV)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportImages,
                  child: const Text('Export Images'),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Data Management:',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _clearAllData,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Clear All Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Last status:',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _status,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


