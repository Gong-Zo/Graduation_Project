/// 가입·로그인. FastAPI가 켜져 있으면 MariaDB 계정을 쓰고, 꺼져 있으면 기기에 둔다.
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'auth_exception.dart';
import 'auth_models.dart';
import 'auth_store.dart';
import 'auth_test_account.dart';
import 'petbefore_api.dart';

/// 이메일·비밀번호 가입/로그인, 비회원 세션, 온보딩 여부를 저장한다.
/// 화면은 이 클래스만 호출하면 된다. DB 비밀번호는 앱에 없다.
class AuthService {
  AuthService(this._store, {this.api, Random? random})
    : _random = random ?? _availableRandom();

  /// 웹/일부 환경에서 Random.secure가 실패하면 일반 Random으로 대체한다.
  static Random _availableRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }

  final AuthStore _store;
  final PetbeforeApi? api;
  final Random _random;
  AuthSnapshot _snapshot = const AuthSnapshot();

  AuthSnapshot get snapshot => _snapshot;

  /// 저장소를 읽고 테스트 계정이 없으면 만든다.
  Future<AuthSnapshot> bootstrap() async {
    _snapshot = await _store.load();
    _applyToken();
    await ensureTestAccount();
    if (_snapshot.sessionMode == AuthMode.signedIn &&
        api != null &&
        api!.isConfigured &&
        api!.accessToken != null) {
      try {
        await api!.me();
      } catch (error) {
        if (!isPetbeforeNetworkError(error)) {
          await _commit(
            _snapshot.copyWith(
              sessionMode: null,
              sessionUserId: null,
              accessToken: null,
            ),
          );
        }
      }
    }
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

  /// 이메일 정규화 후 해시 저장하고 바로 로그인 세션을 연다.
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
    AuthUser? remoteUser;
    if (api != null && api!.isConfigured) {
      try {
        remoteUser = await api!.register(
          email: normalized,
          password: password,
          confirmPassword: confirmPassword,
        );
      } catch (error) {
        if (!isPetbeforeNetworkError(error)) rethrow;
      }
    }
    final stored = remoteUser == null
        ? account
        : StoredAccount(
            id: remoteUser.id,
            email: remoteUser.email,
            passwordHash: account.passwordHash,
            salt: account.salt,
            createdAt: remoteUser.createdAt,
          );
    await _commit(
      _snapshot.copyWith(
        onboardingDone: true,
        accounts: [
          ..._snapshot.accounts.where((item) => item.email != stored.email),
          stored,
        ],
        sessionMode: AuthMode.signedIn,
        sessionUserId: stored.id,
        accessToken: api?.accessToken,
      ),
    );
    return AuthSession.signedIn(stored.toUser());
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final normalized = _normalizeEmail(email);
    if (api != null && api!.isConfigured) {
      try {
        final remote = await api!.login(email: normalized, password: password);
        final local = _findAccount(normalized);
        final salt = local?.salt ?? _newSalt();
        final stored = StoredAccount(
          id: remote.id,
          email: remote.email,
          passwordHash: local?.passwordHash ?? _hash(password, salt),
          salt: salt,
          createdAt: remote.createdAt,
        );
        await _commit(
          _snapshot.copyWith(
            onboardingDone: true,
            accounts: [
              ..._snapshot.accounts.where((item) => item.email != stored.email),
              stored,
            ],
            sessionMode: AuthMode.signedIn,
            sessionUserId: stored.id,
            accessToken: api?.accessToken,
          ),
        );
        return AuthSession.signedIn(stored.toUser());
      } catch (error) {
        if (!isPetbeforeNetworkError(error)) rethrow;
      }
    }
    final account = _findAccount(normalized);
    if (account == null || account.passwordHash != _hash(password, account.salt)) {
      throw const AuthException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }
    await _commit(
      _snapshot.copyWith(
        onboardingDone: true,
        sessionMode: AuthMode.signedIn,
        sessionUserId: account.id,
        accessToken: null,
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
        accessToken: null,
      ),
    );
    return AuthSession.guest();
  }

  Future<void> logout() {
    api?.accessToken = null;
    return _commit(
      _snapshot.copyWith(
        sessionMode: null,
        sessionUserId: null,
        accessToken: null,
      ),
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
    _applyToken();
    await _store.save(snapshot);
  }

  void _applyToken() {
    if (api == null) return;
    api!.accessToken = _snapshot.accessToken;
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
