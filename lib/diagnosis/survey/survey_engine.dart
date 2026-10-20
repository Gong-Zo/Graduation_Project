import 'survey_response.dart';
import 'survey_scorer.dart';

/// 최종 60문항 준비도 엔진. 7일 미션은 이 점수를 바꾸지 않는다.
class SurveyEngine {
  const SurveyEngine();

  SurveyScore evaluate(SurveyResponse response) {
    return SurveyScorer.score(response);
  }
}
