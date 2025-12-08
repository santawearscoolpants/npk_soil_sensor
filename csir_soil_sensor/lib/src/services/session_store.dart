import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class ReadingSession {
  ReadingSession({
    required this.id,
    required this.createdAt,
    required this.readingIds,
  });

  final int id;
  final DateTime createdAt;
  final List<int> readingIds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'readingIds': readingIds,
      };

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readingIds:
          (json['readingIds'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }
}

class SessionStore {
  static const _fileName = 'reading_sessions.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$_fileName';
    return File(path);
  }

  Future<List<ReadingSession>> loadSessions() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final data = jsonDecode(content) as List<dynamic>;
      return data
          .map((e) => ReadingSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<ReadingSession> sessions) async {
    final file = await _file();
    final content = jsonEncode(sessions.map((e) => e.toJson()).toList());
    await file.writeAsString(content);
  }

  Future<ReadingSession> addSession(List<int> readingIds) async {
    final sessions = await loadSessions();
    final newId =
        sessions.isEmpty ? 1 : (sessions.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1);
    final session = ReadingSession(
      id: newId,
      createdAt: DateTime.now(),
      readingIds: List<int>.from(readingIds),
    );
    sessions.add(session);
    await saveSessions(sessions);
    return session;
  }
}

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SessionStore();
});


