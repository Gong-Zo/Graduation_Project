/// 웹은 파일을 못 읽으므로 stub, 데스크톱은 local_api_key.dart를 연다.
export 'local_key_file_stub.dart'
    if (dart.library.io) 'local_key_file_io.dart';
