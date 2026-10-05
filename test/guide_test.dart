import 'dart:convert';

import 'package:flutter_application_1/diagnosis/care_profile.dart';
import 'package:flutter_application_1/diagnosis/diagnosis_config.dart';
import 'package:flutter_application_1/diagnosis/guide/fallback_guide.dart';
import 'package:flutter_application_1/diagnosis/guide/gemini_guide_client.dart';
import 'package:flutter_application_1/diagnosis/readiness_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = ReadinessEngine();
  const fallback = FallbackGuide();

  final result = engine.evaluate(
    const CareProfile(
      housingType: HousingType.studio,
      petPolicy: PetPolicy.unknown,
      walkAccess: false,
      noiseSensitive: true,
      absenceHours: 8,
      careMinutes: 60,
      outingDaysPerWeek: 3,
      monthlyBudgetKrw: 100000,
      canCoverInitialCost: false,
      emergencyFund: EmergencyFund.partial,
      incomeShockCapacity: IncomeShockCapacity.partial,
      hasLongTermPlan: false,
      hasCareContinuity: false,
      allergy: AllergyLevel.none,
    ),
  );

  test('엔진 안내는 계산된 종합 점수를 그대로 말한다', () {
    final guide = fallback.build(result);

    expect(result.totalScore, 40);
    expect(guide.fromModel, isFalse);
    expect(guide.summary, contains('종합 40점'));
    expect(guide.boundary, DiagnosisConfig.boundaryText);
    expect(guide.housingNote, contains('참고'));
  });

  test('Gemini 응답은 점수 설명으로만 받는다', () {
    final body = jsonEncode({
      'candidates': [
        {
          'content': {
            'parts': [
              {
                'text': jsonEncode({
                  'summary': '종합 40점으로 경고 수준입니다.',
                  'actions': [
                    {'domain': 'life', 'text': '돌봄 시간을 정해 두세요.'},
                  ],
                  'housingNote': '주거 점수는 참고 점수입니다.',
                  'boundary': '바꿔도 앱이 고정 문구를 씁니다.',
                }),
              },
            ],
          },
        },
      ],
    });

    final guide = tryParseGeminiResponse(body);

    expect(guide, isNotNull);
    expect(guide!.fromModel, isTrue);
    expect(guide.summary, contains('종합 40점'));
    expect(guide.boundary, DiagnosisConfig.boundaryText);
    expect(guide.actions.single.domain, 'life');
  });

  test('입양 가능 여부를 단정한 응답은 버린다', () {
    final body = jsonEncode({
      'candidates': [
        {
          'content': {
            'parts': [
              {
                'text': jsonEncode({
                  'summary': '입양 가능합니다.',
                  'actions': [
                    {'domain': 'life', 'text': '그대로 진행하세요.'},
                  ],
                  'housingNote': '주거는 괜찮습니다.',
                  'boundary': DiagnosisConfig.boundaryText,
                }),
              },
            ],
          },
        },
      ],
    });

    expect(tryParseGeminiResponse(body), isNull);
  });
}
