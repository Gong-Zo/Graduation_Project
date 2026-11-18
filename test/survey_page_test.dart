import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/survey_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('시작 안내에서 자가점검 질문으로 이동한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 5000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: SurveyPage()));

    expect(find.text('반려견 맞이를 위한\n준비도 자가점검'), findsOneWidget);
    expect(find.text('1. 평일 혼자 두는 시간'), findsNothing);

    await tester.scrollUntilVisible(find.text('자가점검 시작하기'), 300);
    await tester.tap(find.text('자가점검 시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('1. 평일 혼자 두는 시간'), findsOneWidget);
    expect(find.text('자가점검 시작하기'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '다음'));
    await tester.pumpAndSettle();

    expect(find.text('1. 기본 양육비 지속 감당'), findsOneWidget);
    expect(find.text('1. 평일 혼자 두는 시간'), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, '이전'));
    await tester.pumpAndSettle();

    expect(find.text('1. 평일 혼자 두는 시간'), findsOneWidget);
  });

  testWidgets('좁은 화면에서도 시각 선택칸이 오버플로되지 않는다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: SurveyPage()));

    await tester.ensureVisible(find.text('자가점검 시작하기'));
    await tester.tap(find.text('자가점검 시작하기'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
