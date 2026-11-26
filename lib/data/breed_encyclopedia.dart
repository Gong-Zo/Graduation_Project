// 강형욱 견종백과 각 편 제목에서 견종을 읽어 API 이름과 맞춘다. 입양 판단용이 아니다.
import 'breed_names_ko.dart';

/// 견종백과 한 편. 유튜브에서 연다.
class EncyclopediaVideo {
  const EncyclopediaVideo({
    required this.title,
    required this.youtubeId,
  });

  final String title;
  final String youtubeId;

  Uri get watchUri =>
      Uri.parse('https://www.youtube.com/watch?v=$youtubeId');

  Uri get thumbUri =>
      Uri.parse('https://img.youtube.com/vi/$youtubeId/hqdefault.jpg');
}

/// 보듬TV 견종백과 재생목록에서 가져온 편. 예고·모집 글은 매칭에서 뺀다.
const encyclopediaEpisodes = <EncyclopediaVideo>[
  EncyclopediaVideo(title: "늑대견이지롱! | 견종백과 체코슬로바키안 울프독편", youtubeId: "ZRwn--6XQak"),
  EncyclopediaVideo(title: "빗질은 하루에 두시간씩. 감당할 수 있겠습니까 | 견종백과 아프간하운드편", youtubeId: "XT9dQKeel24"),
  EncyclopediaVideo(title: "순수 외모 체급으로 웃겨주는 강아지 | 견종백과 불테리어편", youtubeId: "bcOaka8Coe0"),
  EncyclopediaVideo(title: "몽골에서 누가 돌아왔게~? 늑대로부터 가축을 지키는 몽골의 전설 방카르 | 견종백과 방카르편", youtubeId: "FKU3fsqHF6A"),
  EncyclopediaVideo(title: "어떻게 사자를 때려 잡을지 감도 안옴 | 견종백과 로디지안 리지백편", youtubeId: "e0KsyKxZzGE"),
  EncyclopediaVideo(title: "아프리카 대표 견종 등장 | 견종백과 바센지편", youtubeId: "BDkaIZU9pWs"),
  EncyclopediaVideo(title: "키우는 건 왕 어려움 | 견종백과 코카시안 오브차카편", youtubeId: "kWP6Ij1U2Sg"),
  EncyclopediaVideo(title: "생닭 아니고 강아지임 | 견종백과 차이니즈 크레스티드편", youtubeId: "aXcqhwZT7vo"),
  EncyclopediaVideo(title: "현실은 이진 | 견종백과 아키타이누편", youtubeId: "qWAsiYogbz8"),
  EncyclopediaVideo(title: "강형욱 첫사랑 공개합니다 | 견종백과 그로넨달편", youtubeId: "XqeqKOUuim0"),
  EncyclopediaVideo(title: "내 헤드뱅잉이 멈추지 않는 탓일까? T.T | 견종백과 오스트레일리안 셰퍼드편", youtubeId: "C3sr_JXNq4k"),
  EncyclopediaVideo(title: "달 것 같진 않음... | 견종백과 복서편", youtubeId: "bwboXJtpKBg"),
  EncyclopediaVideo(title: "강형욱이 가장 사랑했던 견종 | 견종백과 저먼셰퍼드편", youtubeId: "8M7xXbZzUvw"),
  EncyclopediaVideo(title: "근데 별명이 '미국 신사견' | 견종백과 보스턴 테리어편", youtubeId: "b4ZnB8kr1Ow"),
  EncyclopediaVideo(title: "영상에서 꼬순내가 진동함 ㄷㄷ | 견종백과 말티푸편", youtubeId: "VQa6yYqa2MU"),
  EncyclopediaVideo(title: "악마견도 혀를 내두르는 새로운 악마견 | 견종백과 달마시안편", youtubeId: "DEmu-FFQS6s"),
  EncyclopediaVideo(title: "폭신♥ 손이 털 속에 숨어버림  | 견종백과 꼬똥 드 툴레아편", youtubeId: "Gg2WQKSb1QY"),
  EncyclopediaVideo(title: "66%의 압도적 개물림 사고 지분율 | 견종백과 핏불 테리어편", youtubeId: "u1RyuNsObxU"),
  EncyclopediaVideo(title: "러시아 진돗개는 호랑이도 잡습니다｜견종백과 라이카편", youtubeId: "-TWWe33nK_I"),
  EncyclopediaVideo(title: "미용비 빼면 단점이 없는 하이브리드견종 | 견종백과 골든두들편", youtubeId: "HfeoPM0C5-Y"),
  EncyclopediaVideo(title: "본인들도 잘난 거를 아는 비주얼 | 견종백과 그레이하운드편", youtubeId: "Cv6dJvk-3sg"),
  EncyclopediaVideo(title: "그레이트 데인씨 카리스마에 녹아버린 강형욱 | 견종백과 그레이트 데인편", youtubeId: "sForpbRdCWI"),
  EncyclopediaVideo(title: "통나무 강아지 | 견종백과 노리치 테리어편", youtubeId: "hw_LqApxMt0"),
  EncyclopediaVideo(title: "개훌륭 단골 출연견. 드디어 나왔습니다 | 견종백과 로트와일러편", youtubeId: "s4GuF4HMTlc"),
  EncyclopediaVideo(title: "쭉쭉 늘어납니다~! (like 모짜렐라)  | 견종백과 샤페이편", youtubeId: "scowNj7Pyak"),
  EncyclopediaVideo(title: "신이라 불리는 강아지. 이집트 벽화에도 존재함ㄷㄷ | 견종백과 살루키편", youtubeId: "BDHZh_Y8jck"),
  EncyclopediaVideo(title: "내가 왕이 될 상인가. 성질머리에 비해 몸이 작아 슬픈 미니핀 | 견종백과 미니어처 핀셔편", youtubeId: "jbs_A0FT16c"),
  EncyclopediaVideo(title: "유리몸 강아지. 내 지갑도 와장창... | 견종백과 잉글리쉬 불독편", youtubeId: "iQD00qkGya4"),
  EncyclopediaVideo(title: "지랄총량 따위는 없는 무한체력 악마견 | 견종백과 잭 러셀 테리어편", youtubeId: "NHGkLb5ifu4"),
  EncyclopediaVideo(title: "귀로 땅바닥 쓸고 다님 | 견종백과 바셋하운드편", youtubeId: "soIoUq72J3w"),
  EncyclopediaVideo(title: "역대 최고 몸무게와 크기를 자랑하는 강형욱의 드림견 등장 | 견종백과 아이리시 울프 하운드편", youtubeId: "K4SCokZRZG8"),
  EncyclopediaVideo(title: "귀털 자르면 안 되세요. 얼마나 소중한 건데. | 견종백과 카발리에 킹 찰스 스파니엘편", youtubeId: "-uX4Sa09TZ8"),
  EncyclopediaVideo(title: "형이라 부를게요.... | 견종백과 아메리칸 불리편", youtubeId: "e-k1EnAWBS4"),
  EncyclopediaVideo(title: "앞이 안 보이니깤! | 견종백과 삽살개편", youtubeId: "2tNFHa3LWT4"),
  EncyclopediaVideo(title: "(리트리버 아님)1박2일 마스코트였던 '그레이트 피레니즈' 두둥등장 | 견종백과 그레이트 피레니즈편", youtubeId: "Lhi7tJzRKXk"),
  EncyclopediaVideo(title: "누구나 마트에서 한 번쯤 봤을 '그 강아지' | 견종백과 웨스트 하이랜드 화이트 테리어편", youtubeId: "gLcYWT4Z0gI"),
  EncyclopediaVideo(title: "영상 내내 공만 찾음 | 견종백과 베들링턴테리어편", youtubeId: "_5OEV4P1_HU"),
  EncyclopediaVideo(title: "스피츠가 예민보스인 이유 | 견종백과 스피츠편", youtubeId: "6vvszdv5pDY"),
  EncyclopediaVideo(title: "\"악마야 물러가라\" 조기교육 필수인 도베르만 | 견종백과 도베르만 핀셔편", youtubeId: "eJvcoohXDuY"),
  EncyclopediaVideo(title: "메롱하면 혓바닥이 보라색인 강아지ㅣ견종백과 차우차우 편", youtubeId: "FCrjawLVIWo"),
  EncyclopediaVideo(title: "강형욱에게 트라우마가 된 견종 | 견종백과 와이어 폭스테리어편", youtubeId: "L5yvqZfpR64"),
  EncyclopediaVideo(title: "귀여워서 쌍코피 터집니다 (*편집자 3번 터짐) | 견종백과 버니즈 마운틴 독편", youtubeId: "x7EmWZsKGVg"),
  EncyclopediaVideo(title: "강형욱도 키우기 힘들다는 견종(일반인 키우기 금지) | 견종백과 말리노이즈편", youtubeId: "8owAHlSFqvA"),
  EncyclopediaVideo(title: "24시간 돌아갑니다. 경고했습니다. | 견종백과 코카스파니엘편", youtubeId: "_6L4ZVPUJhs"),
  EncyclopediaVideo(title: "털 빠짐도 한도초과! 사모예드 우유가 왔어요 | 견종백과 사모예드편", youtubeId: "E8FPnTQxFMo"),
  EncyclopediaVideo(title: "역대 최고 몸무게와 최고 난이도 등극한 어마어마한 초대형견ㅣ견종백과 세인트 버나드 편", youtubeId: "XqLPk37ZtQs"),
  EncyclopediaVideo(title: "참기름 강아지 | 견종백과 닥스훈트편", youtubeId: "NBT2QrulQp8"),
  EncyclopediaVideo(title: "근데 강형욱앞에선 얌전함 | 견종백과 이탈리안 그레이하운드편", youtubeId: "Iw0ElufMEsU"),
  EncyclopediaVideo(title: "보호자가 불러도 안 옴ㅣ견종백과 시베리안 허스키편", youtubeId: "9xmqNrpO8bE"),
  EncyclopediaVideo(title: "이라면 보호자가 악마일 가능성 58000% | 견종백과 슈나우저편", youtubeId: "ghqEL4cP5yc"),
  EncyclopediaVideo(title: "한국에서 보기 진짜 어려운 견종ㅣ견종백과 헝가리안 풀리편", youtubeId: "4TzC6xWzWnw"),
  EncyclopediaVideo(title: "간이고 쓸개고 다 내줌ㅣ견종백과 골든 리트리버편", youtubeId: "x-PyGv9_CJ4"),
  EncyclopediaVideo(title: "예쁘면 다야? 응. 셸티 예뻐서 다야 | 견종백과 셰틀랜드 쉽독편", youtubeId: "Aj4PuxjIpvU"),
  EncyclopediaVideo(title: "10점 만점에 13점. 역대 최고 난이도ㅣ견종백과 와이마라너편", youtubeId: "TipuWIrP934"),
  EncyclopediaVideo(title: "세요 친구도 없으니까..  | 견종백과 프렌치불독편", youtubeId: "--RH6FC_uXs"),
  EncyclopediaVideo(title: "생긴 건 무서운데 성격은 리트리버 뺨치는 겉바속촉 포인터 | 견종백과 포인터편", youtubeId: "OM1QaXiWlDk"),
  EncyclopediaVideo(title: "파피용은 외모부터 성격까지 다 우아해 | 견종백과 파피용편", youtubeId: "3AY3xj_mpu4"),
  EncyclopediaVideo(title: "영상 내내 끌려 다님 | 견종백과 올드 잉글리쉬 쉽독편", youtubeId: "4AGmY-lOfYI"),
  EncyclopediaVideo(title: "영상 내내 먹기만 함 | 견종백과 래브라도 리트리버편", youtubeId: "FABOw10lRbg"),
  EncyclopediaVideo(title: "육구시타리아의 반전 매력. 내 안에 도베르만 있다.ㅣ견종백과 요크셔테리어편", youtubeId: "mgRcG6Z5kBY"),
  EncyclopediaVideo(title: "돈 내고 일하세요. 퍼그로 사심 채우는 강형욱ㅣ견종백과 퍼그편", youtubeId: "j220tzwpeZo"),
  EncyclopediaVideo(title: "도 견디게 하는 극강의 사랑스러움 🤍 | 견종백과 말티즈편", youtubeId: "9xFqDi0HOq8"),
  EncyclopediaVideo(title: "치와와 산책 많이 시키지 마세욜욜욜 | 견종백과 치와와편", youtubeId: "02rMn4giIUs"),
  EncyclopediaVideo(title: "강형욱은 진돗개를 싫어한다? | 견종백과 진돗개편", youtubeId: "vW6Ry2kdsBc"),
  EncyclopediaVideo(title: "육아 난이도 0에 수렴. | 견종백과 시츄편", youtubeId: "xZ0fO7PLY9M"),
  EncyclopediaVideo(title: "보더콜리 키우지 말래요 | 견종백과 보더콜리편", youtubeId: "H9McxKQ-dfk"),
  EncyclopediaVideo(title: "만지지 말고. 부르지 말고. 바라만 보세요. | 견종백과 시바이누편", youtubeId: "dLpy8sadZBA"),
  EncyclopediaVideo(title: "인건 알았는데 침도 한 바가지임 | 견종백과 웰시 코기편", youtubeId: "mXO3DfUgj0I"),
  EncyclopediaVideo(title: "서 봐준다 | 견종백과 포메라니안편", youtubeId: "MItHENgKUpQ"),
  EncyclopediaVideo(title: "엽긴 무슨 이제 당신은 250km를 달려야 합니다 | 견종백과 말라뮤트편", youtubeId: "3dkQJpO8eYI"),
  EncyclopediaVideo(title: "보호자와 떨어지기, 출근하기, 안 만져주기 | 견종백과 푸들편", youtubeId: "xIE-G1TWEHk"),
  EncyclopediaVideo(title: "세요 멈출 수 없으니까 | 견종백과 비숑프리제편", youtubeId: "Wf_A_cnwwvk"),
  EncyclopediaVideo(title: "지만 아이들과 키우기 좋음 | 견종백과 비글편", youtubeId: "2JJqg0JYYkI"),
  EncyclopediaVideo(title: "코카 스파니엘 미용&건강 편(크고 통통한 귀)｜강형욱의 견종백과 X 이승인 누가 X 하늘이", youtubeId: "-v27YncVI8o"),
  EncyclopediaVideo(title: "코카 스파니엘 식욕&성격 편(휴지의 비명,감정공감 최고)｜강형욱의 견종백과 X 이승인 누가 X 하늘이", youtubeId: "THoHZZQ2ibw"),
  EncyclopediaVideo(title: "코카 스파니엘 파괴력&에너지 편(집안 살림 바사삭 주의)｜강형욱의 견종백과 X 이승인 누가 X 하늘이", youtubeId: "GGd0vETcRQA"),
  EncyclopediaVideo(title: "사모예드 성격 편 (사회성,의심쟁이,사람이좋아)｜강형욱의 견종백과 X 극한견주 솜이 X 백곰이", youtubeId: "jrO8TeJ50DI"),
  EncyclopediaVideo(title: "사모예드 대형견&파워  편 (폭풍성장,전력질주)｜강형욱의 견종백과 X 극한견주 솜이 X 백곰이", youtubeId: "GNgr4d5kboI"),
  EncyclopediaVideo(title: "사모예드 털 편 (털빠짐, 목욕고충, 한국더위)｜강형욱의 견종백과 X 극한견주 솜이 X 백곰이", youtubeId: "XkHgmgsuv5E"),
  EncyclopediaVideo(title: "[Eng sub/日本語字幕] 골든 리트리버 2부｜강형욱의 견종백과 X 리틀라이언 레아레토", youtubeId: "VZF0ST0-5vc"),
  EncyclopediaVideo(title: "[Eng sub/日本語字幕] 골든 리트리버 1부｜강형욱의 견종백과 X 리틀라이언 레아레토", youtubeId: "NAjZcaEq_Nc"),
  EncyclopediaVideo(title: "시바 이누(시바견) 2부｜강형욱의 견종백과 X 시바견곰이탱이여우", youtubeId: "J5q34GwAoB8"),
  EncyclopediaVideo(title: "시바 이누(시바견) 1부｜강형욱의 견종백과 X 시바견곰이탱이여우", youtubeId: "l_Bt6544jFg"),
  EncyclopediaVideo(title: "시베리안 허스키 2부｜강형욱의 견종백과 X 노잼봇", youtubeId: "3293XwJTRyg"),
  EncyclopediaVideo(title: "시베리안 허스키 1부｜강형욱의 견종백과 X 노잼봇", youtubeId: "pKDIe670lrw"),
  EncyclopediaVideo(title: "보더 콜리 2부｜강형욱의 견종백과 X 페퍼TV(보더로운생활)", youtubeId: "EW6n-i5zKT4"),
  EncyclopediaVideo(title: "보더 콜리 1부｜강형욱의 견종백과 X 페퍼TV(보더로운생활)", youtubeId: "V_GAcGbmHjI"),
  EncyclopediaVideo(title: "꼬똥 드 툴레아 2부｜강형욱의 견종백과 X 대도서관", youtubeId: "QICG4EUJGk4"),
  EncyclopediaVideo(title: "꼬똥 드 툴레아 1부｜강형욱의 견종백과 X 대도서관", youtubeId: "iG_3rfPkTZc"),
  EncyclopediaVideo(title: "웰시 코기 편 2부｜강형욱의 견종백과", youtubeId: "g98-YQ8-9iE"),
  EncyclopediaVideo(title: "웰시 코기 편 1부｜강형욱의 견종백과", youtubeId: "mQdYYRFV-3s"),
  EncyclopediaVideo(title: "시츄 편 2부｜강형욱의 견종백과", youtubeId: "II9Jup05Ho4"),
  EncyclopediaVideo(title: "시츄 편 1부｜강형욱의 견종백과", youtubeId: "ibm9DPcl5PM"),
  EncyclopediaVideo(title: "포메라니안 편 2부｜강형욱의 견종백과", youtubeId: "pc4lILwieUU"),
  EncyclopediaVideo(title: "포메라니안 편 1부｜강형욱의 견종백과", youtubeId: "vStX-Z87Dpg"),
  EncyclopediaVideo(title: "셰퍼드, 마리노이즈, 래브라도 리트리버(군견 편) 2부｜강형욱의 견종백과", youtubeId: "FekfeXbfTNo"),
  EncyclopediaVideo(title: "셰퍼드, 마리노이즈, 래브라도 리트리버(군견 편) 1부｜강형욱의 견종백과", youtubeId: "jVRZ4-JhFkg"),
  EncyclopediaVideo(title: "군견 편 라이브 예고｜강형욱의 견종백과", youtubeId: "w80HcHAxcc0"),
  EncyclopediaVideo(title: "푸들 편 2부｜강형욱의 견종백과", youtubeId: "d9krnAQ5NUk"),
  EncyclopediaVideo(title: "푸들 편 1부｜강형욱의 견종백과", youtubeId: "3sysIjGyxXE"),
  EncyclopediaVideo(title: "닥스훈트 편 2부｜강형욱의 견종백과", youtubeId: "-Y7s_tm7SBo"),
  EncyclopediaVideo(title: "닥스훈트 편 1부｜강형욱의 견종백과", youtubeId: "VmnGyG9Vy3k"),
  EncyclopediaVideo(title: "말티즈 편 2부｜강형욱의 견종백과", youtubeId: "r5_vEPUa2RE"),
  EncyclopediaVideo(title: "말티즈 편 1부｜Engsub｜강형욱의 견종백과", youtubeId: "yihK9xcf-zo"),
  EncyclopediaVideo(title: "말티즈 편 1부 예고｜강형욱의 견종백과", youtubeId: "aLUFfVatHbo"),
  EncyclopediaVideo(title: "토크 코너 출연 보호자 모집｜강형욱의 견종백과", youtubeId: "qFj0UKemZs4"),
];

