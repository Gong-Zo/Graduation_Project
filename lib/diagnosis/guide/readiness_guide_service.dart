/// Gemini가 없거나 실패하면 로컬 FallbackGuide로 같은 점수를 설명한다.
import '../readiness_result.dart';
import 'fallback_guide.dart';
import 'gemini_guide_client.dart';
import 'readiness_guide.dart';

/// 진단 화면이 호출하는 안내 진입점.
class ReadinessGuideService {
  ReadinessGuideService({GeminiGuideClient? client, FallbackGuide? fallback})
    : _client = client ?? GeminiGuideClient(),
      _fallback = fallback ?? const FallbackGuide();

  final GeminiGuideClient _client;
  final FallbackGuide _fallback;

  Future<ReadinessGuide> explain(ReadinessResult result) async {
    if ((await _client.resolvedApiKey()).isEmpty) {
      return _fallback.build(result);
    }
    try {
      return await _client.explain(result);
    } on GeminiGuideException {
      return _fallback.build(result);
    } catch (_) {
      return _fallback.build(result);
    }
  }
}
