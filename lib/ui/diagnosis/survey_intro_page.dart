/// 자가점검 시작 전 안내. 시작하기를 누르면 60문항 SurveyPage로 간다.
import 'package:flutter/material.dart';

import '../shared/feature_screen.dart';
import '../survey_page.dart';

class SurveyIntroPage extends StatelessWidget {
  const SurveyIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '자가점검 안내',
      description: '반려견 맞이를 위한\n준비도 자가점검',
      icon: Icons.fact_check_outlined,
      children: [
        const FeatureInfoCard(
          title: '현재의 생활을 기준으로 답해 주세요',
          description:
              '생활·경제·돌봄 준비를 차례로 살펴보고 현재의 준비 상태를 확인해요. 정답은 없으며, 답변을 통해 미리 준비할 부분을 찾을 수 있습니다.',
        ),
        const FeatureInfoCard(
          title: '세 영역을 함께 점검해요',
          description: '생활 리듬, 경제적 준비, 장기 돌봄 계획을 확인합니다.',
          icon: Icons.view_list_outlined,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const SurveyPage())),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('자가점검 시작하기'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: const Color(0xFF2F6F4E),
          ),
        ),
      ],
    );
  }
}