/// 제목 속 한국어 견종명(긴 이름 우선) → Dogs API 영어 이름.
const _titleAliases = <(String, List<String>)>[
  ("웨스트 하이랜드 화이트 테리어", ["West Highland White Terrier"]),
  ("카발리에 킹 찰스 스파니엘", ["Cavalier King Charles Spaniel", "Cavalier"]),
  ("오스트레일리안 셰퍼드", ["Australian Shepherd"]),
  ("이탈리안 그레이하운드", ["Italian Greyhound"]),
  ("아이리시 울프 하운드", ["Irish Wolfhound"]),
  ("차이니즈 크레스티드", ["Chinese Crested"]),
  ("래브라도 리트리버", ["Labrador Retriever"]),
  ("코카시안 오브차카", ["Caucasian Shepherd Dog"]),
  ("올드 잉글리쉬 쉽독", ["Old English Sheepdog"]),
  ("와이어 폭스테리어", ["Wire Fox Terrier"]),
  ("그레이트 피레니즈", ["Great Pyrenees"]),
  ("버니즈 마운틴 독", ["Bernese Mountain Dog"]),
  ("베들링턴테리어", ["Bedlington Terrier"]),
  ("베들링턴 테리어", ["Bedlington Terrier"]),
  ("시베리안 허스키", ["Siberian Husky", "Husky"]),
  ("로디지안 리지백", ["Rhodesian Ridgeback"]),
  ("셰틀랜드 쉽독", ["Shetland Sheepdog"]),
  ("잭 러셀 테리어", ["Jack Russell Terrier"]),
  ("보스턴 테리어", ["Boston Terrier"]),
  ("노리치 테리어", ["Norwich Terrier"]),
  ("잉글리쉬 불독", ["Bulldog"]),
  ("골든 리트리버", ["Golden Retriever"]),
  ("골든리트리버", ["Golden Retriever"]),
  ("미니어처 핀셔", ["Miniature Pinscher"]),
  ("도베르만 핀셔", ["Doberman Pinscher"]),
  ("그레이트 데인", ["Great Dane"]),
  ("헝가리안 풀리", ["Puli"]),
  ("아프간하운드", ["Afghan Hound"]),
  ("아프간 하운드", ["Afghan Hound"]),
  ("꼬똥 드 툴레아", ["Coton de Tulear"]),
  ("코카 스파니엘", ["Cocker Spaniel"]),
  ("코카스파니엘", ["Cocker Spaniel"]),
  ("요크셔테리어", ["Yorkshire Terrier"]),
  ("세인트 버나드", ["Saint Bernard"]),
  ("그레이하운드", ["Greyhound"]),
  ("아메리칸 불리", ["American Bully"]),
  ("핏불 테리어", ["American Pit Bull Terrier"]),
  ("프렌치불독", ["French Bulldog"]),
  ("프렌치 불독", ["French Bulldog"]),
  ("저먼셰퍼드", ["German Shepherd Dog"]),
  ("저먼 셰퍼드", ["German Shepherd Dog"]),
  ("아키타이누", ["Akita"]),
  ("말리노이즈", ["Belgian Malinois"]),
  ("마리노이즈", ["Belgian Malinois"]),
  ("포메라니안", ["Pomeranian"]),
  ("비숑프리제", ["Bichon Frise"]),
  ("비숑 프리제", ["Bichon Frise"]),
  ("바셋하운드", ["Basset Hound"]),
  ("바셋 하운드", ["Basset Hound"]),
  ("로트와일러", ["Rottweiler"]),
  ("와이마라너", ["Weimaraner"]),
  ("도베르만", ["Doberman Pinscher"]),
  ("웰시 코기", ["Pembroke Welsh Corgi"]),
  ("웰시코기", ["Pembroke Welsh Corgi"]),
  ("시바이누", ["Shiba Inu"]),
  ("시바 이누", ["Shiba Inu"]),
  ("그로넨달", ["Belgian Sheepdog"]),
  ("말라뮤트", ["Alaskan Malamute"]),
  ("사모예드", ["Samoyed"]),
  ("달마시안", ["Dalmatian"]),
  ("차우차우", ["Chow Chow"]),
  ("슈나우저", ["Schnauzer", "Miniature Schnauzer"]),
  ("보더 콜리", ["Border Collie"]),
  ("보더콜리", ["Border Collie"]),
  ("닥스훈트", ["Dachshund"]),
  ("불테리어", ["Bull Terrier"]),
  ("시바견", ["Shiba Inu"]),
  ("진돗개", ["Jindo", "Korea Jindo Dog"]),
  ("말티즈", ["Maltese"]),
  ("치와와", ["Chihuahua"]),
  ("파피용", ["Papillon"]),
  ("바센지", ["Basenji"]),
  ("살루키", ["Saluki"]),
  ("샤페이", ["Chinese Shar-Pei"]),
  ("포인터", ["Pointer", "German Shorthaired Pointer"]),
  ("셰퍼드", ["German Shepherd Dog"]),
  ("허스키", ["Siberian Husky", "Husky"]),
  ("아키타", ["Akita"]),
  ("시츄", ["Shih Tzu"]),
  ("비글", ["Beagle"]),
  ("푸들", ["Poodle"]),
  ("퍼그", ["Pug"]),
  ("복서", ["Boxer"]),
  ("불독", ["Bulldog"]),
];

