import 'package:flutter/material.dart';

import '../shared/feature_screen.dart';

class AdoptionEducationPage extends StatelessWidget {
  const AdoptionEducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureScreen(
      title: '입양 전 교육자료',
      description: '반려동물과 함께하는 일상은 장기간 이어지는 책임과 돌봄을 포함해요.',
      icon: Icons.menu_book_outlined,
      children: [
        FeatureInfoCard(
          title: '가족 모두의 동의',
          description: '함께 사는 사람들과 역할·비용·돌봄 공백에 대해 충분히 이야기해요.',
        ),
        FeatureInfoCard(
          title: '평생 돌봄 계획',
          description: '이사, 취업, 결혼, 출산 등 생활 변화가 생겨도 돌봄을 이어갈 계획을 세워요.',
          icon: Icons.calendar_month_outlined,
        ),
        FeatureInfoCard(
          title: '건강과 비용',
          description: '일상 양육비 외에 예방 진료와 갑작스러운 의료비도 고려해요.',
          icon: Icons.health_and_safety_outlined,
        ),
        FeatureInfoCard(
          title: '입양 후 적응',
          description:
              '새 환경에 적응하는 시간은 개체마다 다를 수 있어요. 조급하게 판단하지 말고 안전한 공간을 마련해요.',
          icon: Icons.home_outlined,
        ),
        FeatureInfoCard(
          title: '공식 안내 확인',
          description: '입양 조건과 필요 서류는 보호소·지자체의 최신 안내를 직접 확인해 주세요.',
          icon: Icons.info_outline,
        ),
      ],
    );
  }
}
