/// 관심 보호동물·보호소 목록. 항목을 누르면 상세로 간다.
import 'package:flutter/material.dart';

import '../../mypage/member_library_store.dart';
import '../adoption/shelter_detail_page.dart';
import '../adoption_detail_page.dart';
import '../adoption_list_page.dart';
import '../shared/feature_screen.dart';
import 'library_scope.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  MemberLibrary _library = const MemberLibrary();
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
      _library = library;
      _loading = false;
    });
  }

  Future<void> _removeDog(String noticeNo) async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) return;
    final store = LibraryScope.of(context);
    final current = await store.load(userId);
    await store.save(
      userId,
      current.copyWith(
        favoriteDogs: [
          for (final dog in current.favoriteDogs)
            if (dog.noticeNo != noticeNo) dog,
        ],
      ),
    );
    await _load();
  }

  Future<void> _removeShelter(String id) async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) return;
    final store = LibraryScope.of(context);
    final current = await store.load(userId);
    await store.save(
      userId,
      current.copyWith(
        favoriteShelters: [
          for (final shelter in current.favoriteShelters)
            if (shelter.id != id) shelter,
        ],
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('관심 보호소·보호동물')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final empty =
        _library.favoriteDogs.isEmpty && _library.favoriteShelters.isEmpty;

    return FeatureScreen(
      title: '관심 보호소·보호동물',
      description: '관심 있는 보호소와 보호동물을 모아 보는 화면이에요.',
      icon: Icons.favorite_border,
      children: [
        if (empty)
          const FeatureInfoCard(
            title: '관심 항목이 없어요',
            description: '보호동물·보호소 상세 화면의 하트를 누르면 여기에 모입니다.',
            icon: Icons.inbox_outlined,
          ),
        for (final dog in _library.favoriteDogs)
          Card(
            key: Key('favoriteDog_${dog.noticeNo}'),
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text(
                dog.breedName.isEmpty ? '견종 정보 없음' : dog.breedName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                [
                  dog.shelterName,
                  dog.processState,
                ].where((text) => text.isNotEmpty).join(' · '),
              ),
              trailing: IconButton(
                tooltip: '관심 해제',
                onPressed: () => _removeDog(dog.noticeNo),
                icon: const Icon(Icons.favorite),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AdoptionDetailPage(dog: dog),
                ),
              ),
            ),
          ),
        for (final shelter in _library.favoriteShelters)
          Card(
            key: Key('favoriteShelter_${shelter.id}'),
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text(
                shelter.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                shelter.address.isEmpty ? '주소 정보 없음' : shelter.address,
              ),
              trailing: IconButton(
                tooltip: '관심 해제',
                onPressed: () => _removeShelter(shelter.id),
                icon: const Icon(Icons.favorite),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ShelterDetailPage(
                    shelterName: shelter.name,
                    address: shelter.address,
                  ),
                ),
              ),
            ),
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
