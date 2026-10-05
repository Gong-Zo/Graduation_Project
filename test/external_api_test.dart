import 'dart:convert';

import 'package:flutter_application_1/data/abandonment_api_client.dart';
import 'package:flutter_application_1/data/breed_match.dart';
import 'package:flutter_application_1/data/dog_breed.dart';
import 'package:flutter_application_1/data/dogs_api_client.dart';
import 'package:flutter_application_1/diagnosis/care_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('견종 JSON을 특성과 함께 읽는다', () {
    final breeds = parseDogBreeds(
      jsonEncode([
        {
          'name': 'Golden Retriever',
          'image_link': 'https://example.com/dog.jpg',
          'energy': 3,
          'barking': 1,
          'shedding': 4,
          'grooming': 2,
          'trainability': 5,
        },
      ]),
    );

    expect(breeds.single.name, 'Golden Retriever');
    expect(breeds.single.energy, 3);
  });

  test('부재가 길고 소음에 취약하면 낮은 활동량과 낮은 짖음을 앞에 둔다', () {
    final preference = BreedPreference.fromProfile(
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
    const calm = DogBreed(
      name: 'Cavalier',
      imageLink: '',
      energy: 2,
      barking: 1,
      shedding: 2,
      grooming: 2,
      trainability: 4,
    );
    const loud = DogBreed(
      name: 'Husky',
      imageLink: '',
      energy: 2,
      barking: 5,
      shedding: 5,
      grooming: 3,
      trainability: 3,
    );

    final ranked = rankBreeds([loud, calm], preference);

    expect(preference.energy, 2);
    expect(preference.maxBarking, 2);
    expect(ranked.first.name, 'Cavalier');
    expect(breedMatchNotes(calm, preference), ['자가점검 조건에 맞습니다.']);
    expect(
      breedMatchNotes(loud, preference),
      contains('짖음 수준이 높아 소음에 취약한 환경과 맞지 않습니다.'),
    );
  });

  test('구조동물 JSON에서 한 건과 여러 건을 읽는다', () {
    final many = parseRescuedDogs(
      jsonEncode({
        'response': {
          'header': {'resultCode': '00', 'resultMsg': 'NORMAL SERVICE.'},
          'body': {
            'items': {
              'item': [
                {
                  'noticeNo': 'A-1',
                  'kindNm': '믹스견',
                  'age': '2024(년생)',
                  'sexCd': 'M',
                  'processState': '보호중',
                  'careNm': '보호소',
                  'careAddr': '서울시 ',
                  'popfile1': 'https://example.com/a.jpg',
                  'happenDt': '20261004',
                },
              ],
            },
          },
        },
      }),
    );

    expect(many.single.breedName, '믹스견');
    expect(many.single.sexLabel, '수컷');
    expect(many.single.shelterAddress, '서울시');

    final one = parseRescuedDogs(
      jsonEncode({
        'response': {
          'header': {'resultCode': '00'},
          'body': {
            'items': {
              'item': {'noticeNo': 'B-1', 'kindNm': '푸들', 'sexCd': 'F'},
            },
          },
        },
      }),
    );
    expect(one.single.breedName, '푸들');
    expect(one.single.sexLabel, '암컷');
  });

  test('구조동물 API 오류 코드는 예외로 돌린다', () {
    expect(
      () => parseRescuedDogs(
        jsonEncode({
          'response': {
            'header': {'resultCode': '30', 'resultMsg': 'SERVICE KEY ERROR'},
          },
        }),
      ),
      throwsA(
        isA<AbandonmentApiException>().having(
          (error) => error.message,
          'message',
          'SERVICE KEY ERROR',
        ),
      ),
    );
  });
}
