/// 공공데이터 유기동물·보호센터 API. 키가 비면 빈 목록만 돌려준다.
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../diagnosis/guide/local_api_key.dart';
import '../diagnosis/guide/local_key_file.dart';
import 'animal_shelter.dart';
import 'rescued_dog.dart';

class AbandonmentApiException implements Exception {
  const AbandonmentApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 개는 upkind 417000. 테스트는 serviceKey를 넘겨 실제 키 파일을 읽지 않는다.
class AbandonmentApiClient {
  AbandonmentApiClient({http.Client? client, String? serviceKey})
    : _client = client ?? http.Client(),
      _serviceKey = serviceKey?.trim();

  final http.Client _client;
  final String? _serviceKey;

  static const _envServiceKey = String.fromEnvironment(
    'DATA_GO_KR_SERVICE_KEY',
  );

  static final _dogEndpoint = Uri.parse(
    'https://apis.data.go.kr/1543061/abandonmentPublicService_v2/abandonmentPublic_v2',
  );
  static final _sidoEndpoint = Uri.parse(
    'https://apis.data.go.kr/1543061/abandonmentPublicService_v2/sido_v2',
  );
  static final _sigunguEndpoint = Uri.parse(
    'https://apis.data.go.kr/1543061/abandonmentPublicService_v2/sigungu_v2',
  );
  static final _shelterEndpoint = Uri.parse(
    'https://apis.data.go.kr/1543061/animalShelterSrvc_v2/shelterInfo_v2',
  );

  /// 공공데이터 키가 없어도 앱은 실행된다. 조회만 생략한다.
  bool get isConfigured => _serviceKey == null
      ? localDataGoKrServiceKey.trim().isNotEmpty ||
            _envServiceKey.trim().isNotEmpty
      : _serviceKey.isNotEmpty;

  Future<String> _resolvedKey() async {
    if (_serviceKey != null) return _serviceKey;
    if (localDataGoKrServiceKey.trim().isNotEmpty) {
      return localDataGoKrServiceKey.trim();
    }
    if (_envServiceKey.trim().isNotEmpty) return _envServiceKey.trim();
    return readLocalApiKey('localDataGoKrServiceKey');
  }

  Future<List<RescuedDog>> fetchRecentDogs({
    int days = 30,
    int rows = 8,
    String? careRegNo,
  }) async {
    final key = await _resolvedKey();
    if (key.isEmpty) return const [];

    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return parseRescuedDogs(
      await _get(_dogEndpoint, {
        'serviceKey': key,
        '_type': 'json',
        'upkind': '417000',
        'pageNo': '1',
        'numOfRows': '$rows',
        'bgnde': _ymd(start),
        'endde': _ymd(end),
        if (careRegNo != null && careRegNo.isNotEmpty) 'care_reg_no': careRegNo,
      }, '구조동물'),
    );
  }

  Future<List<RegionCode>> fetchSido() async {
    final key = await _resolvedKey();
    if (key.isEmpty) return const [];
    return parseRegionCodes(
      await _get(_sidoEndpoint, {
        'serviceKey': key,
        '_type': 'json',
        'numOfRows': '20',
        'pageNo': '1',
      }, '시도'),
    );
  }

  Future<List<RegionCode>> fetchSigungu(String uprCd) async {
    final key = await _resolvedKey();
    if (key.isEmpty || uprCd.isEmpty) return const [];
    return parseRegionCodes(
      await _get(_sigunguEndpoint, {
        'serviceKey': key,
        '_type': 'json',
        'upr_cd': uprCd,
        'numOfRows': '50',
        'pageNo': '1',
      }, '시군구'),
    );
  }

  Future<List<AnimalShelter>> fetchShelters({
    String? uprCd,
    String? orgCd,
    String? name,
    int rows = 50,
  }) async {
    final key = await _resolvedKey();
    if (key.isEmpty) return const [];
    return parseAnimalShelters(
      await _get(_shelterEndpoint, {
        'serviceKey': key,
        '_type': 'json',
        'numOfRows': '$rows',
        'pageNo': '1',
        if (uprCd != null && uprCd.isNotEmpty) 'upr_cd': uprCd,
        if (orgCd != null && orgCd.isNotEmpty) 'org_cd': orgCd,
        if (name != null && name.trim().isNotEmpty) 'care_nm': name.trim(),
      }, '보호소'),
    );
  }

