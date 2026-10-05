class RescuedDog {
  const RescuedDog({
    required this.noticeNo,
    required this.breedName,
    required this.age,
    required this.sex,
    required this.processState,
    required this.shelterName,
    required this.shelterAddress,
    required this.imageUrl,
    required this.foundDate,
  });

  final String noticeNo;
  final String breedName;
  final String age;
  final String sex;
  final String processState;
  final String shelterName;
  final String shelterAddress;
  final String imageUrl;
  final String foundDate;

  String get sexLabel => switch (sex) {
    'M' => '수컷',
    'F' => '암컷',
    'Q' => '미상',
    _ => sex,
  };
}
