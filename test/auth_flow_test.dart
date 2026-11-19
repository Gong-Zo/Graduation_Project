/// 온보딩·가입·비회원 권한 화면 흐름.
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/auth_controller.dart';
import 'package:flutter_application_1/auth/auth_models.dart';
import 'package:flutter_application_1/auth/auth_scope.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/auth/auth_store.dart';
import 'package:flutter_application_1/ui/auth/auth_gate.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(AuthController auth) {
  return AuthScope(
    controller: auth,
    child: const MaterialApp(home: AuthGate()),
  );
}

Future<void> finishOnboarding(WidgetTester tester) async {
  expect(find.text('반려견과의\n행복한 시작을 준비해요'), findsOneWidget);
  await tester.tap(find.byKey(const Key('onboardingNextButton')));
  await tester.pumpAndSettle();

  expect(find.text('나의 양육 준비도를\n체크해요'), findsOneWidget);
  await tester.tap(find.byKey(const Key('onboardingNextButton')));
  await tester.pumpAndSettle();

  expect(find.text('맞춤 정보로\n더 든든하게!'), findsOneWidget);
  await tester.tap(find.byKey(const Key('onboardingStartButton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('온보딩 후 가입하면 홈에 이메일이 보인다', (tester) async {
    final auth = AuthController(AuthService(MemoryAuthStore()));
    await auth.bootstrap();
    await tester.pumpWidget(app(auth));

    await finishOnboarding(tester);

    await tester.tap(find.byKey(const Key('openRegisterButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registerEmailField')),
      'a@test.com',
    );
    await tester.enterText(
      find.byKey(const Key('registerPasswordField')),
      'secret123',
    );
    await tester.enterText(
      find.byKey(const Key('registerConfirmField')),
      'secret123',
    );
    await tester.tap(find.byKey(const Key('registerButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sessionLabel')), findsOneWidget);
    expect(find.textContaining('a@test.com'), findsOneWidget);
  });

  testWidgets('비회원은 자가점검에서 로그인을 요구한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(AuthService(MemoryAuthStore()));
    await auth.bootstrap();
    await tester.pumpWidget(app(auth));

    await finishOnboarding(tester);
    await tester.tap(find.byKey(const Key('guestButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sessionLabel')), findsOneWidget);
    expect(find.text('로그인 상태: 비회원'), findsOneWidget);
    await tester.tap(find.byKey(const Key('selfCheckTile')));
    await tester.pumpAndSettle();
    expect(find.text('로그인이 필요합니다'), findsOneWidget);
  });

  testWidgets('첫 실행에서 건너뛰어도 완료 상태를 저장한다', (tester) async {
    final store = MemoryAuthStore();
    final auth = AuthController(AuthService(store), autoLoginTestAccount: true);
    await auth.bootstrap();
    await tester.pumpWidget(app(auth));

    expect(auth.session, isNull);
    expect(find.text('반려견과의\n행복한 시작을 준비해요'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboardingSkipButton')));
    await tester.pumpAndSettle();

    expect(auth.onboardingDone, isTrue);
    expect(find.byKey(const Key('openRegisterButton')), findsOneWidget);

    final returningAuth = AuthController(AuthService(store));
    await returningAuth.bootstrap();
    await tester.pumpWidget(app(returningAuth));
    expect(find.byKey(const Key('onboardingSkipButton')), findsNothing);
    expect(find.byKey(const Key('openRegisterButton')), findsOneWidget);
  });

  testWidgets('이미 로그인된 회원에게 온보딩을 다시 표시하지 않는다', (tester) async {
    final store = MemoryAuthStore(
      AuthSnapshot(
        onboardingDone: false,
        accounts: [
          StoredAccount(
            id: 'member-1',
            email: 'member@test.com',
            passwordHash: 'stored-hash',
            salt: 'stored-salt',
            createdAt: DateTime.utc(2026),
          ),
        ],
        sessionMode: AuthMode.signedIn,
        sessionUserId: 'member-1',
      ),
    );
    final auth = AuthController(AuthService(store));
    await auth.bootstrap();
    await tester.pumpWidget(app(auth));

    expect(find.byKey(const Key('sessionLabel')), findsOneWidget);
    expect(find.textContaining('member@test.com'), findsOneWidget);
    expect(find.byKey(const Key('onboardingSkipButton')), findsNothing);
  });
}
