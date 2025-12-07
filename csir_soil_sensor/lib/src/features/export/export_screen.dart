import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/export_service.dart';
import '../../services/permission_service.dart';
import '../../data/db/app_database.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocalExportService(db);
});

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _status = 'No export yet.';
  bool _busy = false;

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
      final message = await service.exportSensorCsv();
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
      final message = await service.exportCombinedCsv();
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
      final message = await service.exportPdfReport();
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


