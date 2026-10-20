import 'dart:math';

import 'survey_response.dart';

abstract final class SurveyRandom {
  static SurveyResponse generate([Random? random]) {
    final rng = random ?? Random();
    return SurveyResponse(
      life: _life(rng),
      economy: _economy(rng),
      responsibility: _responsibility(rng),
    );
  }

  static List<SurveyResponse> generateMany(int count, {int seed = 1}) {
    final rng = Random(seed);
    return [for (var i = 0; i < count; i++) generate(rng)];
  }

  static LifeAnswers _life(Random rng) {
    final leaveHour = 7 + rng.nextInt(3);
    final returnHour = 17 + rng.nextInt(6);
    final burdens = [...LifeBurden.values]..shuffle(rng);
    return LifeAnswers(
      weekdayAlone: _pick(rng, WeekdayAlone.values),
      leaveHour: leaveHour,
      leaveMinute: rng.nextBool() ? 0 : 30,
      returnHour: returnHour,
      returnMinute: rng.nextBool() ? 0 : 30,
      outingDays: _pick(rng, OutingDays.values),
      walkDays: _pick(rng, WalkDays.values),
      dailyCare: _pick(rng, DailyCareTime.values),
      scheduledFeeding: _pick(rng, Ability.values),
      indoorPlay: _pick(rng, Ability.values),
      toiletPlan: _pick(rng, ToiletPlan.values),
      cleanToilet: _pick(rng, const [Ability.full, Ability.mostly, Ability.hard]),
      afterWalkHygiene: _pick(rng, const [
        Ability.full,
        Ability.mostly,
        Ability.hard,
      ]),
      noiseBurden: _pick(rng, NoiseBurden.values),
      walkEnvironment: _pick(rng, WalkEnvironment.values),
      housingType: _pick(rng, SurveyHousingType.values),
      petAllowed: _pick(rng, PetAllowed.values),
      walkBarrier: _pick(rng, WalkBarrier.values),
      dentalCare: _pick(rng, DentalCare.values),
      nightCare: _pick(rng, NightCare.values),
      weekdayWeekendGap: _pick(rng, WeekdayWeekendGap.values),
      allergy: _pick(rng, SurveyAllergy.values),
      burdens: burdens.take(1 + rng.nextInt(3)).toList(),
    );
  }

  static EconomyAnswers _economy(Random rng) {
    return EconomyAnswers(
      canSustainBasicCost: _pick(rng, YesNo.values),
      hasSeparateBudget: _pick(rng, YesNo.values),
      monthlyBudget: _pick(rng, MonthlyBudget.values),
      willTrackSpending: _pick(rng, YesNo.values),
      willPayOneYear: _pick(rng, YesNo.values),
      canCoverRoutineMedical: _pick(rng, YesNo.values),
      emergencyFund: _pick(rng, EmergencyBand.values),
      plannedGroomingBudget: _pick(rng, YesNo.values),
      canCoverOverrun: _pick(rng, YesNo.values),
      canCoverSeniorCost: _pick(rng, YesNo.values),
      initialCost: _pick(rng, InitialCost.values),
      incomeShare: _pick(rng, IncomeShare.values),
      incomeShock: _pick(rng, IncomeShock.values),
      petInsurance: _pick(rng, PetInsurance.values),
      canCoverWithLivingCost: _pick(rng, YesNo.values),
      boardingDayBudget: _pick(rng, BoardingBudget.values),
      checkupPerYear: _pick(rng, CheckupPerYear.values),
      bigExpenseThisYear: _pick(rng, YesNo.values),
      whoPays: _pick(rng, WhoPays.values),
      canCoverOngoingVet: _pick(rng, YesNo.values),
    );
  }

  static ResponsibilityAnswers _responsibility(Random rng) {
    return ResponsibilityAnswers(
      primaryCarer: _pick(rng, PrimaryCarer.values),
      hasWeekdayBackup: _pick(rng, YesNo.values),
      hasSickBackup: _pick(rng, YesNo.values),
      travelCare: _pick(rng, TravelCare.values),
      travelDaysPerMonth: _pick(rng, TravelDays.values),
      checkedBoarding: _pick(rng, YesNo.values),
      tookPreEducation: _pick(rng, YesNo.values),
      appliedEducation: _pick(rng, AppliedEducation.values),
      hasTenYearPlan: _pick(rng, YesNo.values),
      hasMoveJobPlan: _pick(rng, YesNo.values),
      knowsEmergencyClinic: _pick(rng, YesNo.values),
      knowsNightClinic: _pick(rng, YesNo.values),
      knowsLegalDuty: _pick(rng, YesNo.values),
      knowsBehaviorHelp: _pick(rng, YesNo.values),
      knowsHealthResponse: _pick(rng, YesNo.values),
      householdSize: _pick(rng, HouseholdSize.values),
      hasNoSupportPlan: _pick(rng, YesNo.values),
      assignedDailyWalker: _pick(rng, YesNo.values),
      hasHouseholdConsent: _pick(rng, HouseholdConsent.values),
      willKeepDespiteProblems: _pick(rng, YesNo.values),
    );
  }

  static T _pick<T>(Random rng, List<T> values) =>
      values[rng.nextInt(values.length)];
}
