/// 입양 정보 허브. 비회원도 열 수 있다.
import 'package:flutter/material.dart';

import '../adoption_list_page.dart';
import '../shared/feature_screen.dart';
import 'adoption_education_page.dart';
import 'adoption_process_page.dart';
import 'shelter_list_page.dart';

class AdoptionInfoPage extends StatelessWidget {
  const AdoptionInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '입양 관련 정보',
      description: '입양을 결정하기 전 확인하면 좋은 교육 자료, 보호소와 보호동물 정보를 모았어요.',
      icon: Icons.volunteer_activism_outlined,
      children: const [
        FeatureMenuCard(
          title: '입양 전 교육자료',
          description: '입양 전 알아둘 책임과 생활 준비를 확인해요.',
          icon: Icons.menu_book_outlined,
          page: AdoptionEducationPage(),
        ),
        FeatureMenuCard(
          title: '보호소 검색·목록',
          description: '공공데이터로 전국 동물보호센터를 찾고 상세·관심을 저장해요.',
          icon: Icons.location_on_outlined,
          page: ShelterListPage(),
        ),
        FeatureMenuCard(
          title: '보호동물 목록',
          description: '최근 등록된 보호동물과 보호소 정보를 확인해요.',
          icon: Icons.pets_outlined,
          page: AdoptionListPage(),
        ),
        FeatureMenuCard(
          title: '입양 절차 안내',
          description: '상담부터 가족 맞이까지의 일반적인 절차를 살펴봐요.',
          icon: Icons.route_outlined,
          page: AdoptionProcessPage(),
        ),
      ],
    );
  }
}
