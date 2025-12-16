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
import '../../core/thresholds.dart';

final _sessionsProvider =
    FutureProvider.autoDispose<List<ReadingSession>>((ref) async {
  final sessionStore = ref.read(sessionStoreProvider);
  return sessionStore.loadSessions();
});

// Provider to persist the selected session ID across tab navigation
final _selectedSessionIdProvider = StateProvider<int?>((ref) => null);

// Provider to persist the selected chart tab index across tab navigation
final _selectedChartTabIndexProvider = StateProvider<int>((ref) => 0);

// Provider for multiple session comparison
final _comparisonSessionIdsProvider = StateProvider<List<int>>((ref) => []);

// Provider for comparison readings - returns readings grouped by session
final _comparisonReadingsProvider = FutureProvider.autoDispose<Map<int, List<SensorReading>>>((ref) async {
  final comparisonIds = ref.watch(_comparisonSessionIdsProvider);
  if (comparisonIds.isEmpty) return {};
  
  final sessions = await ref.watch(_sessionsProvider.future);
  final sensorRepo = ref.read(sensorRepoProvider);
  final sessionReadings = <int, List<SensorReading>>{};
  
  for (final sessionId in comparisonIds) {
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => ReadingSession(id: -1, createdAt: DateTime.now(), readingIds: []),
    );
    if (session.id != -1 && session.readingIds.isNotEmpty) {
      // Limit readings per session to prevent performance issues
      final limitedIds = session.readingIds.length > 5000 
          ? session.readingIds.take(5000).toList()
          : session.readingIds;
      final readings = await sensorRepo.getReadingsByIds(limitedIds);
      if (readings.isNotEmpty) {
        sessionReadings[session.id] = readings;
      }
    }
  }
  
  return sessionReadings;
});

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

  /// Get threshold values for a specific sensor type
  ({double low, double high, String info}) _getThresholds(int chartIndex) {
    switch (chartIndex) {
      case 1: // Moisture
        return (
          low: TomatoThresholds.moistureLow,
          high: TomatoThresholds.moistureHigh,
          info: 'Ideal: ${TomatoThresholds.moistureLow}-${TomatoThresholds.moistureHigh}%'
        );
      case 2: // EC
        return (
          low: TomatoThresholds.ecLow,
          high: TomatoThresholds.ecHigh,
          info: 'Ideal: ${TomatoThresholds.ecLow}-${TomatoThresholds.ecHigh} mS/cm'
        );
      case 3: // Temperature
        return (
          low: TomatoThresholds.temperatureLow,
          high: TomatoThresholds.temperatureHigh,
          info: 'Ideal: ${TomatoThresholds.temperatureLow}-${TomatoThresholds.temperatureHigh}°C'
        );
      case 4: // pH
        return (
          low: TomatoThresholds.phLow,
          high: TomatoThresholds.phHigh,
          info: 'Ideal: ${TomatoThresholds.phLow}-${TomatoThresholds.phHigh}'
        );
      case 5: // Nitrogen
        return (
          low: TomatoThresholds.nitrogenLow,
          high: TomatoThresholds.nitrogenHigh,
          info: 'Ideal: ${TomatoThresholds.nitrogenLow}-${TomatoThresholds.nitrogenHigh} ppm'
        );
      case 6: // Phosphorus
        return (
          low: TomatoThresholds.phosphorusLow,
          high: TomatoThresholds.phosphorusHigh,
          info: 'Ideal: ${TomatoThresholds.phosphorusLow}-${TomatoThresholds.phosphorusHigh} ppm'
        );
      case 7: // Potassium
        return (
          low: TomatoThresholds.potassiumLow,
          high: TomatoThresholds.potassiumHigh,
          info: 'Ideal: ${TomatoThresholds.potassiumLow}-${TomatoThresholds.potassiumHigh} ppm'
        );
      case 8: // Salinity
        return (
          low: TomatoThresholds.salinityLow,
          high: TomatoThresholds.salinityHigh,
          info: 'Ideal: ${TomatoThresholds.salinityLow}-${TomatoThresholds.salinityHigh} g/L'
        );
      default:
        return (low: 0, high: 0, info: '');
    }
  }

  /// Build horizontal reference lines for optimal thresholds
  List<HorizontalLine> _buildThresholdLines(int chartIndex, double yMin, double yMax) {
    if (chartIndex == 0) return []; // No thresholds for "All" view
    
    final thresholds = _getThresholds(chartIndex);
    if (thresholds.low == 0 && thresholds.high == 0) return [];
    
    // Only show lines if they're within the visible range
    final lines = <HorizontalLine>[];
    
    if (thresholds.low >= yMin && thresholds.low <= yMax) {
      lines.add(
        HorizontalLine(
          y: thresholds.low,
          color: Colors.green.withOpacity(0.6),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: false, // Threshold info shown in footer instead
          ),
        ),
      );
    }
    
    if (thresholds.high >= yMin && thresholds.high <= yMax) {
      lines.add(
        HorizontalLine(
          y: thresholds.high,
          color: Colors.green.withOpacity(0.6),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: false, // Threshold info shown in footer instead
          ),
        ),
      );
    }
    
    return lines;
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


  /// Show session comparison dialog
  Future<void> _showSessionComparisonDialog(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ReadingSession>> sessionsAsync,
  ) async {
    await sessionsAsync.when(
      data: (sessions) async {
        if (sessions.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No sessions available for comparison')),
            );
          }
          return;
        }

        final currentComparisonIds = List<int>.from(ref.read(_comparisonSessionIdsProvider));
        final selectedIds = <int>{...currentComparisonIds};

        if (!context.mounted) return;
        final result = await showDialog<Set<int>>(
          context: context,
          builder: (context) => _SessionComparisonDialog(
            sessions: sessions,
            selectedIds: selectedIds,
          ),
        );

        if (result != null) {
          ref.read(_comparisonSessionIdsProvider.notifier).state = result.toList();
          
          // If comparison mode is active, switch to first selected session for main view
          if (result.isNotEmpty) {
            ref.read(_selectedSessionIdProvider.notifier).state = result.first;
          }
        }
      },
      loading: () async {},
      error: (error, _) async {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading sessions: $error')),
          );
        }
      },
    );
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
    
    // Check if comparison mode is active
    final comparisonIds = ref.watch(_comparisonSessionIdsProvider);
    
    final readingIds = sessionsAsync.when(
      data: (sessions) {
        // If comparison mode is active, return null to use comparison provider
        if (comparisonIds.isNotEmpty) {
          return null; // Will use _comparisonReadingsProvider instead
        }
        
        // Otherwise, use selected session or first session
        final effectiveSessionId = selectedSessionId ?? (sessions.isNotEmpty ? sessions.first.id : null);
        return _getSelectedReadingIds(sessions, effectiveSessionId);
      },
      loading: () => null,
      error: (_, __) => null,
    );
    
    // Use comparison provider if comparison mode is active, otherwise use regular provider
    final isComparisonMode = comparisonIds.isNotEmpty;
    
    // Get comparison data separately for multi-line rendering
    final comparisonDataAsync = isComparisonMode
        ? ref.watch(_comparisonReadingsProvider)
        : null;
    
    // For non-comparison mode, use regular readings provider
    final readingsAsync = isComparisonMode
        ? null
        : ref.watch(_readingsProvider(readingIds));
    
    // Get session name for display
    final selectedSessionName = sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) return 'No sessions';
        
        // If comparison mode is active, show comparison info
        if (comparisonIds.isNotEmpty) {
          if (comparisonIds.length == 1) {
            return 'Session #${comparisonIds.first}';
          } else {
            return '${comparisonIds.length} Sessions';
          }
        }
        
        // Otherwise show selected session
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
          // Session comparison button
          Builder(
            builder: (context) {
              final comparisonIds = ref.watch(_comparisonSessionIdsProvider);
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.compare_arrows),
                    if (comparisonIds.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${comparisonIds.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: 'Compare multiple sessions',
                onPressed: () => _showSessionComparisonDialog(context, ref, sessionsAsync),
              );
            },
          ),
          // Session filter button
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
          Builder(
            builder: (context) {
              final comparisonIds = ref.watch(_comparisonSessionIdsProvider);
              final hasComparison = comparisonIds.isNotEmpty;
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Viewing: $selectedSessionName',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        if (hasComparison)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            tooltip: 'Clear comparison',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ref.read(_comparisonSessionIdsProvider.notifier).state = [];
                            },
                          ),
                      ],
                    ),
                    if (comparisonIds.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Comparing ${comparisonIds.length} session${comparisonIds.length > 1 ? 's' : ''}: ${comparisonIds.map((id) => '#$id').join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          // Charts content
          Expanded(
            child: isComparisonMode && comparisonDataAsync != null
                ? comparisonDataAsync.when(
                    data: (sessionReadings) {
                      if (sessionReadings.isEmpty) {
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
                            ],
                          ),
                        );
                      }

                      try {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAllChartsViewComparison(sessionReadings),
                            _buildComparisonChart(
                              sessionReadings,
                              1,
                              'Moisture',
                              '%',
                              (r) => r.moisture,
                              Colors.blue,
                            ),
                            _buildComparisonChart(
                              sessionReadings,
                              2,
                              'EC',
                              'mS/cm',
                              (r) => r.ec,
                              Colors.green,
                            ),
                            _buildComparisonChart(
                              sessionReadings,
                              3,
                              'Temperature',
                              '°C',
                              (r) => r.temperature,
                              Colors.orange,
                            ),
                            _buildComparisonChart(
                              sessionReadings,
                              4,
                              'pH',
                              '',
                              (r) => r.ph,
                              Colors.purple,
                            ),
                            _buildComparisonChart(
                              sessionReadings,
                              5,
                              'Nitrogen',
                              'ppm',
                              (r) => r.nitrogen.toDouble(),
                              Colors.red,
                            ),
                            _buildComparisonChart(
                              sessionReadings,
                              6,
                              'Phosphorus',
                              'ppm',
                              (r) => r.phosphorus.toDouble(),
                              Colors.teal,
                            ),
                            _buildComparisonChart(
                              sessionReadings,
                              7,
                              'Potassium',
                              'ppm',
                              (r) => r.potassium.toDouble(),
                              Colors.amber,
                            ),
                            _buildComparisonChart(
                              sessionReadings,
                              8,
                              'Salinity',
                              'g/L',
                              (r) => r.salinity,
                              Colors.cyan,
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
                            'Loading comparison data...',
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
                            'Error loading comparison data',
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
                  )
                : readingsAsync != null
                    ? readingsAsync.when(
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

                  // Sample data for performance if needed
                  final displayReadings = _sampleDataIfNeeded(sortedReadings);

                    return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllChartsView(displayReadings, originalCount: sortedReadings.length),
                      _buildChart(
                        displayReadings,
                        1,
                        'Moisture',
                        '%',
                        (r) => r.moisture,
                        Colors.blue,
                        originalCount: sortedReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        2,
                        'EC',
                        'mS/cm',
                        (r) => r.ec,
                        Colors.green,
                        originalCount: sortedReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        3,
                        'Temperature',
                        '°C',
                        (r) => r.temperature,
                        Colors.orange,
                        originalCount: sortedReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        4,
                        'pH',
                        '',
                        (r) => r.ph,
                        Colors.purple,
                        originalCount: sortedReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        5,
                        'Nitrogen',
                        'ppm',
                        (r) => r.nitrogen.toDouble(),
                        Colors.red,
                        originalCount: sortedReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        6,
                        'Phosphorus',
                        'ppm',
                        (r) => r.phosphorus.toDouble(),
                        Colors.teal,
                        originalCount: sortedReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        7,
                        'Potassium',
                        'ppm',
                        (r) => r.potassium.toDouble(),
                        Colors.amber,
                        originalCount: sortedReadings.length,
                      ),
                      _buildChart(
                        displayReadings,
                        8,
                        'Salinity',
                        'g/L',
                        (r) => r.salinity,
                        Colors.cyan,
                        originalCount: sortedReadings.length,
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
            )
                    : const Center(child: Text('No data available')),
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
                    horizontalLines: _buildThresholdLines(chartIndex, yMin, yMax),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Range: ${minValue.toStringAsFixed(2)} - ${maxValue.toStringAsFixed(2)} $unit',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (chartIndex > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        _getThresholds(chartIndex).info,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ],
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

  /// Build chart with multiple lines for comparison mode
  Widget _buildComparisonChart(
    Map<int, List<SensorReading>> sessionReadings,
    int chartIndex,
    String title,
    String unit,
    double Function(SensorReading) valueExtractor,
    Color baseColor, {
    GlobalKey? customKey,
    bool isScrollable = false,
  }) {
    // Define colors for different sessions
    final sessionColors = [
      baseColor,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
      Colors.lime,
      Colors.deepOrange,
      Colors.cyanAccent,
      Colors.purpleAccent,
    ];

    // Prepare line data for each session
    final lineBarsData = <LineChartBarData>[];
    final sessionIds = sessionReadings.keys.toList()..sort();
    
    if (sessionIds.isEmpty) {
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

    // Calculate global min/max across all sessions
    double globalMin = double.infinity;
    double globalMax = double.negativeInfinity;
    final allReadings = sessionReadings.values.expand((r) => r).toList();
    
    for (final reading in allReadings) {
      final value = valueExtractor(reading);
      if (value < globalMin) globalMin = value;
      if (value > globalMax) globalMax = value;
    }

    final range = globalMax - globalMin;
    final padding = range > 0 ? range * 0.1 : (globalMin.abs() * 0.1 + 1);
    final yMin = globalMin - padding;
    final yMax = globalMax + padding;

    // Build a line for each session
    for (int i = 0; i < sessionIds.length; i++) {
      final sessionId = sessionIds[i];
      final readings = sessionReadings[sessionId]!;
      
      // Sort by timestamp
      final sortedReadings = List<SensorReading>.from(readings)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      // Sample if needed
      final displayReadings = _sampleDataIfNeeded(sortedReadings);
      
      // Create spots for this session
      final spots = displayReadings.asMap().entries.map((entry) {
        final index = entry.key.toDouble();
        final value = valueExtractor(entry.value);
        return FlSpot(index, value);
      }).toList();

      final color = sessionColors[i % sessionColors.length];
      
      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: false, // Don't show area fill for comparison
          ),
        ),
      );
    }

    // Prepare X axis labels (use first session's readings for labels)
    final firstSessionReadings = sessionReadings[sessionIds.first]!;
    final sortedFirst = List<SensorReading>.from(firstSessionReadings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final sampledFirst = _sampleDataIfNeeded(sortedFirst);
    final xLabels = sampledFirst.map((r) {
      final time = r.timestamp;
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }).toList();

    // Build the chart widget - use SizedBox for scrollable, Expanded for non-scrollable
    final chartWidget = isScrollable
        ? SizedBox(
            height: 300,
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
                      interval: (xLabels.length / 5).ceil().toDouble(),
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
                maxX: (xLabels.length - 1).toDouble(),
                minY: yMin,
                maxY: yMax,
                lineBarsData: lineBarsData,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final barIndex = spot.barIndex;
                        final xIndex = spot.x.toInt();
                        if (barIndex < sessionIds.length && xIndex >= 0) {
                          final sessionId = sessionIds[barIndex];
                          final readings = sessionReadings[sessionId]!;
                          final sorted = List<SensorReading>.from(readings)
                            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
                          final sampled = _sampleDataIfNeeded(sorted);
                          if (xIndex < sampled.length) {
                            final reading = sampled[xIndex];
                            final color = sessionColors[barIndex % sessionColors.length];
                            return LineTooltipItem(
                              'Session #$sessionId\n${valueExtractor(reading).toStringAsFixed(2)} $unit\n${reading.timestamp.toString().split('.')[0]}',
                              TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
                clipData: const FlClipData.all(),
                extraLinesData: ExtraLinesData(
                  verticalLines: [],
                  horizontalLines: _buildThresholdLines(chartIndex, yMin, yMax),
                ),
              ),
            ),
          )
        : Expanded(
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
                        interval: (xLabels.length / 5).ceil().toDouble(),
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
                  maxX: (xLabels.length - 1).toDouble(),
                  minY: yMin,
                  maxY: yMax,
                  lineBarsData: lineBarsData,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final barIndex = spot.barIndex;
                          final xIndex = spot.x.toInt();
                          if (barIndex < sessionIds.length && xIndex >= 0) {
                            final sessionId = sessionIds[barIndex];
                            final readings = sessionReadings[sessionId]!;
                            final sorted = List<SensorReading>.from(readings)
                              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
                            final sampled = _sampleDataIfNeeded(sorted);
                            if (xIndex < sampled.length) {
                              final reading = sampled[xIndex];
                              final color = sessionColors[barIndex % sessionColors.length];
                              return LineTooltipItem(
                                'Session #$sessionId\n${valueExtractor(reading).toStringAsFixed(2)} $unit\n${reading.timestamp.toString().split('.')[0]}',
                                TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                  clipData: const FlClipData.all(),
                  extraLinesData: ExtraLinesData(
                    verticalLines: [],
                    horizontalLines: _buildThresholdLines(chartIndex, yMin, yMax),
                  ),
                ),
              ),
            );

    return RepaintBoundary(
      key: customKey ?? _chartKeys[chartIndex],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isScrollable ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Text(
              '$title ($unit)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            // Legend with improved styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: sessionIds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sessionId = entry.value;
                  final color = sessionColors[index % sessionColors.length];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 3,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Session #$sessionId',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: color,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            chartWidget,
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Range: ${globalMin.toStringAsFixed(2)} - ${globalMax.toStringAsFixed(2)} $unit',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (chartIndex > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getThresholds(chartIndex).info,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllChartsViewComparison(Map<int, List<SensorReading>> sessionReadings) {
    // Create unique keys for each chart in the "All" view to avoid duplicate key errors
    final allViewKeys = <int, GlobalKey>{};
    for (int i = 0; i < 8; i++) {
      allViewKeys[i] = GlobalKey();
    }
    
    return RepaintBoundary(
      key: _chartKeys[0],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Sensors Overview (Comparison)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildComparisonChart(
              sessionReadings,
              0,
              'Moisture',
              '%',
              (r) => r.moisture,
              Colors.blue,
              customKey: allViewKeys[0],
              isScrollable: true,
            ),
            const SizedBox(height: 24),
            _buildComparisonChart(
              sessionReadings,
              0,
              'EC',
              'mS/cm',
              (r) => r.ec,
              Colors.green,
              customKey: allViewKeys[1],
              isScrollable: true,
            ),
            const SizedBox(height: 24),
            _buildComparisonChart(
              sessionReadings,
              0,
              'Temperature',
              '°C',
              (r) => r.temperature,
              Colors.orange,
              customKey: allViewKeys[2],
              isScrollable: true,
            ),
            const SizedBox(height: 24),
            _buildComparisonChart(
              sessionReadings,
              0,
              'pH',
              '',
              (r) => r.ph,
              Colors.purple,
              customKey: allViewKeys[3],
              isScrollable: true,
            ),
            const SizedBox(height: 24),
            _buildComparisonChart(
              sessionReadings,
              0,
              'Nitrogen',
              'ppm',
              (r) => r.nitrogen.toDouble(),
              Colors.red,
              customKey: allViewKeys[4],
              isScrollable: true,
            ),
            const SizedBox(height: 24),
            _buildComparisonChart(
              sessionReadings,
              0,
              'Phosphorus',
              'ppm',
              (r) => r.phosphorus.toDouble(),
              Colors.teal,
              customKey: allViewKeys[5],
              isScrollable: true,
            ),
            const SizedBox(height: 24),
            _buildComparisonChart(
              sessionReadings,
              0,
              'Potassium',
              'ppm',
              (r) => r.potassium.toDouble(),
              Colors.amber,
              customKey: allViewKeys[6],
              isScrollable: true,
            ),
            const SizedBox(height: 24),
            _buildComparisonChart(
              sessionReadings,
              0,
              'Salinity',
              'g/L',
              (r) => r.salinity,
              Colors.cyan,
              customKey: allViewKeys[7],
              isScrollable: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for selecting multiple sessions for comparison
class _SessionComparisonDialog extends StatefulWidget {
  const _SessionComparisonDialog({
    required this.sessions,
    required this.selectedIds,
  });

  final List<ReadingSession> sessions;
  final Set<int> selectedIds;

  @override
  State<_SessionComparisonDialog> createState() => _SessionComparisonDialogState();
}

class _SessionComparisonDialogState extends State<_SessionComparisonDialog> {
  late Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<int>.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Compare Sessions'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select multiple sessions to compare on the same chart',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.sessions.length,
                itemBuilder: (context, index) {
                  final session = widget.sessions[index];
                  final isSelected = _selectedIds.contains(session.id);
                  return CheckboxListTile(
                    title: Text('Session #${session.id}'),
                    subtitle: Text(
                      '${session.readingIds.length} readings • ${session.createdAt.toLocal().toString().split('.')[0]}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds.add(session.id);
                        } else {
                          _selectedIds.remove(session.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(<int>{});
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedIds);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
