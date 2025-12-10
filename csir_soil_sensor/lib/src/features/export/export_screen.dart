import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/export_service.dart';
import '../../services/permission_service.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/sensor_repository.dart';
import '../../data/repositories/crop_repository.dart';
import '../../services/session_store.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final sessionStore = ref.read(sessionStoreProvider);
  return LocalExportService(db, sessionStore);
});

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _status = 'No export yet.';
  bool _busy = false;
  bool _loadingSessions = true;
  List<ReadingSession> _sessions = [];
  int? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final store = ref.read(sessionStoreProvider);
    final sessions = await store.loadSessions();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loadingSessions = false;
    });
  }

  List<int>? _selectedReadingIds() {
    if (_selectedSessionId == null) return null;
    final session =
        _sessions.firstWhere((s) => s.id == _selectedSessionId, orElse: () => ReadingSession(id: -1, createdAt: DateTime.now(), readingIds: []));
    if (session.id == -1) return null;
    return session.readingIds;
  }

  Future<void> _exportSensorCsv() async {
    setState(() {
      _busy = true;
      _status = 'Exporting sensor data CSV...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportSensorCsv(
        readingIds: _selectedReadingIds(),
      );
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error exporting sensor CSV: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportCombinedCsv() async {
    setState(() {
      _busy = true;
      _status = 'Exporting combined data CSV...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportCombinedCsv(
        readingIds: _selectedReadingIds(),
      );
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error exporting combined CSV: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportPdfReport() async {
    setState(() {
      _busy = true;
      _status = 'Generating PDF report...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportPdfReport(sessionId: _selectedSessionId);
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error generating PDF report: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportCropParamsCsv() async {
    setState(() {
      _busy = true;
      _status = 'Exporting crop parameters CSV...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportCropParamsCsv();
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error exporting crop parameters CSV: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _exportImages() async {
    setState(() {
      _busy = true;
      _status = 'Exporting images...';
    });
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final allowed = await permissionService.ensureStoragePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission is required to export files.',
              ),
            ),
          );
        }
        return;
      }
      final service = ref.read(exportServiceProvider);
      final message = await service.exportImages();
      setState(() {
        _status = message;
      });
    } catch (e) {
      setState(() {
        _status = 'Error exporting images: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete ALL sensor readings, crop parameters, and images. This action cannot be undone.\n\nAre you sure?',
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

    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _status = 'Clearing all data...';
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final sensorRepo = SensorRepository(db);
      final cropRepo = CropRepository(db);
      final sessionStore = ref.read(sessionStoreProvider);

      // Delete all sensor readings
      await sensorRepo.deleteAllReadings();
      
      // Delete all crop parameters (this also deletes associated images from DB)
      await cropRepo.deleteAllCropParams();

      // Clear session groupings
      await sessionStore.saveSessions([]);

      // Note: Physical image files would need to be deleted separately if needed
      // For now, we're just clearing the database references

      setState(() {
        _status = 'All data cleared successfully.';
        _selectedSessionId = null;
      });

      // Reload sessions so the dropdown immediately reflects the cleared state.
      await _loadSessions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Error clearing data: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Export & Share'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadingSessions)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(minHeight: 4),
                ),
              if (!_loadingSessions)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select session to export (or All readings):',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: _selectedSessionId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All readings'),
                        ),
                        ..._sessions.map(
                          (s) => DropdownMenuItem<int?>(
                            value: s.id,
                            child: Text(
                              'Session #${s.id} — ${s.readingIds.length} readings (${s.createdAt.toLocal().toString().split(" ").first})',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedSessionId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportSensorCsv,
                  child: const Text('Export Sensor Data (CSV)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportCombinedCsv,
                  child: const Text('Export Sensor + Params (CSV)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportPdfReport,
                  child: const Text('Export PDF Report'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportCropParamsCsv,
                  child: const Text('Export Crop Parameters (CSV)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _exportImages,
                  child: const Text('Export Images'),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Data Management:',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _clearAllData,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Clear All Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Last status:',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _status,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


