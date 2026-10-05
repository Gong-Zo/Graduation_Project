import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/dogs_api_client.dart';
import 'package:flutter_application_1/diagnosis/guide/gemini_guide_client.dart';
import 'package:flutter_application_1/diagnosis/guide/readiness_guide_service.dart';
import 'package:flutter_application_1/ui/diagnosis_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final dogsApi = DogsApiClient(
    apiKey: 'test',
    client: MockClient((request) async {
      return http.Response(
        jsonEncode([
          {
            'name': 'Cavalier',
            'image_link': '',
            'energy': 2,
            'barking': 1,
            'shedding': 2,
            'grooming': 2,
            'trainability': 4,
          },
        ]),
        200,
      );
    }),
  );

  testWidgets('준비도 계산 후 종합 점수와 엔진 안내를 보여 준다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 5000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: DiagnosisPage(
          guideService: ReadinessGuideService(
            client: GeminiGuideClient(apiKey: ''),
          ),
          dogsApi: dogsApi,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, '자가점검 계산'));
    await tester.pumpAndSettle();

    expect(find.text('종합 40점'), findsOneWidget);
    expect(find.text('경고'), findsOneWidget);
    expect(find.text('엔진 안내'), findsOneWidget);
    expect(find.textContaining('종합 40점'), findsWidgets);
    expect(find.textContaining('입양 허가나 거부가 아닙니다.'), findsOneWidget);
    expect(find.text('Cavalier'), findsOneWidget);
    expect(find.text('자가점검 조건에 맞습니다.'), findsOneWidget);
    expect(find.text('계획 산책 시간'), findsNothing);
  });

  testWidgets('7일 기록은 자가점검 점수와 따로 비교한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 5000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: DiagnosisPage(
          guideService: ReadinessGuideService(
            client: GeminiGuideClient(apiKey: ''),
          ),
          dogsApi: dogsApi,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, '자가점검 계산'));
    await tester.pumpAndSettle();
    expect(find.text('계획 산책 시간'), findsNothing);

    await tester.tap(find.text('7일 기록'));
    await tester.pumpAndSettle();

    Future<void> fill(String label, String value) async {
      await tester.enterText(
        find.ancestor(of: find.text(label), matching: find.byType(TextField)),
        value,
      );
    }

    await fill('계획 산책 시간', '40');
    await fill('실제 산책 시간', '20');
    await fill('계획 돌봄 시간', '60');
    await fill('실제 돌봄 시간', '30');
    await tester.tap(find.widgetWithText(FilledButton, '7일 기록 반영'));
    await tester.pumpAndSettle();

    expect(find.text('종합 40점'), findsOneWidget);
    expect(find.text('생활 영역 · 자가점검 돌봄 60분 (18점)'), findsOneWidget);
    expect(find.text('7일 실제 돌봄 30분 (같은 기준 참고 8점)'), findsOneWidget);
    expect(find.text('자가점검 대비 7일 돌봄: 과대'), findsOneWidget);

    await tester.tap(find.text('자가점검'));
    await tester.pumpAndSettle();
    expect(find.text('계획 산책 시간'), findsNothing);
    expect(find.text('자가점검 대비 7일 돌봄: 과대'), findsNothing);
  });
}
