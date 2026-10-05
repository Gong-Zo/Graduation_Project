import 'dart:convert';

import 'package:http/http.dart' as http;

import '../diagnosis_config.dart';
import '../readiness_result.dart';
import 'local_api_key.dart';
import 'readiness_guide.dart';

class GeminiGuideException implements Exception {
  const GeminiGuideException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeminiGuideClient {
  GeminiGuideClient({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      apiKey = apiKey ?? _storedApiKey;

  static const _envApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _storedApiKey = _envApiKey != ''
      ? _envApiKey
      : localGeminiApiKey;

  final http.Client _client;
  final String apiKey;

  static const model = 'gemini-2.5-flash';

  bool get hasApiKey => apiKey.isNotEmpty;

  Future<ReadinessGuide> explain(ReadinessResult result) async {
    if (!hasApiKey) {
      throw const GeminiGuideException('Gemini API 키가 없습니다.');
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );
    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': buildGuidePrompt(result)},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.2,
              'responseMimeType': 'application/json',
              'responseSchema': {
                'type': 'OBJECT',
                'properties': {
                  'summary': {'type': 'STRING'},
                  'actions': {
                    'type': 'ARRAY',
                    'items': {
                      'type': 'OBJECT',
                      'properties': {
                        'domain': {'type': 'STRING'},
                        'text': {'type': 'STRING'},
                      },
                      'required': ['domain', 'text'],
                    },
                  },
                  'housingNote': {'type': 'STRING'},
                  'boundary': {'type': 'STRING'},
                },
                'required': ['summary', 'actions', 'housingNote', 'boundary'],
                'propertyOrdering': [
                  'summary',
                  'actions',
                  'housingNote',
                  'boundary',
                ],
              },
            },
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw GeminiGuideException('Gemini 호출에 실패했습니다. (${response.statusCode})');
    }

    final guide = tryParseGeminiResponse(response.body);
    if (guide == null) {
      throw const GeminiGuideException('Gemini 응답을 결과 안내로 사용할 수 없습니다.');
    }
    return guide;
  }
}

String buildGuidePrompt(ReadinessResult result) {
  final payload = jsonEncode(result.toGuideJson());
  return '''
너는 1인 가구 예비 반려인의 반려견 준비도 결과를 설명하는 안내자다.
아래 JSON의 점수, 라벨, 경고만 한국어로 설명한다.
종합 점수와 영역 점수를 바꾸거나 다시 계산하지 않는다.
입양 가능 또는 입양 불가라고 단정하지 않는다.
주거 점수는 종합 점수에 포함되지 않은 참고 점수로만 말한다.
practice가 null이면 7일 기록을 언급하지 않는다.
practice가 있으면 적힌 분과 점수, careClaim만 사용한다.
observedCarePoints는 참고값이며 종합 점수에 더하거나 빼지 않는다.
boundary는 반드시 "${DiagnosisConfig.boundaryText}"로 둔다.

입력:
$payload
''';
}

ReadinessGuide? tryParseGeminiResponse(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;
    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final content = candidates.first;
    if (content is! Map<String, dynamic>) return null;
    final contentMap = content['content'];
    if (contentMap is! Map<String, dynamic>) return null;
    final parts = contentMap['parts'];
    if (parts is! List || parts.isEmpty) return null;
    final firstPart = parts.first;
    if (firstPart is! Map<String, dynamic>) return null;
    final text = firstPart['text'];
    if (text is! String || text.trim().isEmpty) return null;
    return tryParseGuideJson(text);
  } on FormatException {
    return null;
  }
}

ReadinessGuide? tryParseGuideJson(String text) {
  try {
    final trimmed = text.trim();
    final jsonText = trimmed.startsWith('```')
        ? trimmed.replaceAll(RegExp(r'^```(?:json)?|```$'), '').trim()
        : trimmed;
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) return null;

    final summary = decoded['summary'];
    final housingNote = decoded['housingNote'];
    final actionsJson = decoded['actions'];
    if (summary is! String || summary.trim().isEmpty) return null;
    if (housingNote is! String || housingNote.trim().isEmpty) return null;
    if (actionsJson is! List) return null;

    final actions = <GuideAction>[];
    for (final item in actionsJson) {
      if (item is! Map<String, dynamic>) return null;
      final domain = item['domain'];
      final actionText = item['text'];
      if (domain is! String || actionText is! String) return null;
      if (domain.trim().isEmpty || actionText.trim().isEmpty) return null;
      actions.add(GuideAction(domain: domain.trim(), text: actionText.trim()));
    }

    final spoken = [
      summary,
      housingNote,
      for (final action in actions) action.text,
    ].join('\n');
    if (_statesAdoptionVerdict(spoken)) return null;

    return ReadinessGuide(
      summary: summary.trim(),
      actions: actions,
      housingNote: housingNote.trim(),
      boundary: DiagnosisConfig.boundaryText,
      fromModel: true,
    );
  } on FormatException {
    return null;
  }
}

bool _statesAdoptionVerdict(String text) {
  return text.contains('입양 불가') || text.contains('입양 가능');
}
