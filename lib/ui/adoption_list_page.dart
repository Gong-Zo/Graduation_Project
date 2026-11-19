/// 유기동물 목록 UI. 키가 없으면 안내만 하고 빈 목록을 보여 준다.
import 'package:flutter/material.dart';

import '../data/abandonment_api_client.dart';
import '../data/rescued_dog.dart';
import 'adoption_detail_page.dart';

class AdoptionListPage extends StatefulWidget {
  const AdoptionListPage({super.key, this.api});

  final AbandonmentApiClient? api;

  @override
  State<AdoptionListPage> createState() => _AdoptionListPageState();
}

class _AdoptionListPageState extends State<AdoptionListPage> {
  late final AbandonmentApiClient _api;
  List<RescuedDog> _dogs = const [];
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AbandonmentApiClient();
    _loadDogs();
  }

  Future<void> _loadDogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dogs = await _api.fetchRecentDogs(days: 30, rows: 20);
      if (!mounted) return;
      setState(() => _dogs = dogs);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보호동물 만나기'),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: _loading ? null : _loadDogs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _MessageView(
              icon: Icons.error_outline,
              message: '보호동물 정보를 불러오지 못했어요.\n$_error',
              actionLabel: '다시 시도',
              onPressed: _loadDogs,
            )
          : _dogs.isEmpty
          ? _MessageView(
              icon: Icons.pets_outlined,
              message: _api.isConfigured
                  ? '최근 등록된 보호동물 정보가 없습니다.'
                  : '보호동물 정보를 보려면 공공데이터 API 키를 설정해 주세요.',
              actionLabel: _api.isConfigured ? null : '새로고침',
              onPressed: _api.isConfigured ? null : _loadDogs,
            )
          : RefreshIndicator(
              onRefresh: _loadDogs,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text(
                    '최근 30일 내 등록된 보호동물이에요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5F6A60),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final dog in _dogs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DogCard(
                        dog: dog,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AdoptionDetailPage(dog: dog),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _DogCard extends StatelessWidget {
  const _DogCard({required this.dog, required this.onTap});

  final RescuedDog dog;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE8E6DE)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DogImage(url: dog.imageUrl, height: 190),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dog.breedName.isEmpty ? '견종 정보 없음' : dog.breedName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (dog.processState.isNotEmpty)
                        Chip(
                          label: Text(dog.processState),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${dog.age.isEmpty ? '나이 정보 없음' : dog.age} · ${dog.sexLabel}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dog.shelterName.isEmpty ? '보호소 정보 없음' : dog.shelterName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5F6A60),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '상세 정보 보기  ›',
                      style: TextStyle(
                        color: Color(0xFF2F6F4E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DogImage extends StatelessWidget {
  const _DogImage({required this.url, required this.height});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _imagePlaceholder(height);
    return Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _imagePlaceholder(height),
    );
  }

  Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFEAF1E8),
      alignment: Alignment.center,
      child: const Icon(Icons.pets, size: 48, color: Color(0xFF2F6F4E)),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF2F6F4E)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onPressed, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
