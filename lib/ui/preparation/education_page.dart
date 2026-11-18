import 'package:flutter/material.dart';

import '../shared/feature_screen.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureScreen(
      title: '맞춤 교육 콘텐츠',
      description: '새로운 환경에 적응하는 동안 필요한 기본 양육 지식을 주제별로 살펴봐요.',
      icon: Icons.school_outlined,
      children: [
        FeatureInfoCard(
          title: '산책과 활동',
          description: '반려견의 나이와 건강 상태에 맞춰 활동량을 조절하고, 안전한 산책 장비를 사용해요.',
          icon: Icons.directions_walk_outlined,
        ),
        FeatureInfoCard(
          title: '건강과 예방',
          description: '예방접종·구충 일정과 정기 검진은 동물병원과 상담해 계획해요.',
          icon: Icons.health_and_safety_outlined,
        ),
        FeatureInfoCard(
          title: '생활 환경',
          description: '휴식 공간, 배변 장소, 위험 물건 관리 등 안정적으로 지낼 환경을 준비해요.',
          icon: Icons.home_outlined,
        ),
        FeatureInfoCard(
          title: '행동 이해',
          description: '행동의 원인을 살피고, 어려움이 지속되면 수의사나 전문가의 도움을 받아요.',
          icon: Icons.psychology_outlined,
        ),
      ],
    );
  }
}
