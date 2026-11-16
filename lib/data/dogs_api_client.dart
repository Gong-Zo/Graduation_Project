import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../diagnosis/guide/local_api_key.dart';
import '../diagnosis/guide/local_key_file.dart';
import 'dog_breed.dart';

class DogsApiException implements Exception {
  const DogsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DogsApiClient {
  DogsApiClient({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey?.trim();

  final http.Client _client;
  final String? _apiKey;

  static const missingKeyMessage =
      'Dogs API 키가 없습니다. lib/diagnosis/guide/local_api_key.example.dart를 복사해 local_api_key.dart로 저장하고, API Ninjas 키를 localApiNinjasKey에 넣으세요.';

  static final _endpoint = Uri.parse('https://api.api-ninjas.com/v1/dogs');

  Future<String> _resolvedKey() async {
    if (_apiKey != null) return _apiKey!;
    if (localApiNinjasKey.trim().isNotEmpty) return localApiNinjasKey.trim();
    const env = String.fromEnvironment('API_NINJAS_KEY');
    if (env.isNotEmpty) return env;
    return readLocalApiKey('localApiNinjasKey');
  }

  Future<List<DogBreed>> search({
    String? name,
    int? energy,
    int? barking,
  }) async {
    final query = <String, String>{};
    if (name != null && name.trim().isNotEmpty) query['name'] = name.trim();
    if (energy != null) query['energy'] = '$energy';
    if (barking != null) query['barking'] = '$barking';
    if (query.isEmpty) {
      throw const DogsApiException('견종 이름 또는 활동량 조건이 필요합니다.');
    }

    final key = await _resolvedKey();
    if (key.isEmpty) {
      throw const DogsApiException(missingKeyMessage);
    }

    final http.Response response;
    try {
      response = await _client
          .get(
            _endpoint.replace(queryParameters: query),
            headers: {'X-Api-Key': key},
          )
          .timeout(const Duration(seconds: 20));
    } on http.ClientException catch (error) {
      throw DogsApiException(_networkMessage(error));
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const DogsApiException(
        'Dogs API 키가 거부되었습니다. api-ninjas.com에서 본인 키를 받아 local_api_key.dart의 localApiNinjasKey에 넣으세요.',
      );
    }
    if (response.statusCode != 200) {
      throw DogsApiException('견종 조회에 실패했습니다. (${response.statusCode})');
    }
    return parseDogBreeds(response.body);
  }

  static String _networkMessage(Object error) {
    if (kIsWeb) {
      return '웹 브라우저에서는 Dogs API가 보안(CORS)으로 막힐 수 있습니다. Windows에서 앱을 실행하세요. ($error)';
    }
    return '견종 조회 네트워크 오류: $error';
  }
}

List<DogBreed> parseDogBreeds(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) {
    throw const DogsApiException('견종 응답 형식이 올바르지 않습니다.');
  }
  return [
    for (final item in decoded)
      if (item is Map<String, dynamic>) DogBreed.fromJson(item),
  ];
}
