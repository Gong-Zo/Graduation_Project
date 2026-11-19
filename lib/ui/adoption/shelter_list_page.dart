/// 공공데이터 보호센터 목록. 시도·시군구·이름으로 찾는다.
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
      final selected = seoul.isNotEmpty
          ? seoul.first.code
          : (sido.isNotEmpty ? sido.first.code : null);
      final shelters = await _api.fetchShelters(uprCd: selected, rows: 80);
      if (!mounted) return;
      setState(() {
        _sido = sido;
        _sidoCode = selected;
        _shelters = shelters;
      });
      if (selected != null) await _loadSigungu(selected);
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
      setState(() {
        _sigungu = list;
        _sigunguCode = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _sigungu = const []);
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Card(
            color: Color(0xFFEAF1E8),
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                '농림축산검역본부 공공데이터로 전국 동물보호센터를 찾습니다. 방문 전 운영과 입양 가능 여부는 보호소에 확인해 주세요.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const Key('shelterSidoDropdown'),
            value: _sidoCode,
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
          DropdownButtonFormField<String>(
            key: const Key('shelterSigunguDropdown'),
            value: _sigunguCode ?? '',
            decoration: const InputDecoration(labelText: '시군구'),
            items: [
              const DropdownMenuItem(value: '', child: Text('전체')),
              for (final item in _sigungu)
                DropdownMenuItem(value: item.code, child: Text(item.name)),
            ],
            onChanged: (value) => setState(
              () => _sigunguCode = (value == null || value.isEmpty) ? null : value,
            ),
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
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Text('보호소 정보를 불러오지 못했어요.\n$_error')
          else if (!_api.isConfigured)
            const Text('보호소 정보를 보려면 공공데이터 API 키를 설정해 주세요.')
          else if (_shelters.isEmpty)
            const Text('조건에 맞는 보호소가 없습니다. 시도와 이름을 바꿔 검색해 보세요.')
          else
            for (final shelter in _shelters)
              Card(
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
                  isThreeLine: shelter.phone.isNotEmpty,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ShelterDetailPage(shelter: shelter, api: _api),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
