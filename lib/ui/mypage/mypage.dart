/// 마이페이지 메뉴. 회원만 홈에서 들어온다.
import 'package:flutter/material.dart';

import '../../auth/auth_scope.dart';
import '../shared/feature_screen.dart';
import 'diagnosis_history_page.dart';
import 'favorites_page.dart';
import 'library_scope.dart';
import 'profile_page.dart';
import 'saved_content_page.dart';
import 'settings_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _headline = '내 정보와 진단 기록, 저장한 콘텐츠와 앱 설정을 관리해요.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadHeadline();
    });
  }

  Future<void> _loadHeadline() async {
    final session = AuthScope.maybeOf(context)?.session;
    final email = session?.user?.email;
    final userId = session?.user?.id;
    var name = '';
    if (userId != null) {
      name = (await LibraryScope.of(context).load(userId)).displayName;
    }
    if (!mounted) return;
    final who = name.isNotEmpty ? name : (email ?? '회원');
    setState(() {
      _headline = '$who 계정입니다. 진단 기록과 저장한 자료를 이 기기에서 관리해요.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return FeatureScreen(
      title: '마이페이지',
      description: _headline,
      icon: Icons.account_circle_outlined,
      children: const [
        FeatureMenuCard(
          title: '내 정보 관리',
          description: '별칭을 저장하고 가입 이메일을 확인해요.',
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
          description: '북마크한 교육·준비 자료를 다시 봐요.',
          icon: Icons.bookmark_border,
          page: SavedContentPage(),
        ),
        FeatureMenuCard(
          title: '관심 보호소·보호동물',
          description: '하트로 담아 둔 항목을 모아 봐요.',
          icon: Icons.favorite_border,
          page: FavoritesPage(),
        ),
        FeatureMenuCard(
          title: '알림·앱 설정',
          description: '알림 설정과 로그아웃을 관리해요.',
          icon: Icons.settings_outlined,
          page: SettingsPage(),
        ),
      ],
    );
  }
}
