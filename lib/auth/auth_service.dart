import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'auth_exception.dart';
import 'auth_models.dart';
import 'auth_store.dart';
import 'auth_test_account.dart';

/// 이메일·비밀번호 가입/로그인, 비회원 세션, 온보딩 여부를 저장한다.
/// 지금은 기기에 계정을 둔다. 나중에 서버로 바꿀 때는 이 클래스만 교체하면 된다.
class AuthService {
  AuthService(this._store, {Random? random})
    : _random = random ?? _availableRandom();

  static Random _availableRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }

  final AuthStore _store;
  final Random _random;
  AuthSnapshot _snapshot = const AuthSnapshot();

  AuthSnapshot get snapshot => _snapshot;

  Future<AuthSnapshot> bootstrap() async {
    _snapshot = await _store.load();
    await ensureTestAccount();
    return _snapshot;
  }

  Future<void> ensureTestAccount() async {
    if (_findAccount(AuthTestAccount.email) != null) return;
    final account = StoredAccount(
      id: AuthTestAccount.id,
      email: AuthTestAccount.email,
      passwordHash: _hash(AuthTestAccount.password, AuthTestAccount.salt),
      salt: AuthTestAccount.salt,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    await _commit(
      _snapshot.copyWith(accounts: [..._snapshot.accounts, account]),
    );
  }

  AuthSession? currentSession() {
    final mode = _snapshot.sessionMode;
    if (mode == null) return null;
    if (mode == AuthMode.guest) return AuthSession.guest();
    final userId = _snapshot.sessionUserId;
    if (userId == null) return null;
    for (final account in _snapshot.accounts) {
      if (account.id == userId) return AuthSession.signedIn(account.toUser());
    }
    return null;
  }

  Future<void> completeOnboarding() {
    return _commit(_snapshot.copyWith(onboardingDone: true));
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final normalized = _normalizeEmail(email);
    _validateEmail(normalized);
    _validatePassword(password);
    if (password != confirmPassword) {
      throw const AuthException('비밀번호가 일치하지 않습니다.');
    }
    if (_findAccount(normalized) != null) {
      throw const AuthException('이미 가입된 이메일입니다.');
    }

    final salt = _newSalt();
    final account = StoredAccount(
      id: _newId(),
      email: normalized,
      passwordHash: _hash(password, salt),
      salt: salt,
      createdAt: DateTime.now().toUtc(),
    );
    await _commit(
      _snapshot.copyWith(
        onboardingDone: true,
        accounts: [..._snapshot.accounts, account],
        sessionMode: AuthMode.signedIn,
        sessionUserId: account.id,
      ),
    );
    return AuthSession.signedIn(account.toUser());
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final normalized = _normalizeEmail(email);
    final account = _findAccount(normalized);
    if (account == null || account.passwordHash != _hash(password, account.salt)) {
      throw const AuthException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }
    await _commit(
      _snapshot.copyWith(
        onboardingDone: true,
        sessionMode: AuthMode.signedIn,
        sessionUserId: account.id,
      ),
    );
    return AuthSession.signedIn(account.toUser());
  }

  Future<AuthSession> enterGuest() async {
    await _commit(
      _snapshot.copyWith(
        onboardingDone: true,
        sessionMode: AuthMode.guest,
        sessionUserId: null,
      ),
    );
    return AuthSession.guest();
  }

  Future<void> logout() {
    return _commit(
      _snapshot.copyWith(sessionMode: null, sessionUserId: null),
    );
  }

  StoredAccount? _findAccount(String email) {
    for (final account in _snapshot.accounts) {
      if (account.email == email) return account;
    }
    return null;
  }

  Future<void> _commit(AuthSnapshot snapshot) async {
    _snapshot = snapshot;
    await _store.save(snapshot);
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static void _validateEmail(String email) {
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!ok) throw const AuthException('이메일 형식이 아닙니다.');
  }

  static void _validatePassword(String password) {
    if (password.length < 8) {
      throw const AuthException('비밀번호는 8자 이상이어야 합니다.');
    }
  }

  String _newId() {
    // Chrome(DDC)에서 nextInt(큰 수)가 0으로 깨지므로 작은 수만 쓴다.
    return 'u_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1000000)}';
  }

  String _newSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}
