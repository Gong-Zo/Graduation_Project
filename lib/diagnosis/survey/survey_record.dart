/// 회원 계정에 남기는 60문항 자가점검 한 건. 점수는 엔진 값을 그대로 둔다.
import 'survey_scorer.dart';

class SurveyRecord {
  const SurveyRecord({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.score,
  });

  final String id;
  final String userId;
  final DateTime createdAt;
  final SurveyScore score;

  Map<String, Object?> toJson() => {
    'id': id,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'score': score.toJson(),
  };

  factory SurveyRecord.fromJson(Map<String, Object?> json) {
    return SurveyRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      score: SurveyScore.fromJson(
        Map<String, Object?>.from(json['score'] as Map),
      ),
    );
  }

  String get createdAtLabel {
    final local = createdAt.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}.${two(local.month)}.${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
