import '../readiness_result.dart';
import 'fallback_guide.dart';
import 'gemini_guide_client.dart';
import 'readiness_guide.dart';

class ReadinessGuideService {
  ReadinessGuideService({GeminiGuideClient? client, FallbackGuide? fallback})
    : _client = client ?? GeminiGuideClient(),
      _fallback = fallback ?? const FallbackGuide();

  final GeminiGuideClient _client;
  final FallbackGuide _fallback;

  Future<ReadinessGuide> explain(ReadinessResult result) async {
    if (!_client.hasApiKey) {
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
