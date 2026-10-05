import 'care_profile.dart';
import 'diagnosis_config.dart';
import 'readiness_result.dart';

abstract final class HardCut {
  static List<ReadinessWarning> evaluate(CareProfile profile) {
    final warnings = <ReadinessWarning>[];
    if (profile.petPolicy == PetPolicy.forbidden) {
      warnings.add(
        const ReadinessWarning(
          code: WarningCode.petForbidden,
          message: '건물에서 반려동물 사육이 불가합니다.',
        ),
      );
    }
    if (profile.allergy == AllergyLevel.severe) {
      warnings.add(
        const ReadinessWarning(
          code: WarningCode.severeAllergy,
          message: '알레르기가 심해 양육 전 확인이 필요합니다.',
        ),
      );
    }
    if (profile.absenceHours >= DiagnosisConfig.absenceWarningHours) {
      warnings.add(
        const ReadinessWarning(
          code: WarningCode.longAbsence,
          message: '하루 부재 시간이 10시간 이상입니다.',
        ),
      );
    }
    return warnings;
  }
}
