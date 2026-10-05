enum HousingType { studio, officetel, apartment, house }

enum PetPolicy { allowed, unknown, forbidden }

enum EmergencyFund { none, partial, ready }

enum AllergyLevel { none, mild, severe }

enum IncomeShockCapacity { cannot, partial, canMaintain }

/// 1인 가구 예비 반려인이 입력하는 양육 여건.
class CareProfile {
  const CareProfile({
    required this.housingType,
    required this.petPolicy,
    required this.walkAccess,
    required this.noiseSensitive,
    required this.absenceHours,
    required this.careMinutes,
    required this.outingDaysPerWeek,
    required this.monthlyBudgetKrw,
    required this.canCoverInitialCost,
    required this.emergencyFund,
    required this.incomeShockCapacity,
    required this.hasLongTermPlan,
    required this.hasCareContinuity,
    required this.allergy,
  });

  final HousingType housingType;
  final PetPolicy petPolicy;
  final bool walkAccess;
  final bool noiseSensitive;
  final int absenceHours;
  final int careMinutes;
  final int outingDaysPerWeek;
  final int monthlyBudgetKrw;
  final bool canCoverInitialCost;
  final EmergencyFund emergencyFund;
  final IncomeShockCapacity incomeShockCapacity;
  final bool hasLongTermPlan;

  /// 가구 구성이나 거주지가 바뀌어도 돌봄을 이어 갈 사람이 있는지.
  final bool hasCareContinuity;
  final AllergyLevel allergy;
}

/// 사전 자가점검과 따로 모은 7일 평균 기록.
class GapInput {
  const GapInput({
    required this.plannedWalkMinutes,
    required this.actualWalkMinutes,
    required this.plannedCareMinutes,
    required this.actualCareMinutes,
  });

  final int plannedWalkMinutes;
  final int actualWalkMinutes;
  final int plannedCareMinutes;
  final int actualCareMinutes;
}
