/// 추천 견종 이름을 눌렀을 때 특성·견종백과 영상을 보여 주는 창.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/breed_encyclopedia.dart';
import '../../data/breed_match.dart';
import '../../data/breed_names_ko.dart';
import '../../data/dog_breed.dart';

/// 유튜브를 연다. 테스트에서는 이 함수를 바꿔 브라우저를 안 띄운다.
Future<bool> openEncyclopediaUrl(Uri uri) {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// 자가점검 추천 목록에서 견종 한 마리에 대한 참고 정보.
Future<void> showBreedDetailSheet({
  required BuildContext context,
  required DogBreed breed,
  required BreedPreference preference,
  Future<bool> Function(Uri uri)? openUrl,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => BreedDetailSheet(
      breed: breed,
      preference: preference,
      openUrl: openUrl ?? openEncyclopediaUrl,
    ),
  );
}

class BreedDetailSheet extends StatelessWidget {
  const BreedDetailSheet({
    super.key,
    required this.breed,
    required this.preference,
    required this.openUrl,
  });

  final DogBreed breed;
  final BreedPreference preference;
  final Future<bool> Function(Uri uri) openUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final videos = encyclopediaVideosFor(breed.name);
    final covered = encyclopediaCovers(breed.name);
    final display = breedDisplayName(breed.name);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(display, style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                '견종 특성은 참고이며, 실제 성향은 개체마다 다릅니다. 입양 허가·거부가 아닙니다.',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
              if (breed.imageLink.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    breed.imageLink,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip('활동량 ${breed.energy}'),
                  _chip('짖음 ${breed.barking}'),
                  _chip('털 빠짐 ${breed.shedding}'),
                  _chip('미용 ${breed.grooming}'),
                  _chip('훈련 ${breed.trainability}'),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '자가점검과 맞춰 보기',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF2F6F4E),
                  fontWeight: FontWeight.w700,
                ),
              ),
              for (final line in breedFitLines(breed, preference))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
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
              const SizedBox(height: 16),
              Text(
                '강형욱의 견종백과',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                covered
                    ? '보듬TV 견종백과에서 이 견종 제목으로 올라온 편입니다. 해당 영상을 유튜브에서 볼 수 있습니다.'
                    : '이 견종 제목의 견종백과 편은 아직 없습니다.',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 10),
              for (final video in videos) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      video.thumbUri.toString(),
                      width: 72,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.play_circle_outline),
                    ),
                  ),
                  title: Text(video.title),
                  subtitle: const Text('유튜브에서 이 편 보기'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _open(context, video.watchUri),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: const Color(0xFFF7F5EF),
      side: BorderSide.none,
    );
  }

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await openUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('영상을 열 수 없습니다. 유튜브 앱 또는 브라우저를 확인해 주세요.')),
      );
    }
  }
}
