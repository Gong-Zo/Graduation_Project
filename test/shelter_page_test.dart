/// 공공데이터 보호소 목록·상세. 실제 네트워크는 MockClient로 막는다.
import 'dart:convert' show jsonEncode, utf8;

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/abandonment_api_client.dart';
import 'package:flutter_application_1/ui/adoption/shelter_list_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String _ok({required Object item}) => jsonEncode({
  'response': {
    'header': {'resultCode': '00', 'resultMsg': 'NORMAL SERVICE.'},
    'body': {
      'items': {'item': item},
    },
  },
});

void main() {
  test('보호소 JSON에서 전화·주소를 읽는다', () {
    final shelters = parseAnimalShelters(
      _ok(
        item: {
          'careRegNo': '311322200900001',
          'careNm': '서울 동물보호소',
          'careAddr': '서울특별시 강남구 1',
          'careTel': '02-123-4567',
          'weekOprStime': '09:00',
          'weekOprEtime': '18:00',
          'closeDay': '일요일',
        },
      ),
    );
    expect(shelters.single.id, '311322200900001');
    expect(shelters.single.phone, '02-123-4567');
    expect(shelters.single.weekdayHours, '09:00 ~ 18:00');
  });

  test('같은 보호소가 여러 줄이면 하나로 합친다', () {
    final item = {
      'careRegNo': 'S-1',
      'careNm': '신공항동물병원',
      'careAddr': '인천광역시 중구',
      'careTel': '032-751-4598',
    };
    final shelters = parseAnimalShelters(
      jsonEncode({
        'response': {
          'header': {'resultCode': '00'},
          'body': {
            'items': {
              'item': [item, item, item, item],
            },
          },
        },
      }),
    );
    expect(shelters, hasLength(1));
    expect(shelters.single.name, '신공항동물병원');
  });

  testWidgets('보호소를 검색하면 목록에서 상세로 들어간다', (tester) async {
    final api = AbandonmentApiClient(
      serviceKey: 'test-key',
      client: MockClient((request) async {
        final path = request.url.path;
        http.Response jsonOk(Object item) {
          return http.Response.bytes(
            utf8.encode(_ok(item: item)),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        if (path.contains('sido_v2')) {
          return jsonOk({'orgCd': '6110000', 'orgdownNm': '서울특별시'});
        }
        if (path.contains('sigungu_v2')) {
          return jsonOk({'orgCd': '3220000', 'orgdownNm': '강남구'});
        }
        if (path.contains('shelter_v2')) {
          return jsonOk({
            'careRegNo': 'S-1',
            'careNm': '강남 동물보호센터',
          });
        }
        return jsonOk({
          'noticeNo': 'N-1',
          'kindNm': '믹스견',
          'sexCd': 'M',
          'careRegNo': 'S-1',
          'careNm': '강남 동물보호센터',
          'careAddr': '서울특별시 강남구',
          'careTel': '02-000-0000',
        });
      }),
    );

    await tester.pumpWidget(MaterialApp(home: ShelterListPage(api: api)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shelterCard_S-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('shelterCard_S-1')));
    await tester.pumpAndSettle();
    expect(find.text('보호소 상세정보'), findsOneWidget);
    expect(find.text('02-000-0000'), findsOneWidget);
  });
}
