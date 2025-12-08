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

final _sensorRepoProvider = Provider<SensorRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SensorRepository(db);
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
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(context, ref),
              tooltip: 'Clear all history',
            ),
          ],
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
                return Dismissible(
                  key: Key('reading_${item.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Reading'),
                        content: const Text(
                          'Are you sure you want to delete this reading?',
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
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) async {
                    final repo = ref.read(_sensorRepoProvider);
                    await repo.deleteReading(item.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reading deleted')),
                      );
                    }
                  },
                  child: ListTile(
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
                        builder: (context) => _ReadingDetailsDialog(
                          reading: item,
                          onDelete: () async {
                            final repo = ref.read(_sensorRepoProvider);
                            await repo.deleteReading(item.id);
                            if (context.mounted) {
                              Navigator.of(context).pop(); // Close details dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reading deleted')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
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
  const _ReadingDetailsDialog({
    required this.reading,
    this.onDelete,
  });

  final SensorReading reading;
  final VoidCallback? onDelete;

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
        if (onDelete != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

Future<void> _showClearAllDialog(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear All History'),
      content: const Text(
        'Are you sure you want to delete all sensor readings? This action cannot be undone.',
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

  if (confirmed == true && context.mounted) {
    try {
      final repo = ref.read(_sensorRepoProvider);
      await repo.deleteAllReadings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All readings deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting readings: $e')),
        );
      }
    }
  }
}


