/// 로그인한 회원의 자가점검 기록 목록. 점수는 다시 계산하지 않는다.
import 'package:flutter/material.dart';

import '../../auth/auth_scope.dart';
import '../../diagnosis/survey/survey_history_store.dart';
import '../../diagnosis/survey/survey_record.dart';
import '../diagnosis/diagnosis_detail_page.dart';
import '../diagnosis/survey_intro_page.dart';
import '../shared/feature_screen.dart';

class DiagnosisHistoryPage extends StatefulWidget {
  const DiagnosisHistoryPage({super.key, this.historyStore});

  final SurveyHistoryStore? historyStore;

  @override
  State<DiagnosisHistoryPage> createState() => _DiagnosisHistoryPageState();
}

class _DiagnosisHistoryPageState extends State<DiagnosisHistoryPage> {
  List<SurveyRecord> _records = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final userId = AuthScope.maybeOf(context)?.session?.user?.id;
    if (userId == null) {
      setState(() {
        _records = const [];
        _loading = false;
      });
      return;
    }
    try {
      final records = await (widget.historyStore ?? defaultSurveyHistoryStore())
          .load(userId);
      if (!mounted) return;
      setState(() {
        _records = records;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _records = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('진단 기록·최종 리포트')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_records.isEmpty) {
      return FeatureScreen(
        title: '진단 기록·최종 리포트',
        description: '완료한 자가점검과 영역별 리포트를 확인하는 곳이에요.',
        icon: Icons.history,
        children: [
          const FeatureInfoCard(
            title: '저장된 진단 기록이 없어요',
            description: '자가점검을 완료하면 이 계정에 종합 점수와 영역 점수가 남습니다.',
            icon: Icons.inbox_outlined,
          ),
          const SizedBox(height: 8),
          FeatureMenuCard(
            title: '자가점검 시작하기',
            description: '현재의 생활과 준비 상태를 점검해 보세요.',
            icon: Icons.fact_check_outlined,
            page: const SurveyIntroPage(),
          ),
        ],
      );
    }

    return FeatureScreen(
      title: '진단 기록·최종 리포트',
      description: '최근에 완료한 자가점검부터 보여 줍니다. 점수는 저장 당시 값입니다.',
      icon: Icons.history,
      children: [
        for (final record in _records)
          Card(
            key: Key('historyRecord_${record.id}'),
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFE8E6DE)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                '종합 ${record.score.totalScore}점 · ${record.score.labelText}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${record.createdAtLabel}\n'
                  '생활 ${record.score.lifeScore} · '
                  '경제 ${record.score.economyScore} · '
                  '책임 ${record.score.responsibilityScore}',
                ),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DiagnosisDetailPage(score: record.score),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
