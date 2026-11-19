/// 교육 안내를 마이페이지 저장 콘텐츠에 넣거나 뺀다.
import 'package:flutter/material.dart';

import '../../mypage/member_library_store.dart';
import 'library_scope.dart';

class SaveContentButton extends StatefulWidget {
  const SaveContentButton({super.key, required this.item});

  final SavedContentItem item;

  @override
  State<SaveContentButton> createState() => _SaveContentButtonState();
}

class _SaveContentButtonState extends State<SaveContentButton> {
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
      () => _saved = library.savedContent.any((item) => item.id == widget.item.id),
    );
  }

  Future<void> _toggle() async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장은 회원 로그인 후에만 됩니다.')),
      );
      return;
    }
    final store = LibraryScope.of(context);
    final current = await store.load(userId);
    final exists = current.savedContent.any((item) => item.id == widget.item.id);
    final next = exists
        ? [
            for (final item in current.savedContent)
              if (item.id != widget.item.id) item,
          ]
        : [...current.savedContent, widget.item];
    await store.save(userId, current.copyWith(savedContent: next));
    if (!mounted) return;
    setState(() => _saved = !exists);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(exists ? '저장을 해제했습니다.' : '마이페이지에 저장했습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: Key('saveContent_${widget.item.id}'),
      tooltip: _saved ? '저장 해제' : '콘텐츠 저장',
      onPressed: _toggle,
      icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border),
    );
  }
}
