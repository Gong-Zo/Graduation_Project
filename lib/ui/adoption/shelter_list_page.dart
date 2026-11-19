/// 공공데이터 보호센터 목록. 시도·시군구·이름으로 찾는다.
/// 드롭다운을 ListView 안에 두면 메뉴를 열 때 슬라이버 인덱스 오류가 나서, 필터는 위에 고정한다.
import 'package:flutter/material.dart';

import '../../data/abandonment_api_client.dart';
import '../../data/animal_shelter.dart';
import 'shelter_detail_page.dart';

class ShelterListPage extends StatefulWidget {
  const ShelterListPage({super.key, this.api});

  final AbandonmentApiClient? api;

  @override
  State<ShelterListPage> createState() => _ShelterListPageState();
}

class _ShelterListPageState extends State<ShelterListPage> {
  late final AbandonmentApiClient _api;
  final _queryController = TextEditingController();
  List<RegionCode> _sido = const [];
  List<RegionCode> _sigungu = const [];
  List<AnimalShelter> _shelters = const [];
  String? _sidoCode;
  String? _sigunguCode;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AbandonmentApiClient();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sido = await _api.fetchSido();
      final seoul = sido.where((item) => item.name.contains('서울')).toList();
      final sidoCode = seoul.isNotEmpty
          ? seoul.first.code
          : (sido.isNotEmpty ? sido.first.code : null);
      final sigungu = sidoCode == null
          ? const <RegionCode>[]
          : await _api.fetchSigungu(sidoCode);
      final gangnam = sigungu.where((item) => item.name.contains('강남')).toList();
      final sigunguCode = gangnam.isNotEmpty
          ? gangnam.first.code
          : (sigungu.isNotEmpty ? sigungu.first.code : null);
      final shelters = await _api.fetchShelters(
        uprCd: sidoCode,
        orgCd: sigunguCode,
      );
      if (!mounted) return;
      setState(() {
        _sido = sido;
        _sidoCode = sidoCode;
        _sigungu = sigungu;
        _sigunguCode = sigunguCode;
        _shelters = shelters;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSigungu(String uprCd) async {
    try {
      final list = await _api.fetchSigungu(uprCd);
      if (!mounted) return;
      final next = list.isNotEmpty ? list.first.code : null;
      setState(() {
        _sigungu = list;
        _sigunguCode = next;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sigungu = const [];
        _sigunguCode = null;
      });
    }
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final shelters = await _api.fetchShelters(
        uprCd: _sidoCode,
        orgCd: _sigunguCode,
        name: _queryController.text,
        rows: 80,
      );
      if (!mounted) return;
      setState(() => _shelters = shelters);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보호소 검색·목록')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: _filters(),
          ),
          const Divider(height: 1),
          Expanded(child: _resultPane()),
        ],
      ),
    );
  }

  Widget _filters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '시군구를 고른 뒤 검색하세요. 방문 전 운영과 입양 가능 여부는 보호소에 확인해 주세요.',
          style: TextStyle(height: 1.45),
        ),
        const SizedBox(height: 12),
        if (_sido.isEmpty)
          const InputDecorator(
            decoration: InputDecoration(labelText: '시도'),
            child: Text('시도를 불러오는 중'),
          )
        else
          DropdownButtonFormField<String>(
            key: const Key('shelterSidoDropdown'),
            value: _dropdownValue(_sidoCode, _sido),
            isExpanded: true,
            decoration: const InputDecoration(labelText: '시도'),
            items: [
              for (final item in _sido)
                DropdownMenuItem(value: item.code, child: Text(item.name)),
            ],
            onChanged: (value) async {
              setState(() => _sidoCode = value);
              if (value != null) await _loadSigungu(value);
            },
          ),
        const SizedBox(height: 10),
        if (_sigungu.isEmpty)
          const InputDecorator(
            decoration: InputDecoration(labelText: '시군구'),
            child: Text('시도를 고르면 시군구가 나옵니다'),
          )
        else
          DropdownButtonFormField<String>(
            key: const Key('shelterSigunguDropdown'),
            value: _dropdownValue(_sigunguCode, _sigungu),
            isExpanded: true,
            decoration: const InputDecoration(labelText: '시군구'),
            items: [
              for (final item in _sigungu)
                DropdownMenuItem(value: item.code, child: Text(item.name)),
            ],
            onChanged: (value) => setState(() => _sigunguCode = value),
          ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('shelterSearchField'),
          controller: _queryController,
          decoration: const InputDecoration(
            labelText: '보호소 이름',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _search(),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          key: const Key('shelterSearchButton'),
          onPressed: _loading ? null : _search,
          icon: const Icon(Icons.search),
          label: const Text('보호소 검색'),
        ),
      ],
    );
  }

  /// 목록에 없는 값은 넣지 않는다. 드롭다운 assertion을 막는다.
  String? _dropdownValue(String? code, List<RegionCode> regions) {
    if (code == null) return null;
    for (final item in regions) {
      if (item.code == code) return code;
    }
    return null;
  }

  Widget _resultPane() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [Text('보호소 정보를 불러오지 못했어요.\n$_error')],
      );
    }
    if (!_api.isConfigured) {
      return const Center(child: Text('보호소 정보를 보려면 공공데이터 API 키를 설정해 주세요.'));
    }
    if (_shelters.isEmpty) {
      return const Center(child: Text('조건에 맞는 보호소가 없습니다. 시군구를 바꿔 검색해 보세요.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: _shelters.length,
      itemBuilder: (context, index) {
        final shelter = _shelters[index];
        return Card(
          key: Key('shelterCard_${shelter.id}'),
          color: Colors.white,
          elevation: 0,
          child: ListTile(
            title: Text(
              shelter.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              [
                if (shelter.address.isNotEmpty) shelter.address,
                if (shelter.phone.isNotEmpty) shelter.phone,
              ].join('\n'),
            ),
            isThreeLine: shelter.phone.isNotEmpty && shelter.address.isNotEmpty,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ShelterDetailPage(shelter: shelter, api: _api),
              ),
            ),
          ),
        );
      },
    );
  }
}
