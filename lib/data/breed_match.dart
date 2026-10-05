import '../diagnosis/care_profile.dart';
import '../diagnosis/diagnosis_config.dart';
import 'dog_breed.dart';

/// 자가점검 입력으로 정한 견종 조건. 종합 점수와는 별도다.
class BreedPreference {
  const BreedPreference({
    required this.energy,
    required this.maxBarking,
    required this.maxGrooming,
    required this.maxShedding,
    required this.summary,
  });

  final int energy;
  final int? maxBarking;
  final int? maxGrooming;
  final int? maxShedding;
  final String summary;

  factory BreedPreference.fromProfile(CareProfile profile) {
    final lowTime =
        profile.absenceHours >= 8 ||
        profile.careMinutes < 60 ||
        profile.outingDaysPerWeek >= 5;
    final highTime =
        profile.absenceHours <= 4 &&
        profile.careMinutes >= 90 &&
        profile.outingDaysPerWeek <= 2;
    final energy = lowTime ? 2 : (highTime ? 4 : 3);
    final maxBarking = profile.noiseSensitive ? 2 : null;
    final maxGrooming =
        profile.monthlyBudgetKrw < DiagnosisConfig.dogMonthlyMeanKrw ? 2 : null;
    final maxShedding =
        profile.housingType == HousingType.studio ||
            profile.housingType == HousingType.officetel
        ? 2
        : null;

    final reasons = <String>[
      if (lowTime) '집에 있는 시간이 짧아 활동량이 낮은 견종',
      if (highTime) '돌봄 시간을 확보할 수 있어 활동량이 있는 견종',
      if (!lowTime && !highTime) '생활 시간에 맞춘 중간 활동량 견종',
      if (profile.noiseSensitive) '소음에 취약해 짖음이 낮은 견종',
      if (maxGrooming != null) '월 예산이 평균보다 낮아 미용 부담이 작은 견종',
      if (maxShedding != null) '좁은 주거라 털 빠짐이 적은 견종',
    ];

    return BreedPreference(
      energy: energy,
      maxBarking: maxBarking,
      maxGrooming: maxGrooming,
      maxShedding: maxShedding,
      summary: '${reasons.join(', ')}을 앞에 둡니다.',
    );
  }
}

List<int> energyQueryOrder(int energy) {
  return switch (energy) {
    1 => const [1, 2],
    2 => const [2, 1, 3],
    4 => const [4, 3, 5],
    5 => const [5, 4],
    _ => const [3, 2, 4],
  };
}

int breedMatchScore(DogBreed breed, BreedPreference preference) {
  var score = breed.energy == preference.energy ? 3 : 0;
  score += _limitScore(breed.barking, preference.maxBarking, 2);
  score += _limitScore(breed.grooming, preference.maxGrooming, 1);
  score += _limitScore(breed.shedding, preference.maxShedding, 1);
  return score;
}

int _limitScore(int value, int? max, int weight) {
  if (max == null) return 0;
  return value <= max ? weight : -weight;
}

List<DogBreed> rankBreeds(List<DogBreed> breeds, BreedPreference preference) {
  final ranked = [...breeds];
  ranked.sort((a, b) {
    final byScore = breedMatchScore(
      b,
      preference,
    ).compareTo(breedMatchScore(a, preference));
    if (byScore != 0) return byScore;
    return a.name.compareTo(b.name);
  });
  return ranked.take(5).toList();
}

List<String> breedMatchNotes(DogBreed breed, BreedPreference preference) {
  final notes = <String>[
    if (breed.energy > preference.energy) '활동량이 현재 생활 시간보다 높습니다.',
    if (preference.maxBarking != null && breed.barking > preference.maxBarking!)
      '짖음 수준이 높아 소음에 취약한 환경과 맞지 않습니다.',
    if (preference.maxGrooming != null &&
        breed.grooming > preference.maxGrooming!)
      '미용 부담이 현재 예산보다 큽니다.',
    if (preference.maxShedding != null &&
        breed.shedding > preference.maxShedding!)
      '털 빠짐이 많아 좁은 주거와 맞지 않습니다.',
  ];
  if (notes.isEmpty) notes.add('자가점검 조건에 맞습니다.');
  return notes;
}
