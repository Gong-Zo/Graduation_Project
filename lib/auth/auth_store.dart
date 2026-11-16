import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_models.dart';

abstract class AuthStore {
  Future<AuthSnapshot> load();
  Future<void> save(AuthSnapshot snapshot);
}

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

class SharedPreferencesAuthStore implements AuthStore {
  SharedPreferencesAuthStore({this.key = 'petbefore.auth.v1'});

  final String key;

  @override
  Future<AuthSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return const AuthSnapshot();
    return AuthSnapshot.fromJson(
      Map<String, Object?>.from(jsonDecode(raw) as Map),
    );
  }

  @override
  Future<void> save(AuthSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(snapshot.toJson()));
  }
}
