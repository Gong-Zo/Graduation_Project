/// 보호동물·보호소를 관심 목록에 넣거나 뺀다.
import 'package:flutter/material.dart';

import '../../data/rescued_dog.dart';
import '../../mypage/member_library_store.dart';
import 'library_scope.dart';

class FavoriteDogButton extends StatefulWidget {
  const FavoriteDogButton({super.key, required this.dog});

  final RescuedDog dog;

  @override
  State<FavoriteDogButton> createState() => _FavoriteDogButtonState();
}

class _FavoriteDogButtonState extends State<FavoriteDogButton> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) return;
    final library = await LibraryScope.of(context).load(userId);
    if (!mounted) return;
    setState(
      () => _saved = library.favoriteDogs.any(
        (dog) => dog.noticeNo == widget.dog.noticeNo,
      ),
    );
  }

  Future<void> _toggle() async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관심 저장은 회원 로그인 후에만 됩니다.')),
      );
      return;
    }
    final store = LibraryScope.of(context);
    final current = await store.load(userId);
    final exists = current.favoriteDogs.any(
      (dog) => dog.noticeNo == widget.dog.noticeNo,
    );
    final next = exists
        ? [
            for (final dog in current.favoriteDogs)
              if (dog.noticeNo != widget.dog.noticeNo) dog,
          ]
        : [...current.favoriteDogs, widget.dog];
    await store.save(userId, current.copyWith(favoriteDogs: next));
    if (!mounted) return;
    setState(() => _saved = !exists);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(exists ? '관심을 해제했습니다.' : '관심 보호동물에 넣었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key('favoriteDogButton_${widget.dog.noticeNo}'),
      tooltip: _saved ? '관심 해제' : '관심 저장',
      onPressed: _toggle,
      icon: Icon(_saved ? Icons.favorite : Icons.favorite_border),
    );
  }
}

class FavoriteShelterButton extends StatefulWidget {
  const FavoriteShelterButton({super.key, required this.shelter});

  final FavoriteShelter shelter;

  @override
  State<FavoriteShelterButton> createState() => _FavoriteShelterButtonState();
}

class _FavoriteShelterButtonState extends State<FavoriteShelterButton> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) return;
    final library = await LibraryScope.of(context).load(userId);
    if (!mounted) return;
    setState(
      () => _saved = library.favoriteShelters.any(
        (shelter) => shelter.id == widget.shelter.id,
      ),
    );
  }

  Future<void> _toggle() async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관심 저장은 회원 로그인 후에만 됩니다.')),
      );
      return;
    }
    final store = LibraryScope.of(context);
    final current = await store.load(userId);
    final exists = current.favoriteShelters.any(
      (shelter) => shelter.id == widget.shelter.id,
    );
    final next = exists
        ? [
            for (final shelter in current.favoriteShelters)
              if (shelter.id != widget.shelter.id) shelter,
          ]
        : [...current.favoriteShelters, widget.shelter];
    await store.save(userId, current.copyWith(favoriteShelters: next));
    if (!mounted) return;
    setState(() => _saved = !exists);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(exists ? '관심을 해제했습니다.' : '관심 보호소에 넣었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key('favoriteShelterButton_${widget.shelter.id}'),
      tooltip: _saved ? '관심 해제' : '관심 저장',
      onPressed: _toggle,
      icon: Icon(_saved ? Icons.favorite : Icons.favorite_border),
    );
  }
}
