/// Dogs API로 견종을 찾고, 준비도 점수와 별도로 맞는 점·안 맞는 점을 보여 준다.
import 'package:flutter/material.dart';

import '../data/breed_match.dart';
import '../data/breed_names_ko.dart';
import '../data/dog_breed.dart';
import '../data/dogs_api_client.dart';
import '../diagnosis/care_profile.dart';

/// 공공데이터 유기동물 API는 호출하지 않는다. 견종 검색만 한다.
class LinkedDataPanel extends StatefulWidget {
  const LinkedDataPanel({super.key, required this.profile, this.dogsApi});

  final CareProfile profile;
  final DogsApiClient? dogsApi;

  @override
  State<LinkedDataPanel> createState() => _LinkedDataPanelState();
}

class _LinkedDataPanelState extends State<LinkedDataPanel> {
  final _nameController = TextEditingController();
  late final BreedPreference _preference = BreedPreference.fromProfile(
    widget.profile,
  );
  List<DogBreed> _breeds = const [];
  String? _breedMessage;
  bool _loadingBreeds = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 생활 시간에 맞춘 energy부터 검색하고, 결과가 없으면 인접 energy를 시도한다.
  Future<void> _loadRecommendation() async {
    setState(() {
      _loadingBreeds = true;
      _breedMessage = null;
    });
    try {
      final api = widget.dogsApi ?? DogsApiClient();
      var found = const <DogBreed>[];
      for (final energy in energyQueryOrder(_preference.energy)) {
        found = await api.search(energy: energy);
        if (found.isNotEmpty) break;
      }
      if (!mounted) return;
      final ranked = rankBreeds(found, _preference);
      setState(() {
        _breeds = ranked;
        _breedMessage = ranked.isEmpty ? '조건에 맞는 견종이 없습니다.' : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _breedMessage = '$error');
    } finally {
      if (mounted) setState(() => _loadingBreeds = false);
    }
  }

  Future<void> _searchByName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      await _loadRecommendation();
      return;
    }
    setState(() {
      _loadingBreeds = true;
      _breedMessage = null;
    });
    try {
      final queries = englishBreedQueries(name);
      if (queries.isEmpty) {
        if (!mounted) return;
        setState(() {
          _breeds = const [];
          _breedMessage = '해당하는 견종 이름을 찾지 못했습니다. 영어 이름도 함께 적어 보세요.';
        });
        return;
      }
      final api = widget.dogsApi ?? DogsApiClient();
      final found = <String, DogBreed>{};
      for (final query in queries) {
        for (final breed in await api.search(name: query)) {
          found[breed.name] = breed;
        }
      }
      if (!mounted) return;
      final ranked = rankBreeds(found.values.toList(), _preference);
      setState(() {
        _breeds = ranked;
        _breedMessage = ranked.isEmpty ? '조건에 맞는 견종이 없습니다.' : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _breedMessage = '$error');
    } finally {
      if (mounted) setState(() => _loadingBreeds = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Card(
          color: const Color(0xFFEAF1E8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.pets, color: Color(0xFF2F6F4E)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '생활에 맞는 견종 찾아보기',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _preference.summary,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '견종 이름으로 검색',
                    hintText: '예: 푸들, 시바견, golden retriever',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loadingBreeds ? null : _searchByName,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: const Color(0xFF2F6F4E),
                      side: const BorderSide(color: Color(0xFF2F6F4E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('견종 검색'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_loadingBreeds) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const Text('조건에 맞는 견종을 찾고 있어요.'),
        ],
        if (_breedMessage != null) ...[
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF6D756B)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_breedMessage!)),
                ],
              ),
            ),
          ),
        ],
        for (final breed in _breeds) ...[
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFE8E6DE)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breedDisplayName(breed.name),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _traitChip('활동량 ${breed.energy}'),
                      _traitChip('짖음 ${breed.barking}'),
                      _traitChip('털 빠짐 ${breed.shedding}'),
                      _traitChip('미용 ${breed.grooming}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    breedFitLines(breed, _preference).every((line) => line.fits)
                        ? '평가 기준과 대체로 맞습니다.'
                        : '맞는 점과 안 맞을 수 있는 점',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF2F6F4E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final line in breedFitLines(breed, _preference))
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            line.fits
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            size: 18,
                            color: line.fits
                                ? const Color(0xFF4F8460)
                                : const Color(0xFFB96835),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(line.text)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _traitChip(String label) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: const Color(0xFFF7F5EF),
      side: BorderSide.none,
    );
  }
}
