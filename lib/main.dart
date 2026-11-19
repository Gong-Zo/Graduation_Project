/// 앱 진입점. 기기 로그인 저장소를 열고 AuthGate로 화면을 고른다.
/// 디버그 빌드에서는 테스트 계정으로 바로 들어가 홈을 볼 수 있다.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_scope.dart';
import 'auth/auth_service.dart';
import 'auth/auth_store.dart';
import 'auth/petbefore_api.dart';
import 'ui/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // kDebugMode일 때만 테스트 계정 자동 로그인. 릴리스에서는 실제 로그인 흐름.
  final auth = AuthController(
    AuthService(LocalAuthStore(), api: PetbeforeApi.instance),
    autoLoginTestAccount: kDebugMode,
  );
  await auth.bootstrap();
  runApp(MainApp(auth: auth));
}

/// 슬현 테마 + 하민 AuthScope. 홈은 AuthGate가 세션에 따라 고른다.
class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: auth,
      child: MaterialApp(
        title: '펫비포',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F4E)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F5EF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F5EF),
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Color(0xFFE5E7E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Color(0xFFE5E7E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Color(0xFF2F6F4E), width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        builder: (context, child) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
