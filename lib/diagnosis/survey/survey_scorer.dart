import '../diagnosis_config.dart';
import '../readiness_result.dart';
import 'survey_response.dart';

class SurveyScore {
  const SurveyScore({
    required this.lifeScore,
    required this.economyScore,
    required this.responsibilityScore,
    required this.totalScore,
    required this.label,
    required this.warnings,
    required this.lifeItemScores,
    required this.economyItemScores,
    required this.responsibilityItemScores,
    required this.habits,
  });

  final int lifeScore;
  final int economyScore;
  final int responsibilityScore;
  final int totalScore;
  final ReadinessLabel label;
  final List<ReadinessWarning> warnings;
  final Map<String, int> lifeItemScores;
  final Map<String, int> economyItemScores;
  final Map<String, int> responsibilityItemScores;
  final List<String> habits;
}

/// 60문항 채점. 영역 안에서는 문항 평균(100점)이고,
/// 종합만 생활 0.42 · 경제 0.31 · 책임 0.27을 곱한다.
/// 주거 형태와 사육 가능은 생활 평균에 넣는다. 알레르기는 넣지 않는다.
abstract final class SurveyScorer {
  static SurveyScore score(SurveyResponse response) {
    final lifeItems = _lifeItems(response.life);
    final economyItems = _economyItems(response.economy);
    final responsibilityItems = _responsibilityItems(response.responsibility);
    final lifeScore = _average(lifeItems.values);
    final economyScore = _average(economyItems.values);
    final responsibilityScore = _average(responsibilityItems.values);
    final totalScore =
        (lifeScore * DiagnosisConfig.lifeWeight +
                economyScore * DiagnosisConfig.economyWeight +
                responsibilityScore * DiagnosisConfig.responsibilityWeight)
            .round();
    final warnings = _warnings(response.life);
    return SurveyScore(
      lifeScore: lifeScore,
      economyScore: economyScore,
      responsibilityScore: responsibilityScore,
      totalScore: totalScore,
      label: _label(totalScore, warnings),
      warnings: warnings,
      lifeItemScores: lifeItems,
      economyItemScores: economyItems,
      responsibilityItemScores: responsibilityItems,
      habits: _habits(response),
    );
  }

  static Map<String, int> _lifeItems(LifeAnswers a) {
    return {
      'A1 평일 부재': switch (a.weekdayAlone) {
        WeekdayAlone.under1 => 100,
        WeekdayAlone.h1to2 => 88,
        WeekdayAlone.h2to3 => 75,
        WeekdayAlone.h3to4 => 58,
        WeekdayAlone.h4to5 => 38,
        WeekdayAlone.h5plus => 15,
      },
      'A3 외출 일수': switch (a.outingDays) {
        OutingDays.d0to1 => 100,
        OutingDays.d2to3 => 70,
        OutingDays.d4to5 => 40,
        OutingDays.d6to7 => 15,
      },
      'A4 산책 일수': switch (a.walkDays) {
        WalkDays.everyday => 100,
        WalkDays.d5to6 => 80,
        WalkDays.d3to4 => 55,
        WalkDays.d1to2 => 28,
        WalkDays.hard => 0,
      },
      'A5 하루 돌봄 시간': switch (a.dailyCare) {
        DailyCareTime.m120plus => 100,
        DailyCareTime.m90to119 => 80,
        DailyCareTime.m60to89 => 55,
        DailyCareTime.m30to59 => 28,
        DailyCareTime.under30 => 0,
        DailyCareTime.unknown => 40,
      },
      'A6 정시 급여': _ability(a.scheduledFeeding),
      'A7 실내 놀이': _ability(a.indoorPlay),
      'A8 배변 계획': switch (a.toiletPlan) {
        ToiletPlan.indoor => 80,
        ToiletPlan.mostlyIndoor => 90,
        ToiletPlan.mixed => 100,
        ToiletPlan.outdoor => 70,
        ToiletPlan.undecided => 35,
      },
      'A9 배변 청결': _ability3(a.cleanToilet),
      'A10 산책 후 위생': _ability3(a.afterWalkHygiene),
      'A11 소음 부담': switch (a.noiseBurden) {
        NoiseBurden.none => 100,
        NoiseBurden.some => 55,
        NoiseBurden.high => 15,
        NoiseBurden.unknown => 40,
      },
      'A12 산책 환경': switch (a.walkEnvironment) {
        WalkEnvironment.enough => 100,
        WalkEnvironment.some => 70,
        WalkEnvironment.lacking => 25,
        WalkEnvironment.unchecked => 40,
      },
      'A13 주거 형태': switch (a.housingType) {
        SurveyHousingType.house => 100,
        SurveyHousingType.apartment => 80,
        SurveyHousingType.officetel => 55,
        SurveyHousingType.studio => 40,
        SurveyHousingType.other => 60,
      },
      'A14 사육 가능': switch (a.petAllowed) {
        PetAllowed.allowed => 100,
        PetAllowed.unknown => 50,
        PetAllowed.forbidden => 0,
      },
      'A15 산책 장애': switch (a.walkBarrier) {
        WalkBarrier.none => 100,
        WalkBarrier.weather => 75,
        WalkBarrier.fatigue => 45,
        WalkBarrier.overtime => 40,
        WalkBarrier.health => 35,
        WalkBarrier.noHelper => 25,
        WalkBarrier.noPlace => 20,
      },
      'A16 구강 관리': switch (a.dentalCare) {
        DentalCare.daily => 100,
        DentalCare.weekly2to3 => 75,
        DentalCare.weekly1 => 45,
        DentalCare.hard => 15,
        DentalCare.unknown => 30,
      },
      'A17 야간 대응': switch (a.nightCare) {
        NightCare.always => 100,
        NightCare.someHours => 60,
        NightCare.needsHelp => 35,
        NightCare.hard => 10,
      },
      'A18 평일·주말 차이': switch (a.weekdayWeekendGap) {
        WeekdayWeekendGap.same => 100,
        WeekdayWeekendGap.little => 70,
        WeekdayWeekendGap.much => 35,
      },
    };
  }

