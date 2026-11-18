import 'package:flutter/material.dart';

import '../adoption_list_page.dart';
import '../shared/feature_screen.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '관심 보호소·보호동물',
      description: '관심 있는 보호소와 보호동물을 모아 보는 화면이에요.',
      icon: Icons.favorite_border,
      children: [
        const FeatureInfoCard(
          title: '관심 항목이 없어요',
          description: '즐겨찾기 저장 기능은 추후 연결할 수 있습니다.',
          icon: Icons.inbox_outlined,
        ),
        const SizedBox(height: 8),
        FeatureMenuCard(
          title: '보호동물 둘러보기',
          description: '현재 등록된 보호동물 정보를 확인해요.',
          icon: Icons.pets_outlined,
          page: const AdoptionListPage(),
        ),
      ],
    );
  }
}
