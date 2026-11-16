import 'dart:io';

/// 실행 폴더의 `local_api_key.dart`에서 키를 읽는다. 파일이 없으면 빈 값.
Future<String> readLocalApiKey(String name) async {
  final files = [
    File('lib/diagnosis/guide/local_api_key.dart'),
    File('diagnosis/guide/local_api_key.dart'),
  ];
  for (final file in files) {
    if (!await file.exists()) continue;
    final text = await file.readAsString();
    final quoted = RegExp('$name\\s*=\\s*[\'"]([^\'"]*)[\'"]').firstMatch(text);
    if (quoted != null) return quoted.group(1)?.trim() ?? '';
  }
  return '';
}
