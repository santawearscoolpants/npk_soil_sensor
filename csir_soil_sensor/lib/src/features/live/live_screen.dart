import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/crop_repository.dart';
import '../../services/bluetooth_service.dart';
import '../bluetooth/bluetooth_connection_screen.dart';

final _cropParamsProvider =
    FutureProvider.autoDispose<List<CropParam>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final repo = CropRepository(db);
  return repo.getAllCropParams();
});

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  int? _selectedCropParamsId;

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bluetoothServiceProvider);
    final cropParamsAsync = ref.watch(_cropParamsProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Data'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bluetooth),
              tooltip: 'Bluetooth Connection',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BluetoothConnectionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Connection status card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bleState.connectionStatus == 'Connected' &&
                                    bleState.connectedDeviceName != null
                                ? Colors.green
                                : bleState.connectionStatus.startsWith('Scanning') ||
                                        bleState.connectionStatus
                                            .startsWith('Connecting')
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bluetooth Status',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bleState.connectedDeviceName != null
                                    ? '${bleState.connectionStatus} (${bleState.connectedDeviceName})'
                                    : bleState.connectionStatus,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BluetoothConnectionScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Manage'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCropParamsId,
                        decoration: const InputDecoration(
                          labelText: 'Link to crop parameter set',
                          hintText: 'Optional',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('None (save without linking)'),
                          ),
                          ...cropParamsAsync.when(
                            data: (params) => params
                                .map(
                                  (p) => DropdownMenuItem<int>(
                                    value: p.id,
                                    child: Text(
                                      'Set #${p.id}: ${p.soilType} (${p.createdAt.toLocal().toString().split(' ')[0]})',
                                    ),
                                  ),
                                )
                                .toList(),
                            loading: () => [],
                            error: (_, __) => [],
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCropParamsId = value;
                          });
                              ref
                                  .read(bluetoothServiceProvider.notifier)
                                  .setActiveCropParamsId(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (bleState.connectionStatus == 'Connected' &&
                  bleState.connectedDeviceName != null &&
                  bleState.latestReading != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _LiveReadingCard(reading: bleState.latestReading!),
                ),
              if (!(bleState.connectionStatus == 'Connected' &&
                  bleState.connectedDeviceName != null &&
                  bleState.latestReading != null))
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text('No data yet. Connect device to see readings.'),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: bleState.pendingCount == 0
                      ? null
                      : () async {
                          final session = await ref
                              .read(bluetoothServiceProvider.notifier)
                              .savePendingReadings();
                          if (context.mounted) {
                            final count = session?.readingIds.length ?? 0;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Saved $count readings as session #${session?.id ?? ''}',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.save),
                  label: Text(
                    bleState.pendingCount == 0
                        ? 'No readings to save'
                        : 'Save readings (${bleState.pendingCount})',
                  ),
                ),
              ),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    final chipStyle = Theme.of(context).textTheme.bodyMedium;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              'Timestamp: ${DateTime.fromMillisecondsSinceEpoch(reading.timestamp * 1000).toLocal()}',
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
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'EC',
                  value: '${reading.ec.toStringAsFixed(2)} mS/cm',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Temperature',
                  value: '${reading.temperature.toStringAsFixed(1)} °C',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'pH',
                  value: reading.ph.toStringAsFixed(1),
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Nitrogen (N)',
                  value: '${reading.nitrogen} mg/kg',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Phosphorus (P)',
                  value: '${reading.phosphorus} mg/kg',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Potassium (K)',
                  value: '${reading.potassium} mg/kg',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Salinity',
                  value: '${reading.salinity.toStringAsFixed(2)}',
                  style: chipStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Chip(
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


