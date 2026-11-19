/// 로그인 이메일과 별칭. 별칭은 이 기기 계정에 저장한다.
import 'package:flutter/material.dart';

import '../../auth/auth_scope.dart';
import '../../mypage/member_library_store.dart';
import 'library_scope.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final session = AuthScope.maybeOf(context)?.session;
    final userId = session?.user?.id;
    final email = session?.user?.email ?? '';
    var name = '';
    if (userId != null) {
      name = (await LibraryScope.of(context).load(userId)).displayName;
    }
    if (!mounted) return;
    setState(() {
      _emailController.text = email;
      _nameController.text = name;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final userId = LibraryScope.userIdOf(context);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 로그인 후에 별칭을 저장할 수 있습니다.')),
      );
      return;
    }
    final store = LibraryScope.of(context);
    final current = await store.load(userId);
    await store.save(
      userId,
      current.copyWith(displayName: _nameController.text.trim()),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('별칭을 저장했습니다.')));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보 관리')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  key: const Key('profileNameField'),
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '이름 또는 별칭',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('profileEmailField'),
                  controller: _emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                    helperText: '이메일은 가입 계정이라 여기서 바꾸지 않습니다.',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('profileSaveButton'),
                  onPressed: _save,
                  child: const Text('변경사항 저장'),
                ),
                const SizedBox(height: 12),
                const Text(
                  '별칭은 이 휴대폰의 계정에만 저장됩니다.',
                  style: TextStyle(color: Color(0xFF5F6A60)),
                ),
              ],
            ),
    );
  }
}
