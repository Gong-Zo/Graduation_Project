import 'dart:convert';

import 'package:http/http.dart' as http;

import '../diagnosis/guide/local_api_key.dart';
import 'rescued_dog.dart';

class AbandonmentApiException implements Exception {
  const AbandonmentApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AbandonmentApiClient {
  AbandonmentApiClient({http.Client? client, String? serviceKey})
    : _client = client ?? http.Client(),
      _serviceKey = serviceKey ?? localDataGoKrServiceKey;

  final http.Client _client;
  final String _serviceKey;

  static final _endpoint = Uri.parse(
    'https://apis.data.go.kr/1543061/abandonmentPublicService_v2/abandonmentPublic_v2',
  );

  Future<List<RescuedDog>> fetchRecentDogs({
    int days = 30,
    int rows = 8,
  }) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    final response = await _client
        .get(
          _endpoint.replace(
            queryParameters: {
              'serviceKey': _serviceKey,
              '_type': 'json',
              'upkind': '417000',
              'pageNo': '1',
              'numOfRows': '$rows',
              'bgnde': _ymd(start),
              'endde': _ymd(end),
            },
          ),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw AbandonmentApiException(
        '구조동물 조회에 실패했습니다. (${response.statusCode})',
      );
    }
    return parseRescuedDogs(response.body);
  }

  static String _ymd(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}$month$day';
  }
}

List<RescuedDog> parseRescuedDogs(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const AbandonmentApiException('구조동물 응답 형식이 올바르지 않습니다.');
  }
  final response = decoded['response'];
  if (response is! Map<String, dynamic>) {
    throw const AbandonmentApiException('구조동물 응답 형식이 올바르지 않습니다.');
  }
  final header = response['header'];
  if (header is Map<String, dynamic>) {
    final code = '${header['resultCode']}';
    if (code != '00') {
      final message = header['resultMsg'] as String? ?? '구조동물 조회에 실패했습니다.';
      throw AbandonmentApiException(message);
    }
  }

  final bodyMap = response['body'];
  if (bodyMap is! Map<String, dynamic>) return const [];
  final items = bodyMap['items'];
  if (items is! Map<String, dynamic>) return const [];
  final item = items['item'];
  final rows = switch (item) {
    List<dynamic> list => list,
    Map<String, dynamic> one => [one],
    _ => const <dynamic>[],
  };

  return [
    for (final row in rows)
      if (row is Map<String, dynamic>)
        RescuedDog(
          noticeNo: row['noticeNo'] as String? ?? '',
          breedName: row['kindNm'] as String? ?? '',
          age: row['age'] as String? ?? '',
          sex: row['sexCd'] as String? ?? '',
          processState: row['processState'] as String? ?? '',
          shelterName: row['careNm'] as String? ?? '',
          shelterAddress: (row['careAddr'] as String? ?? '').trim(),
          imageUrl: row['popfile1'] as String? ?? '',
          foundDate: row['happenDt'] as String? ?? '',
        ),
  ];
}
