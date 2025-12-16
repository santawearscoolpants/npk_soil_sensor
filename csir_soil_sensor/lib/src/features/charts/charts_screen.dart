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

// Provider to persist the selected session ID across tab navigation
final _selectedSessionIdProvider = StateProvider<int?>((ref) => null);

// Provider to persist the selected chart tab index across tab navigation
final _selectedChartTabIndexProvider = StateProvider<int>((ref) => 0);

// Provider for date range filter
final _dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// Provider for multiple session comparison
final _comparisonSessionIdsProvider = StateProvider<List<int>>((ref) => []);

// Export the provider so it can be invalidated from other screens
final readingsProvider = FutureProvider.family
    .autoDispose<List<SensorReading>, List<int>?>((ref, readingIds) async {
  // Watch sessions provider so readings refresh when sessions change
  ref.watch(_sessionsProvider);
  
  final sensorRepo = ref.read(sensorRepoProvider);
  if (readingIds == null) {
    return await sensorRepo.getAllReadings();
  }
  return await sensorRepo.getReadingsByIds(readingIds);
});

// Keep the private version for internal use
final _readingsProvider = readingsProvider;

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
  TabController? _tabController;
  final Map<int, GlobalKey> _chartKeys = {};
  bool _tabControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize global keys for each chart
    for (int i = 0; i < 9; i++) {
      _chartKeys[i] = GlobalKey();
    }
  }

  void _initializeTabController(WidgetRef ref) {
    if (_tabController != null) return;
    
    // Get the persisted tab index from the provider
    final initialTabIndex = ref.read(_selectedChartTabIndexProvider);
    _tabController = TabController(
      length: 9,
      vsync: this,
      initialIndex: initialTabIndex,
    );
    
    // Listen to tab changes and persist the index
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging && _tabControllerInitialized) {
        ref.read(_selectedChartTabIndexProvider.notifier).state = _tabController!.index;
      }
    });
    
    _tabControllerInitialized = true;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
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

  /// Performance optimization: Sample data for large datasets
  /// Returns sampled readings if dataset is too large, otherwise returns original
  List<SensorReading> _sampleDataIfNeeded(List<SensorReading> readings, {int maxPoints = 500}) {
    if (readings.length <= maxPoints) {
      return readings;
    }
    
    // Sample data evenly across the dataset
    final step = (readings.length / maxPoints).ceil();
    final sampled = <SensorReading>[];
    
    for (int i = 0; i < readings.length; i += step) {
      sampled.add(readings[i]);
    }
    
    // Always include the last reading
    if (sampled.last != readings.last) {
      sampled.add(readings.last);
    }
    
    return sampled;
  }

  /// Filter readings by date range
  List<SensorReading> _filterByDateRange(
    List<SensorReading> readings,
    DateTimeRange? dateRange,
  ) {
    if (dateRange == null) return readings;
    
    return readings.where((reading) {
      final readingDate = reading.timestamp;
      return readingDate.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
             readingDate.isBefore(dateRange.end.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Get readings for multiple sessions for comparison
  Future<List<SensorReading>> _getComparisonReadings(
    List<int> sessionIds,
    List<ReadingSession> sessions,
  ) async {
    if (sessionIds.isEmpty) return [];
    
    final allReadingIds = <int>[];
    for (final sessionId in sessionIds) {
      final session = sessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => ReadingSession(id: -1, createdAt: DateTime.now(), readingIds: []),
      );
      if (session.id != -1) {
        allReadingIds.addAll(session.readingIds);
      }
    }
    
    if (allReadingIds.isEmpty) return [];
    
    final sensorRepo = ref.read(sensorRepoProvider);
    return await sensorRepo.getReadingsByIds(allReadingIds);
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

  Future<void> _exportAllSensorsChart(int? sessionId) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exporting all sensors... Please wait.')),
        );
      }

      // Store current tab index to restore later
      if (_tabController == null) return;
      final originalTabIndex = _tabController!.index;
      
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
        _tabController?.animateTo(chartIndex);
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
      _tabController?.animateTo(originalTabIndex);

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

  List<int>? _getSelectedReadingIds(List<ReadingSession> sessions, int? selectedSessionId) {
    if (selectedSessionId == null) return null; // null means "All Readings"
    final session = sessions.firstWhere(
      (s) => s.id == selectedSessionId,
      orElse: () => ReadingSession(
        id: -1,
        createdAt: DateTime.now(),
        readingIds: [],
      ),
    );
    return session.id == -1 ? null : session.readingIds;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize TabController on first build
    _initializeTabController(ref);
    
    // Get the selected session ID from the persistent provider
    final selectedSessionId = ref.watch(_selectedSessionIdProvider);
    
    // Get the persisted tab index and sync TabController if needed
    final persistedTabIndex = ref.watch(_selectedChartTabIndexProvider);
    if (_tabController != null && _tabController!.index != persistedTabIndex && !_tabController!.indexIsChanging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tabController != null && _tabController!.index != persistedTabIndex) {
          _tabController!.animateTo(persistedTabIndex);
        }
      });
    }
    
    final sessionsAsync = ref.watch(_sessionsProvider);
    
    // Auto-select first session if none is selected and sessions exist
    sessionsAsync.whenData((sessions) {
      if (sessions.isNotEmpty && selectedSessionId == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(_selectedSessionIdProvider.notifier).state = sessions.first.id;
        });
      }
    });
    
    final readingIds = sessionsAsync.when(
      data: (sessions) {
        // If no session selected, use first session if available
        final effectiveSessionId = selectedSessionId ?? (sessions.isNotEmpty ? sessions.first.id : null);
        return _getSelectedReadingIds(sessions, effectiveSessionId);
      },
      loading: () => null,
      error: (_, __) => null,
    );
    final readingsAsync = ref.watch(_readingsProvider(readingIds));
    
    // Get session name for display
    final selectedSessionName = sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) return 'No sessions';
        final effectiveSessionId = selectedSessionId ?? sessions.first.id;
        final session = sessions.firstWhere(
          (s) => s.id == effectiveSessionId,
          orElse: () => ReadingSession(
            id: -1,
            createdAt: DateTime.now(),
            readingIds: [],
          ),
        );
        return session.id == -1 ? 'No session' : 'Session #${session.id}';
      },
      loading: () => 'Loading...',
      error: (_, __) => 'Error',
    );

    // Return early if TabController is not initialized yet
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Charts'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.inversePrimary,
          onTap: (index) {
            // Update the persisted tab index when user taps a tab
            ref.read(_selectedChartTabIndexProvider.notifier).state = index;
          },
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
            onSelected: (value) {
              // Update the persistent provider - this will trigger a rebuild
              ref.read(_selectedSessionIdProvider.notifier).state = value;
            },
            itemBuilder: (context) {
              // Watch the provider so the checkmark updates when selection changes
              final currentSelectedId = ref.watch(_selectedSessionIdProvider);
              return sessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return [
                      const PopupMenuItem(child: Text('No sessions available')),
                    ];
                  }
                  return sessions.map(
                    (session) => PopupMenuItem<int?>(
                      value: session.id,
                      child: Row(
                        children: [
                          if (currentSelectedId == session.id)
                            const Icon(Icons.check, size: 20, color: Colors.green),
                          if (currentSelectedId == session.id) const SizedBox(width: 8),
                          Text('Session #${session.id}'),
                        ],
                      ),
                    ),
                  ).toList();
                },
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No readings available to display',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect to a device and collect readings to see charts',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                try {
                  // Sort readings by timestamp
                  final sortedReadings = List<SensorReading>.from(readings)
                    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                  // Apply date range filter if set
                  final dateRange = ref.watch(_dateRangeProvider);
                  final filteredReadings = _filterByDateRange(sortedReadings, dateRange);

                  if (filteredReadings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No readings in selected date range',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              ref.read(_dateRangeProvider.notifier).state = null;
                            },
                            child: const Text('Clear date filter'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Sample data for performance if needed
                  final displayReadings = _sampleDataIfNeeded(filteredReadings);

                    return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllChartsView(displayReadings, originalCount: filteredReadings.length),
                      _buildChart(
                        displayReadings,
                        1,
                        'Moisture',
                        '%',
                        (r) => r.moisture,
                        Colors.blue,
                        originalCount: filteredReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        2,
                        'EC',
                        'mS/cm',
                        (r) => r.ec,
                        Colors.green,
                        originalCount: filteredReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        3,
                        'Temperature',
                        '°C',
                        (r) => r.temperature,
                        Colors.orange,
                        originalCount: filteredReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        4,
                        'pH',
                        '',
                        (r) => r.ph,
                        Colors.purple,
                        originalCount: filteredReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        5,
                        'Nitrogen',
                        'ppm',
                        (r) => r.nitrogen.toDouble(),
                        Colors.red,
                        originalCount: filteredReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        6,
                        'Phosphorus',
                        'ppm',
                        (r) => r.phosphorus.toDouble(),
                        Colors.teal,
                        originalCount: filteredReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        7,
                        'Potassium',
                        'ppm',
                        (r) => r.potassium.toDouble(),
                        Colors.amber,
                        originalCount: filteredReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        8,
                        'Salinity',
                        'g/L',
                        (r) => r.salinity,
                        Colors.cyan,
                        originalCount: filteredReadings.length,
                      ),
                    ],
                  );
                } catch (e) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error displaying charts',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red[700],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          e.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
              },
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading chart data...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading readings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red[700],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
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
    Color color, {
    int originalCount = 0,
  }) {
    if (readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
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
                    enabled: true,
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
                  // Enable zoom and pan
                  clipData: const FlClipData.all(),
                  extraLinesData: ExtraLinesData(
                    verticalLines: [],
                    horizontalLines: [],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Range: ${minValue.toStringAsFixed(2)} - ${maxValue.toStringAsFixed(2)} $unit',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (originalCount > 0 && originalCount != readings.length)
                  Text(
                    '${readings.length}/${originalCount} points',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                        ),
                  )
                else
                  Text(
                    '${readings.length} readings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllChartsView(List<SensorReading> readings, {int originalCount = 0}) {
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
