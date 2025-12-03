import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/sensor_repository.dart';

final _historyProvider =
    StreamProvider.autoDispose<List<SensorReading>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = SensorRepository(db);
  return repo.watchAllReadings();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(_historyProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: historyAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text('No readings saved yet.'),
              );
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(
                    item.timestamp.toLocal().toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Moisture: ${item.moisture.toStringAsFixed(1)} %, '
                    'EC: ${item.ec.toStringAsFixed(2)} mS/cm, '
                    'Temp: ${item.temperature.toStringAsFixed(1)} °C',
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => _ReadingDetailsDialog(reading: item),
                    );
                  },
                );
              },
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _ReadingDetailsDialog extends StatelessWidget {
  const _ReadingDetailsDialog({required this.reading});

  final SensorReading reading;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reading Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Timestamp: ${reading.timestamp.toLocal()}'),
          const SizedBox(height: 8),
          Text('Moisture: ${reading.moisture.toStringAsFixed(1)} %'),
          Text('EC: ${reading.ec.toStringAsFixed(2)} mS/cm'),
          Text('Temperature: ${reading.temperature.toStringAsFixed(1)} °C'),
          Text('pH: ${reading.ph.toStringAsFixed(1)}'),
          Text('N: ${reading.nitrogen} mg/kg'),
          Text('P: ${reading.phosphorus} mg/kg'),
          Text('K: ${reading.potassium} mg/kg'),
          Text('Salinity: ${reading.salinity.toStringAsFixed(2)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}


