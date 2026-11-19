/// 회원별 자가점검 기록이 최신순으로 남는지.
import 'dart:math';

import 'package:flutter_application_1/diagnosis/survey/survey_engine.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_history_store.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_random.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('같은 회원 기록만 최신순으로 읽는다', () async {
    const engine = SurveyEngine();
    final score = engine.evaluate(SurveyRandom.generate(Random(1)));
    final store = MemorySurveyHistoryStore();

    await store.save(
      SurveyRecord(
        id: 'r1',
        userId: 'u1',
        createdAt: DateTime.utc(2026, 1, 1),
        score: score,
      ),
    );
    await store.save(
      SurveyRecord(
        id: 'r2',
        userId: 'u1',
        createdAt: DateTime.utc(2026, 2, 1),
        score: score,
      ),
    );
    await store.save(
      SurveyRecord(
        id: 'r3',
        userId: 'u2',
        createdAt: DateTime.utc(2026, 3, 1),
        score: score,
      ),
    );

    final mine = await store.load('u1');
    expect(mine.map((record) => record.id), ['r2', 'r1']);
    expect(await store.load('u2'), hasLength(1));
  });

  test('점수 JSON을 다시 읽어도 종합과 라벨이 같다', () {
    const engine = SurveyEngine();
    final score = engine.evaluate(SurveyRandom.generate(Random(2)));
    final record = SurveyRecord(
      id: 'r1',
      userId: 'u1',
      createdAt: DateTime.utc(2026, 4, 1, 9, 30),
      score: score,
    );

    final restored = SurveyRecord.fromJson(record.toJson());
    expect(restored.score.totalScore, score.totalScore);
    expect(restored.score.label, score.label);
    expect(restored.score.lifeScore, score.lifeScore);
    expect(restored.createdAtLabel, contains('2026.04.01'));
  });

  test('다른 LocalSurveyHistoryStore 인스턴스에서도 방금 저장한 기록이 보인다', () async {
    SharedPreferences.setMockInitialValues({});
    const engine = SurveyEngine();
    final score = engine.evaluate(SurveyRandom.generate(Random(4)));
    await LocalSurveyHistoryStore().save(
      surveyRecordFromScore(userId: 'u_cache', score: score, id: 'r_cache'),
    );

    final loaded = await LocalSurveyHistoryStore().load('u_cache');
    expect(loaded.map((record) => record.id), contains('r_cache'));
  });
}
