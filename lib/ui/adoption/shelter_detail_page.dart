/// 보호소 상세. 공공데이터 항목과 그 보호소의 최근 보호동물을 보여 준다.
import 'package:flutter/material.dart';

import '../../data/abandonment_api_client.dart';
import '../../data/animal_shelter.dart';
import '../../data/rescued_dog.dart';
import '../../mypage/member_library_store.dart';
import '../adoption_detail_page.dart';
import '../mypage/favorite_buttons.dart';
import '../shared/feature_screen.dart';

class ShelterDetailPage extends StatefulWidget {
  const ShelterDetailPage({
    super.key,
    this.shelter,
    this.shelterName,
    this.address,
    this.api,
  });

  final AnimalShelter? shelter;
  final String? shelterName;
  final String? address;
  final AbandonmentApiClient? api;

  @override
  State<ShelterDetailPage> createState() => _ShelterDetailPageState();
}

class _ShelterDetailPageState extends State<ShelterDetailPage> {
  List<RescuedDog> _dogs = const [];
  bool _loadingDogs = false;

  AnimalShelter get _shelter {
    if (widget.shelter != null) return widget.shelter!;
    final name = widget.shelterName ?? '보호소 상세 미리보기';
    return AnimalShelter(
      id: name,
      name: name,
      address: widget.address ?? '',
    );
  }

  @override
  void initState() {
    super.initState();
    final id = widget.shelter?.id;
    if (id != null && id.isNotEmpty) {
      _loadDogs(id);
    }
  }

  Future<void> _loadDogs(String careRegNo) async {
    setState(() => _loadingDogs = true);
    try {
      final api = widget.api ?? AbandonmentApiClient();
      final dogs = await api.fetchRecentDogs(days: 60, rows: 12, careRegNo: careRegNo);
      if (!mounted) return;
      setState(() => _dogs = dogs);
    } catch (_) {
      if (!mounted) return;
      setState(() => _dogs = const []);
    } finally {
      if (mounted) setState(() => _loadingDogs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shelter = _shelter;
    final favorite = FavoriteShelter(
      id: shelter.id,
      name: shelter.name,
      address: shelter.address,
    );
    return FeatureScreen(
      title: '보호소 상세정보',
      description: widget.shelter == null && widget.shelterName == null
          ? '보호소 정보를 표시할 화면입니다. 목록에서 보호소를 고르면 공공데이터 항목이 채워집니다.'
          : '${shelter.name} 정보를 확인하고 관심 목록에 넣을 수 있어요.',
      icon: Icons.location_on_outlined,
      actions: [FavoriteShelterButton(shelter: favorite)],
      children: [
        FeatureInfoCard(
          title: '주소',
          description: shelter.address.isEmpty
              ? '주소 정보가 등록되어 있지 않습니다.'
              : shelter.address,
          icon: Icons.map_outlined,
        ),
        if (shelter.jibunAddress.isNotEmpty)
          FeatureInfoCard(
            title: '지번 주소',
            description: shelter.jibunAddress,
            icon: Icons.signpost_outlined,
          ),
        FeatureInfoCard(
          title: '연락처',
          description: shelter.phone.isEmpty
              ? '전화번호가 등록되어 있지 않습니다. 방문 전 보호소에 확인해 주세요.'
              : shelter.phone,
          icon: Icons.phone_outlined,
        ),
        if (shelter.orgName.isNotEmpty || shelter.divisionName.isNotEmpty)
          FeatureInfoCard(
            title: '운영 주체',
            description: [
              if (shelter.orgName.isNotEmpty) shelter.orgName,
              if (shelter.divisionName.isNotEmpty) shelter.divisionName,
            ].join(' · '),
            icon: Icons.account_balance_outlined,
          ),
        FeatureInfoCard(
          title: '운영시간',
          description: [
            if (shelter.weekdayHours.isNotEmpty) '평일 ${shelter.weekdayHours}',
            if (shelter.weekendHours.isNotEmpty) '주말 ${shelter.weekendHours}',
            if (shelter.closeDay.isNotEmpty) '휴무 ${shelter.closeDay}',
            if (shelter.weekdayHours.isEmpty &&
                shelter.weekendHours.isEmpty &&
                shelter.closeDay.isEmpty)
              '운영시간이 등록되어 있지 않습니다. 방문 전 보호소에 확인해 주세요.',
          ].join('\n'),
          icon: Icons.schedule_outlined,
        ),
        if (shelter.saveTarget.isNotEmpty)
          FeatureInfoCard(
            title: '구조 대상',
            description: shelter.saveTarget,
            icon: Icons.pets_outlined,
          ),
        _dogSection(),
      ],
    );
  }

  /// 공고 개수가 늘어도 바깥 ListView의 칸은 하나로 둔다.
  Widget _dogSection() {
    if (_loadingDogs) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_dogs.isEmpty) {
      return const FeatureInfoCard(
        title: '최근 보호동물',
        description: '이 보호소에 최근 등록된 개 공고가 없거나, 번호를 연결하지 못했습니다.',
        icon: Icons.pets_outlined,
      );
    }
    return Column(
      children: [
        for (final dog in _dogs)
          Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text(dog.breedName),
              subtitle: Text('${dog.sexLabel} · ${dog.processState}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AdoptionDetailPage(dog: dog),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
