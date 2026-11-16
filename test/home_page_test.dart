import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('홈 화면에서 자가점검 안내로 이동한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MainApp());

    expect(find.text('반려견과 함께할 일상을\n미리 준비해봐요'), findsOneWidget);
    expect(find.text('양육 역량·환경 자가점검'), findsOneWidget);

    await tester.tap(find.text('자가점검 시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('반려견 맞이를 위한\n준비도 자가점검'), findsOneWidget);
  });

  testWidgets('홈 화면에서 7일 기록 비교 화면으로 이동한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MainApp());

    await tester.scrollUntilVisible(find.text('기록 비교 열기'), 200);
    await tester.tap(find.text('기록 비교 열기'));
    await tester.pumpAndSettle();

    expect(find.text('7일 기록 비교'), findsOneWidget);
    expect(find.text('계획 산책 시간'), findsOneWidget);
  });
}
