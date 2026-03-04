import 'package:csir_soil_sensor/src/features/export/export_screen.dart';
import 'package:csir_soil_sensor/src/services/export_service.dart';
import 'package:csir_soil_sensor/src/services/permission_service.dart';
import 'package:csir_soil_sensor/src/services/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExportService implements ExportService {
  int sensorCsvCalls = 0;
  Rect? lastShareOrigin;

  @override
  Future<String> exportSensorCsv({
    List<int>? readingIds,
    Rect? shareOrigin,
  }) async {
    sensorCsvCalls += 1;
    lastShareOrigin = shareOrigin;
    return 'Sensor CSV exported and share sheet opened.';
  }

  @override
  Future<String> exportCombinedCsv({
    List<int>? readingIds,
    Rect? shareOrigin,
  }) async => 'Combined CSV exported.';

  @override
  Future<String> exportPdfReport({int? sessionId, Rect? shareOrigin}) async =>
      'PDF exported.';

  @override
  Future<String> exportImages({Rect? shareOrigin}) async => 'Images exported.';

  @override
  Future<String> exportCropParamsCsv({Rect? shareOrigin}) async =>
      'Crop params exported.';
}

class _FakePermissionService extends PermissionService {
  @override
  Future<StoragePermissionState> ensureStoragePermission() async {
    return StoragePermissionState.denied;
  }
}

class _FakeSessionStore extends SessionStore {
  @override
  Future<List<ReadingSession>> loadSessions() async => [];

  @override
  Future<void> saveSessions(List<ReadingSession> sessions) async {}

  @override
  Future<ReadingSession> addSession(List<int> readingIds) async {
    return ReadingSession(
      id: 1,
      createdAt: DateTime(2026, 1, 1),
      readingIds: List<int>.from(readingIds),
    );
  }
}

void main() {
  testWidgets('sensor CSV export proceeds without storage permission gate', (
    tester,
  ) async {
    final exportService = _FakeExportService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exportServiceProvider.overrideWithValue(exportService),
          permissionServiceProvider.overrideWithValue(_FakePermissionService()),
          sessionStoreProvider.overrideWithValue(_FakeSessionStore()),
        ],
        child: const MaterialApp(home: ExportScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Export Sensor Data (CSV)'));
    await tester.pumpAndSettle();

    expect(exportService.sensorCsvCalls, 1);
    expect(exportService.lastShareOrigin, isNotNull);
    expect(exportService.lastShareOrigin!.width, greaterThan(0));
    expect(exportService.lastShareOrigin!.height, greaterThan(0));
    expect(
      find.text('Sensor CSV exported and share sheet opened.'),
      findsOneWidget,
    );
    expect(find.text('Storage Permission Needed'), findsNothing);
  });
}
