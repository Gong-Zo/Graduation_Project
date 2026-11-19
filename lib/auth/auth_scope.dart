/// 트리 어디서든 AuthController를 읽게 하는 InheritedNotifier.
import 'package:flutter/widgets.dart';

import 'auth_controller.dart';

/// `AuthScope.of(context)`로 로그인 상태에 구독한다.
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope가 없습니다.');
    return scope!.notifier!;
  }

  /// 자가점검 테스트처럼 AuthScope가 없는 화면에서는 null.
  static AuthController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
  }
}
