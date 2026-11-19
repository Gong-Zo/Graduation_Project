/// 계정 JSON을 SharedPreferences와 파일에 나눠 저장한다. Windows 플러그인 공백을 대비한다.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_file.dart';
import 'auth_models.dart';

/// 계정 스냅샷 저장소. 테스트는 메모리, 앱은 LocalAuthStore를 쓴다.
abstract class AuthStore {
  Future<AuthSnapshot> load();
  Future<void> save(AuthSnapshot snapshot);
}

/// 테스트용. 디스크에 쓰지 않는다.
class MemoryAuthStore implements AuthStore {
  MemoryAuthStore([this._snapshot = const AuthSnapshot()]);

  AuthSnapshot _snapshot;

  @override
  Future<AuthSnapshot> load() async => _snapshot;

  @override
  Future<void> save(AuthSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}

/// SharedPreferences가 없는 Windows 등에서도 가입이 되게 파일로도 저장한다.
class LocalAuthStore implements AuthStore {
  LocalAuthStore({this.key = 'petbefore.auth.v1'});

  final String key;

  @override
  Future<AuthSnapshot> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        return _decode(raw);
      }
    } catch (_) {}
    final fileRaw = await readAuthFile();
    if (fileRaw == null) return const AuthSnapshot();
    return _decode(fileRaw);
  }

  @override
  Future<void> save(AuthSnapshot snapshot) async {
    final raw = jsonEncode(snapshot.toJson());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, raw);
    } catch (_) {}
    try {
      await writeAuthFile(raw);
    } catch (_) {}
  }

  AuthSnapshot _decode(String raw) {
    return AuthSnapshot.fromJson(Map<String, Object?>.from(jsonDecode(raw) as Map));
  }
}

/// 예전 이름 호환. 실제 저장은 LocalAuthStore와 같다.
class SharedPreferencesAuthStore extends LocalAuthStore {
  SharedPreferencesAuthStore({super.key});
}
