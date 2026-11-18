import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/auth_controller.dart';
import 'package:flutter_application_1/auth/auth_models.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/auth/auth_store.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_test/flutter_test.dart';

Future<MainApp> loggedInApp() async {
  final auth = AuthController(
    AuthService(MemoryAuthStore(const AuthSnapshot(onboardingDone: true))),
    autoLoginTestAccount: true,
  );
  await auth.bootstrap();
  return MainApp(auth: auth);
}

void main() {
  testWidgets('홈이 2x2 메뉴와 하단 탭으로 표시된다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(await loggedInApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const Key('selfCheckTile')), findsOneWidget);
    expect(find.byKey(const Key('sevenDayTile')), findsOneWidget);
    expect(find.byKey(const Key('preparationTile')), findsOneWidget);
    expect(find.byKey(const Key('adoptionTile')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈 화면에서 자가점검 안내로 이동한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(await loggedInApp());
    await tester.pumpAndSettle();

    expect(find.text('오늘 시작할 수 있어요'), findsOneWidget);
    expect(find.byKey(const Key('selfCheckTile')), findsOneWidget);

    await tester.tap(find.byKey(const Key('selfCheckTile')));
    await tester.pumpAndSettle();

    expect(find.text('반려견 맞이를 위한\n준비도 자가점검'), findsOneWidget);
  });

  testWidgets('홈 화면에서 7일 기록 비교 화면으로 이동한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(await loggedInApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('sevenDayTile')));
    await tester.pumpAndSettle();

    expect(find.text('7일 기록 비교'), findsOneWidget);
    expect(find.text('계획 산책 시간'), findsOneWidget);
  });

  testWidgets('맞춤형 준비 지원에서 체크리스트로 이동한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(await loggedInApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('preparationTile')));
    await tester.pumpAndSettle();
    expect(find.text('맞춤형 준비 지원'), findsOneWidget);

    await tester.tap(find.text('양육 체크리스트'));
    await tester.pumpAndSettle();
    expect(find.text('확인한 항목 0 / 6'), findsOneWidget);
  });

  testWidgets('입양 정보에서 보호소 상세 화면까지 이동한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(await loggedInApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('adoptionTile')));
    await tester.pumpAndSettle();
    expect(find.text('입양 관련 정보'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('보호소 검색·목록'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('보호소 상세 화면 미리보기'));
    await tester.pumpAndSettle();
    expect(find.text('보호소 상세정보'), findsOneWidget);
  });

  testWidgets('마이페이지에서 진단 기록 화면으로 이동한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(await loggedInApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    expect(find.text('마이페이지'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('진단 기록·최종 리포트'), 200);
    await tester.tap(find.text('진단 기록·최종 리포트'));
    await tester.pumpAndSettle();
    expect(find.text('저장된 진단 기록이 없어요'), findsOneWidget);
  });
}
