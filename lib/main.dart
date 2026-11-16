import 'package:flutter/material.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_scope.dart';
import 'auth/auth_service.dart';
import 'auth/auth_store.dart';
import 'ui/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthController(AuthService(SharedPreferencesAuthStore()));
  await auth.bootstrap();
  runApp(MainApp(auth: auth));
}

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
        ),
        home: const AuthGate(),
      ),
    );
  }
}
