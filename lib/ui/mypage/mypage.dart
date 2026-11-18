import 'package:flutter/material.dart';

import '../shared/feature_screen.dart';
import 'diagnosis_history_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'saved_content_page.dart';
import 'settings_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '마이페이지',
      description: '내 정보와 진단 기록, 저장한 콘텐츠와 앱 설정을 관리해요.',
      icon: Icons.account_circle_outlined,
      children: const [
        FeatureMenuCard(
          title: '내 정보 관리',
          description: '프로필 정보를 확인하고 수정해요.',
          icon: Icons.person_outline,
          page: ProfilePage(),
        ),
        FeatureMenuCard(
          title: '진단 기록·최종 리포트',
          description: '자가점검 기록을 모아 보는 화면입니다.',
          icon: Icons.history,
          page: DiagnosisHistoryPage(),
        ),
        FeatureMenuCard(
          title: '저장한 콘텐츠',
          description: '나중에 다시 볼 준비 자료를 확인해요.',
          icon: Icons.bookmark_border,
          page: SavedContentPage(),
        ),
        FeatureMenuCard(
          title: '관심 보호소·보호동물',
          description: '관심 항목을 모아 보는 화면입니다.',
          icon: Icons.favorite_border,
          page: FavoritesPage(),
        ),
        FeatureMenuCard(
          title: '알림·앱 설정',
          description: '알림과 화면 설정을 관리해요.',
          icon: Icons.settings_outlined,
          page: SettingsPage(),
        ),
      ],
    );
  }
}
