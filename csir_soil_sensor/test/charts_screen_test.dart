import 'package:csir_soil_sensor/src/core/routing.dart';
import 'package:csir_soil_sensor/src/data/db/app_database.dart';
import 'package:csir_soil_sensor/src/services/session_store.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
  setUpAll(() {
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  testWidgets('opening charts from navigation renders all chart tabs', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sessionStoreProvider.overrideWithValue(_FakeSessionStore()),
        ],
        child: const MaterialApp(home: RootScaffold()),
      ),
    );

    await tester.tap(find.text('Charts'));
    await tester.pumpAndSettle();

    expect(find.text('Sensor Charts'), findsOneWidget);
    expect(find.text('TDS'), findsWidgets);
    expect(find.text('No readings available to display'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
