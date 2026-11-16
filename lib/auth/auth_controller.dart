import 'package:flutter/foundation.dart';

import 'auth_exception.dart';
import 'auth_models.dart';
import 'auth_service.dart';

/// UI가 구독하는 로그인 상태. 화면은 이 컨트롤러의 메서드만 호출하면 된다.
class AuthController extends ChangeNotifier {
  AuthController(this._service);

  final AuthService _service;

  bool _booting = true;
  bool _busy = false;
  String? _error;
  AuthSession? _session;
  bool _onboardingDone = false;

  bool get booting => _booting;
  bool get busy => _busy;
  String? get error => _error;
  AuthSession? get session => _session;
  bool get onboardingDone => _onboardingDone;
  bool get isLoggedOut => !_booting && _onboardingDone && _session == null;

  bool canAccess(AppFeature feature) => _session?.canAccess(feature) ?? false;

  Future<void> bootstrap() async {
    _booting = true;
    notifyListeners();
    final snapshot = await _service.bootstrap();
    _onboardingDone = snapshot.onboardingDone;
    _session = _service.currentSession();
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

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } on AuthException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
