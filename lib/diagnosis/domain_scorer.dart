import 'care_profile.dart';
import 'diagnosis_config.dart';

abstract final class DomainScorer {
  static int life(CareProfile profile) {
    return _absencePoints(profile.absenceHours) +
        careItemPoints(profile.careMinutes) +
        _outingPoints(profile.outingDaysPerWeek);
  }

  /// 자가점검 돌봄 시간과 7일 실제 돌봄 시간에 같은 점수표를 쓴다.
  static int careItemPoints(int minutes) => _carePoints(minutes);

  static int economy(CareProfile profile) {
    return _budgetPoints(profile.monthlyBudgetKrw) +
        _incomeShockPoints(profile.incomeShockCapacity) +
        _emergencyPoints(profile.emergencyFund) +
        (profile.canCoverInitialCost ? 10 : 0);
  }

  static int responsibility(CareProfile profile) {
    return (profile.hasLongTermPlan ? 60 : 15) +
        (profile.hasCareContinuity ? 40 : 10);
  }

  static int housing(CareProfile profile) {
    return _housingTypePoints(profile.housingType) +
        _petPolicyPoints(profile.petPolicy) +
        (profile.walkAccess ? 15 : 0) +
        (profile.noiseSensitive ? 0 : 10);
  }

  static int _absencePoints(int hours) {
    if (hours <= DiagnosisConfig.absenceFullHours) return 40;
    if (hours <= DiagnosisConfig.absenceHighHours) return 30;
    if (hours <= DiagnosisConfig.absenceMidHours) return 18;
    if (hours < DiagnosisConfig.absenceWarningHours) return 8;
    return 0;
  }

  static int _carePoints(int minutes) {
    if (minutes >= DiagnosisConfig.careFullMinutes) return 35;
    if (minutes >= DiagnosisConfig.careHighMinutes) return 28;
    if (minutes >= DiagnosisConfig.careMidMinutes) return 18;
    if (minutes >= DiagnosisConfig.careLowMinutes) return 8;
    return 0;
  }

  static int _outingPoints(int days) {
    if (days <= DiagnosisConfig.outingFullDays) return 25;
    if (days <= DiagnosisConfig.outingMidDays) return 15;
    if (days <= DiagnosisConfig.outingLowDays) return 8;
    return 0;
  }

  static int _budgetPoints(int amount) {
    if (amount >= DiagnosisConfig.budgetFullKrw) return 45;
    if (amount >= DiagnosisConfig.budgetTwoThirdsKrw) return 30;
    if (amount >= DiagnosisConfig.budgetOneThirdKrw) return 15;
    return 0;
  }

  static int _incomeShockPoints(IncomeShockCapacity capacity) {
    return switch (capacity) {
      IncomeShockCapacity.canMaintain => 25,
      IncomeShockCapacity.partial => 12,
      IncomeShockCapacity.cannot => 0,
    };
  }

  static int _emergencyPoints(EmergencyFund fund) {
    return switch (fund) {
      EmergencyFund.ready => 20,
      EmergencyFund.partial => 10,
      EmergencyFund.none => 0,
    };
  }

  static int _housingTypePoints(HousingType type) {
    return switch (type) {
      HousingType.house => 35,
      HousingType.apartment => 28,
      HousingType.officetel => 18,
      HousingType.studio => 12,
    };
  }

  static int _petPolicyPoints(PetPolicy policy) {
    return switch (policy) {
      PetPolicy.allowed => 40,
      PetPolicy.unknown => 20,
      PetPolicy.forbidden => 0,
    };
  }
}
