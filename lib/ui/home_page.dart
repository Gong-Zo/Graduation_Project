import 'package:flutter/material.dart';

import '../auth/auth_models.dart';
import '../auth/auth_scope.dart';
import 'adoption/adoption_info_page.dart';
import 'diagnosis/survey_intro_page.dart';
import 'diagnosis_page.dart';
import 'mypage/mypage.dart';
import 'preparation/preparation_page.dart';

/// 슬현 홈 UI + 하민 로그인 권한. 자가점검·7일 기록은 회원만.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// 회원만 열고, 비회원이면 로그인 안내 후 로그아웃으로 로그인 화면으로 보낸다.
  Future<void> _openMemberFeature(
    BuildContext context, {
    required AppFeature feature,
    required Widget page,
  }) async {
    final auth = AuthScope.of(context);
    if (auth.canAccess(feature)) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => page));
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

  /// 하단 탭. 자가점검·7일·마이페이지는 회원만, 입양 정보는 비회원도 연다.
  Future<void> _openTab(BuildContext context, int index) async {
    switch (index) {
      case 0:
        return;
      case 1:
        await _openMemberFeature(
          context,
          feature: AppFeature.selfCheck,
          page: const SurveyIntroPage(),
        );
      case 2:
        await _openMemberFeature(
          context,
          feature: AppFeature.sevenDayTrial,
          page: const DiagnosisPage(initialSection: 1),
        );
      case 3:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AdoptionInfoPage()),
        );
      case 4:
        await _openMemberFeature(
          context,
          feature: AppFeature.myPage,
          page: const MyPage(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
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
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  '안녕하세요!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF24352A),
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF24352A),
                    ),
                    children: const [
                      TextSpan(text: '반려견과 '),
                      TextSpan(
                        text: '함께 할 미래',
                        style: TextStyle(color: Color(0xFF6A9E43)),
                      ),
                      TextSpan(text: '를 준비해요.'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '로그인 상태: $label',
                  key: const Key('sessionLabel'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF737A72),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 142,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7EFE5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '준비된 반려인이\n행복한 반려 생활을 만들어요.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            height: 1.45,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF315B3F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 43,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.pets_rounded,
                                size: 48,
                                color: Color(0xFF2F6F4E),
                              ),
                            ),
                            Positioned(
                              top: 1,
                              right: 1,
                              child: Icon(
                                Icons.auto_awesome,
                                color: primary.withValues(alpha: 0.45),
                                size: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  '나에게 필요한 준비',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF24352A),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.94,
                  children: [
                    _DashboardTile(
                      key: const Key('selfCheckTile'),
                      icon: Icons.fact_check_outlined,
                      title: '자가점검',
                      description: '지금 나의 준비 상태를 확인해요.',
                      background: const Color(0xFFEAF2E8),
                      onTap: () => _openMemberFeature(
                        context,
                        feature: AppFeature.selfCheck,
                        page: const SurveyIntroPage(),
                      ),
                    ),
                    _DashboardTile(
                      key: const Key('sevenDayTile'),
                      icon: Icons.calendar_month_outlined,
                      title: '7일 생활 점검',
                      description: '실제 생활을 기록해 비교해요.',
                      background: const Color(0xFFFFF1E2),
                      iconColor: const Color(0xFFB36B25),
                      onTap: () => _openMemberFeature(
                        context,
                        feature: AppFeature.sevenDayTrial,
                        page: const DiagnosisPage(initialSection: 1),
                      ),
                    ),
                    _DashboardTile(
                      key: const Key('preparationTile'),
                      icon: Icons.menu_book_outlined,
                      title: '맞춤형 준비 지원',
                      description: '필요한 교육과 정보를 확인해요.',
                      background: const Color(0xFFFFF1E2),
                      iconColor: const Color(0xFFB36B25),
                      onTap: () => _openMemberFeature(
                        context,
                        feature: AppFeature.personalizedSupport,
                        page: const PreparationPage(),
                      ),
                    ),
                    _DashboardTile(
                      key: const Key('adoptionTile'),
                      icon: Icons.location_on_outlined,
                      title: '입양 관련 정보',
                      description: '보호소와 입양 절차를 알아봐요.',
                      background: const Color(0xFFFFF1E2),
                      iconColor: const Color(0xFFB36B25),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AdoptionInfoPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF2E8),
        onDestinationSelected: (index) => _openTab(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: '자가점검',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: '7일 점검',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: '정보',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), label: '마이'),
        ],
      ),
    );
  }
}

/// 홈 2x2 타일. 탭하면 회원 권한 검사를 거친다.
class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.background,
    required this.onTap,
    this.iconColor = const Color(0xFF2F6F4E),
  });

  final IconData icon;
  final String title;
  final String description;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE8E6DE)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: background,
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9AA098),
                    size: 20,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF24352A),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.35,
                  color: const Color(0xFF687168),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
