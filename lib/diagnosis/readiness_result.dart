import 'diagnosis_config.dart';

enum ReadinessLabel { ready, needsWork, warning }

enum WarningCode { petForbidden, severeAllergy, longAbsence }

class ReadinessWarning {
  const ReadinessWarning({required this.code, required this.message});

  final WarningCode code;
  final String message;
}

enum CareClaimFit { aligned, overstated, understated }

/// 자가점검 돌봄 응답과 7일 실제 돌봄을 같은 점수표로 비교한 출력.
/// 종합 점수에는 더하지 않는다.
class PracticeInteraction {
  const PracticeInteraction({
    required this.gap,
    required this.statedCareMinutes,
    required this.actualCareMinutes,
    required this.statedCarePoints,
    required this.observedCarePoints,
    required this.careClaim,
  });

  final GapReport gap;
  final int statedCareMinutes;
  final int actualCareMinutes;
  final int statedCarePoints;
  final int observedCarePoints;

  /// 7일 기록이 말하는 영역. 산책과 돌봄은 생활 점수 항목이다.
  final String affectedDomain = 'life';
  final CareClaimFit careClaim;

  String get careClaimText => switch (careClaim) {
    CareClaimFit.aligned => '일치',
    CareClaimFit.overstated => '과대',
    CareClaimFit.understated => '과소',
  };
}

class GapReport {
  const GapReport({
    required this.walkGapRatio,
    required this.careGapRatio,
    required this.walkOverestimated,
    required this.careOverestimated,
  });

  final double walkGapRatio;
  final double careGapRatio;
  final bool walkOverestimated;
  final bool careOverestimated;

  bool get hasOverestimate => walkOverestimated || careOverestimated;
}

class ReadinessResult {
  const ReadinessResult({
    required this.lifeScore,
    required this.economyScore,
    required this.responsibilityScore,
    required this.housingScore,
    required this.totalScore,
    required this.label,
    required this.warnings,
    required this.monthlyBudgetKrw,
    this.practice,
  });

  final int lifeScore;
  final int economyScore;
  final int responsibilityScore;
  final int housingScore;
  final int totalScore;
  final ReadinessLabel label;
  final List<ReadinessWarning> warnings;
  final int monthlyBudgetKrw;
  final PracticeInteraction? practice;

  GapReport? get gap => practice?.gap;

  String get labelText => switch (label) {
    ReadinessLabel.ready => '준비완료',
    ReadinessLabel.needsWork => '보완필요',
    ReadinessLabel.warning => '경고',
  };

  Map<String, Object?> toGuideJson() {
    return {
      'household': '1인가구',
      'species': '반려견',
      'scores': {
        'life': lifeScore,
        'economy': economyScore,
        'responsibility': responsibilityScore,
      },
      'weights': {
        'life': DiagnosisConfig.lifeWeight,
        'economy': DiagnosisConfig.economyWeight,
        'responsibility': DiagnosisConfig.responsibilityWeight,
      },
      'total': totalScore,
      'label': labelText,
      'housingScore': housingScore,
      'warnings': [for (final warning in warnings) warning.message],
      'budget': {
        'amount': monthlyBudgetKrw,
        'dogMonthlyMean': DiagnosisConfig.dogMonthlyMeanKrw,
      },
      'practice': practice == null
          ? null
          : {
              'affectedDomain': practice!.affectedDomain,
              'statedCareMinutes': practice!.statedCareMinutes,
              'actualCareMinutes': practice!.actualCareMinutes,
              'statedCarePoints': practice!.statedCarePoints,
              'observedCarePoints': practice!.observedCarePoints,
              'careClaim': practice!.careClaimText,
              'walkGapRatio': practice!.gap.walkGapRatio,
              'careGapRatio': practice!.gap.careGapRatio,
              'walkOverestimated': practice!.gap.walkOverestimated,
              'careOverestimated': practice!.gap.careOverestimated,
              'changesTotal': false,
            },
    };
  }
}
