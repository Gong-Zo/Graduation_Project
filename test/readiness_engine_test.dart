import 'package:flutter_application_1/diagnosis/care_profile.dart';
import 'package:flutter_application_1/diagnosis/readiness_engine.dart';
import 'package:flutter_application_1/diagnosis/readiness_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = ReadinessEngine();

  CareProfile profile({
    HousingType housingType = HousingType.house,
    PetPolicy petPolicy = PetPolicy.allowed,
    bool walkAccess = true,
    bool noiseSensitive = false,
    int absenceHours = 4,
    int careMinutes = 120,
    int outingDaysPerWeek = 1,
    int monthlyBudgetKrw = 200000,
    bool canCoverInitialCost = true,
    EmergencyFund emergencyFund = EmergencyFund.ready,
    IncomeShockCapacity incomeShockCapacity = IncomeShockCapacity.canMaintain,
    bool hasLongTermPlan = true,
    bool hasCareContinuity = true,
    AllergyLevel allergy = AllergyLevel.none,
  }) {
    return CareProfile(
      housingType: housingType,
      petPolicy: petPolicy,
      walkAccess: walkAccess,
      noiseSensitive: noiseSensitive,
      absenceHours: absenceHours,
      careMinutes: careMinutes,
      outingDaysPerWeek: outingDaysPerWeek,
      monthlyBudgetKrw: monthlyBudgetKrw,
      canCoverInitialCost: canCoverInitialCost,
      emergencyFund: emergencyFund,
      incomeShockCapacity: incomeShockCapacity,
      hasLongTermPlan: hasLongTermPlan,
      hasCareContinuity: hasCareContinuity,
      allergy: allergy,
    );
  }

  test('준비 여건이 갖춰지면 종합 100점과 준비완료가 나온다', () {
    final result = engine.evaluate(profile());

    expect(result.lifeScore, 100);
    expect(result.economyScore, 100);
    expect(result.responsibilityScore, 100);
    expect(result.housingScore, 100);
    expect(result.totalScore, 100);
    expect(result.label, ReadinessLabel.ready);
    expect(result.warnings, isEmpty);
  });

  test('부재가 길고 예산이 낮으면 경고 라벨이 된다', () {
    final result = engine.evaluate(
      profile(
        housingType: HousingType.studio,
        petPolicy: PetPolicy.allowed,
        walkAccess: false,
        noiseSensitive: true,
        absenceHours: 11,
        careMinutes: 30,
        outingDaysPerWeek: 5,
        monthlyBudgetKrw: 80000,
        canCoverInitialCost: false,
        emergencyFund: EmergencyFund.none,
        incomeShockCapacity: IncomeShockCapacity.cannot,
        hasLongTermPlan: false,
        hasCareContinuity: false,
      ),
    );

    expect(result.lifeScore, 16);
    expect(result.economyScore, 15);
    expect(result.responsibilityScore, 25);
    expect(result.housingScore, 52);
    expect(result.totalScore, 18);
    expect(result.label, ReadinessLabel.warning);
    expect(result.warnings.map((warning) => warning.code), [
      WarningCode.longAbsence,
    ]);
  });

  test('사육 불가 경고가 있으면 높은 점수도 보완필요가 된다', () {
    final allowed = engine.evaluate(profile());
    final forbidden = engine.evaluate(profile(petPolicy: PetPolicy.forbidden));

    expect(forbidden.totalScore, allowed.totalScore);
    expect(forbidden.housingScore, lessThan(allowed.housingScore));
    expect(forbidden.label, ReadinessLabel.needsWork);
    expect(forbidden.warnings.single.code, WarningCode.petForbidden);
  });

  test('심한 알레르기는 점수를 유지한 채 경고만 붙인다', () {
    final result = engine.evaluate(profile(allergy: AllergyLevel.severe));

    expect(result.totalScore, 100);
    expect(result.label, ReadinessLabel.needsWork);
    expect(result.warnings.single.code, WarningCode.severeAllergy);
  });

  test('7일 격차는 종합 점수를 바꾸지 않는다', () {
    final withoutGap = engine.evaluate(profile());
    final withGap = engine.evaluate(
      profile(),
      gap: const GapInput(
        plannedWalkMinutes: 60,
        actualWalkMinutes: 35,
        plannedCareMinutes: 90,
        actualCareMinutes: 35,
      ),
    );

    expect(withGap.totalScore, withoutGap.totalScore);
    expect(withGap.lifeScore, withoutGap.lifeScore);
    expect(withGap.practice!.careClaim, CareClaimFit.overstated);
    expect(withGap.practice!.statedCareMinutes, 120);
    expect(withGap.practice!.actualCareMinutes, 35);
    expect(withGap.practice!.statedCarePoints, 35);
    expect(withGap.practice!.observedCarePoints, 8);
    expect(withGap.practice!.affectedDomain, 'life');
    expect(withGap.gap!.walkOverestimated, isTrue);
    expect(withGap.gap!.careOverestimated, isTrue);
  });

  test('월 예산 13만 5천 원 이상이 경제 예산 항목 만점이다', () {
    final atMean = engine.evaluate(profile(monthlyBudgetKrw: 135000));
    final justBelow = engine.evaluate(profile(monthlyBudgetKrw: 101250));

    expect(atMean.economyScore, 100);
    expect(justBelow.economyScore, 85);
  });
}
