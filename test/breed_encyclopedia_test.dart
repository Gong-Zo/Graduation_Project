/// 견종백과 연결: 있는 견종만 영상이 붙는다.
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/breed_encyclopedia.dart';
import 'package:flutter_application_1/data/dogs_api_client.dart';
import 'package:flutter_application_1/diagnosis/care_profile.dart';
import 'package:flutter_application_1/ui/linked_data_panel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('제목의 견종명으로 해당 편만 붙는다', () {
    final maltese = encyclopediaVideosFor('Maltese');
    expect(maltese, isNotEmpty);
    expect(maltese.every((v) => v.title.contains('말티즈')), isTrue);
    expect(encyclopediaVideosFor('Poodle').every((v) => v.title.contains('푸들')), isTrue);
    expect(encyclopediaVideosFor('Poodle'), isNotEmpty);
    expect(
      encyclopediaVideosFor('German Shepherd Dog')
          .any((v) => v.title.contains('저먼셰퍼드') || v.title.contains('군견')),
      isTrue,
    );
    expect(
      encyclopediaVideosFor('Australian Shepherd')
          .every((v) => v.title.contains('오스트레일리안')),
      isTrue,
    );
    expect(encyclopediaVideosFor('Unknown Terrier Mix'), isEmpty);
  });

  testWidgets('추천 견종 이름을 누르면 정보 창과 견종백과 영상이 뜬다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final opened = <Uri>[];
    final api = DogsApiClient(
      apiKey: 'test',
      client: MockClient((request) async {
        return http.Response(
          '''
          [{
            "name": "Maltese",
            "image_link": "",
            "energy": 3,
            "barking": 2,
            "shedding": 1,
            "grooming": 3,
            "trainability": 4
          }]
          ''',
          200,
        );
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LinkedDataPanel(
              profile: const CareProfile(
                housingType: HousingType.apartment,
                petPolicy: PetPolicy.allowed,
                walkAccess: true,
                noiseSensitive: false,
                absenceHours: 6,
                careMinutes: 70,
                outingDaysPerWeek: 3,
                monthlyBudgetKrw: 200000,
                canCoverInitialCost: true,
                emergencyFund: EmergencyFund.ready,
                incomeShockCapacity: IncomeShockCapacity.canMaintain,
                hasLongTermPlan: true,
                hasCareContinuity: true,
                allergy: AllergyLevel.none,
              ),
              dogsApi: api,
              openUrl: (uri) async {
                opened.add(uri);
                return true;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maltese (말티즈)'), findsOneWidget);
    await tester.tap(find.text('Maltese (말티즈)'));
    await tester.pumpAndSettle();

    expect(find.text('강형욱의 견종백과'), findsOneWidget);
    expect(find.textContaining('견종백과 말티즈편'), findsWidgets);

    await tester.tap(find.textContaining('견종백과 말티즈편').first);
    await tester.pumpAndSettle();
    expect(opened.single.toString(), contains('9xFqDi0HOq8'));
  });
}