  static Map<String, int> _economyItems(EconomyAnswers a) {
    return {
      'B1 기본비 지속': _yesNo(a.canSustainBasicCost),
      'B2 예산 분리': _yesNo(a.hasSeparateBudget),
      'B3 월 예산': switch (a.monthlyBudget) {
        MonthlyBudget.k135plus => 100,
        MonthlyBudget.k10to135 => 70,
        MonthlyBudget.k7to10 => 45,
        MonthlyBudget.k5to7 => 25,
        MonthlyBudget.k3to5 => 10,
        MonthlyBudget.under3 => 0,
      },
      'B4 지출 점검': _yesNo(a.willTrackSpending),
      'B5 1년 부담': _yesNo(a.willPayOneYear),
      'B6 정기 의료비': _yesNo(a.canCoverRoutineMedical),
      'B7 비상금': switch (a.emergencyFund) {
        EmergencyBand.k50plus => 100,
        EmergencyBand.k30to50 => 80,
        EmergencyBand.k10to30 => 50,
        EmergencyBand.under10 => 20,
        EmergencyBand.none => 0,
      },
      'B8 미용 예산': _yesNo(a.plannedGroomingBudget),
      'B9 초과 비용': _yesNo(a.canCoverOverrun),
      'B10 노령 비용': _yesNo(a.canCoverSeniorCost),
      'B11 초기 비용': switch (a.initialCost) {
        InitialCost.full => 100,
        InitialCost.partial => 50,
        InitialCost.hard => 0,
      },
      'B12 소득 대비': switch (a.incomeShare) {
        IncomeShare.under5 => 100,
        IncomeShare.p5to10 => 65,
        IncomeShare.p10plus => 25,
        IncomeShare.unknown => 40,
      },
      'B13 소득 충격': switch (a.incomeShock) {
        IncomeShock.maintain => 100,
        IncomeShock.partial => 50,
        IncomeShock.hard => 0,
      },
      'B14 펫보험': a.petInsurance == PetInsurance.yesOrPlan ? 100 : 40,
      'B15 생활비 병행': _yesNo(a.canCoverWithLivingCost),
      'B16 위탁비': switch (a.boardingDayBudget) {
        BoardingBudget.k6plus => 100,
        BoardingBudget.k4to6 => 80,
        BoardingBudget.k2to4 => 50,
        BoardingBudget.under2 => 20,
        BoardingBudget.unknown => 35,
      },
      'B17 검진 횟수': switch (a.checkupPerYear) {
        CheckupPerYear.threePlus => 100,
        CheckupPerYear.two => 90,
        CheckupPerYear.one => 70,
        CheckupPerYear.zero => 15,
      },
      'B18 큰 지출': a.bigExpenseThisYear == YesNo.no ? 100 : 45,
      'B19 비용 분담': a.whoPays == WhoPays.family ? 80 : 70,
      'B20 지속 병원비': _yesNo(a.canCoverOngoingVet),
    };
  }

