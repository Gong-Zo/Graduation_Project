import 'package:flutter/material.dart';

import '../../auth/auth_scope.dart';
import '../home_page.dart';
import 'login_page.dart';
import 'onboarding_page.dart';
import 'register_page.dart';
import 'splash_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    if (auth.booting) return const SplashPage();
    if (!auth.onboardingDone) return const OnboardingPage();
    if (auth.session != null) return const HomePage();
    if (auth.showRegister) return const RegisterPage();
    return const LoginPage();
  }
}
