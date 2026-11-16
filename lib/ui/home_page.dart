import 'package:flutter/material.dart';

import 'diagnosis_page.dart';
import 'survey_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('펫비포')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text(
                  '반가워요!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF5F6A60),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '반려견과 함께할 일상을\n미리 준비해봐요',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: const Color(0xFF24352A),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 190,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7EFE5),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 20,
                        right: 24,
                        child: Icon(
                          Icons.auto_awesome,
                          color: primary.withValues(alpha: 0.35),
                          size: 28,
                        ),
                      ),
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.pets, size: 58, color: primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  '오늘 시작할 수 있어요',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF24352A),
                  ),
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.fact_check_outlined,
                  title: '양육 역량·환경 자가점검',
                  description: '생활, 경제, 돌봄 준비를 돌아보고 현재의 준비 상태를 확인해 보세요.',
                  buttonLabel: '자가점검 시작하기',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SurveyPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.calendar_month_outlined,
                  title: '7일 생활 기록 비교',
                  description: '계획한 산책·돌봄 시간과 실제 기록을 비교해 볼 수 있어요.',
                  buttonLabel: '기록 비교 열기',
                  outlined: true,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DiagnosisPage(initialSection: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.outlined = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8E6DE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: outlined
                      ? const Color(0xFFFFF2E4)
                      : const Color(0xFFEDF3EB),
                  child: Icon(
                    icon,
                    color: outlined ? const Color(0xFFB36B25) : primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: const Color(0xFF5F6A60),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: outlined
                  ? OutlinedButton(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: primary,
                        side: BorderSide(color: primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(buttonLabel),
                    )
                  : FilledButton(
                      onPressed: onPressed,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(buttonLabel),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
