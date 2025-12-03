import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/bluetooth_service.dart';
import '../../services/mock_data.dart';

class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleState = ref.watch(bluetoothServiceProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Data'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () {
                // Demo mode: inject a mock reading event
                ref
                    .read(bluetoothServiceProvider.notifier)
                    .emitMockReading(generateMockPayload());
              },
              tooltip: 'Demo reading',
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(bluetoothServiceProvider.notifier)
                            .scanAndConnect();
                      },
                      icon: const Icon(Icons.bluetooth_searching),
                      label: const Text('Scan & Connect'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Status: ${bleState.connectionStatus}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: bleState.latestReading == null
                  ? const Center(
                      child:
                          Text('No data yet. Connect device or use demo mode.'),
                    )
                  : _LiveReadingCard(reading: bleState.latestReading!),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: bleState.latestReading == null
                    ? null
                    : () async {
                        await ref
                            .read(bluetoothServiceProvider.notifier)
                            .saveLatestReading();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reading saved locally'),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.save),
                label: const Text('Save Reading'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveReadingCard extends StatelessWidget {
  const _LiveReadingCard({
    required this.reading,
  });

  final LiveReading reading;

  Color _rangeColor(
    double value,
    double low,
    double high,
  ) {
    if (value < low || value > high) {
      return Colors.red;
    }
    final midLow = low + (high - low) * 0.25;
    final midHigh = low + (high - low) * 0.75;
    if (value < midLow || value > midHigh) {
      return Colors.amber;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final chipStyle = Theme.of(context).textTheme.bodyMedium;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Latest Reading',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Timestamp: ${DateTime.fromMillisecondsSinceEpoch(reading.timestamp * 1000)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip(
                    label: 'Moisture',
                    value: '${reading.moisture.toStringAsFixed(1)} %',
                    color:
                        _rangeColor(reading.moisture, 20, 60), // placeholder
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'EC',
                    value: '${reading.ec.toStringAsFixed(2)} mS/cm',
                    color: _rangeColor(reading.ec, 1, 3),
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'Temp',
                    value: '${reading.temperature.toStringAsFixed(1)} °C',
                    color: _rangeColor(reading.temperature, 18, 32),
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'pH',
                    value: reading.ph.toStringAsFixed(1),
                    color: _rangeColor(reading.ph, 5.5, 7.5),
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'N',
                    value: '${reading.nitrogen} mg/kg',
                    color: _rangeColor(reading.nitrogen.toDouble(), 20, 80),
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'P',
                    value: '${reading.phosphorus} mg/kg',
                    color: _rangeColor(reading.phosphorus.toDouble(), 10, 60),
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'K',
                    value: '${reading.potassium} mg/kg',
                    color: _rangeColor(reading.potassium.toDouble(), 20, 100),
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'Salinity',
                    value: '${reading.salinity.toStringAsFixed(2)}',
                    color: _rangeColor(reading.salinity, 0.2, 1.5),
                    style: chipStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
    required this.style,
  });

  final String label;
  final String value;
  final Color color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withOpacity(0.15),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: style?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: style),
        ],
      ),
    );
  }
}


