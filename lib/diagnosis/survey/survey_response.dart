import '../care_profile.dart';

/// 예비 반려인 자가점검 최종 60문항 응답.
/// 생활·경제·책임은 각 20문항이다. 문항 수가 가중치가 아니다.
class SurveyResponse {
  const SurveyResponse({
    required this.life,
    required this.economy,
    required this.responsibility,
  });

  final LifeAnswers life;
  final EconomyAnswers economy;
  final ResponsibilityAnswers responsibility;

  /// 견종 추천용. 주거 형태는 쓰지 않고 아파트로만 둔다.
  CareProfile toCareProfile() {
    return CareProfile(
      housingType: HousingType.apartment,
      petPolicy: switch (life.petAllowed) {
        PetAllowed.allowed => PetPolicy.allowed,
        PetAllowed.unknown => PetPolicy.unknown,
        PetAllowed.forbidden => PetPolicy.forbidden,
      },
      walkAccess: life.walkEnvironment == WalkEnvironment.enough ||
          life.walkEnvironment == WalkEnvironment.some,
      noiseSensitive: life.noiseBurden == NoiseBurden.some ||
          life.noiseBurden == NoiseBurden.high,
      absenceHours: life.absenceHours.round(),
      careMinutes: switch (life.dailyCare) {
        DailyCareTime.under30 => 20,
        DailyCareTime.m30to59 => 45,
        DailyCareTime.m60to89 => 75,
        DailyCareTime.m90to119 => 105,
        DailyCareTime.m120plus => 120,
        DailyCareTime.unknown => 60,
      },
      outingDaysPerWeek: switch (life.outingDays) {
        OutingDays.d0to1 => 1,
        OutingDays.d2to3 => 3,
        OutingDays.d4to5 => 5,
        OutingDays.d6to7 => 7,
      },
      monthlyBudgetKrw: switch (economy.monthlyBudget) {
        MonthlyBudget.under3 => 20000,
        MonthlyBudget.k3to5 => 40000,
        MonthlyBudget.k5to7 => 60000,
        MonthlyBudget.k7to10 => 85000,
        MonthlyBudget.k10to135 => 120000,
        MonthlyBudget.k135plus => 135000,
      },
      canCoverInitialCost: economy.initialCost == InitialCost.full,
      emergencyFund: switch (economy.emergencyFund) {
        EmergencyBand.k50plus || EmergencyBand.k30to50 => EmergencyFund.ready,
        EmergencyBand.k10to30 || EmergencyBand.under10 => EmergencyFund.partial,
        EmergencyBand.none => EmergencyFund.none,
      },
      incomeShockCapacity: switch (economy.incomeShock) {
        IncomeShock.maintain => IncomeShockCapacity.canMaintain,
        IncomeShock.partial => IncomeShockCapacity.partial,
        IncomeShock.hard => IncomeShockCapacity.cannot,
      },
      hasLongTermPlan: responsibility.hasTenYearPlan == YesNo.yes,
      hasCareContinuity: responsibility.hasSickBackup == YesNo.yes,
      allergy: switch (life.allergy) {
        SurveyAllergy.none => AllergyLevel.none,
        SurveyAllergy.mild => AllergyLevel.mild,
        SurveyAllergy.severe => AllergyLevel.severe,
        SurveyAllergy.unchecked => AllergyLevel.none,
      },
    );
  }
}

class LifeAnswers {
  const LifeAnswers({
    required this.weekdayAlone,
    required this.leaveHour,
    required this.leaveMinute,
    required this.returnHour,
    required this.returnMinute,
    required this.outingDays,
    required this.walkDays,
    required this.dailyCare,
    required this.scheduledFeeding,
    required this.indoorPlay,
    required this.toiletPlan,
    required this.cleanToilet,
    required this.afterWalkHygiene,
    required this.noiseBurden,
    required this.walkEnvironment,
    required this.housingType,
    required this.petAllowed,
    required this.walkBarrier,
    required this.dentalCare,
    required this.nightCare,
    required this.weekdayWeekendGap,
    required this.allergy,
    required this.burdens,
  });

  final WeekdayAlone weekdayAlone;
  final int leaveHour;
  final int leaveMinute;
  final int returnHour;
  final int returnMinute;
  final OutingDays outingDays;
  final WalkDays walkDays;
  final DailyCareTime dailyCare;
  final Ability scheduledFeeding;
  final Ability indoorPlay;
  final ToiletPlan toiletPlan;
  final Ability cleanToilet;
  final Ability afterWalkHygiene;
  final NoiseBurden noiseBurden;
  final WalkEnvironment walkEnvironment;
  final SurveyHousingType housingType;
  final PetAllowed petAllowed;
  final WalkBarrier walkBarrier;
  final DentalCare dentalCare;
  final NightCare nightCare;
  final WeekdayWeekendGap weekdayWeekendGap;
  final SurveyAllergy allergy;
  final List<LifeBurden> burdens;

  /// 외출·귀가 시각으로 계산한 평일 부재 시간. 자정을 넘기면 다음날로 본다.
  double get absenceHours {
    final leave = leaveHour * 60 + leaveMinute;
    var back = returnHour * 60 + returnMinute;
    if (back <= leave) {
      back += 24 * 60;
    }
    return (back - leave) / 60;
  }
}

