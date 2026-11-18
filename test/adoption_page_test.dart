import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/abandonment_api_client.dart';
import 'package:flutter_application_1/ui/adoption_list_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('보호동물 목록에서 상세정보로 이동한다', (tester) async {
    final api = AbandonmentApiClient(
      serviceKey: 'test-key',
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'response': {
              'header': {'resultCode': '00'},
              'body': {
                'items': {
                  'item': {
                    'noticeNo': '20261117001',
                    'kindNm': '믹스견',
                    'age': '2024(년생)',
                    'sexCd': 'F',
                    'processState': '보호중',
                    'careNm': '행복 보호소',
                    'careAddr': '서울시 강남구',
                    'popfile1': '',
                    'happenDt': '20261110',
                  },
                },
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    await tester.pumpWidget(MaterialApp(home: AdoptionListPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('믹스견'), findsOneWidget);
    await tester.tap(find.text('상세 정보 보기  ›'));
    await tester.pumpAndSettle();

    expect(find.text('보호동물 상세정보'), findsOneWidget);
    expect(find.text('2026.11.10'), findsOneWidget);
    expect(find.text('행복 보호소'), findsOneWidget);
    expect(find.text('서울시 강남구'), findsOneWidget);
  });

  testWidgets('API 키가 없으면 키 설정 안내를 표시한다', (tester) async {
    final api = AbandonmentApiClient(
      serviceKey: '',
      client: MockClient((request) async {
        fail('API 키가 없을 때 요청하면 안 됩니다.');
      }),
    );

    await tester.pumpWidget(MaterialApp(home: AdoptionListPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.textContaining('공공데이터 API 키를 설정'), findsOneWidget);
  });
}
