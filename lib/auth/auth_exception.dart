/// 가입·로그인 검증 실패. 메시지는 화면에 그대로 보여 준다.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
