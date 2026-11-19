/// 저장된 자가점검이 마이페이지 기록 목록에 보이는지.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/auth_controller.dart';
import 'package:flutter_application_1/auth/auth_models.dart';
import 'package:flutter_application_1/auth/auth_scope.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/auth/auth_store.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_engine.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_history_store.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_random.dart';
import 'package:flutter_application_1/ui/mypage/diagnosis_history_page.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AuthController> signedInAuth() async {
  final auth = AuthController(
    AuthService(MemoryAuthStore(const AuthSnapshot(onboardingDone: true))),
    autoLoginTestAccount: true,
  );
  await auth.bootstrap();
  return auth;
}

void main() {
  testWidgets('기록이 없으면 빈 안내를 보여 준다', (tester) async {
    final auth = await signedInAuth();
    await tester.pumpWidget(
      AuthScope(
        controller: auth,
        child: MaterialApp(
          home: DiagnosisHistoryPage(historyStore: MemorySurveyHistoryStore()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('저장된 진단 기록이 없어요'), findsOneWidget);
  });

  testWidgets('저장한 기록은 점수와 함께 보이고 상세로 이동한다', (tester) async {
    final auth = await signedInAuth();
    final score = const SurveyEngine().evaluate(SurveyRandom.generate(Random(3)));
    final store = MemorySurveyHistoryStore();
    await store.save(
      surveyRecordFromScore(
        userId: auth.session!.user!.id,
        score: score,
        createdAt: DateTime.utc(2026, 5, 2, 10, 15),
        id: 'r_saved',
      ),
    );

    await tester.pumpWidget(
      AuthScope(
        controller: auth,
        child: MaterialApp(
          home: DiagnosisHistoryPage(historyStore: store),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('저장된 진단 기록이 없어요'), findsNothing);
    expect(find.textContaining('종합 ${score.totalScore}점'), findsOneWidget);
    expect(find.byKey(const Key('historyRecord_r_saved')), findsOneWidget);

    await tester.tap(find.byKey(const Key('historyRecord_r_saved')));
    await tester.pumpAndSettle();
    expect(find.text('상세 결과'), findsOneWidget);
    expect(find.textContaining('${score.totalScore}점'), findsWidgets);
  });
}
