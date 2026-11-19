/// 알림 설정과 로그아웃. 스위치 값은 이 기기 계정에 남긴다.
import 'package:flutter/material.dart';

import '../../auth/auth_scope.dart';
import 'library_scope.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _remindersEnabled = false;
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
    if (userId != null) {
      final library = await LibraryScope.of(context).load(userId);
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = library.notificationsEnabled;
        _remindersEnabled = library.remindersEnabled;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = false);
  }

  Future<void> _setNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _persist();
  }

  Future<void> _setReminders(bool value) async {
    setState(() => _remindersEnabled = value);
    await _persist();
  }

  Future<void> _persist() async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) return;
    final store = LibraryScope.of(context);
    final current = await store.load(userId);
    await store.save(
      userId,
      current.copyWith(
        notificationsEnabled: _notificationsEnabled,
        remindersEnabled: _remindersEnabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.maybeOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('알림·앱 설정')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      SwitchListTile(
                        key: const Key('settingsNotificationSwitch'),
                        title: const Text('서비스 알림'),
                        subtitle: const Text('공지와 서비스 안내를 받아요.'),
                        value: _notificationsEnabled,
                        onChanged: _setNotifications,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        key: const Key('settingsReminderSwitch'),
                        title: const Text('준비 항목 알림'),
                        subtitle: const Text('체크리스트를 다시 확인하도록 알려요.'),
                        value: _remindersEnabled,
                        onChanged: _setReminders,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '알림 스위치는 이 휴대폰에 저장됩니다. 푸시 서버 전송은 아직 없습니다.',
                  style: TextStyle(color: Color(0xFF5F6A60), height: 1.4),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  key: const Key('settingsLogoutButton'),
                  onPressed: auth == null || auth.busy
                      ? null
                      : () async {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          await auth.logout();
                        },
                  child: const Text('로그아웃'),
                ),
              ],
            ),
    );
  }
}
