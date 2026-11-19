/// 양육 체크리스트. 체크 상태는 이 화면을 나가면 사라진다.
import 'package:flutter/material.dart';

class CareChecklistPage extends StatefulWidget {
  const CareChecklistPage({super.key});

  @override
  State<CareChecklistPage> createState() => _CareChecklistPageState();
}

class _CareChecklistPageState extends State<CareChecklistPage> {
  static const _items = [
    '가족·동거인과 돌봄 역할을 정했어요',
    '반려동물을 허용하는 주거 환경인지 확인했어요',
    '매일 산책과 돌봄 시간을 확보했어요',
    '기본 양육비와 비상 의료비를 계획했어요',
    '가까운 동물병원과 야간 진료처를 확인했어요',
    '여행·질병 등 돌봄 공백 대책을 마련했어요',
  ];

  final Set<int> _checked = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('양육 체크리스트')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Card(
            color: const Color(0xFFEAF1E8),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text('확인한 항목 ${_checked.length} / ${_items.length}'),
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < _items.length; index++)
            Card(
              color: Colors.white,
              elevation: 0,
              child: CheckboxListTile(
                value: _checked.contains(index),
                title: Text(_items[index]),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) => setState(() {
                  if (value == true) {
                    _checked.add(index);
                  } else {
                    _checked.remove(index);
                  }
                }),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            '체크 상태는 현재 화면에서만 유지됩니다. 저장 기능은 추후 연결할 수 있어요.',
            style: TextStyle(color: Color(0xFF5F6A60)),
          ),
        ],
      ),
    );
  }
}
