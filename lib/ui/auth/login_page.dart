import 'package:flutter/material.dart';

import '../../auth/auth_exception.dart';
import '../../auth/auth_scope.dart';
import '../../auth/auth_test_account.dart';

/// 로그인 화면. 이메일/비밀번호 필드와 로그인·비회원·회원가입 동작만 고정하면 된다.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = AuthScope.of(context);
    try {
      await auth.login(email: _email.text, password: _password.text);
    } on AuthException {
      // 오류 문구는 AuthController.error 로 표시한다.
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('로그인', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            TextField(
              key: const Key('emailField'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => auth.clearError(),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('passwordField'),
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => auth.clearError(),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(
                auth.error!,
                key: const Key('authError'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('testLoginButton'),
              onPressed: auth.busy ? null : auth.loginAsTest,
              child: const Text('테스트 계정으로 들어가기'),
            ),
            const SizedBox(height: 8),
            Text(
              '${AuthTestAccount.email} / ${AuthTestAccount.password}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              key: const Key('loginButton'),
              onPressed: auth.busy ? null : _login,
              child: const Text('로그인'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('guestButton'),
              onPressed: auth.busy ? null : auth.enterGuest,
              child: const Text('비회원으로 이용'),
            ),
            TextButton(
              key: const Key('openRegisterButton'),
              onPressed: auth.busy ? null : auth.openRegister,
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
