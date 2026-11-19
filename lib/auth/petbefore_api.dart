/// FastAPI 호출. 토큰은 로그인 후 여기에만 둔다.
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../diagnosis/survey/survey_record.dart';
import '../mypage/member_library_store.dart';
import 'api_config.dart';
import 'auth_exception.dart';
import 'auth_models.dart';

class PetbeforeApi {
  PetbeforeApi({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? petbeforeApiBase(),
      _client = client ?? http.Client();

  /// 앱 전역. 로그인하면 토큰을 여기 남긴다.
  static PetbeforeApi instance = PetbeforeApi();

  final String baseUrl;
  final http.Client _client;
  String? accessToken;

  bool get isConfigured => baseUrl.isNotEmpty;

  Future<AuthUser> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final json = await _post('/auth/register', {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    return _readAuth(json);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final json = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return _readAuth(json);
  }

  Future<AuthUser> me() async {
    final json = await _get('/auth/me');
    return AuthUser.fromJson(Map<String, Object?>.from(json['user'] as Map));
  }

  Future<List<SurveyRecord>> loadSurveys() async {
    final json = await _get('/surveys');
    final items = json['records'] as List<dynamic>? ?? const [];
    return [
      for (final item in items)
        if (item is Map)
          SurveyRecord.fromJson(Map<String, Object?>.from(item)),
    ];
  }

  Future<SurveyRecord> saveSurvey(SurveyRecord record) async {
    final json = await _post('/surveys', {'record': record.toJson()});
    return SurveyRecord.fromJson(
      Map<String, Object?>.from(json['record'] as Map),
    );
  }

  Future<MemberLibrary> loadLibrary() async {
    final json = await _get('/library');
    final raw = json['library'];
    if (raw is! Map || raw.isEmpty) return const MemberLibrary();
    return MemberLibrary.fromJson(Map<String, Object?>.from(raw));
  }

  Future<void> saveLibrary(MemberLibrary library) {
    return _put('/library', {'library': library.toJson()});
  }

  AuthUser _readAuth(Map<String, Object?> json) {
    accessToken = json['token'] as String?;
    return AuthUser.fromJson(Map<String, Object?>.from(json['user'] as Map));
  }

  Future<Map<String, Object?>> _get(String path) async {
    return _send(() => _client.get(_uri(path), headers: _headers()));
  }

  Future<Map<String, Object?>> _post(String path, Map<String, Object?> body) {
    return _send(
      () => _client.post(
        _uri(path),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  Future<void> _put(String path, Map<String, Object?> body) async {
    await _send(
      () => _client.put(
        _uri(path),
        headers: _headers(jsonBody: true),
        body: jsonEncode(body),
      ),
    );
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers({bool jsonBody = false}) {
    return {
      if (jsonBody) 'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  Future<Map<String, Object?>> _send(
    Future<http.Response> Function() request,
  ) async {
    if (!isConfigured) {
      throw const AuthException('서버 주소가 없습니다.');
    }
    late http.Response response;
    try {
      response = await request().timeout(const Duration(milliseconds: 1500));
    } on TimeoutException {
      throw const AuthException('서버에 연결하지 못했습니다.');
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('서버에 연결하지 못했습니다.');
    }
    Map<String, Object?> decoded = const {};
    if (response.body.isNotEmpty) {
      final raw = jsonDecode(response.body);
      if (raw is Map) decoded = Map<String, Object?>.from(raw);
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final detail = decoded['detail'];
    throw AuthException(
      detail is String ? detail : '서버가 요청을 거절했습니다. (${response.statusCode})',
    );
  }
}

/// 연결 실패인지. 잘못된 비밀번호는 여기 넣지 않는다.
bool isPetbeforeNetworkError(Object error) {
  if (error is! AuthException) return false;
  return error.message.contains('연결하지');
}
