/// 웹은 stub, Windows/모바일은 파일로 계정 JSON을 읽는다.
export 'auth_file_stub.dart' if (dart.library.io) 'auth_file_io.dart';
