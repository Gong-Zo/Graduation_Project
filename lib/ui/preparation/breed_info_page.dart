/// 견종 정보 안내. 북마크로 마이페이지에 저장할 수 있다.
import 'package:flutter/material.dart';

import '../../mypage/member_library_store.dart';
import '../mypage/save_content_button.dart';
import '../shared/feature_screen.dart';

class BreedInfoPage extends StatelessWidget {
  const BreedInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureScreen(
      title: '양육 특성·견종 정보',
      description: '견종 특성은 참고 정보이며, 실제 성향과 돌봄 필요는 개체의 나이·건강·경험에 따라 달라요.',
      icon: Icons.pets_outlined,
      actions: [SaveContentButton(item: breedContent)],
      children: [
        FeatureInfoCard(
          title: '활동량',
          description: '산책 시간뿐 아니라 실내 놀이와 휴식도 함께 고려해 생활 리듬을 맞춰요.',
          icon: Icons.directions_run_outlined,
        ),
        FeatureInfoCard(
          title: '털 관리',
          description: '털 길이와 종류에 따라 빗질·미용 빈도와 관리 비용이 달라질 수 있어요.',
          icon: Icons.brush_outlined,
        ),
        FeatureInfoCard(
          title: '건강 특성',
          description: '견종별로 알려진 건강 유의점은 수의사 상담과 정기 검진으로 확인해요.',
          icon: Icons.favorite_border,
        ),
        FeatureInfoCard(
          title: '개체 성향 확인',
          description: '견종만으로 성격을 단정하지 말고 보호소에서 개별 행동과 생활 환경을 확인해요.',
          icon: Icons.visibility_outlined,
        ),
      ],
    );
  }
}
