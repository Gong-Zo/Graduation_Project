import 'package:flutter/material.dart';

import '../../diagnosis/readiness_result.dart';
import '../../diagnosis/survey/survey_scorer.dart';
import '../shared/feature_screen.dart';
import 'survey_intro_page.dart';

class DiagnosisDetailPage extends StatelessWidget {
  const DiagnosisDetailPage({super.key, this.score});

  final SurveyScore? score;

  @override
  Widget build(BuildContext context) {
    final result = score;
    if (result == null) {
      return FeatureScreen(
        title: '상세 결과',
        description: '자가점검을 완료하면 영역별 점수와 항목별 결과를 확인할 수 있어요.',
        icon: Icons.analytics_outlined,
        children: [
          FeatureMenuCard(
            title: '자가점검 시작하기',
            description: '생활·경제·돌봄 준비를 입력해 결과를 확인해 보세요.',
            icon: Icons.fact_check_outlined,
            page: const SurveyIntroPage(),
          ),
        ],
      );
    }

    final label = switch (result.label) {
      ReadinessLabel.ready => '준비완료',
      ReadinessLabel.needsWork => '보완필요',
      ReadinessLabel.warning => '주의가 필요해요',
    };
    return FeatureScreen(
      title: '상세 결과',
      description: '종합 ${result.totalScore}점 · $label',
      icon: Icons.analytics_outlined,
      children: [
        _ScoreCard(title: '생활 준비', score: result.lifeScore),
        _ScoreCard(title: '경제적 준비', score: result.economyScore),
        _ScoreCard(title: '돌봄 책임', score: result.responsibilityScore),
        for (final warning in result.warnings)
          FeatureInfoCard(
            title: '확인할 점',
            description: warning.message,
            icon: Icons.warning_amber_rounded,
          ),
        for (final section in [
          ('생활 문항', result.lifeItemScores),
          ('경제 문항', result.economyItemScores),
          ('책임 문항', result.responsibilityItemScores),
        ]) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
            child: Text(
              section.$1,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          for (final entry in section.$2.entries)
            FeatureInfoCard(title: entry.key, description: '${entry.value}점'),
        ],
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.title, required this.score});

  final String title;
  final int score;

  @override
  Widget build(BuildContext context) {
    return FeatureInfoCard(
      title: '$title · $score점',
      description: '현재 응답 기준 점수예요. 점수는 준비 상태를 돌아보기 위한 참고 자료입니다.',
      icon: Icons.insights_outlined,
    );
  }
}
