import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/thresholds.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/crop_repository.dart';
import '../../services/bluetooth_service.dart';
import '../../services/mock_data.dart';

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
                      onPressed: bleState.connectionStatus
                              .startsWith('Scanning')
                          ? null
                          : () {
                              ref
                                  .read(bluetoothServiceProvider.notifier)
                                  .scanForDevices();
                            },
                      icon: bleState.connectionStatus
                              .startsWith('Scanning')
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.bluetooth_searching),
                      label: Text(
                        bleState.connectionStatus.startsWith('Scanning')
                            ? 'Scanning...'
                            : 'Scan for devices',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bleState.connectedDeviceName != null
                          ? 'Status: ${bleState.connectionStatus} (${bleState.connectedDeviceName})'
                          : 'Status: ${bleState.connectionStatus}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (bleState.connectedDeviceName != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade700),
                    ),
                    onPressed: () {
                      ref
                          .read(bluetoothServiceProvider.notifier)
                          .disconnect();
                    },
                    icon: const Icon(Icons.link_off),
                    label: const Text('Disconnect from device'),
                  ),
                ),
              ),
            if (bleState.devices.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tap a device to connect:',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (bleState.devices.isNotEmpty)
              SizedBox(
                height: 160,
                child: ListView.builder(
                  itemCount: bleState.devices.length,
                  itemBuilder: (context, index) {
                    final d = bleState.devices[index];
                    return ListTile(
                      leading: const Icon(Icons.bluetooth),
                      title: Text(d.name),
                      subtitle: Text(d.device.remoteId.str),
                      onTap: () {
                        ref
                            .read(bluetoothServiceProvider.notifier)
                            .connectToDevice(d);
                      },
                    );
                  },
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
                      },
                    ),
                  ),
                ],
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
                            .saveLatestReading(_selectedCropParamsId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _selectedCropParamsId != null
                                    ? 'Reading saved and linked to crop set #$_selectedCropParamsId'
                                    : 'Reading saved locally',
                              ),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Latest Reading',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tooltip(
                    message:
                        'Green = ideal range\nAmber = acceptable\nRed = needs attention',
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
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
                    color: TomatoThresholds.getColorForValue(
                      reading.moisture,
                      TomatoThresholds.moistureLow,
                      TomatoThresholds.moistureHigh,
                    ),
                    tooltip: TomatoThresholds.moistureTooltip,
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'EC',
                    value: '${reading.ec.toStringAsFixed(2)} mS/cm',
                    color: TomatoThresholds.getColorForValue(
                      reading.ec,
                      TomatoThresholds.ecLow,
                      TomatoThresholds.ecHigh,
                    ),
                    tooltip: TomatoThresholds.ecTooltip,
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'Temperature',
                    value: '${reading.temperature.toStringAsFixed(1)} °C',
                    color: TomatoThresholds.getColorForValue(
                      reading.temperature,
                      TomatoThresholds.temperatureLow,
                      TomatoThresholds.temperatureHigh,
                    ),
                    tooltip: TomatoThresholds.temperatureTooltip,
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'pH',
                    value: reading.ph.toStringAsFixed(1),
                    color: TomatoThresholds.getColorForValue(
                      reading.ph,
                      TomatoThresholds.phLow,
                      TomatoThresholds.phHigh,
                    ),
                    tooltip: TomatoThresholds.phTooltip,
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'Nitrogen (N)',
                    value: '${reading.nitrogen} mg/kg',
                    color: TomatoThresholds.getColorForValue(
                      reading.nitrogen.toDouble(),
                      TomatoThresholds.nitrogenLow,
                      TomatoThresholds.nitrogenHigh,
                    ),
                    tooltip: TomatoThresholds.nitrogenTooltip,
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'Phosphorus (P)',
                    value: '${reading.phosphorus} mg/kg',
                    color: TomatoThresholds.getColorForValue(
                      reading.phosphorus.toDouble(),
                      TomatoThresholds.phosphorusLow,
                      TomatoThresholds.phosphorusHigh,
                    ),
                    tooltip: TomatoThresholds.phosphorusTooltip,
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'Potassium (K)',
                    value: '${reading.potassium} mg/kg',
                    color: TomatoThresholds.getColorForValue(
                      reading.potassium.toDouble(),
                      TomatoThresholds.potassiumLow,
                      TomatoThresholds.potassiumHigh,
                    ),
                    tooltip: TomatoThresholds.potassiumTooltip,
                    style: chipStyle,
                  ),
                  _MetricChip(
                    label: 'Salinity',
                    value: '${reading.salinity.toStringAsFixed(2)}',
                    color: TomatoThresholds.getColorForValue(
                      reading.salinity,
                      TomatoThresholds.salinityLow,
                      TomatoThresholds.salinityHigh,
                    ),
                    tooltip: TomatoThresholds.salinityTooltip,
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
    required this.tooltip,
    required this.style,
  });

  final String label;
  final String value;
  final Color color;
  final String tooltip;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Chip(
        backgroundColor: color.withOpacity(0.15),
        avatar: CircleAvatar(
          backgroundColor: color,
          radius: 6,
        ),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: style?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: style),
          ],
        ),
      ),
    );
  }
}


