/// 로그인 화면이 구독하는 상태. 가입·로그인·비회원·로그아웃은 여기만 호출한다.
import 'package:flutter/foundation.dart';

import 'auth_exception.dart';
import 'auth_models.dart';
import 'auth_service.dart';
import 'auth_test_account.dart';

/// UI가 구독하는 로그인 상태. 화면은 이 컨트롤러의 메서드만 호출하면 된다.
class AuthController extends ChangeNotifier {
  AuthController(this._service, {this.autoLoginTestAccount = false});

  final AuthService _service;
  /// true면 bootstrap 때 세션이 없으면 테스트 계정으로 로그인한다.
  final bool autoLoginTestAccount;

  bool _booting = true;
  bool _busy = false;
  bool _showRegister = false;
  String? _error;
  AuthSession? _session;
  bool _onboardingDone = false;

  bool get booting => _booting;
  bool get busy => _busy;
  bool get showRegister => _showRegister;
  String? get error => _error;
  AuthSession? get session => _session;
  bool get onboardingDone => _onboardingDone;
  bool get isLoggedOut => !_booting && _onboardingDone && _session == null;

  bool canAccess(AppFeature feature) => _session?.canAccess(feature) ?? false;

  /// 저장된 세션을 읽고, 필요하면 테스트 계정으로 맞춘 뒤 스플래시를 끝낸다.
  Future<void> bootstrap() async {
    _booting = true;
    notifyListeners();
    final snapshot = await _service.bootstrap();
    _onboardingDone = snapshot.onboardingDone;
    _session = _service.currentSession();
    if (autoLoginTestAccount && _onboardingDone && _session == null) {
      _session = await _service.login(
        email: AuthTestAccount.email,
        password: AuthTestAccount.password,
      );
      _onboardingDone = true;
    }
    _booting = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _run(() async {
      await _service.completeOnboarding();
      _onboardingDone = true;
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _run(() async {
      _session = await _service.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      _onboardingDone = true;
    });
  }

  Future<void> login({required String email, required String password}) {
    return _run(() async {
      _session = await _service.login(email: email, password: password);
      _onboardingDone = true;
    });
  }

  Future<void> loginAsTest() {
    return login(
      email: AuthTestAccount.email,
      password: AuthTestAccount.password,
    );
  }

  Future<void> enterGuest() {
    return _run(() async {
      _session = await _service.enterGuest();
      _onboardingDone = true;
    });
  }

  Future<void> logout() {
    return _run(() async {
      await _service.logout();
      _session = null;
    });
  }

  void openRegister() {
    _showRegister = true;
    _error = null;
    notifyListeners();
  }

  void closeRegister() {
    if (!_showRegister && _error == null) return;
    _showRegister = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// 버튼 중복 탭을 막고, 실패 문구는 [_error]에 남겨 UI가 읽게 한다.
  Future<void> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _showRegister = false;
    } on AuthException catch (e) {
      _error = e.message;
      rethrow;
    } catch (e) {
      _error = '처리하지 못했습니다. $e';
      throw AuthException(_error!);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
