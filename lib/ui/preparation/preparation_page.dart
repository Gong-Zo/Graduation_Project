/// 맞춤형 준비 지원 메뉴. 아직 저장/API 없이 화면 이동만 한다.
import 'package:flutter/material.dart';

import '../shared/feature_screen.dart';
import 'breed_info_page.dart';
import 'care_checklist_page.dart';
import 'education_page.dart';

class PreparationPage extends StatelessWidget {
  const PreparationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '맞춤형 준비 지원',
      description: '반려견을 맞이하기 전 필요한 정보를 살펴보고, 준비 항목을 하나씩 확인해요.',
      icon: Icons.auto_awesome_outlined,
      children: const [
        FeatureMenuCard(
          title: '맞춤 교육 콘텐츠',
          description: '산책, 건강, 생활 환경에 관한 기본 내용을 확인해요.',
          icon: Icons.school_outlined,
          page: EducationPage(),
        ),
        FeatureMenuCard(
          title: '양육 체크리스트',
          description: '입양 전 준비 항목을 확인하고 진행 상태를 표시해요.',
          icon: Icons.checklist_outlined,
          page: CareChecklistPage(),
        ),
        FeatureMenuCard(
          title: '양육 특성·견종 정보',
          description: '견종별 특성은 개체마다 다를 수 있다는 점과 함께 참고 정보를 살펴봐요.',
          icon: Icons.pets_outlined,
          page: BreedInfoPage(),
        ),
      ],
    );
  }
}
