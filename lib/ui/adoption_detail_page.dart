import 'package:flutter/material.dart';

import '../data/rescued_dog.dart';

class AdoptionDetailPage extends StatelessWidget {
  const AdoptionDetailPage({super.key, required this.dog});

  final RescuedDog dog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보호동물 상세정보')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: dog.imageUrl.isEmpty
                ? Container(
                    height: 260,
                    color: const Color(0xFFEAF1E8),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.pets,
                      size: 56,
                      color: Color(0xFF2F6F4E),
                    ),
                  )
                : Image.network(
                    dog.imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 260,
                      color: const Color(0xFFEAF1E8),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.pets,
                        size: 56,
                        color: Color(0xFF2F6F4E),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            dog.breedName.isEmpty ? '견종 정보 없음' : dog.breedName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (dog.processState.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(label: Text(dog.processState)),
            ),
          ],
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
                children: [
                  _DetailRow(label: '나이', value: dog.age),
                  _DetailRow(label: '성별', value: dog.sexLabel),
                  _DetailRow(label: '발견일', value: _formatDate(dog.foundDate)),
                  _DetailRow(label: '공고번호', value: dog.noticeNo),
                  _DetailRow(label: '보호소', value: dog.shelterName),
                  _DetailRow(label: '주소', value: dog.shelterAddress),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '입양 절차와 현재 보호 상태는 방문 전 보호소에 문의해 확인해 주세요.',
            style: TextStyle(color: Color(0xFF5F6A60), height: 1.4),
          ),
        ],
      ),
    );
  }

  String _formatDate(String value) {
    if (value.length != 8) return value.isEmpty ? '정보 없음' : value;
    return '${value.substring(0, 4)}.${value.substring(4, 6)}.'
        '${value.substring(6, 8)}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF5F6A60)),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '정보 없음' : value)),
        ],
      ),
    );
  }
}
