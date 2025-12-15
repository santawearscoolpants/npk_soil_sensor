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

import '../../data/db/app_database.dart';
import '../../data/repositories/sensor_repository.dart';
import '../../services/session_store.dart';

final _sessionsProvider =
    FutureProvider.autoDispose<List<ReadingSession>>((ref) async {
  final sessionStore = ref.read(sessionStoreProvider);
  return sessionStore.loadSessions();
});

final _readingsProvider = FutureProvider.family
    .autoDispose<List<SensorReading>, List<int>?>((ref, readingIds) async {
  final sensorRepo = ref.read(sensorRepoProvider);
  if (readingIds == null) {
    return await sensorRepo.getAllReadings();
  }
  return await sensorRepo.getReadingsByIds(readingIds);
});

final sensorRepoProvider = Provider<SensorRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SensorRepository(db);
});

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedSessionId;
  late TabController _tabController;
  final Map<int, GlobalKey> _chartKeys = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    // Initialize global keys for each chart
    for (int i = 0; i < 9; i++) {
      _chartKeys[i] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<int>? _getSelectedReadingIds(List<ReadingSession> sessions) {
    if (_selectedSessionId == null) return null;
    final session = sessions.firstWhere(
      (s) => s.id == _selectedSessionId,
      orElse: () => ReadingSession(
        id: -1,
        createdAt: DateTime.now(),
        readingIds: [],
      ),
    );
    return session.id == -1 ? null : session.readingIds;
  }

  String _getExportFileName(int chartIndex, int? sessionId) {
    final chartNames = [
      'all_readings',
      'moisture',
      'ec',
      'temperature',
      'pH',
      'nitrogen',
      'phosphorus',
      'potassium',
      'salinity',
    ];
    
    final baseName = chartNames[chartIndex];
    
    if (sessionId != null) {
      return '${baseName}_session${sessionId}_chart';
    } else {
      if (chartIndex == 0) {
        return 'all_readings_chart';
      } else {
        return '${baseName}_all_readings_chart';
      }
    }
  }

  String _getChartTitle(int chartIndex) {
    final chartNames = [
      'All Sensors Overview',
      'Moisture',
      'EC',
      'Temperature',
      'pH',
      'Nitrogen',
      'Phosphorus',
      'Potassium',
      'Salinity',
    ];
    return chartNames[chartIndex];
  }

  Future<ui.Image?> _captureChartImage(int chartIndex) async {
    final key = _chartKeys[chartIndex];
    if (key == null || key.currentContext == null) return null;

    try {
      // Get the RenderRepaintBoundary from the GlobalKey
      final renderObject = key.currentContext!.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        return null;
      }
      final RenderRepaintBoundary boundary = renderObject;
      
      // Wait a bit to ensure the chart is fully rendered
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Capture the image with high pixel ratio for quality
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      return image;
    } catch (e) {
      print('Error capturing chart $chartIndex: $e');
      return null;
    }
  }

  Future<void> _exportChart(int chartIndex, int? sessionId) async {
    // Special handling for "All Sensors" tab - export all individual charts
    if (chartIndex == 0) {
      await _exportAllSensorsChart(sessionId);
      return;
    }

    final image = await _captureChartImage(chartIndex);
    if (image == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chart not ready for export')),
        );
      }
      return;
    }

    try {
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture chart')),
          );
        }
        return;
      }

      // Convert image bytes to PDF image
      final imageBytes = byteData.buffer.asUint8List();
      
      // Verify image bytes are valid
      if (imageBytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image data is empty')),
          );
        }
        return;
      }
      
      // Create PDF image
      final pdfImage = pw.MemoryImage(imageBytes);

      // Get image dimensions for proper sizing
      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();
      final aspectRatio = imageWidth / imageHeight;
      
      // Calculate available dimensions (A4 minus margins)
      const pageWidth = 595.28;
      const pageHeight = 841.89;
      const margin = 40.0;
      final availableWidth = pageWidth - (margin * 2);
      final availableHeight = pageHeight - (margin * 2) - 80;
      
      // Calculate image size to fit within available space
      double imageWidthPdf = availableWidth;
      double imageHeightPdf = imageWidthPdf / aspectRatio;
      
      if (imageHeightPdf > availableHeight) {
        imageHeightPdf = availableHeight;
        imageWidthPdf = imageHeightPdf * aspectRatio;
      }

      // Create PDF document
      final pdf = pw.Document();
      final chartTitle = _getChartTitle(chartIndex);
      final sessionText = sessionId != null 
          ? 'Session #$sessionId' 
          : 'All Readings';
      final exportDate = DateTime.now();

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
                        chartTitle,
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
                // Chart image centered below the header
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

      // Save PDF
      final dir = await getTemporaryDirectory();
      final fileName = '${_getExportFileName(chartIndex, sessionId)}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      final exportName = _getExportFileName(chartIndex, sessionId);
      await Share.shareXFiles([XFile(file.path)]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chart exported as PDF: $exportName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }

  Future<void> _exportAllSensorsChart(int? sessionId) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exporting all sensors... Please wait.')),
        );
      }

      // Store current tab index to restore later
      final originalTabIndex = _tabController.index;
      
      // Create a PDF with all sensor charts
      final pdf = pw.Document();
      final sessionText = sessionId != null 
          ? 'Session #$sessionId' 
          : 'All Readings';
      final exportDate = DateTime.now();

      // Chart indices to capture (1-8 for individual sensors)
      final chartIndices = [1, 2, 3, 4, 5, 6, 7, 8];
      final chartTitles = [
        'Moisture',
        'EC',
        'Temperature',
        'pH',
        'Nitrogen',
        'Phosphorus',
        'Potassium',
        'Salinity',
      ];

      // Switch to each tab, capture the chart, then move to next
      for (int i = 0; i < chartIndices.length; i++) {
        final chartIndex = chartIndices[i];
        final chartTitle = chartTitles[i];

        // Switch to this tab
        _tabController.animateTo(chartIndex);
        await Future.delayed(const Duration(milliseconds: 300)); // Wait for chart to render

        // Capture the chart
        final image = await _captureChartImage(chartIndex);
        if (image == null) {
          print('Failed to capture chart for $chartTitle');
          continue;
        }

        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) continue;

        final imageBytes = byteData.buffer.asUint8List();
        final pdfImage = pw.MemoryImage(imageBytes);

        // Calculate image dimensions
        final imageWidth = image.width.toDouble();
        final imageHeight = image.height.toDouble();
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
                          chartTitle,
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

      // Restore original tab
      _tabController.animateTo(originalTabIndex);

      // Save PDF
      final dir = await getTemporaryDirectory();
      final fileName = '${_getExportFileName(0, sessionId)}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      final exportName = _getExportFileName(0, sessionId);
      await Share.shareXFiles([XFile(file.path)]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All sensors exported as PDF: $exportName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(_sessionsProvider);
    final readingIds = sessionsAsync.when(
      data: (sessions) => _getSelectedReadingIds(sessions),
      loading: () => null,
      error: (_, __) => null,
    );
    final readingsAsync = ref.watch(_readingsProvider(readingIds));
    
    // Get session name for display
    final selectedSessionName = sessionsAsync.when(
      data: (sessions) {
        if (_selectedSessionId == null) return 'All Readings';
        final session = sessions.firstWhere(
          (s) => s.id == _selectedSessionId,
          orElse: () => ReadingSession(
            id: -1,
            createdAt: DateTime.now(),
            readingIds: [],
          ),
        );
        return session.id == -1 ? 'All Readings' : 'Session #${session.id}';
      },
      loading: () => 'Loading...',
      error: (_, __) => 'All Readings',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Charts'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.inversePrimary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Moisture'),
            Tab(text: 'EC'),
            Tab(text: 'Temperature'),
            Tab(text: 'pH'),
            Tab(text: 'Nitrogen'),
            Tab(text: 'Phosphorus'),
            Tab(text: 'Potassium'),
            Tab(text: 'Salinity'),
          ],
        ),
        actions: [
          PopupMenuButton<int?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by session',
            onSelected: (value) async {
              setState(() {
                _selectedSessionId = value; // value can be null for "All Readings"
              });
              
              // Get sessions fresh to calculate readingIds
              final sessionsAsyncValue = await ref.read(_sessionsProvider.future);
              
              // Calculate new readingIds based on selection
              List<int>? newReadingIds;
              if (value == null) {
                newReadingIds = null; // All readings
              } else {
                final session = sessionsAsyncValue.firstWhere(
                  (s) => s.id == value,
                  orElse: () => ReadingSession(
                    id: -1,
                    createdAt: DateTime.now(),
                    readingIds: [],
                  ),
                );
                newReadingIds = session.id == -1 ? null : session.readingIds;
              }
              
              // Invalidate the specific provider instance to force reload
              ref.invalidate(_readingsProvider(newReadingIds));
            },
            itemBuilder: (context) {
              return sessionsAsync.when(
                data: (sessions) => [
                  const PopupMenuItem<int?>(
                    value: null,
                    child: Text('All Readings'),
                  ),
                  ...sessions.map(
                    (session) => PopupMenuItem<int?>(
                      value: session.id,
                      child: Text('Session #${session.id}'),
                    ),
                  ),
                ],
                loading: () => [
                  const PopupMenuItem(child: Text('Loading...')),
                ],
                error: (_, __) => [
                  const PopupMenuItem(child: Text('Error loading sessions')),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Session indicator banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Viewing: $selectedSessionName',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          // Charts content
          Expanded(
            child: readingsAsync.when(
              data: (readings) {
                if (readings.isEmpty) {
                  return const Center(
                    child: Text('No readings available to display'),
                  );
                }

                // Sort readings by timestamp
                final sortedReadings = List<SensorReading>.from(readings)
                  ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllChartsView(sortedReadings),
                    _buildChart(
                      sortedReadings,
                      1,
                      'Moisture',
                      '%',
                      (r) => r.moisture,
                      Colors.blue,
                    ),
                    _buildChart(
                      sortedReadings,
                      2,
                      'EC',
                      'mS/cm',
                      (r) => r.ec,
                      Colors.green,
                    ),
                    _buildChart(
                      sortedReadings,
                      3,
                      'Temperature',
                      '°C',
                      (r) => r.temperature,
                      Colors.orange,
                    ),
                    _buildChart(
                      sortedReadings,
                      4,
                      'pH',
                      '',
                      (r) => r.ph,
                      Colors.purple,
                    ),
                    _buildChart(
                      sortedReadings,
                      5,
                      'Nitrogen',
                      'ppm',
                      (r) => r.nitrogen.toDouble(),
                      Colors.red,
                    ),
                    _buildChart(
                      sortedReadings,
                      6,
                      'Phosphorus',
                      'ppm',
                      (r) => r.phosphorus.toDouble(),
                      Colors.teal,
                    ),
                    _buildChart(
                      sortedReadings,
                      7,
                      'Potassium',
                      'ppm',
                      (r) => r.potassium.toDouble(),
                      Colors.amber,
                    ),
                    _buildChart(
                      sortedReadings,
                      8,
                      'Salinity',
                      'g/L',
                      (r) => r.salinity,
                      Colors.cyan,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading readings: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    List<SensorReading> readings,
    int chartIndex,
    String title,
    String unit,
    double Function(SensorReading) valueExtractor,
    Color color,
  ) {
    if (readings.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Prepare chart data points
    final spots = readings.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final reading = entry.value;
      final value = valueExtractor(reading);
      return FlSpot(index, value);
    }).toList();

    // Calculate min/max for Y axis
    final values = readings.map(valueExtractor).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final padding = range > 0 ? range * 0.1 : (minValue.abs() * 0.1 + 1);
    final yMin = minValue - padding;
    final yMax = maxValue + padding;

    // Prepare X axis labels (time-based)
    final xLabels = readings.map((r) {
      final time = r.timestamp;
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }).toList();

    return RepaintBoundary(
      key: _chartKeys[chartIndex],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title ($unit)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          if (index >= 0 && index < xLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                xLabels[index],
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
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < readings.length) {
                            final reading = readings[index];
                            return LineTooltipItem(
                              '${valueExtractor(reading).toStringAsFixed(2)} $unit\n${reading.timestamp.toString().split('.')[0]}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Range: ${minValue.toStringAsFixed(2)} - ${maxValue.toStringAsFixed(2)} $unit | ${readings.length} readings',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllChartsView(List<SensorReading> readings) {
    return RepaintBoundary(
      key: _chartKeys[0],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Sensors Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildCompactChart(
            readings,
            'Moisture',
            '%',
            (r) => r.moisture,
            Colors.blue,
          ),
          const SizedBox(height: 24),
          _buildCompactChart(
            readings,
            'EC',
            'mS/cm',
            (r) => r.ec,
            Colors.green,
          ),
          const SizedBox(height: 24),
          _buildCompactChart(
            readings,
            'Temperature',
            '°C',
            (r) => r.temperature,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildCompactChart(
            readings,
            'pH',
            '',
            (r) => r.ph,
            Colors.purple,
          ),
          const SizedBox(height: 24),
          _buildCompactChart(
            readings,
            'Nitrogen',
            'ppm',
            (r) => r.nitrogen.toDouble(),
            Colors.red,
          ),
          const SizedBox(height: 24),
          _buildCompactChart(
            readings,
            'Phosphorus',
            'ppm',
            (r) => r.phosphorus.toDouble(),
            Colors.teal,
          ),
          const SizedBox(height: 24),
          _buildCompactChart(
            readings,
            'Potassium',
            'ppm',
            (r) => r.potassium.toDouble(),
            Colors.amber,
          ),
          const SizedBox(height: 24),
          _buildCompactChart(
            readings,
            'Salinity',
            'g/L',
            (r) => r.salinity,
            Colors.cyan,
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildCompactChart(
    List<SensorReading> readings,
    String title,
    String unit,
    double Function(SensorReading) valueExtractor,
    Color color,
  ) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ($unit)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (yMax - yMin) / 4,
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
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: (yMax - yMin) / 4,
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
        const SizedBox(height: 4),
        Text(
          'Range: ${minValue.toStringAsFixed(2)} - ${maxValue.toStringAsFixed(2)} $unit',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
