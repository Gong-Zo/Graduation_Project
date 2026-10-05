/// 1인 가구 예비 반려인의 반려견 준비도 기준.
///
/// 영역 가중치는 2025년 동물복지 국민의식조사에서 입양 계획이 없는 이유
/// 시간 25.3%, 경제 18.2%, 관리 자신 부족 16.3%를 합 59.8로 나눈 값이다.
/// 주거 점수는 이 문항에 비율이 없어 종합 가중치에 넣지 않는다.
/// 월 예산 만점선은 2025년 반려동물 양육현황조사의 반려견 월평균 13만 5천 원이다.
/// 영역 안 항목 점수와 라벨 구간, 부재 10시간 경고선은 설계값이다.
abstract final class DiagnosisConfig {
  static const lifeWeight = 0.42;
  static const economyWeight = 0.31;
  static const responsibilityWeight = 0.27;

  static const dogMonthlyMeanKrw = 135000;
  static const budgetFullKrw = dogMonthlyMeanKrw;
  static const budgetTwoThirdsKrw = 101250;
  static const budgetOneThirdKrw = 67500;

  static const absenceFullHours = 4;
  static const absenceHighHours = 6;
  static const absenceMidHours = 8;
  static const absenceWarningHours = 10;

  static const careFullMinutes = 120;
  static const careHighMinutes = 90;
  static const careMidMinutes = 60;
  static const careLowMinutes = 30;

  static const outingFullDays = 1;
  static const outingMidDays = 3;
  static const outingLowDays = 5;

  static const readyMinScore = 75;
  static const needsWorkMinScore = 50;

  static const gapOverestimateRatio = 0.7;

  static const boundaryText = '이 안내는 입양 허가나 거부가 아닙니다.';
}
