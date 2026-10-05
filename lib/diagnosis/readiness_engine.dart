import 'care_profile.dart';
import 'diagnosis_config.dart';
import 'domain_scorer.dart';
import 'hard_cut.dart';
import 'practice_gap.dart';
import 'readiness_result.dart';

/// 준비도 알고리즘은 하나다.
///
/// 사전 자가점검만 넣으면 생활, 경제, 책임 점수와 종합 점수를 낸다.
/// 7일 기록을 함께 넣으면 같은 돌봄 점수표로 생활 영역 비교를 붙인다.
/// 7일 기록은 종합 점수를 바꾸지 않는다.
class ReadinessEngine {
  const ReadinessEngine();

  ReadinessResult evaluate(CareProfile profile, {GapInput? gap}) {
    final lifeScore = DomainScorer.life(profile);
    final economyScore = DomainScorer.economy(profile);
    final responsibilityScore = DomainScorer.responsibility(profile);
    final housingScore = DomainScorer.housing(profile);
    final totalScore =
        (lifeScore * DiagnosisConfig.lifeWeight +
                economyScore * DiagnosisConfig.economyWeight +
                responsibilityScore * DiagnosisConfig.responsibilityWeight)
            .round();
    final warnings = HardCut.evaluate(profile);

    return ReadinessResult(
      lifeScore: lifeScore,
      economyScore: economyScore,
      responsibilityScore: responsibilityScore,
      housingScore: housingScore,
      totalScore: totalScore,
      label: _label(totalScore, warnings),
      warnings: warnings,
      monthlyBudgetKrw: profile.monthlyBudgetKrw,
      practice: gap == null ? null : PracticeGap.fromProfile(profile, gap),
    );
  }

  ReadinessLabel _label(int totalScore, List<ReadinessWarning> warnings) {
    final label = switch (totalScore) {
      >= DiagnosisConfig.readyMinScore => ReadinessLabel.ready,
      >= DiagnosisConfig.needsWorkMinScore => ReadinessLabel.needsWork,
      _ => ReadinessLabel.warning,
    };
    if (warnings.isNotEmpty && label == ReadinessLabel.ready) {
      return ReadinessLabel.needsWork;
    }
    return label;
  }
}
