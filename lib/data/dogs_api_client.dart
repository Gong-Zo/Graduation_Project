import 'dart:convert';

import 'package:http/http.dart' as http;

import '../diagnosis/guide/local_api_key.dart';
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
      _apiKey = apiKey ?? localApiNinjasKey;

  final http.Client _client;
  final String _apiKey;

  static final _endpoint = Uri.parse('https://api.api-ninjas.com/v1/dogs');

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

    final response = await _client
        .get(
          _endpoint.replace(queryParameters: query),
          headers: {'X-Api-Key': _apiKey},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw DogsApiException('견종 조회에 실패했습니다. (${response.statusCode})');
    }
    return parseDogBreeds(response.body);
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
