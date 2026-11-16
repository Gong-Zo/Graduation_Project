import 'package:flutter/material.dart';

import '../../auth/auth_scope.dart';

/// 온보딩 화면. 시각 디자인은 교체하고, 시작하기에서 completeOnboarding만 호출하면 된다.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('펫비포', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 12),
              const Text('입양 전 준비 상태를 스스로 점검합니다.'),
              const Spacer(),
              FilledButton(
                key: const Key('onboardingStartButton'),
                onPressed: auth.busy ? null : auth.completeOnboarding,
                child: const Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
