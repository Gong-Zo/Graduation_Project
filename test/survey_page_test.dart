/// 안내 → 1번 문항 → 다음/이전 페이지 전환.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/dogs_api_client.dart';
import 'package:flutter_application_1/diagnosis/guide/gemini_guide_client.dart';
import 'package:flutter_application_1/diagnosis/guide/readiness_guide_service.dart';
import 'package:flutter_application_1/ui/survey_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

  testWidgets('결과 확인 후 엔진 안내가 점수를 그대로 설명한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 8000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final dogsApi = DogsApiClient(
      apiKey: 'test',
      client: MockClient((request) async {
        return http.Response(jsonEncode(const <Object>[]), 200);
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: SurveyPage(
          guideService: ReadinessGuideService(
            client: GeminiGuideClient(apiKey: ''),
          ),
          dogsApi: dogsApi,
        ),
      ),
    );

    await tester.scrollUntilVisible(find.text('자가점검 시작하기'), 300);
    await tester.tap(find.text('자가점검 시작하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '결과 확인하기'));
    await tester.pumpAndSettle();

    expect(find.text('엔진 안내'), findsOneWidget);
    expect(find.textContaining('종합'), findsWidgets);
    expect(find.textContaining('입양 허가나 거부가 아닙니다.'), findsWidgets);
    expect(find.text('Gemini 안내'), findsNothing);
  });
}
