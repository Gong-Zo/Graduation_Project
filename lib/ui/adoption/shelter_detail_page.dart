import 'package:flutter/material.dart';

import '../shared/feature_screen.dart';

class ShelterDetailPage extends StatelessWidget {
  const ShelterDetailPage({super.key, this.shelterName});

  final String? shelterName;

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '보호소 상세정보',
      description: shelterName ?? '보호소 정보를 표시할 화면입니다. 실제 정보는 데이터 연동 후 제공됩니다.',
      icon: Icons.location_on_outlined,
      children: const [
        FeatureInfoCard(
          title: '주소',
          description: '보호소 데이터 연동 후 표시됩니다.',
          icon: Icons.map_outlined,
        ),
        FeatureInfoCard(
          title: '연락처·운영시간',
          description: '방문 전 보호소에 직접 확인해 주세요.',
          icon: Icons.phone_outlined,
        ),
        FeatureInfoCard(
          title: '보호동물',
          description: '보호동물 정보가 연결되면 관련 목록을 표시합니다.',
          icon: Icons.pets_outlined,
        ),
      ],
    );
  }
}
