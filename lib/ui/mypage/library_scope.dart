/// 마이페이지 저장소와 회원 id를 화면에서 꺼낸다.
import 'package:flutter/widgets.dart';

import '../../auth/auth_scope.dart';
import '../../mypage/member_library_store.dart';

class LibraryScope extends InheritedWidget {
  const LibraryScope({
    super.key,
    required this.store,
    required super.child,
  });

  final MemberLibraryStore store;

  static MemberLibraryStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LibraryScope>();
    return scope?.store ?? defaultMemberLibraryStore();
  }

  static String? userIdOf(BuildContext context) {
    return AuthScope.maybeOf(context)?.session?.user?.id;
  }

  @override
  bool updateShouldNotify(LibraryScope oldWidget) => store != oldWidget.store;
}
