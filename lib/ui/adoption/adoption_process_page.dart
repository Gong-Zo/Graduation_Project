import 'package:flutter/material.dart';

import '../shared/feature_screen.dart';
import '../adoption_list_page.dart';

class AdoptionProcessPage extends StatelessWidget {
  const AdoptionProcessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '입양 절차 안내',
      description: '기관과 지역에 따라 절차가 다를 수 있으니 해당 보호소의 최신 안내를 확인해 주세요.',
      icon: Icons.route_outlined,
      children: [
        for (final step in const [
          ('1. 정보 확인', '보호동물의 성격·건강 상태와 보호소의 입양 조건을 확인해요.'),
          ('2. 상담 신청', '보호소에 문의해 가족 구성과 양육 환경을 상담해요.'),
          ('3. 만남과 준비', '동물을 직접 만나고 필요한 생활 환경과 물품을 준비해요.'),
          ('4. 입양 절차 진행', '신청서, 확인 절차와 계약 내용은 보호소 안내에 따라 진행해요.'),
          ('5. 적응 지원', '입양 후에도 건강 관리와 환경 적응을 꾸준히 살펴봐요.'),
        ])
          FeatureInfoCard(
            title: step.$1,
            description: step.$2,
            icon: Icons.check_circle_outline,
          ),
        const SizedBox(height: 8),
        FeatureMenuCard(
          title: '보호동물 살펴보기',
          description: '현재 등록된 보호동물 정보를 확인해요.',
          icon: Icons.pets_outlined,
          page: const AdoptionListPage(),
        ),
      ],
    );
  }
}
