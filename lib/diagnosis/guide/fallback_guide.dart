import '../diagnosis_config.dart';
import '../readiness_result.dart';
import 'readiness_guide.dart';

class FallbackGuide {
  const FallbackGuide();

  ReadinessGuide build(ReadinessResult result) {
    final warningText = result.warnings
        .map((warning) => warning.message)
        .join(' ');
    final summary = StringBuffer(
      '종합 ${result.totalScore}점으로 ${result.labelText} 수준입니다. '
      '생활 ${result.lifeScore}점, 경제 ${result.economyScore}점, '
      '책임 ${result.responsibilityScore}점입니다.',
    );
    if (warningText.isNotEmpty) {
      summary.write(' $warningText');
    }
    if (result.practice != null) {
      final practice = result.practice!;
      summary.write(
        ' 자가점검 돌봄 ${practice.statedCareMinutes}분, '
        '7일 실제 돌봄 ${practice.actualCareMinutes}분으로 '
        '${practice.careClaimText}입니다. '
        '같은 돌봄 기준의 참고 점수는 ${practice.observedCarePoints}점이며 '
        '종합 점수는 바꾸지 않습니다.',
      );
    }

    final actions = <GuideAction>[];
    if (result.lifeScore < DiagnosisConfig.readyMinScore) {
      actions.add(
        const GuideAction(
          domain: 'life',
          text: '퇴근 후 확보할 수 있는 돌봄 시간과 산책 시간을 먼저 정해 두세요.',
        ),
      );
    }
    if (result.economyScore < DiagnosisConfig.readyMinScore) {
      actions.add(
        GuideAction(
          domain: 'economy',
          text:
              '월 예산 ${result.monthlyBudgetKrw}원은 반려견 평균 '
              '${DiagnosisConfig.dogMonthlyMeanKrw}원과 비교해 유지 가능한지, '
              '소득이 줄어도 치료비를 감당할 수 있는지 확인해 보세요.',
        ),
      );
    }
    if (result.responsibilityScore < DiagnosisConfig.readyMinScore) {
      actions.add(
        const GuideAction(
          domain: 'responsibility',
          text: '거주지나 생활이 바뀌어도 돌봄을 이어 갈 사람을 정해 두세요.',
        ),
      );
    }

    final gap = result.gap;
    if (gap != null && gap.walkOverestimated) {
      actions.add(
        const GuideAction(
          domain: 'life',
          text: '계획한 산책 시간보다 7일 평균 산책 시간이 짧습니다. 실제 일정에 맞춰 계획을 낮추세요.',
        ),
      );
    }

    return ReadinessGuide(
      summary: summary.toString(),
      actions: actions,
      housingNote: '주거 점수는 ${result.housingScore}점이며 종합 점수에는 포함되지 않은 참고 점수입니다.',
      boundary: DiagnosisConfig.boundaryText,
      fromModel: false,
    );
  }
}