String _compact(String raw) =>
    raw.toLowerCase().replaceAll(RegExp(r'\s+'), '');

bool _isPromo(String title) {
  return title.contains('예고') || title.contains('토크 코너');
}

/// 제목에서 견종백과가 가리키는 이름 토막을 뽑는다.
List<String> encyclopediaLabelsFromTitle(String title) {
  if (_isPromo(title)) return const [];
  final labels = <String>[];
  final a = RegExp(r'견종백과\s*(.+?)편').firstMatch(title);
  if (a != null) labels.add(a.group(1)!.trim());
  final b = RegExp(r'([^｜|]+?)\s*편\s*[12]부').firstMatch(title);
  if (b != null) labels.add(b.group(1)!.trim());
  final c = RegExp(r'\]\s*(.+?)\s*[12]부').firstMatch(title);
  if (c != null) labels.add(c.group(1)!.trim());
  final d = RegExp(r'^(.+?)\s*[12]부\s*｜').firstMatch(title);
  if (d != null) labels.add(d.group(1)!.trim());
  if (title.contains('군견')) {
    labels.addAll(const ['저먼셰퍼드', '말리노이즈', '래브라도 리트리버']);
  }
  return labels;
}

Set<String> _englishNamesInLabels(Iterable<String> labels) {
  final names = <String>{};
  for (final label in labels) {
    var rest = _compact(label);
    for (final alias in _titleAliases) {
      final key = _compact(alias.$1);
      if (key.isEmpty) continue;
      if (rest.contains(key)) {
        names.addAll(alias.$2);
        rest = rest.replaceFirst(key, '');
      }
    }
  }
  return names;
}

Set<String> _queryNames(String englishName) {
  final names = <String>{englishName.trim()};
  final english = englishName.trim().toLowerCase();
  for (final entry in breedNamesKo.entries) {
    if (entry.key.toLowerCase() == english) names.add(entry.key);
  }
  for (final entry in breedSearchAliases.entries) {
    if (entry.value.any((name) => name.toLowerCase() == english)) {
      names.addAll(entry.value);
    }
  }
  return names;
}

/// 이 견종 제목이 들어간 편만 돌려 준다.
List<EncyclopediaVideo> encyclopediaVideosFor(String englishName) {
  final wanted = {for (final name in _queryNames(englishName)) name.toLowerCase()};
  if (wanted.isEmpty) return const [];
  final matched = <EncyclopediaVideo>[];
  for (final episode in encyclopediaEpisodes) {
    final found = _englishNamesInLabels(encyclopediaLabelsFromTitle(episode.title));
    if (found.any((name) => wanted.contains(name.toLowerCase()))) {
      matched.add(episode);
    }
  }
  return matched;
}

bool encyclopediaCovers(String englishName) =>
    encyclopediaVideosFor(englishName).isNotEmpty;
