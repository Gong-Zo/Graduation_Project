import 'package:flutter/material.dart';

import '../../auth/auth_exception.dart';
import '../../auth/auth_scope.dart';

/// 회원가입 화면. 가입이 끝나면 AuthGate가 홈으로 바꾼다.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final auth = AuthScope.of(context);
    try {
      await auth.register(
        email: _email.text,
        password: _password.text,
        confirmPassword: _confirm.text,
      );
    } on AuthException {
      // 오류 문구는 AuthController.error 로 표시한다.
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          onPressed: auth.busy ? null : auth.closeRegister,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            key: const Key('registerEmailField'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '이메일',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => auth.clearError(),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('registerPasswordField'),
            controller: _password,
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '비밀번호 (8자 이상)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => auth.clearError(),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('registerConfirmField'),
            controller: _confirm,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!auth.busy) _register();
            },
            decoration: const InputDecoration(
              labelText: '비밀번호 확인',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => auth.clearError(),
          ),
          if (auth.error != null) ...[
            const SizedBox(height: 12),
            Text(
              auth.error!,
              key: const Key('registerError'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('registerButton'),
            onPressed: auth.busy ? null : _register,
            child: Text(auth.busy ? '가입 중...' : '가입하기'),
          ),
        ],
      ),
    );
  }
}
