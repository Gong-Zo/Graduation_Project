/// 웹은 stub, 데스크톱/모바일은 파일로 점검 기록을 읽는다.
export 'survey_history_file_stub.dart'
    if (dart.library.io) 'survey_history_file_io.dart';
