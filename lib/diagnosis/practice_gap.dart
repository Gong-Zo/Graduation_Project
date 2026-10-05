import 'care_profile.dart';
import 'diagnosis_config.dart';
import 'domain_scorer.dart';
import 'readiness_result.dart';

abstract final class PracticeGap {
  static PracticeInteraction fromProfile(CareProfile profile, GapInput input) {
    return PracticeInteraction(
      gap: GapReport(
        walkGapRatio: _ratio(input.plannedWalkMinutes, input.actualWalkMinutes),
        careGapRatio: _ratio(input.plannedCareMinutes, input.actualCareMinutes),
        walkOverestimated: _overestimated(
          input.plannedWalkMinutes,
          input.actualWalkMinutes,
        ),
        careOverestimated: _overestimated(
          input.plannedCareMinutes,
          input.actualCareMinutes,
        ),
      ),
      statedCareMinutes: profile.careMinutes,
      actualCareMinutes: input.actualCareMinutes,
      statedCarePoints: DomainScorer.careItemPoints(profile.careMinutes),
      observedCarePoints: DomainScorer.careItemPoints(input.actualCareMinutes),
      careClaim: _claim(profile.careMinutes, input.actualCareMinutes),
    );
  }

  static double _ratio(int planned, int actual) {
    if (planned <= 0) return 0;
    return (planned - actual) / planned;
  }

  static bool _overestimated(int planned, int actual) {
    if (planned <= 0) return false;
    return actual < planned * DiagnosisConfig.gapOverestimateRatio;
  }

  /// 7일 실제가 자가점검 돌봄의 70% 미만이면 과대, 자가점검보다 크면 과소.
  static CareClaimFit _claim(int stated, int actual) {
    if (stated <= 0) {
      return actual <= 0 ? CareClaimFit.aligned : CareClaimFit.understated;
    }
    if (actual < stated * DiagnosisConfig.gapOverestimateRatio) {
      return CareClaimFit.overstated;
    }
    if (actual > stated) return CareClaimFit.understated;
    return CareClaimFit.aligned;
  }
}
