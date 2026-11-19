/// 계정 파일과 같은 petbefore 폴더에 survey_history.json을 둔다.
import 'dart:io';

Future<File> _historyFile() async {
  final home =
      Platform.environment['APPDATA'] ??
      Platform.environment['HOME'] ??
      Directory.current.path;
  final dir = Directory('$home${Platform.pathSeparator}petbefore');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return File('${dir.path}${Platform.pathSeparator}survey_history.json');
}

Future<String?> readSurveyHistoryFile() async {
  try {
    final file = await _historyFile();
    if (!await file.exists()) return null;
    final raw = await file.readAsString();
    return raw.isEmpty ? null : raw;
  } catch (_) {
    return null;
  }
}

Future<void> writeSurveyHistoryFile(String raw) async {
  final file = await _historyFile();
  await file.writeAsString(raw);
}
