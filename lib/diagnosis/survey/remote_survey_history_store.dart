/// 자가점검 기록을 기기에 남기고, 로그인이면 MariaDB에도 올린다.
import '../../auth/petbefore_api.dart';
import 'survey_history_store.dart';
import 'survey_record.dart';

class RemoteSurveyHistoryStore implements SurveyHistoryStore {
  RemoteSurveyHistoryStore(this._local, {PetbeforeApi? api})
    : _api = api ?? PetbeforeApi.instance;

  final SurveyHistoryStore _local;
  final PetbeforeApi _api;

  @override
  Future<List<SurveyRecord>> load(String userId) async {
    if (_api.isConfigured && _api.accessToken != null) {
      try {
        final remote = await _api.loadSurveys();
        for (final record in remote) {
          await _local.save(record);
        }
      } catch (_) {
        // 오프라인이면 기기 목록만 보여 준다.
      }
    }
    return _local.load(userId);
  }

  @override
  Future<SurveyRecord> save(SurveyRecord record) async {
    final saved = await _local.save(record);
    if (_api.isConfigured && _api.accessToken != null) {
      try {
        return await _api.saveSurvey(saved);
      } catch (_) {
        return saved;
      }
    }
    return saved;
  }
}

SurveyHistoryStore defaultSurveyHistoryStore() {
  return RemoteSurveyHistoryStore(LocalSurveyHistoryStore());
}
