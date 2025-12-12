import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> _exportChart(int chartIndex, String chartName) async {
    final key = _chartKeys[chartIndex];
    if (key == null || key.currentContext == null) return;

    try {
      // Get the RenderRepaintBoundary from the GlobalKey
      final renderObject = key.currentContext!.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chart not ready for export')),
          );
        }
        return;
      }
      final RenderRepaintBoundary boundary = renderObject;
      
      // Capture the image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
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

      final dir = await getTemporaryDirectory();
      final fileName =
          '${chartName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles([XFile(file.path)],
          text: 'Chart: $chartName');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chart exported: $chartName')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Charts'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Moisture'),
            Tab(text: 'EC'),
            Tab(text: 'Temperature'),
            Tab(text: 'pH'),
            Tab(text: 'Nitrogen'),
            Tab(text: 'Phosphorus'),
            Tab(text: 'Potassium'),
            Tab(text: 'Salinity'),
            Tab(text: 'All'),
          ],
        ),
        actions: [
          PopupMenuButton<int?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by session',
            onSelected: (value) {
              setState(() {
                _selectedSessionId = value;
              });
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
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export current chart',
            onPressed: () {
              final chartNames = [
                'Moisture',
                'EC',
                'Temperature',
                'pH',
                'Nitrogen',
                'Phosphorus',
                'Potassium',
                'Salinity',
                'All_Sensors',
              ];
              _exportChart(_tabController.index, chartNames[_tabController.index]);
            },
          ),
        ],
      ),
      body: readingsAsync.when(
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
              _buildChart(
                sortedReadings,
                0,
                'Moisture',
                '%',
                (r) => r.moisture,
                Colors.blue,
              ),
              _buildChart(
                sortedReadings,
                1,
                'EC',
                'mS/cm',
                (r) => r.ec,
                Colors.green,
              ),
              _buildChart(
                sortedReadings,
                2,
                'Temperature',
                '°C',
                (r) => r.temperature,
                Colors.orange,
              ),
              _buildChart(
                sortedReadings,
                3,
                'pH',
                '',
                (r) => r.ph,
                Colors.purple,
              ),
              _buildChart(
                sortedReadings,
                4,
                'Nitrogen',
                'ppm',
                (r) => r.nitrogen.toDouble(),
                Colors.red,
              ),
              _buildChart(
                sortedReadings,
                5,
                'Phosphorus',
                'ppm',
                (r) => r.phosphorus.toDouble(),
                Colors.teal,
              ),
              _buildChart(
                sortedReadings,
                6,
                'Potassium',
                'ppm',
                (r) => r.potassium.toDouble(),
                Colors.amber,
              ),
              _buildChart(
                sortedReadings,
                7,
                'Salinity',
                'g/L',
                (r) => r.salinity,
                Colors.cyan,
              ),
              _buildAllChartsView(sortedReadings),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading readings: $error'),
        ),
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
    return SingleChildScrollView(
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
