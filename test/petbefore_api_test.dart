/// FastAPI 로그인 응답을 앱이 세션으로 바꾸는 경로.
import 'dart:convert';

import 'package:flutter_application_1/auth/auth_models.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/auth/auth_store.dart';
import 'package:flutter_application_1/auth/petbefore_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('서버 로그인에 성공하면 토큰과 회원 id를 남긴다', () async {
    final api = PetbeforeApi(
      baseUrl: 'http://api.test',
      client: MockClient((request) async {
        expect(request.url.path, '/auth/login');
        return http.Response(
          jsonEncode({
            'token': 'tok_1',
            'user': {
              'id': 'u_db_1',
              'email': 'user@petbefore.kr',
              'createdAt': '2026-01-01T00:00:00.000Z',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final service = AuthService(MemoryAuthStore(), api: api);
    await service.bootstrap();
    final session = await service.login(
      email: 'user@petbefore.kr',
      password: 'secret123',
    );
    expect(session.user?.id, 'u_db_1');
    expect(api.accessToken, 'tok_1');
    expect(service.snapshot.accessToken, 'tok_1');
  });

  test('서버가 꺼져 있으면 기기 계정으로 로그인한다', () async {
    final api = PetbeforeApi(
      baseUrl: 'http://api.test',
      client: MockClient((request) async {
        throw http.ClientException('connection refused');
      }),
    );
    final store = MemoryAuthStore();
    final first = AuthService(store);
    await first.bootstrap();
    await first.register(
      email: 'offline@test.com',
      password: 'secret123',
      confirmPassword: 'secret123',
    );
    await first.logout();

    final second = AuthService(store, api: api);
    await second.bootstrap();
    final session = await second.login(
      email: 'offline@test.com',
      password: 'secret123',
    );
    expect(session.user?.email, 'offline@test.com');
    expect(second.snapshot.accessToken, isNull);
  });
}
