/// FastAPI 주소. 앱에는 DB 비밀번호를 두지 않는다.
/// 빈 값·off 이면 서버를 쓰지 않고 기기 저장만 한다.
String petbeforeApiBase() {
  const fromDefine = String.fromEnvironment('PETBEFORE_API_BASE');
  final raw = fromDefine.trim();
  if (raw == 'off' || raw == 'none' || raw == 'local') return '';
  if (raw.isNotEmpty) return _withoutSlash(raw);
  return 'http://127.0.0.1:8000';
}

String _withoutSlash(String url) {
  if (url.endsWith('/')) return url.substring(0, url.length - 1);
  return url;
}
