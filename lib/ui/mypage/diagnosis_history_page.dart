import 'package:flutter/material.dart';

import '../diagnosis/survey_intro_page.dart';
import '../shared/feature_screen.dart';

class DiagnosisHistoryPage extends StatelessWidget {
  const DiagnosisHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '진단 기록·최종 리포트',
      description: '완료한 자가점검과 영역별 리포트를 확인하는 곳이에요.',
      icon: Icons.history,
      children: [
        const FeatureInfoCard(
          title: '저장된 진단 기록이 없어요',
          description: '자가점검 결과를 계정에 저장하는 기능은 추후 연결할 수 있습니다.',
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
}
