import 'package:flutter/material.dart';

import '../auth/auth_models.dart';
import '../auth/auth_scope.dart';
import 'survey_page.dart';

/// 로그인 이후 홈. 기능 진입과 권한 확인만 두고, 카드 UI는 바꿔도 된다.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openMemberFeature(
    BuildContext context, {
    required AppFeature feature,
    required String title,
    required Widget page,
  }) async {
    final auth = AuthScope.of(context);
    if (auth.canAccess(feature)) {
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
      return;
    }
    if (!context.mounted) return;
    final goLogin = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('로그인이 필요합니다'),
          content: const Text('이 기능은 회원만 사용할 수 있습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('닫기'),
            ),
            FilledButton(
              key: const Key('guestLoginPromptButton'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('로그인'),
            ),
          ],
        );
      },
    );
    if (goLogin == true && context.mounted) {
      await AuthScope.of(context).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final session = auth.session!;
    final label = session.isGuest ? '비회원' : session.user!.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('펫비포'),
        actions: [
          TextButton(
            key: const Key('logoutButton'),
            onPressed: auth.busy ? null : auth.logout,
            child: const Text('로그아웃'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('로그인 상태: $label', key: const Key('sessionLabel')),
          const SizedBox(height: 16),
          ListTile(
            key: const Key('selfCheckTile'),
            title: const Text('자가점검'),
            subtitle: const Text('회원 전용'),
            onTap: () => _openMemberFeature(
              context,
              feature: AppFeature.selfCheck,
              title: '자가점검',
              page: const SurveyPage(),
            ),
          ),
          ListTile(
            key: const Key('sevenDayTile'),
            title: const Text('7일 체험'),
            subtitle: const Text('회원 전용 · 이후 구현'),
            onTap: () => _openMemberFeature(
              context,
              feature: AppFeature.sevenDayTrial,
              title: '7일 체험',
              page: const _PlaceholderPage(title: '7일 체험'),
            ),
          ),
          ListTile(
            key: const Key('adoptionInfoTile'),
            title: const Text('입양 관련 정보'),
            subtitle: const Text('비회원도 이용 가능'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _PlaceholderPage(title: '입양 관련 정보'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title 화면은 이후에 연결합니다.')),
    );
  }
}