class EconomyAnswers {
  const EconomyAnswers({
    required this.canSustainBasicCost,
    required this.hasSeparateBudget,
    required this.monthlyBudget,
    required this.willTrackSpending,
    required this.willPayOneYear,
    required this.canCoverRoutineMedical,
    required this.emergencyFund,
    required this.plannedGroomingBudget,
    required this.canCoverOverrun,
    required this.canCoverSeniorCost,
    required this.initialCost,
    required this.incomeShare,
    required this.incomeShock,
    required this.petInsurance,
    required this.canCoverWithLivingCost,
    required this.boardingDayBudget,
    required this.checkupPerYear,
    required this.bigExpenseThisYear,
    required this.whoPays,
    required this.canCoverOngoingVet,
  });

  final YesNo canSustainBasicCost;
  final YesNo hasSeparateBudget;
  final MonthlyBudget monthlyBudget;
  final YesNo willTrackSpending;
  final YesNo willPayOneYear;
  final YesNo canCoverRoutineMedical;
  final EmergencyBand emergencyFund;
  final YesNo plannedGroomingBudget;
  final YesNo canCoverOverrun;
  final YesNo canCoverSeniorCost;
  final InitialCost initialCost;
  final IncomeShare incomeShare;
  final IncomeShock incomeShock;
  final PetInsurance petInsurance;
  final YesNo canCoverWithLivingCost;
  final BoardingBudget boardingDayBudget;
  final CheckupPerYear checkupPerYear;
  final YesNo bigExpenseThisYear;
  final WhoPays whoPays;
  final YesNo canCoverOngoingVet;
}

class ResponsibilityAnswers {
  const ResponsibilityAnswers({
    required this.primaryCarer,
    required this.hasWeekdayBackup,
    required this.hasSickBackup,
    required this.travelCare,
    required this.travelDaysPerMonth,
    required this.checkedBoarding,
    required this.tookPreEducation,
    required this.appliedEducation,
    required this.hasTenYearPlan,
    required this.hasMoveJobPlan,
    required this.knowsEmergencyClinic,
    required this.knowsNightClinic,
    required this.knowsLegalDuty,
    required this.knowsBehaviorHelp,
    required this.knowsHealthResponse,
    required this.householdSize,
    required this.hasNoSupportPlan,
    required this.assignedDailyWalker,
    required this.hasHouseholdConsent,
    required this.willKeepDespiteProblems,
  });

  final PrimaryCarer primaryCarer;
  final YesNo hasWeekdayBackup;
  final YesNo hasSickBackup;
  final TravelCare travelCare;
  final TravelDays travelDaysPerMonth;
  final YesNo checkedBoarding;
  final YesNo tookPreEducation;
  final AppliedEducation appliedEducation;
  final YesNo hasTenYearPlan;
  final YesNo hasMoveJobPlan;
  final YesNo knowsEmergencyClinic;
  final YesNo knowsNightClinic;
  final YesNo knowsLegalDuty;
  final YesNo knowsBehaviorHelp;
  final YesNo knowsHealthResponse;
  final HouseholdSize householdSize;
  final YesNo hasNoSupportPlan;
  final YesNo assignedDailyWalker;
  final HouseholdConsent hasHouseholdConsent;
  final YesNo willKeepDespiteProblems;
}

enum WeekdayAlone { under1, h1to2, h2to3, h3to4, h4to5, h5plus }

enum OutingDays { d0to1, d2to3, d4to5, d6to7 }

enum WalkDays { everyday, d5to6, d3to4, d1to2, hard }

enum DailyCareTime { under30, m30to59, m60to89, m90to119, m120plus, unknown }

enum Ability { full, mostly, hard, unknown }

enum ToiletPlan { indoor, mostlyIndoor, mixed, outdoor, undecided }

enum NoiseBurden { none, some, high, unknown }

enum WalkEnvironment { enough, some, lacking, unchecked }

enum SurveyHousingType { studio, officetel, apartment, house, other }

enum PetAllowed { allowed, unknown, forbidden }

enum WalkBarrier { overtime, weather, fatigue, health, noHelper, noPlace, none }

enum DentalCare { daily, weekly2to3, weekly1, hard, unknown }

enum NightCare { always, someHours, hard, needsHelp }

enum WeekdayWeekendGap { same, little, much }

enum SurveyAllergy { none, mild, severe, unchecked }

enum LifeBurden {
  longAbsence,
  dailyWalk,
  toilet,
  noise,
  alone,
  play,
  hygiene,
  sleep,
  other,
}

enum YesNo { yes, no }

enum MonthlyBudget { under3, k3to5, k5to7, k7to10, k10to135, k135plus }

enum EmergencyBand { under10, k10to30, k30to50, k50plus, none }

enum InitialCost { full, partial, hard }

enum IncomeShare { under5, p5to10, p10plus, unknown }

enum IncomeShock { maintain, partial, hard }

enum PetInsurance { yesOrPlan, no }

enum BoardingBudget { under2, k2to4, k4to6, k6plus, unknown }

enum CheckupPerYear { zero, one, two, threePlus }

enum WhoPays { self, family }

enum PrimaryCarer { self, familyShare, service }

enum TravelCare { together, family, boarding, none }

enum TravelDays { d0to1, d2to3, d4to5, d6plus }

enum AppliedEducation { yes, no, notTaken }

enum HouseholdSize { one, two, threePlus }

enum HouseholdConsent { yes, no, livesAlone }
