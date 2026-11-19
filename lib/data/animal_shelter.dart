/// 공공데이터 동물보호센터 한 곳. 관심 목록에는 번호·이름·주소만 남긴다.
import '../mypage/member_library_store.dart';

class RegionCode {
  const RegionCode({required this.code, required this.name});

  final String code;
  final String name;
}

class AnimalShelter {
  const AnimalShelter({
    required this.id,
    required this.name,
    required this.address,
    this.jibunAddress = '',
    this.phone = '',
    this.orgName = '',
    this.divisionName = '',
    this.saveTarget = '',
    this.weekdayHours = '',
    this.weekendHours = '',
    this.closeDay = '',
  });

  final String id;
  final String name;
  final String address;
  final String jibunAddress;
  final String phone;
  final String orgName;
  final String divisionName;
  final String saveTarget;
  final String weekdayHours;
  final String weekendHours;
  final String closeDay;

  AnimalShelter copyWith({String? address, String? phone}) {
    return AnimalShelter(
      id: id,
      name: name,
      address: address ?? this.address,
      jibunAddress: jibunAddress,
      phone: phone ?? this.phone,
      orgName: orgName,
      divisionName: divisionName,
      saveTarget: saveTarget,
      weekdayHours: weekdayHours,
      weekendHours: weekendHours,
      closeDay: closeDay,
    );
  }

  FavoriteShelter toFavorite() =>
      FavoriteShelter(id: id, name: name, address: address);
}
