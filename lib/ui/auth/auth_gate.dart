/// 부트스트랩 → 온보딩 → 세션/가입/로그인 화면을 고르는 게이트.
import 'package:flutter/material.dart';

import '../../auth/auth_scope.dart';
import '../home_page.dart';
import 'login_page.dart';
import 'onboarding_page.dart';
import 'register_page.dart';
import 'splash_page.dart';

/// AuthController 상태에 따라 스플래시·온보딩·홈·가입·로그인을 보여 준다.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    if (auth.booting) return const SplashPage();
    if (auth.session != null) return const HomePage();
    if (!auth.onboardingDone) return const OnboardingPage();
    if (auth.showRegister) return const RegisterPage();
    return const LoginPage();
  }
}
