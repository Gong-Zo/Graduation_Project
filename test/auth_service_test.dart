import 'dart:math';

import 'package:flutter_application_1/auth/auth_exception.dart';
import 'package:flutter_application_1/auth/auth_models.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/auth/auth_store.dart';
import 'package:flutter_test/flutter_test.dart';

AuthService service() {
  return AuthService(MemoryAuthStore(), random: Random(1));
}

void main() {
  test('회원가입 후 로그인하면 회원 세션이 유지된다', () async {
    final auth = service();
    await auth.bootstrap();
    await auth.register(
      email: ' User@Petbefore.kr ',
      password: 'secret123',
      confirmPassword: 'secret123',
    );

    expect(auth.currentSession()?.user?.email, 'user@petbefore.kr');
    expect(auth.currentSession()?.isSignedIn, isTrue);

    await auth.logout();
    expect(auth.currentSession(), isNull);

    final session = await auth.login(
      email: 'user@petbefore.kr',
      password: 'secret123',
    );
    expect(session.user?.email, 'user@petbefore.kr');
  });

  test('잘못된 비밀번호와 중복 이메일은 거절한다', () async {
    final auth = service();
    await auth.bootstrap();
    await auth.register(
      email: 'a@test.com',
      password: 'secret123',
      confirmPassword: 'secret123',
    );

    expect(
      () => auth.login(email: 'a@test.com', password: 'wrongpass'),
      throwsA(isA<AuthException>()),
    );
    expect(
      () => auth.register(
        email: 'a@test.com',
        password: 'secret123',
        confirmPassword: 'secret123',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('비회원은 입양 정보만 열고 자가점검은 막는다', () async {
    final auth = service();
    await auth.bootstrap();
    final session = await auth.enterGuest();

    expect(session.isGuest, isTrue);
    expect(session.canAccess(AppFeature.adoptionInfo), isTrue);
    expect(session.canAccess(AppFeature.selfCheck), isFalse);
    expect(session.canAccess(AppFeature.sevenDayTrial), isFalse);
  });

  test('세션은 저장소에 남아 다시 불러올 수 있다', () async {
    final store = MemoryAuthStore();
    final first = AuthService(store, random: Random(1));
    await first.bootstrap();
    await first.register(
      email: 'keep@test.com',
      password: 'secret123',
      confirmPassword: 'secret123',
    );

    final second = AuthService(store, random: Random(2));
    await second.bootstrap();
    expect(second.currentSession()?.user?.email, 'keep@test.com');
  });
}
