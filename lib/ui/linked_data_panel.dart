import 'package:flutter/material.dart';

import '../data/breed_match.dart';
import '../data/breed_names_ko.dart';
import '../data/dog_breed.dart';
import '../data/dogs_api_client.dart';
import '../diagnosis/care_profile.dart';

class LinkedDataPanel extends StatefulWidget {
  const LinkedDataPanel({
    super.key,
    required this.profile,
    this.dogsApi,
  });

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('자가점검에 맞는 견종', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(_preference.summary),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '다른 견종 이름',
            hintText: '예: 푸들, 시바견, golden retriever',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _loadingBreeds ? null : _searchByName,
          child: const Text('이름으로 찾기'),
        ),
        if (_loadingBreeds) ...[
          const SizedBox(height: 12),
          const Text('견종을 찾고 있습니다.'),
        ],
        if (_breedMessage != null) ...[
          const SizedBox(height: 12),
          Text(_breedMessage!),
        ],
        for (final breed in _breeds) ...[
          const SizedBox(height: 12),
          Text(
            breedDisplayName(breed.name),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            '활동량 ${breed.energy} · 짖음 ${breed.barking} · 털 빠짐 ${breed.shedding} · 미용 ${breed.grooming}',
          ),
          const SizedBox(height: 4),
          Text(
            breedFitLines(breed, _preference).every((line) => line.fits)
                ? '평가 기준과 대체로 맞습니다.'
                : '맞는 점과 안 맞을 수 있는 점',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          for (final line in breedFitLines(breed, _preference)) Text(line.text),
        ],
      ],
    );
  }
}
