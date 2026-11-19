/// Windows는 APPDATA/petbefore/auth.json, 그 외는 HOME에 계정 JSON을 둔다.
import 'dart:io';

Future<File> _authFile() async {
  final home =
      Platform.environment['APPDATA'] ??
      Platform.environment['HOME'] ??
      Directory.current.path;
  final dir = Directory('$home${Platform.pathSeparator}petbefore');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return File('${dir.path}${Platform.pathSeparator}auth.json');
}

Future<String?> readAuthFile() async {
  try {
    final file = await _authFile();
    if (!await file.exists()) return null;
    final raw = await file.readAsString();
    return raw.isEmpty ? null : raw;
  } catch (_) {
    return null;
  }
}

Future<void> writeAuthFile(String raw) async {
  final file = await _authFile();
  await file.writeAsString(raw);
}
