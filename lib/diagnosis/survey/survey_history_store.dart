/// 회원별 자가점검 기록. 서버 전에는 기기에만 둔다.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'survey_history_file.dart';
import 'survey_record.dart';
import 'survey_scorer.dart';

export 'remote_survey_history_store.dart';

abstract class SurveyHistoryStore {
  Future<List<SurveyRecord>> load(String userId);
  Future<SurveyRecord> save(SurveyRecord record);
}

/// 테스트용. 디스크에 쓰지 않는다.
class MemorySurveyHistoryStore implements SurveyHistoryStore {
  MemorySurveyHistoryStore([Map<String, List<SurveyRecord>>? records])
    : _records = records ?? {};

  final Map<String, List<SurveyRecord>> _records;

  @override
  Future<List<SurveyRecord>> load(String userId) async {
    return List.unmodifiable(_sorted(_records[userId] ?? const []));
  }

  @override
  Future<SurveyRecord> save(SurveyRecord record) async {
    _records[record.userId] = _upsert(
      _records[record.userId] ?? const <SurveyRecord>[],
      record,
    );
    return record;
  }
}

/// SharedPreferences와 파일에 회원별 기록을 쌓는다.
/// 화면마다 인스턴스가 달라도 같은 메모리 캐시를 본다.
class LocalSurveyHistoryStore implements SurveyHistoryStore {
  LocalSurveyHistoryStore({this.key = 'petbefore.survey_history.v1'});

  final String key;

  /// 위젯 테스트에서 디스크 대기를 끄고 메모리만 쓴다.
  static bool useDisk = true;

  static final Map<String, List<SurveyRecord>> _memory = {};
  static bool _hydrated = false;

  @override
  Future<List<SurveyRecord>> load(String userId) async {
    await _hydrate();
    return List.unmodifiable(_sorted(_memory[userId] ?? const []));
  }

  @override
  Future<SurveyRecord> save(SurveyRecord record) async {
    await _hydrate();
    _memory[record.userId] = _upsert(
      _memory[record.userId] ?? const <SurveyRecord>[],
      record,
    );
    if (useDisk) {
      try {
        await _persist();
      } catch (_) {
        // 메모리는 남긴다. 같은 실행에서는 마이페이지 기록이 보여야 한다.
      }
    }
    return record;
  }

  Future<void> _hydrate() async {
    if (_hydrated) return;
    if (!useDisk) {
      _hydrated = true;
      return;
    }
    final fromDisk = await _readAllFromDisk();
    for (final entry in fromDisk.entries) {
      final existing = _memory[entry.key] ?? const <SurveyRecord>[];
      final merged = [...existing];
      final ids = {for (final record in merged) record.id};
      for (final record in entry.value) {
        if (ids.add(record.id)) merged.add(record);
      }
      _memory[entry.key] = merged;
    }
    _hydrated = true;
  }

  Future<void> _persist() async {
    final raw = jsonEncode({
      for (final entry in _memory.entries)
        entry.key: [for (final record in entry.value) record.toJson()],
    });
    var wrote = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      wrote = await prefs.setString(key, raw);
    } catch (_) {}
    try {
      await writeSurveyHistoryFile(raw);
      wrote = true;
    } catch (_) {}
    if (!wrote) {
      throw StateError('자가점검 기록을 기기에 쓰지 못했습니다.');
    }
  }

  Future<Map<String, List<SurveyRecord>>> _readAllFromDisk() async {
    final raw = await _readRaw();
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    final result = <String, List<SurveyRecord>>{};
    for (final entry in decoded.entries) {
      final items = entry.value;
      if (items is! List) continue;
      result['${entry.key}'] = [
        for (final item in items)
          if (item is Map)
            SurveyRecord.fromJson(Map<String, Object?>.from(item)),
      ];
    }
    return result;
  }

  Future<String?> _readRaw() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) return raw;
    } catch (_) {}
    try {
      return await readSurveyHistoryFile();
    } catch (_) {
      return null;
    }
  }
}

List<SurveyRecord> _upsert(List<SurveyRecord> current, SurveyRecord record) {
  final next = [...current];
  final index = next.indexWhere((item) => item.id == record.id);
  if (index >= 0) {
    next[index] = record;
  } else {
    next.add(record);
  }
  return next;
}

List<SurveyRecord> _sorted(List<SurveyRecord> records) {
  final copy = [...records];
  copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return copy;
}

SurveyRecord surveyRecordFromScore({
  required String userId,
  required SurveyScore score,
  DateTime? createdAt,
  String? id,
}) {
  final at = createdAt ?? DateTime.now().toUtc();
  return SurveyRecord(
    id: id ?? 'r_${at.microsecondsSinceEpoch}',
    userId: userId,
    createdAt: at,
    score: score,
  );
}
