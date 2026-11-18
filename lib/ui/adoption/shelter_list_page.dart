import 'package:flutter/material.dart';

import '../shared/feature_screen.dart';
import 'shelter_detail_page.dart';

class ShelterListPage extends StatefulWidget {
  const ShelterListPage({super.key});

  @override
  State<ShelterListPage> createState() => _ShelterListPageState();
}

class _ShelterListPageState extends State<ShelterListPage> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보호소 검색·목록')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Card(
            color: Color(0xFFEAF1E8),
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                '지역이나 보호소 이름으로 찾을 수 있도록 준비 중이에요. 방문 전 운영 여부와 입양 가능 동물을 보호소에 확인해 주세요.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _queryController,
            decoration: const InputDecoration(
              labelText: '지역 또는 보호소 이름',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('보호소 검색 데이터 연동을 준비 중입니다.')),
            ),
            icon: const Icon(Icons.search),
            label: const Text('보호소 검색'),
          ),
          const SizedBox(height: 12),
          const FeatureInfoCard(
            title: '검색 결과',
            description: '보호소 데이터가 연결되면 이곳에 검색 결과가 표시됩니다.',
            icon: Icons.location_searching,
          ),
          const SizedBox(height: 12),
          FeatureMenuCard(
            title: '보호소 상세 화면 미리보기',
            description: '보호소 상세 화면 구성을 확인해요. 실제 보호소 정보는 아닙니다.',
            icon: Icons.open_in_new,
            page: const ShelterDetailPage(),
          ),
        ],
      ),
    );
  }
}
