import 'package:flutter/material.dart';

import '../diagnosis/care_profile.dart';
import '../diagnosis/readiness_result.dart';
import '../diagnosis/survey/survey_engine.dart';
import '../diagnosis/survey/survey_response.dart';
import '../diagnosis/survey/survey_scorer.dart';
import 'linked_data_panel.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  static const _engine = SurveyEngine();

  WeekdayAlone _weekdayAlone = WeekdayAlone.h4to5;
  int _leaveHour = 8;
  int _leaveMinute = 30;
  int _returnHour = 19;
  int _returnMinute = 0;
  OutingDays _outingDays = OutingDays.d4to5;
  WalkDays _walkDays = WalkDays.d3to4;
  DailyCareTime _dailyCare = DailyCareTime.m60to89;
  Ability _scheduledFeeding = Ability.mostly;
  Ability _indoorPlay = Ability.mostly;
  ToiletPlan _toiletPlan = ToiletPlan.indoor;
  Ability _cleanToilet = Ability.mostly;
  Ability _afterWalkHygiene = Ability.mostly;
  NoiseBurden _noiseBurden = NoiseBurden.some;
  WalkEnvironment _walkEnvironment = WalkEnvironment.some;
  WalkBarrier _walkBarrier = WalkBarrier.overtime;
  DentalCare _dentalCare = DentalCare.weekly2to3;
  NightCare _nightCare = NightCare.someHours;
  WeekdayWeekendGap _weekdayWeekendGap = WeekdayWeekendGap.little;
  SurveyAllergy _allergy = SurveyAllergy.none;
  final Set<LifeBurden> _burdens = {LifeBurden.longAbsence, LifeBurden.dailyWalk};

  YesNo _canSustainBasicCost = YesNo.yes;
  YesNo _hasSeparateBudget = YesNo.no;
  MonthlyBudget _monthlyBudget = MonthlyBudget.k10to135;
  YesNo _willTrackSpending = YesNo.yes;
  YesNo _willPayOneYear = YesNo.yes;
  YesNo _canCoverRoutineMedical = YesNo.yes;
  EmergencyBand _emergencyFund = EmergencyBand.k10to30;
  YesNo _plannedGroomingBudget = YesNo.no;
  YesNo _canCoverOverrun = YesNo.yes;
  YesNo _canCoverSeniorCost = YesNo.no;
  InitialCost _initialCost = InitialCost.partial;
  IncomeShare _incomeShare = IncomeShare.p5to10;
  IncomeShock _incomeShock = IncomeShock.partial;
  PetInsurance _petInsurance = PetInsurance.no;
  YesNo _canCoverWithLivingCost = YesNo.yes;
  BoardingBudget _boardingDayBudget = BoardingBudget.k2to4;
  CheckupPerYear _checkupPerYear = CheckupPerYear.one;
  YesNo _bigExpenseThisYear = YesNo.yes;
  WhoPays _whoPays = WhoPays.self;
  YesNo _canCoverOngoingVet = YesNo.no;

  PrimaryCarer _primaryCarer = PrimaryCarer.self;
  YesNo _hasWeekdayBackup = YesNo.no;
  YesNo _hasSickBackup = YesNo.no;
  TravelCare _travelCare = TravelCare.none;
  TravelDays _travelDaysPerMonth = TravelDays.d2to3;
  YesNo _checkedBoarding = YesNo.no;
  YesNo _tookPreEducation = YesNo.no;
  AppliedEducation _appliedEducation = AppliedEducation.notTaken;
  YesNo _hasTenYearPlan = YesNo.no;
  YesNo _hasMoveJobPlan = YesNo.no;
  YesNo _knowsEmergencyClinic = YesNo.no;
  YesNo _knowsNightClinic = YesNo.no;
  YesNo _knowsLegalDuty = YesNo.yes;
  YesNo _knowsBehaviorHelp = YesNo.no;
  YesNo _knowsHealthResponse = YesNo.no;
  HouseholdSize _householdSize = HouseholdSize.one;
  YesNo _hasNoSupportPlan = YesNo.no;
  YesNo _assignedDailyWalker = YesNo.yes;
  HouseholdConsent _hasHouseholdConsent = HouseholdConsent.livesAlone;
  YesNo _willKeepDespiteProblems = YesNo.yes;

  SurveyScore? _score;
  CareProfile? _profile;

  void _submit() {
    final response = SurveyResponse(
          life: LifeAnswers(
            weekdayAlone: _weekdayAlone,
            leaveHour: _leaveHour,
            leaveMinute: _leaveMinute,
            returnHour: _returnHour,
            returnMinute: _returnMinute,
            outingDays: _outingDays,
            walkDays: _walkDays,
            dailyCare: _dailyCare,
            scheduledFeeding: _scheduledFeeding,
            indoorPlay: _indoorPlay,
            toiletPlan: _toiletPlan,
            cleanToilet: _cleanToilet,
            afterWalkHygiene: _afterWalkHygiene,
            noiseBurden: _noiseBurden,
            walkEnvironment: _walkEnvironment,
            housingType: SurveyHousingType.apartment,
            petAllowed: PetAllowed.allowed,
            walkBarrier: _walkBarrier,
            dentalCare: _dentalCare,
            nightCare: _nightCare,
            weekdayWeekendGap: _weekdayWeekendGap,
            allergy: _allergy,
            burdens: _burdens.toList(),
          ),
          economy: EconomyAnswers(
            canSustainBasicCost: _canSustainBasicCost,
            hasSeparateBudget: _hasSeparateBudget,
            monthlyBudget: _monthlyBudget,
            willTrackSpending: _willTrackSpending,
            willPayOneYear: _willPayOneYear,
            canCoverRoutineMedical: _canCoverRoutineMedical,
            emergencyFund: _emergencyFund,
            plannedGroomingBudget: _plannedGroomingBudget,
            canCoverOverrun: _canCoverOverrun,
            canCoverSeniorCost: _canCoverSeniorCost,
            initialCost: _initialCost,
            incomeShare: _incomeShare,
            incomeShock: _incomeShock,
            petInsurance: _petInsurance,
            canCoverWithLivingCost: _canCoverWithLivingCost,
            boardingDayBudget: _boardingDayBudget,
            checkupPerYear: _checkupPerYear,
            bigExpenseThisYear: _bigExpenseThisYear,
            whoPays: _whoPays,
            canCoverOngoingVet: _canCoverOngoingVet,
          ),
          responsibility: ResponsibilityAnswers(
            primaryCarer: _primaryCarer,
            hasWeekdayBackup: _hasWeekdayBackup,
            hasSickBackup: _hasSickBackup,
            travelCare: _travelCare,
            travelDaysPerMonth: _travelDaysPerMonth,
            checkedBoarding: _checkedBoarding,
            tookPreEducation: _tookPreEducation,
            appliedEducation: _appliedEducation,
            hasTenYearPlan: _hasTenYearPlan,
            hasMoveJobPlan: _hasMoveJobPlan,
            knowsEmergencyClinic: _knowsEmergencyClinic,
            knowsNightClinic: _knowsNightClinic,
            knowsLegalDuty: _knowsLegalDuty,
            knowsBehaviorHelp: _knowsBehaviorHelp,
            knowsHealthResponse: _knowsHealthResponse,
            householdSize: _householdSize,
            hasNoSupportPlan: _hasNoSupportPlan,
            assignedDailyWalker: _assignedDailyWalker,
            hasHouseholdConsent: _hasHouseholdConsent,
            willKeepDespiteProblems: _willKeepDespiteProblems,
          ),
    );
    setState(() {
      _score = _engine.evaluate(response);
      _profile = response.toCareProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('펫비포 준비도 자가점검')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [
          Text(
            '생활·경제·책임 문항입니다. 점검하기를 누르면 영역 평균 뒤 0.42·0.31·0.27로 종합합니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _sectionTitle('A. 생활'),
          _drop('1. 평일 혼자 두는 시간', _weekdayAlone, {
            WeekdayAlone.under1: '1시간 미만',
            WeekdayAlone.h1to2: '1~2시간',
            WeekdayAlone.h2to3: '2~3시간',
            WeekdayAlone.h3to4: '3~4시간',
            WeekdayAlone.h4to5: '4~5시간',
            WeekdayAlone.h5plus: '5시간 이상',
          }, (v) => _weekdayAlone = v),
          _timeRow(),
          _drop('3. 일주일 외출 일수', _outingDays, {
            OutingDays.d0to1: '0~1일',
            OutingDays.d2to3: '2~3일',
            OutingDays.d4to5: '4~5일',
            OutingDays.d6to7: '6~7일',
          }, (v) => _outingDays = v),
          _drop('4. 산책 가능 일수', _walkDays, {
            WalkDays.everyday: '매일',
            WalkDays.d5to6: '주 5~6일',
            WalkDays.d3to4: '주 3~4일',
            WalkDays.d1to2: '주 1~2일',
            WalkDays.hard: '실천하기 어려움',
          }, (v) => _walkDays = v),
          _drop('5. 하루 직접 돌봄 시간', _dailyCare, {
            DailyCareTime.under30: '30분 미만',
            DailyCareTime.m30to59: '30~59분',
            DailyCareTime.m60to89: '60~89분',
            DailyCareTime.m90to119: '90~119분',
            DailyCareTime.m120plus: '120분 이상',
            DailyCareTime.unknown: '판단하기 어려움',
          }, (v) => _dailyCare = v),
          _drop('6. 정시 급여', _scheduledFeeding, _ability, (v) => _scheduledFeeding = v),
          _drop('7. 실내 놀이·훈련', _indoorPlay, _ability, (v) => _indoorPlay = v),
          _drop('8. 배변 장소 계획', _toiletPlan, {
            ToiletPlan.indoor: '실내 배변 중심',
            ToiletPlan.mostlyIndoor: '주로 실내·일부 실외',
            ToiletPlan.mixed: '실내외 병행',
            ToiletPlan.outdoor: '주로 실외',
            ToiletPlan.undecided: '미정',
          }, (v) => _toiletPlan = v),
          _drop('9. 배변 후 즉시 청결', _cleanToilet, _ability3, (v) => _cleanToilet = v),
          _drop('10. 산책 후 위생', _afterWalkHygiene, _ability3, (v) => _afterWalkHygiene = v),
          _drop('11. 소음 부담', _noiseBurden, {
            NoiseBurden.none: '부담이 거의 없음',
            NoiseBurden.some: '어느 정도 부담됨',
            NoiseBurden.high: '부담이 큼',
            NoiseBurden.unknown: '판단하기 어려움',
          }, (v) => _noiseBurden = v),
          _drop('12. 산책 환경', _walkEnvironment, {
            WalkEnvironment.enough: '충분함',
            WalkEnvironment.some: '어느 정도 마련되어 있음',
            WalkEnvironment.lacking: '부족함',
            WalkEnvironment.unchecked: '확인하지 못함',
          }, (v) => _walkEnvironment = v),
          _drop('13. 산책을 못 지킬 이유', _walkBarrier, {
            WalkBarrier.overtime: '야근·학업',
            WalkBarrier.weather: '날씨',
            WalkBarrier.fatigue: '피로',
            WalkBarrier.health: '건강 문제',
            WalkBarrier.noHelper: '대신 돌봐줄 사람 부족',
            WalkBarrier.noPlace: '산책 장소 부족',
            WalkBarrier.none: '특별히 예상되는 어려움 없음',
          }, (v) => _walkBarrier = v),
          _drop('14. 구강 관리', _dentalCare, {
            DentalCare.daily: '매일 가능',
            DentalCare.weekly2to3: '주 2~3회 가능',
            DentalCare.weekly1: '주 1회 정도 가능',
            DentalCare.hard: '꾸준한 관리가 어려움',
            DentalCare.unknown: '방법을 잘 모름',
          }, (v) => _dentalCare = v),
          _drop('15. 야간 돌봄', _nightCare, {
            NightCare.always: '언제든 대응 가능',
            NightCare.someHours: '일부 시간대에만 가능',
            NightCare.hard: '대응이 어려울 수 있음',
            NightCare.needsHelp: '함께 대응할 사람이 필요함',
          }, (v) => _nightCare = v),
          _drop('16. 평일·주말 차이', _weekdayWeekendGap, {
            WeekdayWeekendGap.same: '거의 같음',
            WeekdayWeekendGap.little: '조금 다름',
            WeekdayWeekendGap.much: '많이 다름',
          }, (v) => _weekdayWeekendGap = v),
          _drop('17. 알레르기', _allergy, {
            SurveyAllergy.none: '없음',
            SurveyAllergy.mild: '약함',
            SurveyAllergy.severe: '심함',
            SurveyAllergy.unchecked: '아직 확인 안 함',
          }, (v) => _allergy = v),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('18. 가장 부담될 생활 요소 (최대 3개)'),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in {
                LifeBurden.longAbsence: '장시간 외출',
                LifeBurden.dailyWalk: '매일 산책',
                LifeBurden.toilet: '배변 관리',
                LifeBurden.noise: '소음 문제',
                LifeBurden.alone: '혼자 돌보는 부담',
                LifeBurden.play: '놀이·훈련 시간',
                LifeBurden.hygiene: '위생 관리',
                LifeBurden.sleep: '수면 방해',
                LifeBurden.other: '기타',
              }.entries)
                FilterChip(
                  label: Text(entry.value),
                  selected: _burdens.contains(entry.key),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_burdens.length < 3) _burdens.add(entry.key);
                      } else {
                        _burdens.remove(entry.key);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('B. 경제적 준비'),
          _drop('1. 기본 양육비 지속 감당', _canSustainBasicCost, _yesNo, (v) => _canSustainBasicCost = v),
          _drop('2. 매달 예산 별도 확보', _hasSeparateBudget, _yesNo, (v) => _hasSeparateBudget = v),
          _drop('3. 한 달 양육비(병원 제외)', _monthlyBudget, {
            MonthlyBudget.under3: '3만 미만',
            MonthlyBudget.k3to5: '3~5만',
            MonthlyBudget.k5to7: '5~7만',
            MonthlyBudget.k7to10: '7~10만',
            MonthlyBudget.k10to135: '10~13.5만',
            MonthlyBudget.k135plus: '13.5만 이상',
          }, (v) => _monthlyBudget = v),
          _drop('4. 지출 점검 계획', _willTrackSpending, _yesNo, (v) => _willTrackSpending = v),
          _drop('5. 1년 이상 부담 계획', _willPayOneYear, _yesNo, (v) => _willPayOneYear = v),
          _drop('6. 정기 의료비 감당', _canCoverRoutineMedical, _yesNo, (v) => _canCoverRoutineMedical = v),
          _drop('7. 예상치 못한 지출', _emergencyFund, {
            EmergencyBand.under10: '10만 미만',
            EmergencyBand.k10to30: '10~30만',
            EmergencyBand.k30to50: '30~50만',
            EmergencyBand.k50plus: '50만 이상',
            EmergencyBand.none: '없음',
          }, (v) => _emergencyFund = v),
          _drop('8. 미용 예산 계획', _plannedGroomingBudget, _yesNo, (v) => _plannedGroomingBudget = v),
          _drop('9. 예상보다 비용이 늘 때', _canCoverOverrun, _yesNo, (v) => _canCoverOverrun = v),
          _drop('10. 노령기 비용', _canCoverSeniorCost, _yesNo, (v) => _canCoverSeniorCost = v),
          _drop('11. 입양 초기 비용', _initialCost, {
            InitialCost.full: '전액 가능',
            InitialCost.partial: '일부 가능',
            InitialCost.hard: '어려움',
          }, (v) => _initialCost = v),
          _drop('12. 월 소득 대비 양육비', _incomeShare, {
            IncomeShare.under5: '5% 미만',
            IncomeShare.p5to10: '5~10%',
            IncomeShare.p10plus: '10% 이상',
            IncomeShare.unknown: '모름',
          }, (v) => _incomeShare = v),
          _drop('13. 소득이 줄어도 유지', _incomeShock, {
            IncomeShock.maintain: '유지',
            IncomeShock.partial: '일부',
            IncomeShock.hard: '어려움',
          }, (v) => _incomeShock = v),
          _drop('14. 펫보험', _petInsurance, {
            PetInsurance.yesOrPlan: '들었거나 들 계획',
            PetInsurance.no: '없음',
          }, (v) => _petInsurance = v),
          _drop('15. 생활비와 동시 감당', _canCoverWithLivingCost, _yesNo, (v) => _canCoverWithLivingCost = v),
          _drop('16. 하루 위탁비', _boardingDayBudget, {
            BoardingBudget.under2: '2만 미만',
            BoardingBudget.k2to4: '2~4만',
            BoardingBudget.k4to6: '4~6만',
            BoardingBudget.k6plus: '6만 이상',
            BoardingBudget.unknown: '모름',
          }, (v) => _boardingDayBudget = v),
          _drop('17. 정기 검진 횟수', _checkupPerYear, {
            CheckupPerYear.zero: '0회',
            CheckupPerYear.one: '1회',
            CheckupPerYear.two: '2회',
            CheckupPerYear.threePlus: '3회 이상',
          }, (v) => _checkupPerYear = v),
          _drop('18. 1년 안 큰 지출', _bigExpenseThisYear, _yesNo, (v) => _bigExpenseThisYear = v),
          _drop('19. 비용 부담', _whoPays, {
            WhoPays.self: '본인이 거의 다 냄',
            WhoPays.family: '가족과 나눔',
          }, (v) => _whoPays = v),
          _drop('20. 지속 병원비', _canCoverOngoingVet, _yesNo, (v) => _canCoverOngoingVet = v),
          const SizedBox(height: 24),
          _sectionTitle('C. 돌봄 책임 계획'),
          _drop('1. 주된 돌봄', _primaryCarer, {
            PrimaryCarer.self: '본인',
            PrimaryCarer.familyShare: '가족과 나눔',
            PrimaryCarer.service: '돌봄 서비스',
          }, (v) => _primaryCarer = v),
          _drop('2. 평일 낮 대체 돌봄', _hasWeekdayBackup, _yesNo, (v) => _hasWeekdayBackup = v),
          _drop('3. 아플 때 대체 돌봄', _hasSickBackup, _yesNo, (v) => _hasSickBackup = v),
          _drop('4. 여행·외박 돌봄', _travelCare, {
            TravelCare.together: '동반',
            TravelCare.family: '가족·지인',
            TravelCare.boarding: '위탁',
            TravelCare.none: '아직 없음',
          }, (v) => _travelCare = v),
          _drop('5. 한 달 외박 일수', _travelDaysPerMonth, {
            TravelDays.d0to1: '0~1일',
            TravelDays.d2to3: '2~3일',
            TravelDays.d4to5: '4~5일',
            TravelDays.d6plus: '6일 이상',
          }, (v) => _travelDaysPerMonth = v),
          _drop('6. 위탁 시설을 알아보았나', _checkedBoarding, _yesNo, (v) => _checkedBoarding = v),
          _drop('7. 입양 전 교육', _tookPreEducation, _yesNo, (v) => _tookPreEducation = v),
          _drop('8. 교육을 계획에 반영', _appliedEducation, {
            AppliedEducation.yes: '반영함',
            AppliedEducation.no: '반영하지 않음',
            AppliedEducation.notTaken: '교육을 듣지 않음',
          }, (v) => _appliedEducation = v),
          _drop('9. 10년 이상 계획', _hasTenYearPlan, _yesNo, (v) => _hasTenYearPlan = v),
          _drop('10. 이사·취업 후에도 양육', _hasMoveJobPlan, _yesNo, (v) => _hasMoveJobPlan = v),
          _drop('11. 응급 병원', _knowsEmergencyClinic, _yesNo, (v) => _knowsEmergencyClinic = v),
          _drop('12. 야간·휴일 병원', _knowsNightClinic, _yesNo, (v) => _knowsNightClinic = v),
          _drop('13. 법적 의무', _knowsLegalDuty, _yesNo, (v) => _knowsLegalDuty = v),
          _drop('14. 문제행동 전문가', _knowsBehaviorHelp, _yesNo, (v) => _knowsBehaviorHelp = v),
          _drop('15. 건강 이상 대처', _knowsHealthResponse, _yesNo, (v) => _knowsHealthResponse = v),
          _drop('16. 함께 사는 사람', _householdSize, {
            HouseholdSize.one: '1명',
            HouseholdSize.two: '2명',
            HouseholdSize.threePlus: '3명 이상',
          }, (v) => _householdSize = v),
          _drop('17. 비협조 시 대책', _hasNoSupportPlan, _yesNo, (v) => _hasNoSupportPlan = v),
          _drop('18. 산책 담당자를 정했나', _assignedDailyWalker, _yesNo, (v) => _assignedDailyWalker = v),
          _drop('19. 동거인 동의', _hasHouseholdConsent, {
            HouseholdConsent.yes: '동의함',
            HouseholdConsent.no: '동의 없음',
            HouseholdConsent.livesAlone: '혼자 거주',
          }, (v) => _hasHouseholdConsent = v),
          _drop('20. 질병·행동 문제 후에도 책임', _willKeepDespiteProblems, _yesNo, (v) => _willKeepDespiteProblems = v),
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: const Text('점검하기')),
          if (_score != null && _profile != null) ...[
            const SizedBox(height: 24),
            _ResultCard(score: _score!, profile: _profile!),
          ],
        ],
      ),
    );
  }

  static const _yesNo = {YesNo.yes: '예', YesNo.no: '아니요'};
  static const _ability = {
    Ability.full: '충분히 가능',
    Ability.mostly: '대체로 가능',
    Ability.hard: '어려울 수 있음',
    Ability.unknown: '판단하기 어려움',
  };
  static const _ability3 = {
    Ability.full: '항상 가능',
    Ability.mostly: '대체로 가능',
    Ability.hard: '어려울 수 있음',
  };

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _timeRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: _hourDrop('2. 외출 시각', _leaveHour, (v) => _leaveHour = v),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _minuteDrop(_leaveMinute, (v) => _leaveMinute = v),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _hourDrop('귀가 시각', _returnHour, (v) => _returnHour = v),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _minuteDrop(_returnMinute, (v) => _returnMinute = v),
          ),
        ],
      ),
    );
  }

  Widget _hourDrop(String label, int value, ValueChanged<int> onChanged) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: [
        for (var h = 0; h < 24; h++)
          DropdownMenuItem(value: h, child: Text('$h시')),
      ],
      onChanged: (v) {
        if (v != null) setState(() => onChanged(v));
      },
    );
  }

  Widget _minuteDrop(int value, ValueChanged<int> onChanged) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: const InputDecoration(labelText: '분', border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(value: 0, child: Text('00분')),
        DropdownMenuItem(value: 30, child: Text('30분')),
      ],
      onChanged: (v) {
        if (v != null) setState(() => onChanged(v));
      },
    );
  }

  Widget _drop<T>(
    String label,
    T value,
    Map<T, String> items,
    ValueChanged<T> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: [
          for (final entry in items.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: (selected) {
          if (selected != null) setState(() => onChanged(selected));
        },
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.score, required this.profile});

  final SurveyScore score;
  final CareProfile profile;

  @override
  Widget build(BuildContext context) {
    final label = switch (score.label) {
      ReadinessLabel.ready => '준비완료',
      ReadinessLabel.needsWork => '보완필요',
      ReadinessLabel.warning => '경고',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('종합 ${score.totalScore}점 · $label', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('생활 ${score.lifeScore}점'),
            Text('경제 ${score.economyScore}점'),
            Text('책임 ${score.responsibilityScore}점'),
            if (score.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final warning in score.warnings) Text(warning.message),
            ],
            if (score.habits.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('보완이 필요해 보이는 생활 습관'),
              for (final habit in score.habits) Text('· $habit'),
            ],
            const SizedBox(height: 12),
            const Text('이 안내는 입양 허가나 거부가 아닙니다.'),
            LinkedDataPanel(
              key: ValueKey(
                '${profile.absenceHours}-${profile.careMinutes}-${profile.outingDaysPerWeek}-${profile.monthlyBudgetKrw}-${profile.noiseSensitive}',
              ),
              profile: profile,
            ),
          ],
        ),
      ),
    );
  }
}
