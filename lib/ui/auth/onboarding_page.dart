/// 첫 실행 안내 슬라이드. 시작하기/건너뛰면 온보딩 완료로 저장한다.
import 'package:flutter/material.dart';

import '../../auth/auth_scope.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _slides = [
    _OnboardingSlide(
      title: '반려견과의\n행복한 시작을 준비해요',
      description: '나의 생활환경과 양육 준비도를 점검하고,\n함께할 준비를 차근차근 해보세요.',
      icon: Icons.pets_rounded,
      background: Color(0xFFFFF2D2),
      accent: Color(0xFFB88C5B),
    ),
    _OnboardingSlide(
      title: '나의 양육 준비도를\n체크해요',
      description: '생활, 경제, 주거, 책임 등\n여러 영역으로 현재 준비 상태를 확인할 수 있어요.',
      icon: Icons.checklist_rounded,
      background: Color(0xFFEAF2D7),
      accent: Color(0xFF5D925C),
    ),
    _OnboardingSlide(
      title: '맞춤 정보로\n더 든든하게!',
      description: '진단 결과에 맞는 교육 콘텐츠와\n입양 정보를 통해 더 현명한 반려 생활을 준비해요.',
      icon: Icons.home_rounded,
      background: Color(0xFFE3F1E7),
      accent: Color(0xFF4F8B62),
    ),
  ];

  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_currentPage < _slides.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      return;
    }
    await AuthScope.of(context).completeOnboarding();
  }

  Future<void> _previous() {
    return _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('onboardingSkipButton'),
                  onPressed: auth.busy ? null : auth.completeOnboarding,
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(color: Color(0xFF737A72)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) =>
                    _OnboardingSlideView(slide: _slides[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < _slides.length; index++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentPage ? 10 : 9,
                          height: index == _currentPage ? 10 : 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentPage
                                ? const Color(0xFF4F8B50)
                                : const Color(0xFFE5E3DE),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (_currentPage == 0)
                    _OnboardingButton(
                      key: const Key('onboardingNextButton'),
                      label: '다음',
                      onPressed: auth.busy ? null : _next,
                      primary: true,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _OnboardingButton(
                            key: const Key('onboardingPreviousButton'),
                            label: '이전',
                            onPressed: auth.busy ? null : _previous,
                            primary: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _OnboardingButton(
                            key: Key(
                              isLastPage
                                  ? 'onboardingStartButton'
                                  : 'onboardingNextButton',
                            ),
                            label: isLastPage ? '시작하기' : '다음',
                            onPressed: auth.busy ? null : _next,
                            primary: true,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.background,
    required this.accent,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color background;
  final Color accent;
}

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationHeight = constraints.maxHeight < 450 ? 170.0 : 230.0;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OnboardingIllustration(
                  slide: slide,
                  height: illustrationHeight,
                ),
                const SizedBox(height: 20),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    color: const Color(0xFF262824),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: const Color(0xFF555A54),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.slide, required this.height});

  final _OnboardingSlide slide;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: height * 0.88,
            height: height * 0.88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.background,
            ),
          ),
          Container(
            width: height * 0.62,
            height: height * 0.62,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: height * 0.4, color: slide.accent),
          ),
          Positioned(
            top: height * 0.12,
            right: height * 0.15,
            child: Icon(
              Icons.favorite,
              size: height * 0.12,
              color: const Color(0xFFF3A18F),
            ),
          ),
          Positioned(
            left: height * 0.12,
            bottom: height * 0.19,
            child: Icon(
              Icons.auto_awesome,
              size: height * 0.12,
              color: slide.accent.withValues(alpha: 0.65),
            ),
          ),
          Positioned(
            right: height * 0.13,
            bottom: height * 0.18,
            child: Icon(
              Icons.pets_outlined,
              size: height * 0.11,
              color: slide.accent.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  const _OnboardingButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    );
    if (primary) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: const Color(0xFF4F8B50),
          shape: shape,
        ),
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: const Color(0xFFF7F5F1),
        foregroundColor: const Color(0xFF555A54),
        side: BorderSide.none,
        shape: shape,
      ),
      child: Text(label),
    );
  }
}
