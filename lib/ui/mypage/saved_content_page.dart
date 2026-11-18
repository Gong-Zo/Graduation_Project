import 'package:flutter/material.dart';

import '../preparation/education_page.dart';
import '../preparation/breed_info_page.dart';
import '../shared/feature_screen.dart';
import '../adoption/adoption_education_page.dart';

class SavedContentPage extends StatelessWidget {
  const SavedContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '저장한 콘텐츠',
      description: '저장한 교육·준비 자료를 모아 보는 화면이에요.',
      icon: Icons.bookmark_border,
      children: [
        const FeatureInfoCard(
          title: '저장한 콘텐츠가 없어요',
          description: '콘텐츠 저장 기능은 추후 연결할 수 있습니다.',
          icon: Icons.inbox_outlined,
        ),
        const SizedBox(height: 8),
        FeatureMenuCard(
          title: '맞춤 교육 콘텐츠 둘러보기',
          description: '기본 양육 지식을 주제별로 확인해요.',
          icon: Icons.school_outlined,
          page: const EducationPage(),
        ),
        FeatureMenuCard(
          title: '견종 정보 둘러보기',
          description: '견종 특성과 양육 시 고려할 점을 살펴봐요.',
          icon: Icons.pets_outlined,
          page: const BreedInfoPage(),
        ),
        FeatureMenuCard(
          title: '입양 전 교육자료 둘러보기',
          description: '입양 전 확인할 책임과 준비를 살펴봐요.',
          icon: Icons.menu_book_outlined,
          page: const AdoptionEducationPage(),
        ),
      ],
    );
  }
}
