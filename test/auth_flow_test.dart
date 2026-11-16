import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/auth_controller.dart';
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

void main() {
  testWidgets('온보딩 후 가입하면 홈에 이메일이 보인다', (tester) async {
    final auth = AuthController(AuthService(MemoryAuthStore()));
    await auth.bootstrap();
    await tester.pumpWidget(app(auth));

    await tester.tap(find.byKey(const Key('onboardingStartButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('openRegisterButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('registerEmailField')), 'a@test.com');
    await tester.enterText(find.byKey(const Key('registerPasswordField')), 'secret123');
    await tester.enterText(find.byKey(const Key('registerConfirmField')), 'secret123');
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

    await tester.tap(find.byKey(const Key('onboardingStartButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guestButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sessionLabel')), findsOneWidget);
    expect(find.text('로그인 상태: 비회원'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('자가점검 시작하기'), 200);
    await tester.tap(find.text('자가점검 시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('로그인이 필요합니다'), findsOneWidget);
  });
}
