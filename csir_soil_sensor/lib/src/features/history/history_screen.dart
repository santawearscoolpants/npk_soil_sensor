import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/crop_repository.dart';
import '../../data/repositories/sensor_repository.dart';
import '../../services/session_store.dart';

final _sessionsProvider =
    FutureProvider.autoDispose<List<ReadingSession>>((ref) async {
  final sessionStore = ref.read(sessionStoreProvider);
  return sessionStore.loadSessions();
});

final _sensorRepoProvider = Provider<SensorRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SensorRepository(db);
});

final _cropRepoProvider = Provider<CropRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CropRepository(db);
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_sessionsProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(context, ref),
              tooltip: 'Clear all sessions',
            ),
          ],
        ),
        body: sessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return const Center(
                child: Text('No reading sessions saved yet.'),
              );
            }
            // Sort sessions by creation date, newest first
            final sortedSessions = List<ReadingSession>.from(sessions)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: sortedSessions.length,
              itemBuilder: (context, index) {
                final session = sortedSessions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${session.readingIds.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      'Session #${session.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${session.readingIds.length} reading${session.readingIds.length == 1 ? '' : 's'}',
                        ),
                        Text(
                          session.createdAt.toLocal().toString().split('.')[0],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showSessionDetails(context, ref, session);
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

Future<void> _showSessionDetails(
  BuildContext context,
  WidgetRef ref,
  ReadingSession session,
) async {
  final sensorRepo = ref.read(_sensorRepoProvider);
  final cropRepo = ref.read(_cropRepoProvider);

  // Load readings for this session
  final readings = await sensorRepo.getReadingsByIds(session.readingIds);

  if (readings.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No readings found for this session'),
        ),
      );
    }
    return;
  }

  // Get unique cropParamsIds from readings
  final cropParamsIds = readings
      .where((r) => r.cropParamsId != null)
      .map((r) => r.cropParamsId!)
      .toSet()
      .toList();

  // Get crop parameters if any are linked
  List<CropParam>? linkedCropParams;
  if (cropParamsIds.isNotEmpty) {
    final allCropParams = await cropRepo.getAllCropParams();
    linkedCropParams = allCropParams
        .where((cp) => cropParamsIds.contains(cp.id))
        .toList();
  }

  // Calculate time range
  final timestamps = readings.map((r) => r.timestamp).toList()..sort();
  final startTime = timestamps.first;
  final endTime = timestamps.last;

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (context) => _SessionDetailsDialog(
      session: session,
      readings: readings,
      linkedCropParams: linkedCropParams,
      startTime: startTime,
      endTime: endTime,
      onLinkCropParams: () async {
        Navigator.of(context).pop(); // Close details dialog
        await _showLinkCropParamsDialog(context, ref, session);
      },
      onDelete: () async {
        Navigator.of(context).pop(); // Close details dialog
        await _deleteSession(context, ref, session);
      },
    ),
  );
}

class _SessionDetailsDialog extends StatelessWidget {
  const _SessionDetailsDialog({
    required this.session,
    required this.readings,
    this.linkedCropParams,
    required this.startTime,
    required this.endTime,
    this.onLinkCropParams,
    this.onDelete,
  });

  final ReadingSession session;
  final List<SensorReading> readings;
  final List<CropParam>? linkedCropParams;
  final DateTime startTime;
  final DateTime endTime;
  final VoidCallback? onLinkCropParams;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    // Calculate averages
    final avgMoisture = readings
            .map((r) => r.moisture)
            .reduce((a, b) => a + b) /
        readings.length;
    final avgEC = readings.map((r) => r.ec).reduce((a, b) => a + b) /
        readings.length;
    final avgTemp = readings
            .map((r) => r.temperature)
            .reduce((a, b) => a + b) /
        readings.length;
    final avgPH = readings.map((r) => r.ph).reduce((a, b) => a + b) /
        readings.length;

