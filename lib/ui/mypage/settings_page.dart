import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _remindersEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림·앱 설정')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Colors.white,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('서비스 알림'),
                  subtitle: const Text('공지와 서비스 안내를 받아요.'),
                  value: _notificationsEnabled,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('준비 항목 알림'),
                  subtitle: const Text('체크리스트를 다시 확인하도록 알려요.'),
                  value: _remindersEnabled,
                  onChanged: (value) =>
                      setState(() => _remindersEnabled = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '설정은 현재 화면에서만 유지됩니다. 기기 저장과 알림 전송은 추후 연결할 수 있어요.',
            style: TextStyle(color: Color(0xFF5F6A60), height: 1.4),
          ),
        ],
      ),
    );
  }
}
