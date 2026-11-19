/// 웹(dart:io 없음)에서는 파일 저장을 쓰지 않는다.
Future<String?> readAuthFile() async => null;

Future<void> writeAuthFile(String raw) async {}
