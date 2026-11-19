/// 북마크한 교육·견종·입양 안내를 다시 연다.
import 'package:flutter/material.dart';

import '../../mypage/member_library_store.dart';
import '../adoption/adoption_education_page.dart';
import '../preparation/breed_info_page.dart';
import '../preparation/education_page.dart';
import '../shared/feature_screen.dart';
import 'library_scope.dart';

class SavedContentPage extends StatefulWidget {
  const SavedContentPage({super.key});

  @override
  State<SavedContentPage> createState() => _SavedContentPageState();
}

class _SavedContentPageState extends State<SavedContentPage> {
  List<SavedContentItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    final library = await LibraryScope.of(context).load(userId);
    if (!mounted) return;
    setState(() {
      _items = library.savedContent;
      _loading = false;
    });
  }

  Widget _pageFor(String id) {
    return switch (id) {
      'education' => const EducationPage(),
      'breed' => const BreedInfoPage(),
      'adoptionEducation' => const AdoptionEducationPage(),
      _ => const EducationPage(),
    };
  }

  Future<void> _remove(SavedContentItem item) async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) return;
    final store = LibraryScope.of(context);
    final current = await store.load(userId);
    await store.save(
      userId,
      current.copyWith(
        savedContent: [
          for (final saved in current.savedContent)
            if (saved.id != item.id) saved,
        ],
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('저장한 콘텐츠')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FeatureScreen(
      title: '저장한 콘텐츠',
      description: '저장한 교육·준비 자료를 모아 보는 화면이에요.',
      icon: Icons.bookmark_border,
      children: [
        if (_items.isEmpty)
          const FeatureInfoCard(
            title: '저장한 콘텐츠가 없어요',
            description: '교육·견종·입양 안내 화면 오른쪽 위의 북마크를 누르면 여기에 모입니다.',
            icon: Icons.inbox_outlined,
          )
        else
          for (final item in _items)
            Card(
              key: Key('savedContent_${item.id}'),
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFE8E6DE)),
              ),
              child: ListTile(
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item.description),
                trailing: IconButton(
                  tooltip: '저장 해제',
                  onPressed: () => _remove(item),
                  icon: const Icon(Icons.bookmark),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => _pageFor(item.id)),
                ),
              ),
            ),
        const SizedBox(height: 8),
        FeatureMenuCard(
          title: '맞춤 교육 콘텐츠 둘러보기',
          description: '기본 양육 지식을 주제별로 확인해요.',
          icon: Icons.school_outlined,
          page: const EducationPage(),
        ),
        FeatureMenuCard(
          title: '견종 정보 둘러보기',
          description: '견종 특성과 양육 시 고려할 점을 살펴봐요.',
          icon: Icons.pets_outlined,
          page: const BreedInfoPage(),
        ),
        FeatureMenuCard(
          title: '입양 전 교육자료 둘러보기',
          description: '입양 전 확인할 책임과 준비를 살펴봐요.',
          icon: Icons.menu_book_outlined,
          page: const AdoptionEducationPage(),
        ),
      ],
    );
  }
}
