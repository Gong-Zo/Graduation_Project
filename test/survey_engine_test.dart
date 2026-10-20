import 'package:flutter_application_1/diagnosis/readiness_result.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_engine.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_random.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_response.dart';
import 'package:flutter_application_1/diagnosis/survey/survey_scorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = SurveyEngine();

  test('랜덤 응답 100건의 종합은 0~100이고 경고가 있으면 준비완료가 아니다', () {
    final samples = SurveyRandom.generateMany(100, seed: 42);
    for (final response in samples) {
      final score = engine.evaluate(response);
      expect(score.lifeScore, inInclusiveRange(0, 100));
      expect(score.economyScore, inInclusiveRange(0, 100));
      expect(score.responsibilityScore, inInclusiveRange(0, 100));
      expect(score.totalScore, inInclusiveRange(0, 100));
      expect(score.lifeItemScores.length, 17);
      expect(score.economyItemScores.length, 20);
      expect(score.responsibilityItemScores.length, 19);
      if (score.warnings.isNotEmpty) {
        expect(score.label, isNot(ReadinessLabel.ready));
      }
    }
  });

  test('같은 응답은 같은 점수가 나온다', () {
    final response = SurveyRandom.generateMany(1, seed: 7).single;
    expect(engine.evaluate(response).totalScore, engine.evaluate(response).totalScore);
  });

  test('사육 불가와 심한 알레르기는 경고이고 준비완료를 막는다', () {
    final base = SurveyRandom.generateMany(1, seed: 3).single;
    final blocked = SurveyResponse(
      life: LifeAnswers(
        weekdayAlone: WeekdayAlone.under1,
        leaveHour: 9,
        leaveMinute: 0,
        returnHour: 18,
        returnMinute: 0,
        outingDays: OutingDays.d0to1,
        walkDays: WalkDays.everyday,
        dailyCare: DailyCareTime.m120plus,
        scheduledFeeding: Ability.full,
        indoorPlay: Ability.full,
        toiletPlan: ToiletPlan.mixed,
        cleanToilet: Ability.full,
        afterWalkHygiene: Ability.full,
        noiseBurden: NoiseBurden.none,
        walkEnvironment: WalkEnvironment.enough,
        housingType: SurveyHousingType.house,
        petAllowed: PetAllowed.forbidden,
        walkBarrier: WalkBarrier.none,
        dentalCare: DentalCare.daily,
        nightCare: NightCare.always,
        weekdayWeekendGap: WeekdayWeekendGap.same,
        allergy: SurveyAllergy.severe,
        burdens: const [],
      ),
      economy: base.economy,
      responsibility: base.responsibility,
    );

    final score = engine.evaluate(blocked);
    expect(score.warnings.map((w) => w.code), containsAll([
      WarningCode.petForbidden,
      WarningCode.severeAllergy,
    ]));
    expect(score.label, isNot(ReadinessLabel.ready));
    expect(score.lifeItemScores['A14 사육 가능'], 0);
  });

  test('주거 형태와 사육 가능은 생활 점수에 넣는다', () {
    final base = SurveyRandom.generateMany(1, seed: 5).single;
    int lifeFor(SurveyHousingType housing, PetAllowed allowed) {
      return SurveyScorer.score(
        SurveyResponse(
          life: LifeAnswers(
            weekdayAlone: base.life.weekdayAlone,
            leaveHour: base.life.leaveHour,
            leaveMinute: base.life.leaveMinute,
            returnHour: base.life.returnHour,
            returnMinute: base.life.returnMinute,
            outingDays: base.life.outingDays,
            walkDays: base.life.walkDays,
            dailyCare: base.life.dailyCare,
            scheduledFeeding: base.life.scheduledFeeding,
            indoorPlay: base.life.indoorPlay,
            toiletPlan: base.life.toiletPlan,
            cleanToilet: base.life.cleanToilet,
            afterWalkHygiene: base.life.afterWalkHygiene,
            noiseBurden: base.life.noiseBurden,
            walkEnvironment: base.life.walkEnvironment,
            housingType: housing,
            petAllowed: allowed,
            walkBarrier: base.life.walkBarrier,
            dentalCare: base.life.dentalCare,
            nightCare: base.life.nightCare,
            weekdayWeekendGap: base.life.weekdayWeekendGap,
            allergy: base.life.allergy,
            burdens: base.life.burdens,
          ),
          economy: base.economy,
          responsibility: base.responsibility,
        ),
      ).lifeScore;
    }

    expect(lifeFor(SurveyHousingType.house, PetAllowed.allowed),
        greaterThan(lifeFor(SurveyHousingType.studio, PetAllowed.forbidden)));
  });

  test('랜덤 10건 채점 결과를 출력한다', () {
    final samples = SurveyRandom.generateMany(10, seed: 42);
    for (var i = 0; i < samples.length; i++) {
      final score = engine.evaluate(samples[i]);
      final label = switch (score.label) {
        ReadinessLabel.ready => '준비완료',
        ReadinessLabel.needsWork => '보완필요',
        ReadinessLabel.warning => '경고',
      };
      final warningText = score.warnings.isEmpty
          ? '없음'
          : score.warnings.map((w) => w.message).join(' / ');
      // ignore: avoid_print
      print(
        '${i + 1}. 종합 ${score.totalScore}점 $label | '
        '생활 ${score.lifeScore} 경제 ${score.economyScore} 책임 ${score.responsibilityScore} '
        '| 경고: $warningText | '
        '습관: ${score.habits.take(3).join(', ')}',
      );
    }
  });

  test('종합은 생활·경제·책임만 합친다', () {
    final response = SurveyRandom.generateMany(1, seed: 11).single;
    final score = SurveyScorer.score(response);
    final fromDomains =
        (score.lifeScore * 0.42 + score.economyScore * 0.31 + score.responsibilityScore * 0.27)
            .round();
    expect(score.totalScore, fromDomains);
  });
}