  Future<String> _get(
    Uri endpoint,
    Map<String, String> query,
    String label,
  ) async {
    final response = await _client
        .get(endpoint.replace(queryParameters: query))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw AbandonmentApiException('$label 조회에 실패했습니다. (${response.statusCode})');
    }
    return response.body;
  }

  static String _ymd(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}$month$day';
  }
}

List<dynamic> dataGoKrRows(String body, String label) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw AbandonmentApiException('$label 응답 형식이 올바르지 않습니다.');
  }
  final response = decoded['response'];
  if (response is! Map<String, dynamic>) {
    throw AbandonmentApiException('$label 응답 형식이 올바르지 않습니다.');
  }
  final header = response['header'];
  if (header is Map<String, dynamic>) {
    final code = '${header['resultCode']}';
    if (code != '00') {
      final message = header['resultMsg'] as String? ?? '$label 조회에 실패했습니다.';
      throw AbandonmentApiException(message);
    }
  }
  final bodyMap = response['body'];
  if (bodyMap is! Map<String, dynamic>) return const [];
  final items = bodyMap['items'];
  if (items == null || items == '') return const [];
  if (items is! Map<String, dynamic>) return const [];
  final item = items['item'];
  return switch (item) {
    List<dynamic> list => list,
    Map<String, dynamic> one => [one],
    _ => const <dynamic>[],
  };
}

String _field(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value == null) return '';
  return '$value'.trim();
}

String _hours(Map<String, dynamic> row, String startKey, String endKey) {
  final start = _field(row, startKey);
  final end = _field(row, endKey);
  if (start.isEmpty && end.isEmpty) return '';
  if (end.isEmpty) return start;
  if (start.isEmpty) return end;
  return '$start ~ $end';
}

/// 공공데이터 JSON의 items를 RescuedDog 목록으로 바꾼다.
List<RescuedDog> parseRescuedDogs(String body) {
  return [
    for (final row in dataGoKrRows(body, '구조동물'))
      if (row is Map<String, dynamic>)
        RescuedDog(
          noticeNo: _field(row, 'noticeNo'),
          breedName: _field(row, 'kindNm'),
          age: _field(row, 'age'),
          sex: _field(row, 'sexCd'),
          processState: _field(row, 'processState'),
          shelterName: _field(row, 'careNm'),
          shelterAddress: _field(row, 'careAddr'),
          imageUrl: _field(row, 'popfile1'),
          foundDate: _field(row, 'happenDt'),
        ),
  ];
}

List<RegionCode> parseRegionCodes(String body) {
  return [
    for (final row in dataGoKrRows(body, '지역'))
      if (row is Map<String, dynamic>)
        RegionCode(code: _field(row, 'orgCd'), name: _field(row, 'orgdownNm')),
  ];
}

List<AnimalShelter> parseAnimalShelters(String body) {
  return [
    for (final row in dataGoKrRows(body, '보호소'))
      if (row is Map<String, dynamic>)
        AnimalShelter(
          id: _field(row, 'careRegNo').isEmpty
              ? _field(row, 'careNm')
              : _field(row, 'careRegNo'),
          name: _field(row, 'careNm'),
          address: _field(row, 'careAddr').isEmpty
              ? _field(row, 'jibunAddr')
              : _field(row, 'careAddr'),
          jibunAddress: _field(row, 'jibunAddr'),
          phone: _field(row, 'careTel'),
          orgName: _field(row, 'orgNm'),
          divisionName: _field(row, 'divisionNm'),
          saveTarget: _field(row, 'saveTrgtAnimal'),
          weekdayHours: _hours(row, 'weekOprStime', 'weekOprEtime'),
          weekendHours: _hours(row, 'weekendOprStime', 'weekendOprEtime'),
          closeDay: _field(row, 'closeDay'),
        ),
  ];
}