    return AlertDialog(
      title: Text('Session #${session.id}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              label: 'Readings',
              value: '${readings.length}',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Date',
              value: session.createdAt.toLocal().toString().split('.')[0],
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Time Range',
              value:
                  '${startTime.toLocal().toString().split('.')[0]} - ${endTime.toLocal().toString().split('.')[0]}',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Average Values',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Moisture',
              value: '${avgMoisture.toStringAsFixed(1)} %',
            ),
            _DetailRow(
              label: 'EC',
              value: '${avgEC.toStringAsFixed(2)} mS/cm',
            ),
            _DetailRow(
              label: 'Temperature',
              value: '${avgTemp.toStringAsFixed(1)} °C',
            ),
            _DetailRow(
              label: 'pH',
              value: avgPH.toStringAsFixed(1),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Crop Parameters',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (linkedCropParams == null || linkedCropParams!.isEmpty)
              const Text(
                'No crop parameters linked',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              )
            else
              ...linkedCropParams!.map(
                (cp) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Set #${cp.id}: ${cp.soilType}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
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
            child: const Text('Delete Session'),
          ),
        TextButton(
          onPressed: onLinkCropParams,
          child: const Text('Link Crop Params'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

Future<void> _showLinkCropParamsDialog(
  BuildContext context,
  WidgetRef ref,
  ReadingSession session,
) async {
  final cropRepo = ref.read(_cropRepoProvider);
  final sensorRepo = ref.read(_sensorRepoProvider);

  // Load all crop parameters
  final cropParams = await cropRepo.getAllCropParams();

  if (!context.mounted) return;

  // Get current linked crop params ID (if all readings have the same one)
  final sensorRepoForCurrent = ref.read(_sensorRepoProvider);
  final currentReadings = await sensorRepoForCurrent.getReadingsByIds(session.readingIds);
  int? currentCropParamsId;
  if (currentReadings.isNotEmpty) {
    final uniqueIds = currentReadings
        .where((r) => r.cropParamsId != null)
        .map((r) => r.cropParamsId!)
        .toSet();
    if (uniqueIds.length == 1) {
      currentCropParamsId = uniqueIds.first;
    }
  }

  final selectedCropParamsId = await showDialog<int?>(
    context: context,
    builder: (context) {
      int? selectedValue = currentCropParamsId;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Link to Crop Parameters'),
          content: SizedBox(
            width: double.maxFinite,
            child: cropParams.isEmpty
                ? const Text('No crop parameters available. Create one first.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: cropParams.length + 1, // +1 for "None" option
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return RadioListTile<int?>(
                          title: const Text('None (unlink)'),
                          value: null,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                            });
                            Navigator.of(context).pop(value);
                          },
                        );
                      }
                      final cp = cropParams[index - 1];
                      return RadioListTile<int?>(
                        title: Text('Set #${cp.id}: ${cp.soilType}'),
                        subtitle: Text(
                          cp.createdAt.toLocal().toString().split(' ')[0],
                        ),
                        value: cp.id,
                        groupValue: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                          });
                          Navigator.of(context).pop(value);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    },
  );

  // Check if value actually changed
  if (selectedCropParamsId == currentCropParamsId) {
    return; // No change, user likely cancelled
  }

  // Update all readings in the session
  try {
    await sensorRepo.updateReadingsCropParamsId(
      session.readingIds,
      selectedCropParamsId,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedCropParamsId == null
                ? 'Unlinked from crop parameters'
                : 'Linked to crop parameter set #$selectedCropParamsId',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh the session details if dialog is still open
      ref.invalidate(_sessionsProvider);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error linking crop parameters: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _deleteSession(
  BuildContext context,
  WidgetRef ref,
  ReadingSession session,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Session'),
      content: Text(
        'Are you sure you want to delete Session #${session.id} with ${session.readingIds.length} readings? This action cannot be undone.',
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
  );

  if (confirmed != true || !context.mounted) return;

  try {
    final sessionStore = ref.read(sessionStoreProvider);
    final sessions = await sessionStore.loadSessions();
    sessions.removeWhere((s) => s.id == session.id);
    await sessionStore.saveSessions(sessions);

    // Also delete the actual readings from the database
    final sensorRepo = ref.read(_sensorRepoProvider);
    for (final readingId in session.readingIds) {
      await sensorRepo.deleteReading(readingId);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session deleted')),
      );
      // Refresh the sessions list
      ref.invalidate(_sessionsProvider);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting session: $e')),
      );
    }
  }
}

Future<void> _showClearAllDialog(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear All Sessions'),
      content: const Text(
        'Are you sure you want to delete all reading sessions? This action cannot be undone.',
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
      final sessionStore = ref.read(sessionStoreProvider);
      await sessionStore.saveSessions([]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All sessions deleted')),
        );
        ref.invalidate(_sessionsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting sessions: $e')),
        );
      }
    }
  }
}