  static Map<String, int> _responsibilityItems(ResponsibilityAnswers a) {
    return {
      'C1 주 돌봄': switch (a.primaryCarer) {
        PrimaryCarer.self => 90,
        PrimaryCarer.familyShare => 100,
        PrimaryCarer.service => 55,
      },
      'C2 낮 대체': _yesNo(a.hasWeekdayBackup),
      'C3 아플 때 대체': _yesNo(a.hasSickBackup),
      'C4 여행 돌봄': switch (a.travelCare) {
        TravelCare.together => 100,
        TravelCare.family => 90,
        TravelCare.boarding => 70,
        TravelCare.none => 0,
      },
      'C5 외박 일수': switch (a.travelDaysPerMonth) {
        TravelDays.d0to1 => 100,
        TravelDays.d2to3 => 75,
        TravelDays.d4to5 => 45,
        TravelDays.d6plus => 15,
      },
      'C6 위탁 조사': _yesNo(a.checkedBoarding),
      'C7 입양 전 교육': _yesNo(a.tookPreEducation),
      'C8 교육 반영': switch (a.appliedEducation) {
        AppliedEducation.yes => 100,
        AppliedEducation.notTaken => 40,
        AppliedEducation.no => 20,
      },
      'C9 10년 계획': _yesNo(a.hasTenYearPlan),
      'C10 환경 변화 대책': _yesNo(a.hasMoveJobPlan),
      'C11 응급 병원': _yesNo(a.knowsEmergencyClinic),
      'C12 야간 병원': _yesNo(a.knowsNightClinic),
      'C13 법적 의무': _yesNo(a.knowsLegalDuty),
      'C14 행동 전문가': _yesNo(a.knowsBehaviorHelp),
      'C15 건강 대처': _yesNo(a.knowsHealthResponse),
      'C17 비협조 대책': _yesNo(a.hasNoSupportPlan),
      'C18 산책 담당': _yesNo(a.assignedDailyWalker),
      'C19 동거인 동의': switch (a.hasHouseholdConsent) {
        HouseholdConsent.yes => 100,
        HouseholdConsent.livesAlone => 70,
        HouseholdConsent.no => 0,
      },
      'C20 문제 후에도 책임': _yesNo(a.willKeepDespiteProblems),
    };
  }

  static List<ReadinessWarning> _warnings(LifeAnswers a) {
    final warnings = <ReadinessWarning>[];
    if (a.petAllowed == PetAllowed.forbidden) {
      warnings.add(
        const ReadinessWarning(
          code: WarningCode.petForbidden,
          message: '건물에서 반려동물 사육이 불가합니다.',
        ),
      );
    }
    if (a.allergy == SurveyAllergy.severe) {
      warnings.add(
        const ReadinessWarning(
          code: WarningCode.severeAllergy,
          message: '알레르기가 심해 양육 전 확인이 필요합니다.',
        ),
      );
    }
    if (a.absenceHours >= DiagnosisConfig.absenceWarningHours) {
      warnings.add(
        const ReadinessWarning(
          code: WarningCode.longAbsence,
          message: '하루 부재 시간이 10시간 이상입니다.',
        ),
      );
    }
    return warnings;
  }

  static List<String> _habits(SurveyResponse response) {
    final habits = <String>[];
    if (response.life.weekdayAlone == WeekdayAlone.h5plus) {
      habits.add('평일 긴 부재');
    }
    if (response.life.walkDays == WalkDays.hard ||
        response.life.walkDays == WalkDays.d1to2) {
      habits.add('산책 일수 부족');
    }
    if (response.life.dailyCare == DailyCareTime.under30 ||
        response.life.dailyCare == DailyCareTime.m30to59) {
      habits.add('하루 돌봄 시간 부족');
    }
    for (final burden in response.life.burdens) {
      habits.add(switch (burden) {
        LifeBurden.longAbsence => '장시간 외출',
        LifeBurden.dailyWalk => '매일 산책',
        LifeBurden.toilet => '배변 관리',
        LifeBurden.noise => '소음',
        LifeBurden.alone => '혼자 돌봄',
        LifeBurden.play => '놀이·훈련',
        LifeBurden.hygiene => '위생 관리',
        LifeBurden.sleep => '수면 방해',
        LifeBurden.other => '기타 생활 부담',
      });
    }
    if (response.responsibility.hasSickBackup == YesNo.no) {
      habits.add('돌봄 연속 대책 부족');
    }
    if (response.economy.monthlyBudget == MonthlyBudget.under3 ||
        response.economy.monthlyBudget == MonthlyBudget.k3to5 ||
        response.economy.monthlyBudget == MonthlyBudget.k5to7) {
      habits.add('월 양육 예산 부족');
    }
    return habits.toSet().toList();
  }

  static int _ability(Ability value) => switch (value) {
    Ability.full => 100,
    Ability.mostly => 70,
    Ability.hard => 25,
    Ability.unknown => 40,
  };

  static int _ability3(Ability value) => switch (value) {
    Ability.full => 100,
    Ability.mostly => 70,
    Ability.hard => 25,
    Ability.unknown => 40,
  };

  static int _yesNo(YesNo value) => value == YesNo.yes ? 100 : 20;

  static int _average(Iterable<int> values) {
    final list = values.toList();
    return (list.reduce((a, b) => a + b) / list.length).round();
  }

  static ReadinessLabel _label(int totalScore, List<ReadinessWarning> warnings) {
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
