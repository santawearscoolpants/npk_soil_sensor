import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/crop_repository.dart';
import '../../services/bluetooth_service.dart';
import '../bluetooth/bluetooth_connection_screen.dart';

final _cropParamsProvider = FutureProvider.autoDispose<List<CropParam>>((
  ref,
) async {
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
    final canShowLiveReading = bleState.canDisplayLiveReading;
    final statusColor =
        bleState.hasActiveDeviceSession && !bleState.isConnecting
        ? Colors.green
        : bleState.isScanning || bleState.isConnecting
        ? Colors.orange
        : Colors.red;

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
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bluetooth Status',
                                style: Theme.of(context).textTheme.titleSmall
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
              if (bleState.hasConnectionIssue)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              bleState.lastDataErrorMessage!,
                              style: TextStyle(color: Colors.orange.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedCropParamsId,
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
              if (canShowLiveReading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _LiveReadingCard(reading: bleState.latestReading!),
                      if (bleState.latestReading!.hasDerivedValues)
                        _CalibratedReadingCard(
                          reading: bleState.latestReading!,
                        ),
                    ],
                  ),
                ),
              if (!canShowLiveReading)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      bleState.hasSelectedDevice
                          ? 'Waiting for the next sensor reading...'
                          : 'No data yet. Connect device to see readings.',
                    ),
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
  const _LiveReadingCard({required this.reading});

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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  value:
                      '${reading.ecDisplayValue.toStringAsFixed(3)} ${reading.ecDisplayUnit}',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Temperature',
                  value: '${reading.temperature.toStringAsFixed(1)} °C',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'pH',
                  value: reading.phDisplayValue.toStringAsFixed(2),
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Nitrogen (N)',
                  value:
                      '${reading.nitrogenDisplayValue.toStringAsFixed(reading.nitrogenDisplayPrecision)} ${reading.nitrogenDisplayUnit}',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Phosphorus (P)',
                  value:
                      '${reading.phosphorusDisplayValue.toStringAsFixed(reading.phosphorusDisplayPrecision)} ${reading.phosphorusDisplayUnit}',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Potassium (K)',
                  value:
                      '${reading.potassiumDisplayValue.toStringAsFixed(reading.potassiumDisplayPrecision)} ${reading.potassiumDisplayUnit}',
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'Salinity',
                  value: reading.salinity.toStringAsFixed(2),
                  style: chipStyle,
                ),
                _MetricChip(
                  label: 'TDS',
                  value: '${reading.tds} ppm',
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

class _CalibratedReadingCard extends StatelessWidget {
  const _CalibratedReadingCard({required this.reading});

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
              'Calibrated Values',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Values reported by the sensor conversion/calibration pipeline',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (reading.ecConv != null)
                  _MetricChip(
                    label: 'EC (conv)',
                    value: '${reading.ecConv!.toStringAsFixed(3)} dS/m',
                    style: chipStyle,
                  ),
                if (reading.ecCal != null)
                  _MetricChip(
                    label: 'EC (cal)',
                    value: '${reading.ecCal!.toStringAsFixed(3)} dS/m',
                    style: chipStyle,
                  ),
                if (reading.phConv != null)
                  _MetricChip(
                    label: 'pH (conv)',
                    value: reading.phConv!.toStringAsFixed(2),
                    style: chipStyle,
                  ),
                if (reading.phCal != null)
                  _MetricChip(
                    label: 'pH (cal)',
                    value: reading.phCal!.toStringAsFixed(2),
                    style: chipStyle,
                  ),
                if (reading.nConv != null)
                  _MetricChip(
                    label: 'N (conv)',
                    value: '${reading.nConv!.toStringAsFixed(4)} %',
                    style: chipStyle,
                  ),
                if (reading.nCal != null)
                  _MetricChip(
                    label: 'N (cal)',
                    value: '${reading.nCal!.toStringAsFixed(4)} %',
                    style: chipStyle,
                  ),
                if (reading.pConv != null)
                  _MetricChip(
                    label: 'P (conv)',
                    value: '${reading.pConv!.toStringAsFixed(1)} mg/kg',
                    style: chipStyle,
                  ),
                if (reading.pCal != null)
                  _MetricChip(
                    label: 'P (cal)',
                    value: '${reading.pCal!.toStringAsFixed(1)} mg/kg',
                    style: chipStyle,
                  ),
                if (reading.kConv != null)
                  _MetricChip(
                    label: 'K (conv)',
                    value: '${reading.kConv!.toStringAsFixed(3)} cmol(+)/kg',
                    style: chipStyle,
                  ),
                if (reading.kCal != null)
                  _MetricChip(
                    label: 'K (cal)',
                    value: '${reading.kCal!.toStringAsFixed(3)} cmol(+)/kg',
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
