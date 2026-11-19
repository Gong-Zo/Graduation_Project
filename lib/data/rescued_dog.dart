/// 공공데이터 유기동물 한 건. 화면에 아직 연결하지 않았다.
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
    this.careRegNo = '',
    this.careTel = '',
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
  final String careRegNo;
  final String careTel;

  String get sexLabel => switch (sex) {
    'M' => '수컷',
    'F' => '암컷',
    'Q' => '미상',
    _ => sex,
  };

  Map<String, Object?> toJson() => {
    'noticeNo': noticeNo,
    'breedName': breedName,
    'age': age,
    'sex': sex,
    'processState': processState,
    'shelterName': shelterName,
    'shelterAddress': shelterAddress,
    'imageUrl': imageUrl,
    'foundDate': foundDate,
    'careRegNo': careRegNo,
    'careTel': careTel,
  };

  factory RescuedDog.fromJson(Map<String, Object?> json) {
    return RescuedDog(
      noticeNo: json['noticeNo'] as String? ?? '',
      breedName: json['breedName'] as String? ?? '',
      age: json['age'] as String? ?? '',
      sex: json['sex'] as String? ?? '',
      processState: json['processState'] as String? ?? '',
      shelterName: json['shelterName'] as String? ?? '',
      shelterAddress: json['shelterAddress'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      foundDate: json['foundDate'] as String? ?? '',
      careRegNo: json['careRegNo'] as String? ?? '',
      careTel: json['careTel'] as String? ?? '',
    );
  }
}
